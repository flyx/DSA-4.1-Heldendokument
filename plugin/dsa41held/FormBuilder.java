package dsa41held;

import java.awt.*;
import javax.swing.*;

import java.util.function.Consumer;

public class FormBuilder {
  private final Container container;
  private int row = 0;
  
  public FormBuilder(Container container) {
    this.container = container;
    container.setLayout(new GridBagLayout());
  }
  
  private GridBagConstraints labelAt(int x, int anchor) {
    GridBagConstraints cons = new GridBagConstraints();
    cons.gridx = x;
    cons.gridy = row;
    cons.weightx = 0;
    cons.gridwidth = 1;
    cons.ipadx = 1;
    cons.anchor = anchor;
    return cons;
  }
  
  private GridBagConstraints cellAt(int x, int pTop, int pLeft, int pBottom, int pRight) {
    GridBagConstraints cons = new GridBagConstraints();
    cons.gridx = x;
    cons.gridy = row;
    cons.fill = GridBagConstraints.BOTH;
    if (pTop > 0 || pLeft > 0 || pBottom > 0 || pRight > 0) {
      cons.insets = new Insets(pTop, pLeft, pBottom, pRight);
    }
    return cons;
  }
  
  @SafeVarargs
  public final FormBuilder add(String label, JComponent comp, JLabel errorLabel, Consumer<GridBagConstraints>... consSetters) {
    JLabel jl = new JLabel(label);
    container.add(jl, labelAt(0, GridBagConstraints.NORTHEAST));
    GridBagConstraints cons = cellAt(1, 0, 5, 5, 0);
    if (consSetters != null) {
      for (Consumer<GridBagConstraints> cs : consSetters) {
        cs.accept(cons);
      }
    }
    container.add(comp, cons);
    ++row;
    if (errorLabel != null) {
      container.add(Box.createVerticalStrut(13), cellAt(0, 0, 0, 0, 0));
      errorLabel.setVisible(false);
      container.add(errorLabel, labelAt(1, GridBagConstraints.NORTHWEST));
      ++row;
    }
    
    return this;
  }
}