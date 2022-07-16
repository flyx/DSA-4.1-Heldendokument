package dsa41held;

import java.util.HashMap;
import java.util.Map;

import org.w3c.dom.Document;
import org.w3c.dom.Element;

public class Mirakel {
  public static enum Art {
    PLUS, MINUS;
    
    String id() {
      switch (this) {
      case PLUS: return "plus";
      case MINUS: return "minus";
      default: return null;
      }
    }
  }

  Map<String, Art> data = new HashMap<String, Art>();
  
  public void load() {
    data.clear();
  
    for (final var art : Art.values()) {
      for (final var name : Plugin.getHeldData("mirakel-" + art.toString()).split("\\|")) {
        if (!"".equals(name)) data.put(name, art);
      }
    }
  }
  
  public void save() {
    for (var item : Art.values()) {
      Plugin.setHeldData("mirakel-" + item.toString(), serialize(item));
    }
  }
  
  private String serialize(Art art) {
    final var builder = new StringBuilder();
    for (final var entry : data.entrySet()) {
      if (entry.getValue().equals(art)) {
        if (builder.length() > 0) builder.append("|");
        builder.append(entry.getKey());
      }
    }
    return builder.toString();
  }
  
  public Element toXML(Document doc) {
    final var root = doc.createElement("mirakel");
    for (var art : Art.values()) {
      for (final var entry : data.entrySet()) {
        if (entry.getValue().equals(art)) {
          final var el = doc.createElement(art.id());
          el.setAttribute("talent", entry.getKey());
          root.appendChild(el);
        }
      }
    }
    return root;
  }
  
  public void fromXML(Element input) {
    data.clear();
    for (int i = 0; i < input.getChildNodes().getLength(); i++) {
      Element cur = (Element) input.getChildNodes().item(i);
      for (final var art : Art.values()) {
        if (art.id().equals(cur.getNodeName())) {
          data.put(cur.getAttribute("talent"), art);
          break;
        }
      }
    }
  }
}