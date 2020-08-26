Feature:  E2E-00076: League image validation

# [ TEST CODE ]
# @Regression
# Scenario: E2E-00076: League image validation
#     When def result = karate.callSingle('classpath:CIMBL/Tests/E2E-00076/E2E-00076.feature')
#     Then match result.testStatus == 'pass'

Background:
  * url CIMBLbaseUrl
  * def currentPath = 'classpath:CIMBL/Tests/E2E-00076/'
  * def downloadPath = 'target/test-classes/CIMBL/downloads/'
  * def validCimblHeader = read('classpath:CIMBL/Auth/' + authType + '.json')
  * def query = read(currentPath + 'data/requests/request.txt')
  * def setHeaderParams = { query: #(query), validCimblHeader: #(validCimblHeader) }
  * def setHeaderResults = call read('classpath:CIMBL/utils/karate/setHeader.feature') setHeaderParams
  * def downloadImagesFromS3 =
    """
      function(respObject) {       
        var getLeaguesData = respObject.data.getLeagues;
        for(var i in getLeaguesData) {
          var thisLeague = getLeaguesData[i];
          var thisProtocol = eval('thisLeague.' + imgType + '.split(\'\\\/\')')[0];
          var thisHost = eval('thisLeague.' + imgType + '.split(\'\\\/\')')[2];
          var thisDomain = thisProtocol + '//' + thisHost + '/';
          var thisS3Key = eval('thisLeague.' + imgType).replace(thisDomain, '');
          var thisObjectInfo = {
            s3Region: CIMBLS3BucketRegion,
            s3BucketName: CIMBLImgS3Bucket,
            s3Key: thisS3Key,
            downloadPath: downloadPath + 'S3'
          }
          karate.call('classpath:CIMBL/utils/karate/getS3Object.feature', { s3ObjectInfo: thisObjectInfo });
        }
      }
    """
  * def downloadImagesFromURL =
    """
      function(respObject) {
        var getLeaguesData = respObject.data.getLeagues;
        for(var i in getLeaguesData) {
          var thisLeague = getLeaguesData[i];
          var thisURLObjectInfo = {
            targetUrl: eval('thisLeague.' + imgType),
            downloadPath: downloadPath + 'URL'
          }
          karate.call('classpath:CIMBL/utils/karate/downloadFileFromURL.feature', { URLObjectInfo: thisURLObjectInfo});
        }
      }
    """
  * def checkIfImagesAreSame =
    """
      function(respObject) {
        var FileDiffUtilsClass = Java.type('FileDiffUtils.FileDiffUtils');
        var FileDiffUtils = new FileDiffUtilsClass();

        var getLeaguesData = respObject.data.getLeagues;
        var resp = true;

        for(var i in getLeaguesData) {
          var thisLeague = getLeaguesData[i];
          var thisHostSplit = eval('thisLeague.' + imgType + '.split(\'\\\/\')');
          var filename = thisHostSplit[thisHostSplit.length - 1];
          var URLPath = 'classpath:' + downloadPath + 'URL/' + filename;
          var S3Path = 'classpath:' + downloadPath + 'S3/' + filename;
          
          var SuT = karate.readAsString(URLPath);
          var SoT = karate.readAsString(S3Path);

          var output = FileDiffUtils.differentiate(SoT, SuT);
          var msg = null;
          if(!output.contains('NO DIFFS')) {
            resp = false;
            msg = 'Images are DIFFERENT';
          } else {
            msg = 'Images are the SAME';
          }
          karate.log(thisLeague.name + ' - ' + URLPath + ' vs ' + S3Path + ': ' + msg);
        }
        return resp;
      }
    """

@E2E @E2E-00076
Scenario: E2E-00076: League image validation (PNG)
  * def tags = karate.tags
  # * configure abortedStepsShouldPass = true
  * eval if (tags.contains('skip' + targetEnv)) {karate.abort()}
  * def imgType = 'url'
  * configure headers = setHeaderResults.output
  * request
  """
    {
      query: #(query)
    }
  """
  * method post
  * print response
  * call downloadImagesFromS3 response
  * call downloadImagesFromURL response
  * def areImagesSame = call checkIfImagesAreSame response
  * match areImagesSame == true

@E2E @E2E-00076
Scenario: E2E-00076: League image validation (SVG)
  * def tags = karate.tags
  * configure abortedStepsShouldPass = true
  * eval if (tags.contains('skip' + targetEnv)) {karate.abort()}
  * def imgType = 'svgUrl'
  * configure headers = setHeaderResults.output
  * request
  """
    {
      query: #(query)
    }
  """
  * method post
  * print response
  * call downloadImagesFromS3 response
  * call downloadImagesFromURL response
  * def areImagesSame = call checkIfImagesAreSame response
  * match areImagesSame == true