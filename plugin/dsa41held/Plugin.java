package dsa41held;

import helden.plugin.HeldenXMLDatenPlugin3;
import helden.plugin.datenxmlplugin.DatenAustausch3Interface;

import java.util.*;
import javax.swing.*;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.nio.charset.Charset;

import javax.xml.transform.*;
import javax.xml.transform.dom.*;
import javax.xml.transform.stream.StreamResult;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.xpath.*;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;

/** Basis-Klasse des Plugins. Praktisch ein Singleton. */
public class Plugin implements HeldenXMLDatenPlugin3 {
  public static DatenAustausch3Interface dai;
  public static Tab tab;
  public static Data data;
  public static Props props;
  public static DockerRunner dockerRunner;
  private JFrame hf;
  
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
    this.data = new Data();
    this.data.load();
    this.data.mirakel.updateTalente();
    dai.addChangeListener(this.data);
    this.tab = new Tab(dai, data);
    this.props = new Props(dai);
    this.dockerRunner = new DockerRunner();
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
  
  public static String getHeldName() {
    var held = getHeld();
    try {
      XPath xPath = XPathFactory.newInstance().newXPath();
      String expression = "/daten/angaben/name/text()";
      return xPath.compile(expression).evaluate(held);
    } catch (Exception e) {
      e.printStackTrace();
      return null;
    }
  }
  
  public static org.w3c.dom.Document exportHeld() {
    org.w3c.dom.Document request;
    final DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
    try {
      request = factory.newDocumentBuilder().newDocument();
    } catch (Exception ex) {
      request = null;
    }
    Element requestElement = request.createElement("action");
    request.appendChild(requestElement);
    requestElement.setAttribute("action", "exportHeld");
    requestElement.setAttribute("id", "selected");
    final org.w3c.dom.Document doc = (org.w3c.dom.Document) dai.exec(request);
    return doc;
  }
  
  public static String getHeldData(String name) {
    Document request;
    final DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
    try {
      request = factory.newDocumentBuilder().newDocument();
    } catch (Exception ex) {
      throw new RuntimeException(ex);
    }
    Element requestElement = request.createElement("action");
    request.appendChild(requestElement);
    requestElement.setAttribute("action", "getHeldProperties");
    requestElement.setAttribute("heldenkey", "selected");
    requestElement.setAttribute("key", "dsa41held-" + name);
    Document doc = (Document) dai.exec(request);
    String value = (doc == null) ? "" : doc.getChildNodes().item(0).getTextContent();
    System.out.println("getHeldData(\"" + name + "\") -> \"" + value + "\"");
    return value;
  }
  
  public static void setHeldData(String name, String content) {
    Document request;
    final DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
    try {
      request = factory.newDocumentBuilder().newDocument();
    } catch (Exception ex) {
      throw new RuntimeException(ex);
    }
    
    final Element actionElement = request.createElement("action");
    request.appendChild(actionElement);
    actionElement.setAttribute("action", "setHeldProperties");
    actionElement.setAttribute("heldenkey", "selected");
    actionElement.setAttribute("key", "dsa41held-" + name);
    actionElement.setTextContent(content);  
    final Document ret = (org.w3c.dom.Document) dai.exec(request);
    System.out.println("setHeldData(\"" + name + "\", \"" + content + "\")");
  }
}