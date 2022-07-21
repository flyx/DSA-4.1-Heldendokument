package dsa41held;

import org.w3c.dom.Document;
import org.w3c.dom.Element;

import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.xpath.*;

import helden.plugin.datenxmlplugin.DatenAustausch3Interface;

/** Globale Properties des Plugins */
public class Props {
  private String serverUrl;
  private int serverSelection;
  
  private String propVal(Document doc, String name) {
    try {
      XPath xPath = XPathFactory.newInstance().newXPath();
      String expression = String.format("/result/prop[@key = '%s']/@value", name);
      return xPath.compile(expression).evaluate(doc);
    } catch (Exception e) {
      e.printStackTrace();
      return null;
    }
  }
  
  public Props(DatenAustausch3Interface dai) {
    try {
      Document request = DocumentBuilderFactory.newInstance().newDocumentBuilder().newDocument();
      Element requestElement = request.createElement("action");
      request.appendChild(requestElement);
      requestElement.setAttribute("action", "listProperties");
      requestElement.setAttribute("pluginName", "dsa41held");
      var res = (Document) dai.exec(request);
      serverUrl = propVal(res, "serverUrl");
      serverSelection = "1".equals(propVal(res, "serverSelection")) ? 1 : 0;
    } catch (Exception ex) {
      ex.printStackTrace();
      serverUrl = "";
    }
  }

  public String getServerUrl() {
    return serverUrl;
  }
  
  public int getServerSelection() {
    return serverSelection;
  }
  
  public void setServerSelection(int value) {
    serverSelection = value;
    save();
  }
  
  public void setServerUrl(String value) {
    serverUrl = value;
    save();
  }
  
  private Element propEl(Document doc, String key, String value) {
    var ret = doc.createElement("prop");
    ret.setAttribute("key", key);
    ret.setAttribute("value", value);
    return ret;
  }
  
  private void save() {
    try {
      Document request = DocumentBuilderFactory.newInstance().newDocumentBuilder().newDocument();
      Element action = request.createElement("action");
      request.appendChild(action);
      action.setAttribute("action", "saveProperties");
      action.setAttribute("pluginName", "dsa41held");
      action.appendChild(propEl(request, "serverUrl", serverUrl));
      action.appendChild(propEl(request, "serverSelection", String.valueOf(serverSelection)));
      Plugin.dai.exec(request);
    } catch (Exception ex) {
      ex.printStackTrace();
    }
  }
}