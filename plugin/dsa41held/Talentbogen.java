package dsa41held;

import javax.swing.table.AbstractTableModel;
import java.awt.datatransfer.DataFlavor;
import java.awt.datatransfer.Transferable;
import javax.swing.TransferHandler;
import javax.swing.JComponent;
import javax.swing.JTable;

import java.util.ArrayList;

import org.w3c.dom.Document;
import org.w3c.dom.Element;

public class Talentbogen extends AbstractTableModel {
  static enum Gruppe {
    SONDERFERTIGKEITEN, GABEN, BEGABUNGEN, KAMPF, KOERPER, GESELLSCHAFT, NATUR, WISSEN, SPRACHEN, HANDWERK;
    
    int defaultZeilen() {
      switch (this) {
      case SONDERFERTIGKEITEN: return 6;
      case GABEN: return 2;
      case BEGABUNGEN: return 0;
      case KAMPF: return 13;
      case KOERPER: return 17;
      case GESELLSCHAFT: return 9;
      case NATUR: return 7;
      case WISSEN: return 17;
      case SPRACHEN: return 10;
      case HANDWERK: return 15;
      default: return 0;
      }
    }
    
    String label() {
      switch (this) {
      case SONDERFERTIGKEITEN: return "Sonderfertigkeiten";
      case GABEN: return "Gaben";
      case BEGABUNGEN: return "Begabungen";
      case KAMPF: return "Kampf";
      case KOERPER: return "Körper";
      case GESELLSCHAFT: return "Gesellschaft";
      case NATUR: return "Natur";
      case WISSEN: return "Wissen";
      case SPRACHEN: return "Sprachen";
      case HANDWERK: return "Handwerk";
      default: return null;
      }
    }
    
    static Gruppe from(String name) {
      for (var g : values()) {
        if (g.label().equals(name)) return g;
      }
      return null;
    }
  }
  
  static class Eintrag {
    Gruppe g;
    int zeilen;
    
    Eintrag(Gruppe g, int zeilen) {
      this.g = g;
      this.zeilen = zeilen;
    }
  }
  
  Eintrag[] data;
  
  public Talentbogen() {
    data = new Eintrag[Gruppe.values().length];
    for (int i = 0; i < Gruppe.values().length; i++) {
      Gruppe g = Gruppe.values()[i];
      data[i] = new Eintrag(g, g.defaultZeilen());
    }
  }
  
  public Element toXML(Document doc) {
    final var root = doc.createElement("talentbogen");
    for (final var item : data) {
      final var group = doc.createElement("gruppe");
      group.setAttribute("id", item.g.label());
      group.setAttribute("zeilen", String.valueOf(item.zeilen));
      root.appendChild(group);
    }
    return root;
  }
  
  public void fromXML(Element input) {
    final var expected = new ArrayList<Gruppe>();
    for (var g : Gruppe.values()) expected.add(g);
    
    int pos = 0;
    for (int i = 0; i < input.getChildNodes().getLength(); i++) {
      Element cur = (Element) input.getChildNodes().item(i);
      var g = Gruppe.from(cur.getAttribute("id"));
      var zeilen = Integer.parseInt(cur.getAttribute("zeilen"));
      
      if (expected.remove(g)) {
        data[pos].g = g;
        data[pos].zeilen = zeilen;
        pos++;
      }
    }
    for (final var g : expected) {
      data[pos].g = g;
      data[pos].zeilen = g.defaultZeilen();
      pos++;
    }
    fireTableDataChanged();
  }
  
  // AbstractTableModel implementation
  
  @Override
  public String getColumnName(int col) {
    switch (col) {
    case 0: return "Gruppe";
    case 1: return "Zeilenanzahl";
    default: return null;
    }
  }
  
  @Override
  public int getRowCount() { return Gruppe.values().length; }
  
  @Override
  public int getColumnCount() { return 2; }
  
  @Override
  public Class getColumnClass(int c) {
    switch (c) {
    case 0: return String.class;
    case 1: return Integer.class;
    default: return null;
    }
  }
  
  @Override
  public Object getValueAt(int row, int col) {
    switch (col) {
    case 0: return data[row].g.label();
    case 1: return data[row].zeilen;
    default: return null;
    }
  }
  
  @Override
  public boolean isCellEditable(int row, int col) {
    return col == 1;
  }
  
  @Override
  public void setValueAt(Object value, int row, int col) {
    data[row].zeilen = (Integer) value;
    Plugin.data.save();
    fireTableCellUpdated(row, col);
  }
  
  // TransferHandler implementation 
  
  static class DragHandler extends TransferHandler {
    private static final DataFlavor localObjectFlavor = new DataFlavor(Integer.class, "Integer Row Index");
    
    private JTable table;
    
    DragHandler(JTable table) {
      this.table = table;
    }
  
    @Override
    public boolean canImport(TransferHandler.TransferSupport info) {
      return info.getComponent() == table && info.isDrop() && info.isDataFlavorSupported(localObjectFlavor);
    }
    
    @Override
    protected Transferable createTransferable(JComponent c) {
      return new RowTransfer(table.getSelectedRow());
    }
    
    @Override
    public int getSourceActions(JComponent c) {
      return TransferHandler.MOVE;
    }
    
    @Override
    public boolean importData(TransferHandler.TransferSupport info) {
      if (!info.isDrop()) {
          return false;
      }
      Talentbogen tb = (Talentbogen)table.getModel();
      JTable.DropLocation dl = (JTable.DropLocation)info.getDropLocation();
      int index = dl.getRow();
      int srcIndex;
      try {
        srcIndex = (Integer) info.getTransferable().getTransferData(localObjectFlavor);
      } catch (Exception ex) {
        throw new RuntimeException(ex);
      }
      
      Eintrag item = tb.data[srcIndex];
      if (index > srcIndex) {
        index -= 1;
        for (int i = srcIndex; i < index; i++) {
          tb.data[i] = tb.data[i+1];
        }
      } else {
        for (int i = srcIndex; i > index; i--) {
          tb.data[i] = tb.data[i-1];
        }
      }
      tb.data[index] = item;
      Plugin.data.save();
      tb.fireTableDataChanged();
      return true;
    }

    @Override    
    protected void exportDone(JComponent c, Transferable data, int action) {
      // don't do anything, table has been updated in importData().
    }
    
    static class RowTransfer implements Transferable {
      int index;
      
      RowTransfer(int index) {
        this.index = index;
      }
      
      @Override
      public Object getTransferData(DataFlavor flavor) {
       return index;
      }
      
      @Override
      public DataFlavor[] getTransferDataFlavors() {
        return new DataFlavor[]{localObjectFlavor};
      }
      
      @Override
      public boolean isDataFlavorSupported(DataFlavor flavor) {
        return flavor == localObjectFlavor;
      }
    }
  }
}