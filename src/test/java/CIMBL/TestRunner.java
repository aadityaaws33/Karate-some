package CIMBL;

import static org.testng.AssertJUnit.assertTrue;

import com.intuit.karate.KarateOptions;
import com.intuit.karate.Results;
import com.intuit.karate.Runner;
import java.io.File;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import net.masterthought.cucumber.Configuration;
import net.masterthought.cucumber.ReportBuilder;
import org.apache.commons.io.FileUtils;
import org.testng.annotations.Test;

@KarateOptions()
public class TestRunner {

  private static void generateReport(String karateOutputPath) {
    Collection<File> jsonFiles =
        FileUtils.listFiles(new File(karateOutputPath), new String[] {"json"}, true);
    List<String> jsonPaths = new ArrayList(jsonFiles.size());
    jsonFiles.forEach(file -> jsonPaths.add(file.getAbsolutePath()));
    Configuration config = new Configuration(new File("target"), "CIMBL API Test Automation");
    ReportBuilder reportBuilder = new ReportBuilder(jsonPaths, config);
    reportBuilder.generateReports();
  }

  @Test
  public void testParallel() {
    String karateOutputPath = "target/cucumber-html-reports";
    //Results results = Runner.path("classpath:ilex").parallel(5);
    
    Results results = Runner.parallel(getClass(), 20, karateOutputPath);
    generateReport(results.getReportDir());
    assertTrue(results.getErrorMessages(), results.getFailCount() == 0);
  }
}
