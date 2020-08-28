package CA.utils.java;

import java.awt.Color;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import java.net.URL;
import java.text.Collator;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import javax.imageio.ImageIO;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import org.apache.commons.io.FileUtils;

public class MiscUtils {

  public List<String> sortByAlphabet(List<String> strList, String langCode) {
    Locale thisLang = new Locale(langCode, langCode.toUpperCase());
    Collator collator = Collator.getInstance(thisLang);
    Collections.sort(strList, collator);
    return strList;
  }

  public Long convertStringDateToLong(String dateStr) {
    SimpleDateFormat inputFormat = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'");
    Long dateLong = 0L;
    try {
      Date date = inputFormat.parse(dateStr);
      dateLong = date.getTime();
    } catch (ParseException e) {
      System.err.println(e.getMessage());
    }
    return dateLong;
  }

  public String getFileFromURL(String downloadSrc, String outputPath) {
    System.out.format("Downloading file from %s to %s\n", downloadSrc, outputPath);
    String[] downloadSrcSplit = downloadSrc.split("/");
    String filename = downloadSrcSplit[downloadSrcSplit.length - 1];
    String output = "Download successful.";
    try {
      FileUtils.copyURLToFile(new URL(downloadSrc), new File(outputPath + '/' + filename), 10000, 10000);
    } catch (IOException e) {
      output = e.getMessage();
      System.err.println(e.getMessage());
    }
    return output;
  }

  public String getImageDifference(String filePath1, String filePath2) throws Exception {
    BufferedImage img1 = ImageIO.read(new File(filePath1));
    BufferedImage img2 = ImageIO.read(new File(filePath2));
    int w1 = img1.getWidth();
    int w2 = img2.getWidth();
    int h1 = img1.getHeight();
    int h2 = img2.getHeight();
    String output = "Images are the same";
    if ((w1 != w2) || (h1 != h2)) {
      output = "Difference: Image dimensions.";
    } else {
      long diff = 0;
      for (int j = 0; j < h1; j++) {
        for (int i = 0; i < w1; i++) {
          // Getting the RGB values of a pixel
          int pixel1 = img1.getRGB(i, j);
          Color color1 = new Color(pixel1, true);
          int r1 = color1.getRed();
          int g1 = color1.getGreen();
          int b1 = color1.getBlue();
          int pixel2 = img2.getRGB(i, j);
          Color color2 = new Color(pixel2, true);
          int r2 = color2.getRed();
          int g2 = color2.getGreen();
          int b2 = color2.getBlue();
          // sum of differences of RGB values of the two images
          long data = Math.abs(r1 - r2) + Math.abs(g1 - g2) + Math.abs(b1 - b2);
          diff = diff + data;
        }
      }
      double avg = diff / (w1 * h1 * 3);
      double percentage = (avg / 255) * 100;
      if (percentage > 0) {
        output = "Difference: " + percentage + "% of image pixels.";
      }
    }
    return output;
  }

  public int Add(int a, int b) {
    System.out.println("**********Calling Function********");
    int c = 0;
    c = a + b;
    return c;
  }

  public Map<String, Object> doWork(String fromJs) {
    Map<String, Object> map = new HashMap<>();
    map.put("someKey", "hello " + fromJs);
    return map;
  }

  public JsonObject ConverttoJSON(String jsonString) {
    String json = jsonString;
    JsonObject jsonObject = new JsonParser().parse(json).getAsJsonObject();
    System.out.println("---------String in Json Format---------"+ jsonObject.toString());
    return jsonObject;
  }

}