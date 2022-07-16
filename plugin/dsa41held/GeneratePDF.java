package dsa41held;

import java.awt.BorderLayout;
import java.util.concurrent.CompletionStage;
import java.util.concurrent.CountDownLatch;
import java.util.List;
import javax.swing.*;
import java.net.*;
import java.net.http.HttpClient;
import java.net.http.WebSocket;
import java.nio.ByteBuffer;
import java.nio.charset.StandardCharsets;
import java.io.IOException;
import java.io.File;
import java.io.FileOutputStream;
import javax.xml.parsers.DocumentBuilderFactory;
import java.time.Duration;

import java.nio.charset.Charset;

import org.w3c.dom.Element;

public class GeneratePDF extends JDialog {
  private JProgressBar progressBar;

  private class Worker extends SwingWorker<Object, Integer> implements WebSocket.Listener {
    private URL baseUrl;
    private CountDownLatch latch = new CountDownLatch(1);
    private File target;
    private FileOutputStream oStream;
    private String msg;
    private Exception unexpectedEx;
    
    Worker(URL baseUrl, File target) {
      this.target = target;
      if (baseUrl.getPath().endsWith("/")) {
        this.baseUrl = baseUrl;
      } else {
        try {
          this.baseUrl = new URL(baseUrl.getProtocol(), baseUrl.getHost(), baseUrl.getPort(), baseUrl.getPath() + "/", null);
        } catch (MalformedURLException ex) {
          throw new RuntimeException(ex);
        }
      }
    }
  
    private HttpURLConnection connect(String subpath) {
      try {
        URL url = new URL(baseUrl.getProtocol(), baseUrl.getHost(), baseUrl.getPort(), baseUrl.getPath() + subpath, null);
        return (HttpURLConnection) url.openConnection();
      } catch (MalformedURLException ex) {
        throw new RuntimeException(ex);
      } catch (IOException ex) {
        throw new RuntimeException(ex);
      }
    }
    
    private URI websocketURI(String subpath) {
      try {
        return new URI(
          baseUrl.toString().replaceFirst("^http", "ws") + subpath
        );
      } catch (URISyntaxException e) {
        throw new RuntimeException(e);
      }
    }
  
    @Override
    public Object doInBackground() {
      var uri = websocketURI("process");
      try {
        URLConnection connection = connect("import");
        MultipartUtility util = new MultipartUtility((HttpURLConnection) connection);
        util.addFilePart("data", "held.xml", Plugin.documentToStream(Plugin.exportHeld()), "text/xml");
        var luaData = util.finish();
        
        WebSocket ws = HttpClient.newHttpClient().newWebSocketBuilder()
          .header("Origin", baseUrl.toString())
          .buildAsync(uri, this).join();
        System.out.println("[ws] opened to " + uri.toString());
        ws.sendBinary(ByteBuffer.wrap(luaData), true).join();
        System.out.println("[ws] sent lua data");
        latch.await();
      } catch (ConnectException e) {
        msg = String.format("Konnte keine Verbindung zu %s aufbauen", uri.toString());
      } catch (Exception ex) {
        unexpectedEx = ex;
      }
      publish(101);
      return null;
    }
  
    @Override
    protected void process(List<Integer> chunks) {
      var progress = chunks.get(chunks.size() - 1);
      System.out.println("progress: " + String.valueOf(progress));
      if (progress == 101) {
        if (unexpectedEx != null) {
          dispose();
          throw new RuntimeException(unexpectedEx);
        }
        if (msg != null) {
          JOptionPane.showMessageDialog((JFrame) SwingUtilities.getWindowAncestor(GeneratePDF.this), msg);
        }
        dispose();
      } else {
        GeneratePDF.this.progressBar.setValue(progress);
      }
    }
    
    // implementation of Websocket.Listener
    
    @Override
    public void onError(WebSocket ws, Throwable error) {
      System.out.println("[ws] error:");
      error.printStackTrace();
      WebSocket.Listener.super.onError(ws, error);
    }
    
    @Override
    public CompletionStage<?> onBinary(WebSocket ws, ByteBuffer data, boolean last) {
      var status = data.get(data.limit() - 1);
      if (last) data.limit(data.limit() - 1);
      
      if (!last || status == 2) {
        try {
          if (oStream == null) oStream = new FileOutputStream(target);
          oStream.getChannel().write(data);
        } catch (IOException e) {
          msg = String.format("Fehler beim Schreiben der Datei: %s", e.getMessage());
          ws.sendClose(WebSocket.NORMAL_CLOSURE, "");
          latch.countDown();
          return WebSocket.Listener.super.onBinary(ws, data, last);
        }
      }
    
      if (last) {
        switch (status) {
          case 0:
            publish(Byte.toUnsignedInt(data.get(0)));
            return WebSocket.Listener.super.onBinary(ws, data, last);
          case 1:
            msg = StandardCharsets.UTF_8.decode(data).toString();
            break;
          case 2:
            try {
              oStream.close();
            } catch (Exception e) {
              e.printStackTrace();
            }
            break;
          case 3:
            msg = "Server überlastet! Versuche es später nochmal.";
            break;
        }
        ws.sendClose(WebSocket.NORMAL_CLOSURE, "");
        latch.countDown();
      }
      return WebSocket.Listener.super.onBinary(ws, data, last);
    }
  }

  public GeneratePDF(JFrame hf, URL baseUrl, File targetFile) {
    super(hf, "Generiere PDF…", Dialog.ModalityType.DOCUMENT_MODAL);
    ((JPanel) getContentPane()).setBorder(BorderFactory.createEmptyBorder(20, 20, 20, 20));
    
    JLabel label = new JLabel("Generiere PDF…", SwingConstants.CENTER);
    add(label, BorderLayout.PAGE_START);
    
    progressBar = new JProgressBar(0, 100);
    progressBar.setValue(0);
    progressBar.setStringPainted(false);
    progressBar.setBorder(BorderFactory.createEmptyBorder(15, 15, 15, 15));
    add(progressBar, BorderLayout.CENTER);
    
    JButton cancel = new JButton("Abbrechen");
    add(cancel, BorderLayout.PAGE_END);
    var worker = new Worker(baseUrl, targetFile);
    cancel.addActionListener(e -> {
      worker.cancel(true);
      dispose();
    });
    
    setUndecorated(true);
    pack();
    setLocationRelativeTo(hf);
    worker.execute();
    setVisible(true);
  }
}