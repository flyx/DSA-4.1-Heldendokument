package dsa41held;

import java.awt.*;
import java.awt.event.*;
import javax.swing.*;
import java.net.URL;
import java.net.URI;
import java.net.MalformedURLException;
import java.io.File;

public class Dialog extends JDialog {
  private JFrame hf;
  private Form form;
  private Docker docker;
  private Buttons buttons;
  private SwingWorker<Boolean, Object> worker;
  
  private class Docker extends JPanel {
    private JButton runButton;
    
    private GridBagConstraints cell(int x, int y) {
      var c = new GridBagConstraints();
      c.fill = GridBagConstraints.HORIZONTAL;
      c.gridx = x;
      c.gridy = y;
      return c;
    }
    
    private JLabel link(String url, String text) {
      var ret = new JLabel();
      ret.setText("<html><a href=\"\">"+text+"</a></html>");
      ret.setCursor(new Cursor(Cursor.HAND_CURSOR));
      ret.addMouseListener(new MouseAdapter() {
        @Override
        public void mouseClicked(MouseEvent e) {
          try {
            Desktop.getDesktop().browse(new URI(url));
          } catch (Exception ex) {
            ex.printStackTrace();
          }
        }
      });
      return ret;
    }
    
    Docker() {
      var layout = new GridBagLayout();
      layout.rowHeights = new int[]{25, 25, 25};
      layout.columnWidths = new int[]{85, 220};
      setLayout(layout);
    
      add(new JLabel("Docker"), cell(0, 0));
      if (Plugin.dockerRunner.available()) {
        add(new JLabel("Gefunden"), cell(1, 0));
      } else {
        add(link("https://docs.docker.com/get-docker/", "Docker nicht gefunden (braucht Neustart der Software)"), cell(1, 0));
      }
      add(new JLabel("Image"), cell(0, 1));
      var hasImage = Plugin.dockerRunner.imageAvailable();
      if (hasImage) {
        add(new JLabel("Image verfügbar."), cell(1, 1));
      } else {
        var button = new JButton("Baue Image");
        if (!Plugin.dockerRunner.available()) button.setEnabled(false);
        button.addActionListener(e -> {
          button.setVisible(false);
          var pb = new JProgressBar();
          pb.setIndeterminate(true);
          add(pb, cell(1, 1));
        
          worker = new SwingWorker<Boolean, Object>() {
            @Override
            public Boolean doInBackground() {
              Plugin.dockerRunner.buildImage();
              return Plugin.dockerRunner.imageAvailable();
            }
            
            @Override
            protected void done() {
              worker = null;
              try {
                remove(pb);
                if (get()) {
                  remove(button);
                  add(new JLabel("Image verfügbar."), cell(1, 1));
                } else {
                  button.setVisible(true);
                  runButton.setEnabled(true);
                }
              } catch (Exception e) {
                e.printStackTrace();
                button.setVisible(true);
                remove(button);
              } finally {
                revalidate();
              }
            }
          };
          worker.execute();
        });
        add(button, cell(1, 1));
      }
      add(new JLabel("Container"), cell(0, 2));
      runButton = new JButton(Plugin.dockerRunner.isRunning() ? "Stop" : "Start");
      runButton.addActionListener(e -> {
        if (Plugin.dockerRunner.isRunning()) {
          Plugin.dockerRunner.stop();
        } else {
          Plugin.dockerRunner.start();
        }
        if (Plugin.dockerRunner.isRunning()) {
          runButton.setText("Stop");
          buttons.generate.setEnabled(true);
        } else {
          runButton.setText("Start");
          buttons.generate.setEnabled(false);
        }
      });
      if (!hasImage) runButton.setEnabled(false);
      add(runButton, cell(1, 2));
    }
  }
  
  private class Form extends JPanel {
    JTextField url;
    JLabel urlError;
  
    {
      url = new JTextField(35);
      url.setText(Plugin.props.getServerUrl());
      urlError = new JLabel("ungültige URL");
      urlError.setForeground(Color.RED);
    
      FormBuilder builder = new FormBuilder(this);
      builder.add("URL:", url, urlError);
    }
  };

  private class Buttons extends JPanel {
    JButton generate;
  
    {
      setLayout(new FlowLayout(FlowLayout.RIGHT));
    
      JButton cancel = new JButton("Abbrechen");
      cancel.addActionListener(e -> {
        if (worker != null) worker.cancel(true);
        Dialog.this.dispose();
      });
      add(cancel);
      
      generate = new JButton("Generieren");
      generate.addActionListener(e -> {
        URL url = null;
        boolean seenError = false;
        try {
          if (Plugin.props.getServerSelection() == 0) {
            url = new URL(Dialog.this.form.url.getText());
            Dialog.this.form.urlError.setVisible(false);
          } else {
            url = new URL("http://localhost:8073/");
          }
        } catch (MalformedURLException ex) {
          Dialog.this.form.urlError.setVisible(true);
          seenError = true;
        }
        if (seenError) {
          Dialog.this.pack();
        } else {
          Dialog.this.setVisible(false);
          var chooser = new JFileChooser();
          chooser.setDialogTitle("Speichern unter");
          chooser.setSelectedFile(new File(Plugin.getHeldName().replaceAll("\\W+", "") + ".pdf"));
          
          if (chooser.showSaveDialog(new JFrame()) == JFileChooser.APPROVE_OPTION) {
            Plugin.props.setServerUrl(Dialog.this.form.url.getText());
          
            new GeneratePDF(Dialog.this.hf, url, chooser.getSelectedFile());
            Dialog.this.dispose();
          }
        }
      });
      add(generate);
      Dialog.this.getRootPane().setDefaultButton(generate);
    }
  }
  
  private static String[] CARD_LABELS = new String[]{"Existierender Server", "Lokal via Docker"};

  public Dialog(JFrame hf) {
    super(hf, "Generiere DSA 4.1 Heldendokument", Dialog.ModalityType.DOCUMENT_MODAL);
    this.hf = hf;
    ((JPanel) getContentPane()).setBorder(BorderFactory.createEmptyBorder(15, 15, 15, 15));
    
    setDefaultCloseOperation(DISPOSE_ON_CLOSE);
    
    var cl = new CardLayout();
    var cards = new JPanel(cl);
    
    buttons = new Buttons();
    
    var select = new JComboBox(CARD_LABELS);
    select.setSelectedIndex(Plugin.props.getServerSelection());
    if (select.getSelectedIndex() == 1) {
      buttons.generate.setEnabled(Plugin.dockerRunner.isRunning());
    } else {
      buttons.generate.setEnabled(true);
    }
    select.addItemListener(e -> {
      Plugin.props.setServerSelection(select.getSelectedIndex());
      cl.show(cards, (String)e.getItem());
      if (select.getSelectedIndex() == 1) {
        buttons.generate.setEnabled(Plugin.dockerRunner.isRunning());
      } else {
        buttons.generate.setEnabled(true);
      }
    });
    select.setEditable(false);
    
    form = new Form();
    docker = new Docker();
    cards.add(form, CARD_LABELS[0]);
    cards.add(docker, CARD_LABELS[1]);
    cl.show(cards, CARD_LABELS[Plugin.props.getServerSelection()]);
    
    Container content = getContentPane();
    content.add(select, BorderLayout.PAGE_START);
    content.add(cards, BorderLayout.CENTER);
    content.add(buttons, BorderLayout.PAGE_END);
    
    setPreferredSize(new Dimension(500, 200));
    pack();
    setLocationRelativeTo(hf);
    setVisible(true);
  }
}