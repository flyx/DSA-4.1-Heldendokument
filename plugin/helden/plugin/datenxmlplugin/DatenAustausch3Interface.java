package helden.plugin.datenxmlplugin;

import javax.swing.event.ChangeListener;

import org.w3c.dom.Document;

public interface DatenAustausch3Interface {
    Object exec(Document d);
    void addChangeListener(ChangeListener c);
}
