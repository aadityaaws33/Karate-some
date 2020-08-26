Feature:  E2E-00076: Team image validation

# [ TEST CODE ]
# @Regression
# Scenario: E2E-00076: Team image validation
#     When def result = karate.callSingle('classpath:CIMBL/Tests/E2E-00076/E2E-00076.feature')
#     Then match result.testStatus == 'pass'

Background:
  * url CIMBLbaseUrl
  * def currentPath = 'classpath:CIMBL/Tests/E2E-00077/'
  * def downloadPath = 'target/test-classes/CIMBL/downloads/'
  * def validCimblHeader = read('classpath:CIMBL/Auth/' + authType + '.json')
  * def query = read(currentPath + 'data/requests/request.txt')
  * def downloadImagesFromS3 =
    """
      function(respObject) {       
        var getTeamsData = respObject.data.getTeams;
        for(var i in getTeamsData) {
          var thisTeam = getTeamsData[i];
          var thisProtocol = eval('thisTeam.' + imgType + '.split(\'\\\/\')')[0];
          var thisHost = eval('thisTeam.' + imgType + '.split(\'\\\/\')')[2];
          var thisDomain = thisProtocol + '//' + thisHost + '/';
          var thisS3Key = eval('thisTeam.' + imgType).replace(thisDomain, '');
          var thisS3Key = eval('thisTeam.' + imgType).replace(thisDomain, '');
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
        var getTeamsData = respObject.data.getTeams;
        for(var i in getTeamsData) {
          var thisTeam = getTeamsData[i];
          var thisURLObjectInfo = {
            targetUrl: eval('thisTeam.' + imgType),
            downloadPath: downloadPath + 'URL'
          }
          karate.call('classpath:CIMBL/utils/karate/downloadFileFromURL.feature', { URLObjectInfo: thisURLObjectInfo});
        }
      }
    """
    
  * def checkIfPNG =
    """
      function(respObject) {
        var MiscUtilsClass = Java.type('MiscUtils.MiscUtils');
        var MiscUtils = new MiscUtilsClass();
        var getTeamsData = respObject.data.getTeams;
        var resp = true;
        for(var i in getTeamsData) {
          var thisTeam = getTeamsData[i];
          var thisHostSplit = eval('thisTeam.' + imgType + '.split(\'\\\/\')');
          var filename = thisHostSplit[thisHostSplit.length - 1];
          var pngURLPath = downloadPath + 'URL/' + filename;
          var pngS3Path = downloadPath + 'S3/' + filename;
          var output = MiscUtils.getImageDifference(pngURLPath, pngS3Path);
          karate.log(thisTeam.name + ' - ' + pngURLPath + ' vs ' + pngS3Path + ': ' + output);
          if(output != 'Images are the same') {
            resp = false;
            break;
          }
        }
        return resp;
      }
    """
  * def checkIfImagesAreSame =
    """
      function(respObject) {
        var FileDiffUtilsClass = Java.type('FileDiffUtils.FileDiffUtils');
        var FileDiffUtils = new FileDiffUtilsClass();

        var getTeamsData = respObject.data.getTeams;
        var resp = true;

        for(var i in getTeamsData) {
          var thisTeam = getTeamsData[i];
          var thisHostSplit = eval('thisTeam.' + imgType + '.split(\'\\\/\')');
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
          karate.log(thisTeam.name + ' - ' + URLPath + ' vs ' + S3Path + ': ' + msg);
        }
        return resp;
      }
    """

@E2E @E2E-00077
Scenario: E2E-00076: Team image validation (league Id: 25) (PNG)
  * def tags = karate.tags
  * configure abortedStepsShouldPass = true
  * eval if (tags.contains('skip' + targetEnv)) {karate.abort()}
  * def imgType = 'url'
  * replace query.LEAGUEID = '25'
  * def setHeaderParams = { query: #(query), validCimblHeader: #(validCimblHeader) }
  * def setHeaderResults = call read('classpath:CIMBL/utils/karate/setHeader.feature') setHeaderParams
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

@E2E @E2E-00077
Scenario: E2E-00076: Team image validation (league Id: 26) (PNG)
  * def tags = karate.tags
  * configure abortedStepsShouldPass = true
  * eval if (tags.contains('skip' + targetEnv)) {karate.abort()}
  * def imgType = 'url'
  * replace query.LEAGUEID = '26'
  * def setHeaderParams = { query: #(query), validCimblHeader: #(validCimblHeader) }
  * def setHeaderResults = call read('classpath:CIMBL/utils/karate/setHeader.feature') setHeaderParams
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

@E2E @E2E-00077
Scenario: E2E-00076: Team image validation (league Id: 25) (SVG)
  * def tags = karate.tags
  * configure abortedStepsShouldPass = true
  * eval if (tags.contains('skip' + targetEnv)) {karate.abort()}
  * def imgType = 'svgUrl'
  * replace query.LEAGUEID = '25'
  * def setHeaderParams = { query: #(query), validCimblHeader: #(validCimblHeader) }
  * def setHeaderResults = call read('classpath:CIMBL/utils/karate/setHeader.feature') setHeaderParams
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

@E2E @E2E-00077
Scenario: E2E-00076: Team image validation (league Id: 26) (SVG)
  * def tags = karate.tags
  * configure abortedStepsShouldPass = true
  * eval if (tags.contains('skip' + targetEnv)) {karate.abort()}
  * def imgType = 'svgUrl'
  * replace query.LEAGUEID = '26'
  * def setHeaderParams = { query: #(query), validCimblHeader: #(validCimblHeader) }
  * def setHeaderResults = call read('classpath:CIMBL/utils/karate/setHeader.feature') setHeaderParams
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
