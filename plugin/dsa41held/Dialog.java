package dsa41held;

import java.awt.*;
import javax.swing.*;
import java.net.URL;
import java.net.MalformedURLException;

public class Dialog extends JDialog {
  private JFrame hf;
  private Form form;
  
  private class Form extends JPanel {
    JTextField url;
    JLabel urlError;
  
    {
      url = new JTextField(35);
      urlError = new JLabel("ungültige URL");
      urlError.setForeground(Color.RED);
    
      FormBuilder builder = new FormBuilder(this);
      builder.add("URL:", url, urlError);
    }
  };

  private class Buttons extends JPanel {
    {
      setLayout(new FlowLayout(FlowLayout.RIGHT));
    
      JButton cancel = new JButton("Abbrechen");
      cancel.addActionListener(e -> Dialog.this.dispose());
      add(cancel);
      
      JButton generate = new JButton("Generieren");
      generate.addActionListener(e -> {
        URL url = null;
        boolean seenError = false;
        try {
          url = new URL(Dialog.this.form.url.getText());
          Dialog.this.form.urlError.setVisible(false);
        } catch (MalformedURLException ex) {
          Dialog.this.form.urlError.setVisible(true);
          seenError = true;
        }
        if (seenError) {
          Dialog.this.pack();
        } else {
          Dialog.this.setVisible(false);
          new GeneratePDF(Dialog.this.hf, url);
          Dialog.this.dispose();
        }
      });
      add(generate);
      Dialog.this.getRootPane().setDefaultButton(generate);
    }
  }

  public Dialog(JFrame hf) {
    super(hf, "Generiere DSA 4.1 Heldendokument", Dialog.ModalityType.DOCUMENT_MODAL);
    this.hf = hf;
    ((JPanel) getContentPane()).setBorder(BorderFactory.createEmptyBorder(15, 15, 15, 15));
    
    setDefaultCloseOperation(DISPOSE_ON_CLOSE);
    form = new Form();
    
    Container content = getContentPane();
    content.add(form, BorderLayout.CENTER);
    content.add(new Buttons(), BorderLayout.PAGE_END);
    
    pack();
    setLocationRelativeTo(hf);
    setVisible(true);
  }
}