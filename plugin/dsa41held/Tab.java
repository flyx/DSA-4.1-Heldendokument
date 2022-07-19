package dsa41held;

import helden.plugin.datenxmlplugin.DatenAustausch3Interface;

import java.util.*;
import java.util.stream.IntStream;
import javax.swing.*;
import javax.swing.border.*;
import javax.swing.event.*;
import javax.swing.table.*;
import java.awt.*;
import java.awt.event.*;

public class Tab extends JPanel {
  private class MirakelLine extends Box {
    private JButton button;
    MirakelLine(String talent) {
      super(BoxLayout.LINE_AXIS);
      this.setAlignmentX(Component.LEFT_ALIGNMENT);
      var val = data.mirakel.data.get(talent);
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
        var cur = data.mirakel.data.get(talent);
        if (cur == null) {
          data.mirakel.data.put(talent, Mirakel.Art.PLUS);
          button.setText("+");
        } else switch (cur) {
          case PLUS:
            data.mirakel.data.put(talent, Mirakel.Art.MINUS);
            button.setText("-");
            break;
          case MINUS:
            data.mirakel.data.remove(talent);
            button.setText(" ");
            break;
        }
        data.save();
      });
      this.add(button);
      
      var label = new JLabel(talent);
      this.add(label);
    }
  }
  
  private static class SpinnerCells {
    public static class Editor extends AbstractCellEditor implements TableCellEditor {
      private JSpinner spinner = new JSpinner();
      
      public Editor() {
        spinner.setModel(new SpinnerNumberModel(0, 0, 50, 1));
      }
    
      @Override
      public Component getTableCellEditorComponent(
          JTable table, Object value, boolean isSelected, int row, int column) {
        spinner.setValue(value);
        return spinner;
      }
      
      @Override
      public boolean isCellEditable(EventObject evt2) {
        return true;
      }
      
      @Override
      public Object getCellEditorValue() {
        return spinner.getValue();
      }
    }
    
    public static class Renderer extends JSpinner implements TableCellRenderer {
      @Override
      public Component getTableCellRendererComponent(
          JTable table, Object value, boolean isSelected, boolean hasFocus, int row, int column) {
        setValue(value);
        return this;
      }
    }
  }
  
  public static class MirakelRenderer extends JLabel implements TableCellRenderer {
    MirakelRenderer(String text) {
      super(text);
      setOpaque(true);
      setBorder(new EmptyBorder(1,1,1,1));
    }
    
    @Override
    public Component getTableCellRendererComponent(
        JTable table, Object value, boolean isSelected, boolean hasFocus, int row, int column) {
      if ((Boolean) value) {
        setBackground(Color.black);
        setForeground(Color.white);
      } else {
        setBackground(Color.white);
        setForeground(Color.black);
      }
      return this;
    }
  }
  
  private static class TalentgruppenTable extends JTable {
    TalentgruppenTable(Talentbogen data) {
      super(data);
      setFillsViewportHeight(true);
      setRowHeight(20);
      getColumnModel().getColumn(1).setCellRenderer(new SpinnerCells.Renderer());
      getColumnModel().getColumn(1).setCellEditor(new SpinnerCells.Editor());
      
      setDragEnabled(true);
      setDropMode(DropMode.INSERT_ROWS);
      setSelectionMode(ListSelectionModel.SINGLE_SELECTION);
      setTransferHandler(new Talentbogen.DragHandler(this));
    }
  }
  
  private static class MirakelTable extends JTable {
    MirakelTable(Mirakel data) {
      super(data);
      setRowHeight(20);
      getColumnModel().getColumn(0).setCellRenderer(new MirakelRenderer("M+"));
      getColumnModel().getColumn(0).setPreferredWidth(24);
      getColumnModel().getColumn(0).setMaxWidth(24);
      getColumnModel().getColumn(1).setCellRenderer(new MirakelRenderer("M-"));
      getColumnModel().getColumn(1).setPreferredWidth(24);
      getColumnModel().getColumn(1).setMaxWidth(24);
      setAutoResizeMode(JTable.AUTO_RESIZE_LAST_COLUMN);
      setTableHeader(null);
      
      addMouseListener(new MouseAdapter() {
        @Override
        public void mouseClicked(MouseEvent e) {
          int row = rowAtPoint(e.getPoint());
          int col = columnAtPoint(e.getPoint());
          if (row >= 0) switch (col) {
          case 0:
            data.toggleAt(row, Mirakel.Art.PLUS);
            break;
          case 1:
            data.toggleAt(row, Mirakel.Art.MINUS);
            break;
          }
        }
      });
    }
  }
  
  private class Silhouette extends JPanel {
    JComboBox sCombo;
    JComboBox vCombo;
    
    Silhouette() {
      setBorder(BorderFactory.createTitledBorder("Silhouette"));
      setLayout(new GridLayout(0, 2));
      
      add(new JLabel("Name:"));
      add(new JLabel("Variante:"));
      
      sCombo = new JComboBox(data.silhouette.werte);
      sCombo.setSelectedIndex(data.silhouette.silhouette);
      sCombo.addActionListener(e -> {
        data.silhouette.silhouette = sCombo.getSelectedIndex();
        data.save();
      });
      add(sCombo);
      
      vCombo = new JComboBox(data.silhouette.varianten);
      vCombo.setSelectedIndex(data.silhouette.variante);
      vCombo.addActionListener(e -> {
        data.silhouette.variante = vCombo.getSelectedIndex();
        data.save();
      });
      add(vCombo);
    }
  }

  private Box box;
  private Data data;
  private Silhouette silhouette;
  
  public Tab(DatenAustausch3Interface dai, Data data) {
    this.setLayout(new BoxLayout(this, BoxLayout.LINE_AXIS));
    
    this.data = data;
    this.box = Box.createVerticalBox();
    
    final JScrollPane sp = new JScrollPane(new MirakelTable(data.mirakel));
    sp.setBorder(BorderFactory.createTitledBorder("Mirakel"));
    this.add(sp);
    
    final var tbb = Box.createVerticalBox();
    tbb.setBorder(BorderFactory.createTitledBorder("Talentgruppen"));
    final var label = new JLabel("Reihenfolge editierbar per Drag & Drop");
    tbb.add(label);
    final JScrollPane tsp = new JScrollPane(new TalentgruppenTable(data.talentbogen));
    tbb.add(tsp);
    this.box.add(tbb);
    
    this.silhouette = new Silhouette();
    this.box.add(this.silhouette);
    
    this.add(this.box);
  }
  
  public void refresh() {
    this.silhouette.sCombo.setSelectedIndex(data.silhouette.silhouette);
    this.silhouette.vCombo.setSelectedIndex(data.silhouette.variante);
  }
}