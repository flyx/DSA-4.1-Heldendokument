package helden.plugin;

import javax.swing.ImageIcon;
import javax.swing.JFrame;

public interface HeldenPlugin {
    String SIMPLE = "simple execute";
    String getMenuName();
    String getToolTipText();
    ImageIcon getIcon();
    void doWork(JFrame frame);
    String getType();
}
