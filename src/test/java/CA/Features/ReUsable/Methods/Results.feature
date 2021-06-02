Feature: Anything to do with Results.json

@shouldContinue
Scenario: Check if any of the previous scenarios failed, abort test if any
  * def shouldContinue =
    """
      function(objectInfo) {
        var tcResultReadPath = objectInfo.tcResultReadPath;
        var tcResultWritePath = objectInfo.tcResultWritePath;
        var tcName = objectInfo.tcName;

        var results = karate.read(tcResultReadPath);
        for(var resultSet in results) {
          var thisResultSet = results[resultSet];
          karate.log(thisResultSet);
          if(thisResultSet['name'] == tcName) {
            for(var key in thisResultSet) {
              if(thisResultSet[key] == 'Fail') {
                karate.callSingle(ResuableMethodsPath + '/Results.feature@updateFinalResults', {updateFinalResultParams: objectInfo});
                karate.log('Previous scenario failed');
                karate.abort();
                break;
              }
            }
          }
        }
      }
    """
  * call shouldContinue customReportplaceholderParams

@updateResult
Scenario: Update Test Results to Results.json
  * def retries = 15
  * def updateResults = 
    """
      function(objectInfo) {
        var tcName = objectInfo.tcName;
        var scenarioName = objectInfo.scenarioName;
        var tcResultReadPath = objectInfo.tcResultReadPath;
        var tcResultWritePath = objectInfo.tcResultWritePath;
        var passedResult = objectInfo.result;
        
        var tcResult = '';
        if(typeof(passedResult) == 'string') {
          tcResult = passedResult;
        } else if (typeof(passedResult) == 'object') {
          tcResult = passedResult.pass == true? 'Pass': 'Fail';
        } else {
          karate.fail('Unknown result object: ' + passedResult);
        }
        
        for(var i = 0; i < retries; ++i) {
          try {
            var results = karate.read(tcResultReadPath);
            results[scenarioName] = tcResult;
            karate.log('Current TC Results:' + karate.pretty(results));
            karate.write(karate.pretty(results), tcResultWritePath);
            break;
          } catch(e) {
            karate.log('Something went wrong: ' + e);
          }
        }

        if(tcResult == 'Fail') {
          karate.fail(TCName + '-' + scenarioName + ': ' + karate.pretty(passedResult));
        }
      }
    """
  * call updateResults updateParams

@setPlaceholder
Scenario: Create placeholder in Results.json
  * def setResultPlaceholder = 
    """
      function(objectInfo) {
        var tcResultReadPath = objectInfo.tcResultReadPath;
        var tcResultWritePath = objectInfo.tcResultWritePath;
        var tcName = objectInfo.tcName;
        var tcValidationType = objectInfo.tcValidationType;
        var results = {
            name: tcName,
            tableName: tcValidationType
        }
        karate.write(karate.pretty(results), tcResultWritePath);
      }
    """
  * call setResultPlaceholder customReportplaceholderParams

@updateFinalResults
Scenario: Update Results.json with TC Results
  * def updateFinalResults =
    """
      function(objectInfo) {
        var tcResultReadPath = objectInfo.tcResultReadPath;
        var tcResultWritePath = objectInfo.tcResultWritePath;
        var finalResultReadPath = objectInfo.finalResultReadPath;
        var finalResultWritePath = objectInfo.finalResultWritePath;
        var tcName = objectInfo.tcName;
        var results = [];
        try {
          tcResults = karate.read(tcResultReadPath);
          finalResults = karate.read(finalResultReadPath);
          karate.appendTo(finalResults, tcResults);
          karate.write(karate.pretty(finalResults), finalResultWritePath);
        } catch(err) {
          karate.log('Something went wrong');
        }
      }
    """
  * call updateFinalResults updateFinalResultParams