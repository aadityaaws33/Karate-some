@SchemaValidation
Feature: Schema Validation: Check difference between Source of Truth and Actual schema
# CHANGE - change in line
# INSERT - new line
# DELETE - deleted line

Background:
  * def currentPath = 'classpath:CIMBL/SchemaValidation/'
  * def AWSUtils = 
    """
      function() {
        var AWSUtilsClass = Java.type('AWSUtils.AWSUtils');
        var AWSUtils = new AWSUtilsClass();
        return AWSUtils
      }
    """
  * def AWSUtilsObj = call AWSUtils
  * def downloadSoT = 
    """
      function(AWSUtilsObj) {
        var resp = AWSUtilsObj.downloadS3Object(
          CIMBLQaBucket, 
          'schema/' + targetEnv + '.graphql', 
          CIMBLQaBucketRegion, 
          'target/test-classes/CIMBL/downloads'); 
        karate.log(resp);
        return resp;
      }
    """
  * call downloadSoT(AWSUtilsObj)
  * def downloadSuT = 
    """
      function(AWSUtilsObj) {
        var resp = AWSUtilsObj.downloadAppSyncSchema(
          CIMBLApiId, 
          CIMBLApiRegion,
          'target/test-classes/CIMBL/downloads'
        );
        karate.log(resp);
        return resp;
      }
    """
  * call downloadSuT(AWSUtilsObj)
  * def SuT = karate.readAsString('classpath:CIMBL/downloads/SuT.graphql')
  * def SoT = karate.readAsString('classpath:CIMBL/downloads/' + targetEnv + '.graphql')
  * def differentiate = 
    """
      function() {
        var FileDiffUtilsClass = Java.type('FileDiffUtils.FileDiffUtils');
        var FileDiffUtils = new FileDiffUtilsClass();
        return FileDiffUtils.differentiate(SoT, SuT);
      }
    """
  * def diffs = call differentiate
  
Scenario: There should be no difference between the Schema of Truth and the Schema-under-test
  # * print "THIS"
  * print diffs
  * match diffs == ["NO DIFFS"]
