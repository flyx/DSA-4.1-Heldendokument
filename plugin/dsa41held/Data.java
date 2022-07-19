package dsa41held;

import javax.swing.event.ChangeEvent;
import javax.swing.event.ChangeListener;

import javax.xml.parsers.DocumentBuilderFactory;

import org.w3c.dom.Document;
import org.w3c.dom.Element;

/** Persistierbare Daten eines Helden.
 *  Singleton, wird neu befüllt wenn anderer Held ausgewählt wird.
 */
public class Data implements ChangeListener {
  public static class Silhouette {
    public final static String[] werte = new String[]{"auto", "generic-m", "generic-w"};
    public final static String[] varianten = new String[]{"Standard", "Regenbogen"};
    
    int silhouette = 0;
    int variante = 0;
    
    public void fromXML(Element data) {
      silhouette = 0;
      for (int i = 0; i < werte.length; i++) {
        if (werte[i].equals(data.getAttribute("name"))) {
          silhouette = i;
          break;
        }
      }
      
      variante = 0;
      for (int i = 0; i < varianten.length; i++) {
        if (varianten[i].equals(data.getAttribute("variante"))) {
          variante = i;
          break;
        }
      }
    }
    
    public Element toXML(Document doc) {
      var ret = doc.createElement("silhouette");
      ret.setAttribute("name", werte[silhouette]);
      ret.setAttribute("variante", varianten[variante]);
      return ret;
    }
  }

  final public Talentbogen talentbogen = new Talentbogen();
  final public Mirakel mirakel = new Mirakel();
  final public Silhouette silhouette = new Silhouette();
  
  private boolean hasFocus = false;
  
  private Element getOrEmpty(Document doc, String tagName) {
    var list = doc.getElementsByTagName(tagName);
    return list.getLength() == 0 ? doc.createElement(tagName) : (Element) list.item(0);
  }
  
  public void load() {
    Document request;
    try {
      request = DocumentBuilderFactory.newInstance().newDocumentBuilder().newDocument();
    } catch (Exception e) {
      throw new RuntimeException(e);
    }
    final Element action = request.createElement("action");
    request.appendChild(action);
    action.setAttribute("action", "getHeldPluginData");
    action.setAttribute("heldenkey", "selected");
    action.setAttribute("key", "dsa41held");
    
    Document result = (Document) Plugin.dai.exec(request);
    mirakel.fromXML(getOrEmpty(result, "mirakel"));
    talentbogen.fromXML(getOrEmpty(result, "talentbogen"));
    silhouette.fromXML(getOrEmpty(result, "silhouette"));
  }
  
  public void save() {
    Document request;
    try {
      request = DocumentBuilderFactory.newInstance().newDocumentBuilder().newDocument();
    } catch (Exception e) {
      throw new RuntimeException(e);
    }
    final Element action = request.createElement("action");
    request.appendChild(action);
    action.setAttribute("action", "setHeldPluginData");
    action.setAttribute("heldenkey", "selected");
    
    final Element root = request.createElement("dsa41held");
    root.appendChild(talentbogen.toXML(request));
    root.appendChild(mirakel.toXML(request));
    root.appendChild(silhouette.toXML(request));
    action.appendChild(root);
    
    Plugin.dai.exec(request);
  }
  
  @Override
  public void stateChanged(ChangeEvent e) {
    switch ((String) e.getSource()) {
    case "Focus":
      // Talente können sich ändern, wenn Tab nicht den Fokus hat.
      mirakel.updateTalente();
      load();
      Plugin.tab.refresh();
      hasFocus = true;
      break;
    case "Kein Focus":
      hasFocus = false;
      break;
    case "neuer Held":
      if (hasFocus) mirakel.updateTalente();
      // fallthrough
    case "Änderung":
      if (hasFocus) {
        load();
        Plugin.tab.refresh();
      }
      break;
    }
  }
}