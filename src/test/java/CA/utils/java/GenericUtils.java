package CA.utils.java;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.TimeZone;

import org.apache.commons.io.FileUtils;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;



public class GenericUtils {

   String region = System.getProperty("karate.region");
   
public String CreateDate()
{
    TimeZone tz = TimeZone.getTimeZone("GMT");
    //DateFormat df = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm'Z'"); // Quoted "Z" to indicate UTC, no timezone offset
    DateFormat df = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm"); // Quoted "Z" to indicate UTC, no timezone offset
    df.setTimeZone(tz);
    String nowAsISO = df.format(new Date());
    //System.out.println("--------Printing Date-------"+ nowAsISO);

    return nowAsISO;
}
public String getHTML_String() {
    String Path = System.getProperty("user.dir");
    StringBuilder contentBuilder = new StringBuilder();
    try {
        BufferedReader in = new BufferedReader(new FileReader(Path + "/target/CustomReport.html/CustomReport.html"));
        String str;
        while ((str = in.readLine()) != null) {
            contentBuilder.append(str);
        }
        in.close();
    } catch (IOException e) {
    }
    return contentBuilder.toString();

}
public void UpdateReport(String ID , int cell)
{
    
    String html = getHTML_String();
    //System.out.println("-------Print Html Before change------"+ html);
    Document document = Jsoup.parse(html);
    Elements Table_Row = document.getElementsByAttributeValue("id", ID);
    Element Table_Cell = Table_Row.select("td").get(cell);
    Table_Cell.html("<td>Pass</td>");
    //System.out.println("-------Print Html after change------"+ document.outerHtml());
    WriteResultFile(document.outerHtml());
}
private void WriteResultFile(String Text) {
    try {
        String Path = System.getProperty("user.dir");
        FileWriter myWriter = new FileWriter(Path + "/target/CustomReport.html/CustomReport.html");
        myWriter.write(Text);
        myWriter.close();
        //System.out.println("Successfully wrote to the file.");
      } catch (IOException e) {
        System.out.println("An error occurred.");
        e.printStackTrace();
      }

}
public void BeforeAll()
{
    String Path = System.getProperty("user.dir");

    try {
        File srcFile = new File(Path + "/src/test/java/CA/CustomReport.html");
        File destDir = new File(Path + "/target/CustomReport.html");
        FileUtils.copyFileToDirectory(srcFile, destDir);
    } catch(Exception e) {
    }

}


}