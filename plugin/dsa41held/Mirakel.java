package dsa41held;

import java.util.HashMap;
import java.util.Map;

public class Mirakel {
  public static enum Art {
    PLUS, MINUS;
  }

  Map<String, Art> data = new HashMap<String, Art>();
  
  public void load() {
    data.clear();
  
    for (final var art : Art.values()) {
      for (final var name : Plugin.getHeldData("mirakel-" + art.toString()).split("\\|")) {
        if (!"".equals(name)) data.put(name, art);
      }
    }
  }
  
  public void save() {
    for (var item : Art.values()) {
      Plugin.setHeldData("mirakel-" + item.toString(), serialize(item));
    }
  }
  
  private String serialize(Art art) {
    final var builder = new StringBuilder();
    for (final var entry : data.entrySet()) {
      if (entry.getValue().equals(art)) {
        if (builder.length() > 0) builder.append("|");
        builder.append(entry.getKey());
      }
    }
    return builder.toString();
  }
}