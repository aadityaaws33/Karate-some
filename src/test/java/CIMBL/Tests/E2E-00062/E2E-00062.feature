Feature:  E2E-00062: Ensure CIMBL updates S3 objects every 15 minutes
# [ TEST CODE ]
# @Regression
# Scenario: E2E-00062: Ensure CIMBL updates S3 objects
#     When def result = karate.callSingle('classpath:CIMBL/Tests/E2E-00062/E2E-00062.feature')
#     Then match result.testStatus == 'pass'

Background:
  * def getLastModified = 
    """
      function(objectKey) {
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
        var lastModified = AWSUtils.getS3ObjectLastModified(
          CIMBLSMCRespS3Bucket,
          'allsvenskan_static_response/eu/' + thisEnv + '/v1/' + objectKey,
          CIMBLS3BucketRegion
        );
        karate.log('LAST MODIFIED[' + objectKey + ']: ' + lastModified);
        return lastModified.getTime();
      }
    """
  * def getTimeDiff = 
    """
      function(lastModified) {
        var AWSUtilsClass = Java.type('AWSUtils.AWSUtils');
        var AWSUtils = new AWSUtilsClass();
        var timeNow = AWSUtils.getTimeNow();
        var timeDiff = AWSUtils.getTimeDiff(
          timeNow,
          lastModified,
          'minutes'
        );
        karate.log('TIME DIFFERENCE[' + objectKey + '][MINUTES]: ' + timeDiff);
        return timeDiff;
      }
    """

@E2E @E2E-00062
Scenario: E2E-00062: Ensure CIMBL updates S3 objects every 15 minutes [leagues.json]
  * def tags = karate.tags
  * configure abortedStepsShouldPass = true
  * eval if (tags.contains('skip' + targetEnv)) {karate.abort()}
  * def objectKey = 'leagues.json'
  * def lastModified = call getLastModified objectKey
  * def timeDiff = call getTimeDiff lastModified
  * assert timeDiff <= 15


@E2E @E2E-00062
Scenario: E2E-00062: Ensure CIMBL updates S3 objects every 15 minutes [25/matches.json]
  * def tags = karate.tags
  * configure abortedStepsShouldPass = true
  * eval if (tags.contains('skip' + targetEnv)) {karate.abort()}
  * def objectKey = '25/matches.json'
  * def lastModified = call getLastModified objectKey
  * def timeDiff = call getTimeDiff lastModified
  * assert timeDiff <= 15


@E2E @E2E-00062
Scenario: E2E-00062: Ensure CIMBL updates S3 objects every 15 minutes [25/teams.json]
  * def tags = karate.tags
  * configure abortedStepsShouldPass = true
  * eval if (tags.contains('skip' + targetEnv)) {karate.abort()}
  * def objectKey = '25/teams.json'
  * def lastModified = call getLastModified objectKey
  * def timeDiff = call getTimeDiff lastModified
  * assert timeDiff <= 15


@E2E @E2E-00062 
Scenario: E2E-00062: Ensure CIMBL updates S3 objects every 15 minutes [26/matches.json]
  * def tags = karate.tags
  * configure abortedStepsShouldPass = true
  * eval if (tags.contains('skip' + targetEnv)) {karate.abort()}
  * def objectKey = '26/matches.json'
  * def lastModified = call getLastModified objectKey
  * def timeDiff = call getTimeDiff lastModified
  * assert timeDiff <= 15


  @E2E @E2E-00062 
Scenario: E2E-00062: Ensure CIMBL updates S3 objects every 15 minutes [26/teams.json]
  * def tags = karate.tags
  * configure abortedStepsShouldPass = true
  * eval if (tags.contains('skip' + targetEnv)) {karate.abort()}
  * def objectKey = '26/teams.json'
  * def lastModified = call getLastModified objectKey
  * def timeDiff = call getTimeDiff lastModified
  * assert timeDiff <= 15

