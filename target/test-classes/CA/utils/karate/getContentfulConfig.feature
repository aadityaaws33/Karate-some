Feature:  Get contentfulConfig.json from S3

Background:
  * def getContentfulConfig = 
    """
      function() {
        var AWSUtilsClass = Java.type('AWSUtils.AWSUtils');
        var AWSUtils = new AWSUtilsClass();
        var thisEnv = ''
        //Need to transform this to match S3 key(path)
        if (targetEnv == 'staging') {
          thisEnv = 'stage';
        }
        else {
          thisEnv = targetEnv;
        }
        var resp = AWSUtils.downloadS3Object(
          CIMBLImgS3Bucket, 
          'cimbl-team-names/' + thisEnv + '/contentfulConfig.json', 
          CIMBLS3BucketRegion, 
          //Should target the output dir as tests are executed relative to that dir not via the src dir
          'target/test-classes/CIMBL/downloads'
        ); 
        if(!resp.contains('successful')) {
          karate.abort();
        }
        return resp;
      }
    """
  * def sleep = 
    """
      function(ms) {
        java.lang.System.out.println('Sleeping for ' + ms + 'ms');
        java.lang.Thread.sleep(ms);
      }
    """
Scenario:
  * def getContentfulConfigResults = call getContentfulConfig
  * print getContentfulConfigResults

# @utilSanity
# Scenario: Check getContentfulConfig.feature Sanity
#   * def getContentfulConfigResults = call getContentfulConfig
#   * print getContentfulConfigResults
#   * match getContentfulConfigResults contains 'successful'