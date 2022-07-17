package dsa41held;

import java.util.HashMap;
import java.util.Map;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;

import javax.swing.table.AbstractTableModel;

import javax.xml.xpath.*;

public class Mirakel extends AbstractTableModel {
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
  String[] talente;
  
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
  
  public void updateTalente() {
    var held = Plugin.getHeld();
    if (held == null) {
      talente = new String[0];
      return;
    }
    try {
      XPath xPath = XPathFactory.newInstance().newXPath();
      String expression = "/daten/talentliste/talent/name";
      var tNodes = (NodeList) xPath.compile(expression).evaluate(held, XPathConstants.NODESET);
      talente = new String[tNodes.getLength()];
      for (int i = 0; i < tNodes.getLength(); i++) {
        talente[i] = tNodes.item(i).getTextContent();
      }
    } catch (XPathExpressionException ex) {
      ex.printStackTrace();
    }
  }
  
  // AbstractTableModel implementation
  
  @Override
  public String getColumnName(int col) {
    switch (col) {
    case 0: return "Mirakel+";
    case 1: return "Mirakel-";
    case 2: return "Talent";
    default: return null;
    }
  }
  
  @Override
  public int getRowCount() { return talente.length; }
  
  @Override
  public int getColumnCount() { return 3; }
  
  @Override
  public Class getColumnClass(int c) {
    switch(c) {
    case 0:
    case 1: return Boolean.class;
    case 2: return String.class;
    default: return null;
    }
  }
  
  @Override
  public Object getValueAt(int row, int col) {
    switch (col) {
    case 0: return Art.PLUS.equals(data.get(talente[row]));
    case 1: return Art.MINUS.equals(data.get(talente[row]));
    case 2: return talente[row];
    default: return null;
    }
  }
  
  @Override
  public boolean isCellEditable(int row, int col) {
    return false;
  }
  
  @Override
  public void setValueAt(Object value, int row, int col) {
  }
  
  public void toggleAt(int row, Art art) {
    if (art.equals(data.get(talente[row]))) {
      data.remove(talente[row]);
    } else {
      data.put(talente[row], art);
    }
    fireTableRowsUpdated(row, row);
  }
}