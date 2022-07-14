package dsa41held;

import helden.plugin.datenxmlplugin.DatenAustausch3Interface;

import java.util.*;
import java.util.stream.IntStream;
import javax.swing.*;
import javax.swing.border.*;
import javax.swing.event.*;
import java.awt.*;
import javax.xml.xpath.*;

import org.w3c.dom.Document;
import org.w3c.dom.NodeList;

public class Tab extends JPanel implements ChangeListener {
  private class MirakelLine extends Box {
    private JButton button;
    MirakelLine(String talent) {
      super(BoxLayout.LINE_AXIS);
      this.setAlignmentX(Component.LEFT_ALIGNMENT);
      var val = mirakel.data.get(talent);
      if (val == null) {
        button = new JButton(" ");
      } else switch (val) {
        case PLUS:
          button = new JButton("+");
          break;
        case MINUS:
          button = new JButton("-");
          break;
      }
      
      var size = new Dimension(24, 24);
      button.setFocusable(false);
      button.setMargin(new Insets(1, 1, 1, 1));
      button.setMinimumSize(size);
      button.setPreferredSize(size);
      button.setMaximumSize(size);
      button.addActionListener(e -> {
        var cur = mirakel.data.get(talent);
        if (cur == null) {
          mirakel.data.put(talent, Mirakel.Art.PLUS);
          button.setText("+");
        } else switch (cur) {
          case PLUS:
            mirakel.data.put(talent, Mirakel.Art.MINUS);
            button.setText("-");
            break;
          case MINUS:
            mirakel.data.remove(talent);
            button.setText(" ");
            break;
        }
        mirakel.save();
      });
      this.add(button);
      
      var label = new JLabel(talent);
      this.add(label);
    }
  }

  private Box box;
  private Mirakel mirakel;
  private Talentbogen tb;
  private boolean hasFocus;
  
  public Tab(DatenAustausch3Interface dai) {
    this.setLayout(new BoxLayout(this, BoxLayout.LINE_AXIS));
    
    this.mirakel = new Mirakel();
    this.box = Box.createVerticalBox();
    this.hasFocus = false;
    
    final JScrollPane sp = new JScrollPane(this.box,
      JScrollPane.VERTICAL_SCROLLBAR_ALWAYS,
      JScrollPane.HORIZONTAL_SCROLLBAR_NEVER);
    sp.setBorder(BorderFactory.createTitledBorder("Mirakel"));
    this.add(sp);
    this.updateMirakel(dai);
    
    this.tb = new Talentbogen();
    tb.load();
    final JTable table = new JTable(tb);
    final JScrollPane tsp = new JScrollPane(table);
    table.setFillsViewportHeight(true);
    table.setDragEnabled(true);
    table.setDropMode(DropMode.INSERT_ROWS);
    table.setSelectionMode(ListSelectionModel.SINGLE_SELECTION);
    table.setTransferHandler(new Talentbogen.DragHandler(table));
    
    final var tbb = Box.createVerticalBox();
    tbb.setBorder(BorderFactory.createTitledBorder("Talentgruppen"));
    final var label = new JLabel("<html>Du kannst hier die Tabellen auf dem Talentbogen modifizieren. Die Anzahl Zeilen pro Tabelle ist editierbar; bedenke jedoch, dass immer mindestens so viele Zeilen ausgegeben werden wie Talente bekannt sind. Du kannst die Reihenfolge mittels drag & drop editieren; die gegebene Reihenfolge wird automatisch zuerst in die linke und dann in die rechte Spalte des Talentbogens verteilt.</html>");
    label.setPreferredSize(new Dimension(70, 90));
    tbb.add(label);
    tbb.add(tsp);
    this.add(tbb);
  }
  
  private void updateMirakel(DatenAustausch3Interface dai) {
    this.box.removeAll();
    Document held = Plugin.getHeld();
    if (held == null) return;
    
    try {
      XPath xPath = XPathFactory.newInstance().newXPath();
      String expression = "/daten/talentliste/talent/name";
      var talente = (NodeList) xPath.compile(expression).evaluate(held, XPathConstants.NODESET);
      IntStream.range(0, talente.getLength()).mapToObj(talente::item).forEach(talent -> {
        this.box.add(new MirakelLine(talent.getTextContent()));
      });
      this.box.add(Box.createVerticalGlue());
    } catch (XPathExpressionException ex) {
      throw new RuntimeException(ex);
    }
  }
  
  private void refresh() {
    mirakel.load();
    updateMirakel(Plugin.dai);
    tb.load();
  }
  
  @Override
  public void stateChanged(ChangeEvent e) {
    if (e.getSource().equals("Focus")) {
      hasFocus = true;
      refresh();
    } else if (e.getSource().equals("Kein Focus")) {
      hasFocus = false;
    } else if (e.getSource().equals("Änderung")) {
      if (hasFocus) refresh();
    } else if (e.getSource().equals("neuer Held")) {
      if (hasFocus) refresh();
    }
  }
}