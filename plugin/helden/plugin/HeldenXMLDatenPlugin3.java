package helden.plugin;

import helden.plugin.datenxmlplugin.DatenAustausch3Interface;

import java.util.ArrayList;

import javax.swing.JComponent;
import javax.swing.JFrame;

public interface HeldenXMLDatenPlugin3 extends HeldenPlugin  {
    String DATEN = "DatenXMLPlugin3";
    ArrayList<JComponent> getUntermenus();
    void init(DatenAustausch3Interface dai, JFrame hf);
    void click();
    boolean hatMenu();
    boolean hatTab();
    JComponent getPanel();
}
