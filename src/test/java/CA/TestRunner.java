package CA;

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

import com.intuit.karate.core.ExecutionHook;
import com.intuit.karate.core.Scenario;
import com.intuit.karate.core.ScenarioContext;
import com.intuit.karate.core.ScenarioResult;
import com.intuit.karate.core.Feature;
import com.intuit.karate.core.FeatureResult;
import com.intuit.karate.core.ExecutionContext;
import com.intuit.karate.core.Step;
import com.intuit.karate.core.StepResult;
import com.intuit.karate.http.HttpRequestBuilder;
import com.intuit.karate.core.PerfEvent;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.StringWriter;
import java.io.FileWriter;
import java.io.FileReader;
import java.io.IOException;

@KarateOptions()
public class TestRunner {

  private static void generateReport(String karateOutputPath) {
    Collection<File> jsonFiles =
        FileUtils.listFiles(new File(karateOutputPath), new String[] {"json"}, true);
    List<String> jsonPaths = new ArrayList(jsonFiles.size());
    jsonFiles.forEach(file -> jsonPaths.add(file.getAbsolutePath()));
    Configuration config = new Configuration(new File("target"), "CA API Test Automation");
    ReportBuilder reportBuilder = new ReportBuilder(jsonPaths, config);
    reportBuilder.generateReports();
  }

  @Test
  public void testParallel() {
    Results results = Runner.path("classpath:CA").hook(new ExecHook()).parallel(3);
    generateReport(results.getReportDir());
    assertTrue(results.getErrorMessages(), results.getFailCount() == 0);
  }
}

class ExecHook implements ExecutionHook {
  @Override
  public void afterAll(Results results) {
    String Path = System.getProperty("user.dir");
    StringBuilder contentBuilder = new StringBuilder();
    try {
      BufferedReader Results = new BufferedReader(new FileReader(Path + "/target/test-classes/Results.json"));
      BufferedWriter bw = new BufferedWriter(new FileWriter(Path + "/target/test-classes/CA/utils/customReport/js/data.js"));
      String line;
      bw.write("var data = ");
      while((line = Results.readLine()) != null) {
        bw.write(line);
        bw.newLine();
      }
      Results.close();
      bw.close();
    } catch (IOException e) {
      System.err.println(e.getMessage());
    }
  }

  @Override
  public boolean beforeScenario(Scenario scenario, ScenarioContext context) {
    return true;
  }

  @Override
  public void afterScenario(ScenarioResult result, ScenarioContext context) {

  }    

  @Override
  public boolean beforeFeature(Feature feature, ExecutionContext context) {
    return true;
  }

  @Override
  public void afterFeature(FeatureResult result, ExecutionContext context) {
    
  }    

  @Override
  public void beforeAll(Results results) {

  }       

  @Override
  public boolean beforeStep(Step step, ScenarioContext context) {
    return true;
  }

  @Override
  public void afterStep(StepResult result, ScenarioContext context) {

  }        
      
  @Override
  public String getPerfEventName(HttpRequestBuilder req, ScenarioContext context) {
    return null;
  }    
  
  @Override
  public void reportPerfEvent(PerfEvent event) {
      
  }
  
}
