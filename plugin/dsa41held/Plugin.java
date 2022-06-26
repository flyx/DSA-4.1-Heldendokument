package dsa41held;

import helden.plugin.HeldenXMLDatenPlugin3;
import helden.plugin.datenxmlplugin.DatenAustausch3Interface;

import java.util.*;
import javax.swing.*;
import java.lang.reflect.Field;
import java.lang.reflect.Method;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.nio.charset.Charset;

import javax.xml.transform.*;
import javax.xml.transform.dom.*;
import javax.xml.transform.stream.StreamResult;
import javax.xml.parsers.DocumentBuilderFactory;

import org.w3c.dom.Document;
import org.w3c.dom.Element;

/**
 * Diese Klasse hat absichtlich keine absurd klobigen und nutzlosen JavaDoc-Kommentare.
 */
public class Plugin implements HeldenXMLDatenPlugin3 {
  public static DatenAustausch3Interface dai;
  private JFrame hf;
  private Tab tab;
  
  public Plugin() {
    super();
  }

  @Override
  public ArrayList<JComponent> getUntermenus() {
    return new ArrayList<JComponent>();
  }

  @Override
  public ImageIcon getIcon() {
    return null;
  }

  @Override
  public String getMenuName() {
    return "DSA 4.1 Heldendokument LaTeX";
  }

  @Override
  public void doWork(JFrame f) {
  }

  @Override
  public String getType() {
    return DATEN;
  }
  
  @Override
  public JComponent getPanel() {
    return tab;
  }

  @Override
  public String getToolTipText() {
    return "Erstelle ein PDF des Helden mit dem DSA 4.1 Heldendokument Generator";
  }

  @Override
  public void click() {
    new Dialog(hf);
  }

  @Override
  public boolean hatMenu() {
    return true;
  }

  @Override
  public boolean hatTab() {
    return true;
  }
  
  private Set<String> shown = new HashSet<String>();
  
  private void show(Field[] fields, Method[] methods, int indent) {
    for (Field f : fields) {
      for (int i = 0; i < indent; ++i) System.out.print(' ');
      String t = f.getType().getName();
      System.out.println(f.getName() + ": " + t);
      if (t.startsWith("helden")) {
        if (!shown.contains(t)) {
          shown.add(t);
          show(f.getType().getDeclaredFields(),
            t.equals("helden.framework.C.public") ? f.getType().getDeclaredMethods() : null, indent + 2);
        }
      }
    }
    if (methods != null) {
      for (Method m : methods) {
        for (int i = 0; i < indent; ++i) System.out.print(' ');
        System.out.println("method " + m.getName() + ": " + m.getGenericReturnType().getTypeName());
      }
    }
  }
  
  public static InputStream documentToStream(org.w3c.dom.Document doc) {
    ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
    Source xmlSource = new DOMSource(doc);
    Result outputTarget = new StreamResult(outputStream);
    try {
      TransformerFactory.newInstance().newTransformer().transform(xmlSource, outputTarget);
    } catch (TransformerException ex) {
      throw new RuntimeException(ex);
    }
    byte[] data = outputStream.toByteArray();
    return new ByteArrayInputStream(outputStream.toByteArray());
  }

  @Override
  public void init(DatenAustausch3Interface dai, JFrame hf) {
    this.dai = dai;
    this.hf = hf;
    this.tab = new Tab(dai);
    dai.addChangeListener(this.tab);
    /* reverse engineering: XML output
    System.out.println("frame class: " + hf.getClass().getName());
    shown.add(hf.getClass().getName());
    show(hf.getClass().getDeclaredFields(), null, 2); */
  }
  
  public static org.w3c.dom.Document getHeld() {
    org.w3c.dom.Document request;
    final DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
    try {
      request = factory.newDocumentBuilder().newDocument();
    } catch (Exception ex) {
      request = null;
    }
    Element requestElement = request.createElement("action");
    request.appendChild(requestElement);
    requestElement.setAttribute("action", "held");
    requestElement.setAttribute("id", "selected");
    requestElement.setAttribute("format", "xml");
    requestElement.setAttribute("version", "2");
    final org.w3c.dom.Document doc = (org.w3c.dom.Document) dai.exec(request);
    return doc;
  }
}