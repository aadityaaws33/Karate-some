@APIRegression
# @parallel=false    
Feature:  CA AppSync GraphQL Query: getRenditions

Background:
  # PREPROD and PROD ENVs are not ready
  * configure abortedStepsShouldPass = true
  * eval if (TargetEnv.contains('preprod') || TargetEnv.contains('prod')) { karate.log(TargetEnv + ' is not yet ready.'); karate.abort()}
  # ---------
  * def apiName = 'getRenditions'
  # Paths
  * def currentTestDataPath = 'classpath:CA/TestData/APICases/' + apiName
  * def FeatureFilePath = 'classpath:CA/Features/ReUsable/Methods'
  # End
  * def appSyncURL = EnvConfig['Common']['AppSync']['URL']
  * def apiKey = EnvConfig['Common']['AppSync']['X-Api-Key']

Scenario: CA-BE-00002 [Field check] getRenditions has no null fields
  * def country = 'NORWAY'
  * def filters = null
  * def baseFromDate = call read(FeatureFilePath + '/Date.feature@GetDateWithOffset') { offset: -7 }
  * def baseToDate = call read(FeatureFilePath + '/Date.feature@GetDateWithOffset') { offset: 0 }
  * def fromDate = baseFromDate.result + 'T00:00:00.000Z'
  * def toDate = baseToDate.result + 'T23:59:59.999Z'
  * def ExpectedResponse = read(currentTestDataPath + '/renditionEntry.json')
  * def HTTPRequest = read(currentTestDataPath + '/request.json')
  * def HTTPHeaders =
    """
      {
        Content-Type: 'application/json',
        X-Api-Key: #(apiKey)
      }
    """
  Given url appSyncURL
  And headers HTTPHeaders
  When request HTTPRequest
  And method post
  Then match each response.data.getRenditions.renditions[*] == ExpectedResponse

Scenario: CA-BE-00003 [Filter Country] getRenditions gives correct country
  * def country = 'NORWAY'
  * def filters = null
  * def baseFromDate = call read(FeatureFilePath + '/Date.feature@GetDateWithOffset') { offset: -7 }
  * def baseToDate = call read(FeatureFilePath + '/Date.feature@GetDateWithOffset') { offset: 0 }
  * def fromDate = baseFromDate.result + 'T00:00:00.000Z'
  * def toDate = baseToDate.result + 'T23:59:59.999Z'
  * def HTTPRequest = read(currentTestDataPath + '/request.json')
  * def HTTPHeaders =
    """
      {
        Content-Type: 'application/json',
        X-Api-Key: #(apiKey)
      }
    """
  Given url appSyncURL
  And headers HTTPHeaders
  When request HTTPRequest
  And method post
  Then match each response.data.getRenditions.renditions[*].country == country

Scenario: CA-BE-00004 [Filter Dates] getRenditions gives correct dates
  * def country = 'NORWAY'
  * def filters = null
  * def baseFromDate = call read(FeatureFilePath + '/Date.feature@GetDateWithOffset') { offset: -7 }
  * def baseToDate = call read(FeatureFilePath + '/Date.feature@GetDateWithOffset') { offset: 0 }
  * def fromDate = baseFromDate.result + 'T00:00:00.000Z'
  * def toDate = baseToDate.result + 'T23:59:59.999Z'
  * def HTTPRequest = read(currentTestDataPath + '/request.json')
  * def HTTPHeaders =
    """
      {
        Content-Type: 'application/json',
        X-Api-Key: #(apiKey)
      }
    """
  * def createExpectedDateList = call read(FeatureFilePath + '/Date.feature@CreateDateList') { offset: -7 }
  * def expectedDateList = createExpectedDateList.result
  * print expectedDateList
  * def isDateContains =
    """
      function() {
        var finalResult = true;
        for(var i in actualDates) {
          var thisResult = false;
          var actualDate = actualDates[i];
          for(var j in expectedDateList) {
            var thisDate = expectedDateList[j];
            if(actualDate.contains(thisDate)) {
              thisResult = true;
            }
            karate.log(actualDate + ' vs ' + thisDate + ': ' + thisResult);
            if(thisResult == true) {
              break;
            }
          }
          if(thisResult == false) {
            finalResult = false;
            break;
          }
        }
        return finalResult;
      }
    """
  Given url appSyncURL
  And headers HTTPHeaders
  When request HTTPRequest
  And method post
  * def actualDates = get response.data.getRenditions.renditions[*].createdAt
  Then match isDateContains() == true

Scenario: CA-BE-00005 [Filter Rendition Status] getRenditions gives correct rendition status
  * def country = 'NORWAY'
  * def ExpectedRenditionStatus = 'PROCESSING'
  * def filters =
    """
      {
        wochitRenditionStatus:{
          eq: '#(ExpectedRenditionStatus)'
        },
        assetType: null
      }
    """
  * def baseFromDate = call read(FeatureFilePath + '/Date.feature@GetDateWithOffset') { offset: -7 }
  * def baseToDate = call read(FeatureFilePath + '/Date.feature@GetDateWithOffset') { offset: 0 }
  * def fromDate = baseFromDate.result + 'T00:00:00.000Z'
  * def toDate = baseToDate.result + 'T23:59:59.999Z'
  * def HTTPRequest = read(currentTestDataPath + '/request.json')
  * def HTTPHeaders =
    """
      {
        Content-Type: 'application/json',
        X-Api-Key: #(apiKey)
      }
    """
  Given url appSyncURL
  And headers HTTPHeaders
  When request HTTPRequest
  And method post
  Then match each response.data.getRenditions.renditions[*].wochitRenditionStatus == ExpectedRenditionStatus

Scenario: CA-BE-00006 [Filter Media Type] getRenditions gives correct media type
  * def country = 'NORWAY'
  * def ExpectedMediaType = 'VIDEO'
  * def filters =
    """
      {
        assetType:{
          eq: '#(ExpectedMediaType)'
        },
        wochitRenditionStatus: null
      }
    """
  * def baseFromDate = call read(FeatureFilePath + '/Date.feature@GetDateWithOffset') { offset: -7 }
  * def baseToDate = call read(FeatureFilePath + '/Date.feature@GetDateWithOffset') { offset: 0 }
  * def fromDate = baseFromDate.result + 'T00:00:00.000Z'
  * def toDate = baseToDate.result + 'T23:59:59.999Z'
  * def HTTPRequest = read(currentTestDataPath + '/request.json')
  * def HTTPHeaders =
    """
      {
        Content-Type: 'application/json',
        X-Api-Key: #(apiKey)
      }
    """
  Given url appSyncURL
  And headers HTTPHeaders
  When request HTTPRequest
  And method post
  Then match each response.data.getRenditions.renditions[*].assetType == ExpectedMediaType