package dsa41held;

import helden.plugin.datenxmlplugin.DatenAustausch3Interface;

import javax.xml.parsers.DocumentBuilderFactory;

import java.util.stream.*;
import java.util.HashMap;
import java.util.Map;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;

import java.io.IOException;

public class Props {
  public static enum Mirakel {
    PLUS, MINUS;
    
    public static Mirakel from(String input) {
      return input.equals("plus") ? PLUS : MINUS;
    }
  }
  
  Map<String, Mirakel> mirakel;
  
  public Props(DatenAustausch3Interface dai) {
    load(dai);
  }
  
  public void load(DatenAustausch3Interface dai) {
    this.mirakel = new HashMap<String, Mirakel>();
  
    final Element data = pull(dai);
    if (data == null) return;
    Element mirakel = elements(data.getChildNodes()).filter( e -> e.getTagName().equals("mirakel")).findFirst().orElse(null);
    if (mirakel != null) {
      elements(mirakel.getChildNodes()).forEach(item -> {
        this.mirakel.put(item.getAttribute("talent"), Mirakel.from(item.getTagName()));
      });
    }
  }
  
  public void save(DatenAustausch3Interface dai) {
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
    actionElement.setAttribute("key", "dsa41held");
    actionElement.appendChild(serializeMirakel(request));
    
    System.out.println("setHeldProperties() >>> request");
    var stream = Plugin.documentToStream(request);
    var buffer = new byte[256];
    try {
      var len = stream.read(buffer);
      while (len > 0) {
        System.out.write(buffer, 0, len);
        len = stream.read(buffer);
      }
    } catch (IOException ex) {
      throw new RuntimeException(ex);
    }
    System.out.println();
    
    final Document ret = (org.w3c.dom.Document) dai.exec(request);
    
    System.out.println("setHeldProperties() <<< response");
    stream = Plugin.documentToStream(ret);
    try {
      var len = stream.read(buffer);
      while (len > 0) {
        System.out.write(buffer, 0, len);
        len = stream.read(buffer);
      }
    } catch (IOException ex) {
      throw new RuntimeException(ex);
    }
    System.out.println();
  }
  
  private Element serializeMirakel(Document request) {
    final Element ret = request.createElement("mirakel");
    for (var entry : mirakel.entrySet()) {
      final Element me = request.createElement(entry.getValue().equals(Mirakel.PLUS) ? "plus" : "minus");
      me.setAttribute("talent", entry.getKey());
      ret.appendChild(me);
    }
    return ret;
  }
  
  private static Stream<Element> elements(NodeList nodeList) {
    var nodeStream = IntStream.range(0, nodeList.getLength()).mapToObj(nodeList::item);
    return nodeStream.filter(Element.class::isInstance).map(Element.class::cast);
  }

  private static Element pull(DatenAustausch3Interface dai) {
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
    requestElement.setAttribute("key", "dsa41held");
    Document doc = (Document) dai.exec(request);
    if (doc == null) return null;
    return (Element) doc.getChildNodes().item(0);
  }
}