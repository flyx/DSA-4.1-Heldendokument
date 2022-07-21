package dsa41held;

import java.io.*;
import java.nio.file.*;
import java.lang.Runtime;

public class DockerRunner {
  private String dockerPath;
  private boolean foundImage;
  private Process container;
  
  private boolean imageExists(String name) {
    try {
      var process = Runtime.getRuntime().exec(new String[]{
        dockerPath, "inspect", "--type=image", name
      });
      process.waitFor();
      return process.exitValue() == 0;
    } catch (Exception e) {
      e.printStackTrace();
      return false;
    }
  }
  
  public DockerRunner() {
    try {
      var command = System.getProperty("os.name").startsWith("Windows") ? "where docker.exe" : "which docker";
    
      var process = Runtime.getRuntime().exec(command);
      try (var in = new BufferedReader(new InputStreamReader(process.getInputStream()))) {
        dockerPath = in.readLine();
      }
      process.waitFor();
      if (process.exitValue() != 0) {
        dockerPath = null;
      } else {
        foundImage = imageExists("dsa41held_webui-docker:latest");
      }
    } catch (Exception e) {
      e.printStackTrace();
      dockerPath = null;
    }
  }
  
  public boolean available() {
    return dockerPath != null;
  }
  
  public boolean imageAvailable() {
    if (!available()) return false;
    return foundImage;
  }
  
  public void buildImage() {
    try {
      if (!foundImage) {
        var dir = Files.createTempDirectory("dsa41held");
        System.out.println("generiere in temporärem Verzeichnis: " + dir.toFile().getAbsolutePath());
        if (!imageExists("dsa41held-build:latest")) {
          System.out.println("generiere build image");
          var dockerfile = dir.resolve("build.dockerfile");
          try {
              Files.copy(getClass().getResourceAsStream("/build.dockerfile"), dockerfile, StandardCopyOption.REPLACE_EXISTING);
          } catch (IOException ex) {
              ex.printStackTrace();
              return;
          }
          var process = Runtime.getRuntime().exec(new String[]{
            dockerPath, "build", "-f", "build.dockerfile", "-t", "dsa41held-build", "."
          }, null, dir.toFile());
          process.waitFor();
        }
        
        System.out.println("generiere image");
        var pb = new ProcessBuilder(dockerPath, "run", "--rm", "dsa41held-build:latest");
        pb.redirectOutput(dir.resolve("dsa41held-webui.tar").toFile());
        pb.redirectError(ProcessBuilder.Redirect.INHERIT);
        pb.directory(dir.toFile());
        var process = pb.start();
        process.waitFor();
        
        if (process.exitValue() == 0) {
          System.out.println("lade image");
          process = Runtime.getRuntime().exec(new String[]{
            dockerPath, "load", "-i", "dsa41held-webui.tar"
          }, null, dir.toFile());
          process.waitFor();
          if (process.exitValue() == 0) {
            foundImage = true;
          } else {
            System.err.println("Beim Laden des Images:");
            process.getErrorStream().transferTo(System.err);
          }
        } else {
          System.err.println("Fehler beim Generieren des Images.");
        }
      }
    } catch (Exception e) {
      e.printStackTrace();
    }
  }
  
  public void start() {
    if (!imageAvailable()) return;
    if (container == null) {
      try {
        container = Runtime.getRuntime().exec(new String[]{
          dockerPath, "run", "-p", "8073:80", "--rm", "dsa41held_webui-docker:latest"
        });
      } catch (Exception e) {
        e.printStackTrace();
      }
    }
  }
  
  public void stop() {
    if (container != null) {
      container.destroy();
      container = null;
    }
  }
  
  public boolean isRunning() {
    return container != null;
  }
}