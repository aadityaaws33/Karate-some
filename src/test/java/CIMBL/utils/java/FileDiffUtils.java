package FileDiffUtils;


import com.github.difflib.algorithm.DiffException;
import com.github.difflib.DiffUtils;
import com.github.difflib.patch.Patch;
import com.github.difflib.patch.AbstractDelta;

import java.util.Arrays;
import java.util.ArrayList;
import java.util.List;
import java.util.HashMap;

public class FileDiffUtils {
  

  public List differentiate(String SoT, String SuT) {
    String[] SoTStrArr = SoT.split("\\r?\\n");
    String[] SuTStrArr = SuT.split("\\r?\\n");
    List<String> SoTrows = Arrays.asList(SoTStrArr);
    List<String> SuTrows = Arrays.asList(SuTStrArr);
    Patch patch = new Patch();
    List response = new ArrayList();

    // Patch[IN-PROGRESS]
    try {
      patch = DiffUtils.diff(SoTrows, SuTrows);
    } catch (DiffException e) {
      System.out.println("NAGERROR");
      System.err.println(e);
      response.add(e.getMessage()) ;
    }
    List<AbstractDelta> deltas = patch.getDeltas();
    if (deltas.isEmpty()) {
      response.add("NO DIFFS");
    } else {
      for ( AbstractDelta d : deltas ) {
        HashMap<String, String> resp = new HashMap<String, String>();
        resp.put("Line", String.valueOf(d.getTarget().getPosition() + 1));
        resp.put("Type", d.getType().toString());
        resp.put("Schema[Truth]", d.getSource().getLines().toString().trim());
        resp.put("Schema[AppSync]", d.getTarget().getLines().toString().trim());
        response.add(resp);
      }
    }
    return response;
  }
}