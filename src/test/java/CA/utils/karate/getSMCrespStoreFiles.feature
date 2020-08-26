Feature:  Get SMC response store files

Background:
  * def getSMCrespStoreFile = 
    """
      function(objectInfo) {
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
          CIMBLSMCRespS3Bucket,
          'allsvenskan_static_response/eu/' + thisEnv + '/v1/' + objectInfo.objectKey,
          CIMBLS3BucketRegion,
          //Should target the output dir as tests are executed relative to that dir not via the src dir
          'target/test-classes/CIMBL/downloads/' + objectInfo.dir
        ); 
        if(resp.contains('does not exist')) {
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
  * def getSMCrespStoreFileResults = call getSMCrespStoreFile { objectKey: 'leagues.json', dir: '' }
  * print getSMCrespStoreFileResults
  * def getSMCrespStoreFileResults = call getSMCrespStoreFile { objectKey: '25/matches.json', dir: '25' }
  * print getSMCrespStoreFileResults
  * def getSMCrespStoreFileResults = call getSMCrespStoreFile { objectKey: '25/teams.json', dir: '25' }
  * print getSMCrespStoreFileResults
  * def getSMCrespStoreFileResults = call getSMCrespStoreFile { objectKey: '26/matches.json', dir: '26' }
  * print getSMCrespStoreFileResults
  * def getSMCrespStoreFileResults = call getSMCrespStoreFile { objectKey: '26/teams.json', dir: '26' }
  * print getSMCrespStoreFileResults

# @utilSanity
# Scenario:
#   * def getSMCrespStoreFileResults = call getSMCrespStoreFile { objectKey: 'leagues.json', dir: '' }
#   * print getSMCrespStoreFileResults
#   * match getSMCrespStoreFileResults contains 'successful'