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
  final public Talentbogen talentbogen = new Talentbogen();
  final public Mirakel mirakel = new Mirakel();
  
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
    action.appendChild(root);
    
    Plugin.dai.exec(request);
  }
  
  @Override
  public void stateChanged(ChangeEvent e) {
    switch ((String) e.getSource()) {
    case "Focus":
      Plugin.tab.setHasFocus(true);
      break;
    case "Kein Focus":
      Plugin.tab.setHasFocus(false);
      break;
    case "Änderung":
    case "neuer Held":
      load();
      Plugin.tab.refresh();
      break;
    }
  }
}