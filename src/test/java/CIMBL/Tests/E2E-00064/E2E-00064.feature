Feature:  E2E-00064: Querying getLeagues should return correct updatedTimeStamps

# [ TEST CODE ]
# @Regression
# Scenario: E2E-00064: Querying getLeagues should return correct updatedTimeStamps
#     When def result = karate.callSingle('classpath:CIMBL/Tests/E2E-00064/E2E-00064.feature')
#     Then match result.testStatus == 'pass'

Background:
  * url CIMBLbaseUrl
  * def currentPath = 'classpath:CIMBL/Tests/E2E-00064/'
  * def validCimblHeader = read('classpath:CIMBL/Auth/' + authType + '.json')
  * def getSMCrespStoreFiles = karate.callSingle('classpath:CIMBL/utils/karate/getSMCrespStoreFiles.feature')
  * def compareUpdatedTimeStamp = 
    """
      function(resp) {
        var state = true;
        for(var i in resp.data.getLeagues) {
          if(resp.data.getLeagues[i].updatedTimeStamp != updatedTimeStamp) {
            state = false;
            karate.log(resp.data.getLeagues[i].updatedTimeStamp + ' is not the same as ' + updatedTimeStamp);
            break;
          }
        }
        return state;
      }
    """
@E2E @E2E-00064
Scenario: E2E-00064: Querying getLeagues should return correct updatedTimeStamps [league: 25]
  * def tags = karate.tags
  * configure abortedStepsShouldPass = true
  * eval if (tags.contains('skip' + targetEnv)) {karate.abort()}
  * def SMCRespStoreFile = read('classpath:CIMBL/downloads/leagues.json')
  * def updatedTimeStamp = SMCRespStoreFile.updatedTimeStamp
  * print updatedTimeStamp
  * def query = read(currentPath + 'data/requests/request.txt')
  * replace query.LEAGUEID = '25'
  * def setHeaderParams = { query: #(query), validCimblHeader: #(validCimblHeader) }
  * def setHeaderResults = call read('classpath:CIMBL/utils/karate/setHeader.feature') setHeaderParams
  Given configure headers = setHeaderResults.output
  When request
  """
    {
      query: #(query)
    }
  """
  And method post
  * print response
  * def isUpdatedTimeStampsSame = call compareUpdatedTimeStamp response
  * match isUpdatedTimeStampsSame == true
  And status 200


@E2E @E2E-00064
Scenario: E2E-00064: Querying getLeagues should return correct updatedTimeStamps [league: 26]
  * def tags = karate.tags
  * configure abortedStepsShouldPass = true
  * eval if (tags.contains('skip' + targetEnv)) {karate.abort()}
  * def SMCRespStoreFile = read('classpath:CIMBL/downloads/leagues.json')
  * def updatedTimeStamp = SMCRespStoreFile.updatedTimeStamp
  * print updatedTimeStamp
  * def query = read(currentPath + 'data/requests/request.txt')
  * replace query.LEAGUEID = '26'
  * def setHeaderParams = { query: #(query), validCimblHeader: #(validCimblHeader) }
  * def setHeaderResults = call read('classpath:CIMBL/utils/karate/setHeader.feature') setHeaderParams
  Given configure headers = setHeaderResults.output
  When request
  """
    {
      query: #(query)
    }
  """
  And method post
  * print response
  * def isUpdatedTimeStampsSame = call compareUpdatedTimeStamp response
  * match isUpdatedTimeStampsSame == true
  And status 200
