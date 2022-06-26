package dsa41held;

import java.awt.BorderLayout;
import java.util.List;
import javax.swing.*;
import java.net.*;
import java.io.IOException;
import javax.xml.parsers.DocumentBuilderFactory;

import java.nio.charset.Charset;

import org.w3c.dom.Element;

public class GeneratePDF extends JDialog {
  private JProgressBar progressBar;

  private class Worker extends SwingWorker<Object, Integer> {
    private URL baseUrl;
    
    Worker(URL baseUrl) {
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
  
    @Override
    public Object doInBackground() {
      try {
        URLConnection connection = connect("import");
        MultipartUtility util = new MultipartUtility((HttpURLConnection) connection);
        util.addFilePart("data", "held.xml", Plugin.documentToStream(Plugin.getHeld()), "text/xml");
        byte[] lua = util.finish();
        System.out.println("Lua data:\n-----");
        System.out.println(new String(lua, Charset.forName("UTF-8")));
        System.out.println("-----");
        
        publish(10);
        Thread.sleep(100);
        publish(20);
        Thread.sleep(100);
        publish(30);
        Thread.sleep(100);
        publish(40);
        Thread.sleep(100);
        publish(60);
        Thread.sleep(100);
        publish(80);
        Thread.sleep(100);
        publish(100);
      } catch (InterruptedException ex) {
        Thread.currentThread().interrupt();
      } catch (IOException ex) {
        throw new RuntimeException(ex);
      }
      return null;
    }
  
    @Override
    protected void process(List<Integer> chunks) {
      System.out.println("processing!");
      GeneratePDF.this.progressBar.setValue(chunks.get(chunks.size() - 1));
    }
  }

  public GeneratePDF(JFrame hf, URL baseUrl) {
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
    cancel.addActionListener(e -> dispose());
    
    setUndecorated(true);
    pack();
    setLocationRelativeTo(hf);
    (new Worker(baseUrl)).execute();
    setVisible(true);
  }
}