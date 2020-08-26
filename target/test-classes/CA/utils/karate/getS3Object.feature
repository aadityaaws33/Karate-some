Feature:  Get S3 Object

Background:
  * def getS3Object = 
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
          objectInfo.s3BucketName, //s3 bucket name
          objectInfo.s3Key, //s3 key
          objectInfo.s3Region, //s3 region
          //Should target the output dir as tests are executed relative to that dir not via the src dir
          objectInfo.downloadPath //target download path
        ); 
        if(!resp.contains('success')) {
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
  * def getObjectResult = call getS3Object s3ObjectInfo
  * print getObjectResult

# @utilSanity
# Scenario: Check getS3Object.feature sanity
#   * def testObjectInfo =
#     """
#       {
#         s3Region: #(CIMBLS3BucketRegion),
#         s3BucketName: #(CIMBLImgS3Bucket),
#         s3Key: 'leagues/allsvenskan/teams/108445_1.png',
#         downloadPath: 'target/test-classes/CIMBL/downloads'
#       }
#     """
#   * def getObjectResult = call getS3Object testObjectInfo
#   * print getObjectResult