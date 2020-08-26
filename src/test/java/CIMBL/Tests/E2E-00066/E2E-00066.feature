Feature:  E2E-00066: Querying getFixtures should return chronologically-sorted results

# [ TEST CODE ]
# @Regression
# Scenario: E2E-00066: Querying getFixtures should return chronologically-sorted results
#     When def result = karate.callSingle('classpath:CIMBL/Tests/E2E-00066/E2E-00066.feature')
#     Then match result.testStatus == 'pass'

Background:
  * url CIMBLbaseUrl
  * def currentPath = 'classpath:CIMBL/Tests/E2E-00066/'
  * def validCimblHeader = read('classpath:CIMBL/Auth/' + authType + '.json')
  * def query = read(currentPath + 'data/requests/request.txt')
  # * def expectedResponse = read(currentPath + 'data/responses/' + targetEnv + '.json')
  # * print expectedResponse
  * def setHeaderParams = { query: #(query), validCimblHeader: #(validCimblHeader) }
  * def setHeaderResults = call read('classpath:CIMBL/utils/karate/setHeader.feature') setHeaderParams
  * def checkOrder = 
    """
      function(resp) {
        var MiscUtilsClass = Java.type('MiscUtils.MiscUtils');
        var MiscUtils = new MiscUtilsClass();
        getFixturesData = resp.data.getFixtures;
        var state = true;

        for(var i = 0; i < getFixturesData.length - 1; i++) {
          var date1 = MiscUtils.convertStringDateToLong(getFixturesData[i].date);
          var date2 = MiscUtils.convertStringDateToLong(getFixturesData[i+1].date);
          if(date1 > date2) {
            state = false;
            karate.log('getFixtures is not sorted in ASCENDING ORDER BY DATE');
            break;
          }
        }
        karate.log(state);
        return state;
      }
    """

@E2E @E2E-00066
Scenario: E2E-00066: Querying getFixtures should return chronologically-sorted results
  * def tags = karate.tags
  * configure abortedStepsShouldPass = true
  * eval if (tags.contains('skip' + targetEnv)) {karate.abort()}
  Given configure headers = setHeaderResults.output
  When request
  """
    {
      query: #(query)
    }
  """
  And method post
  * print response
  * def isAscendingOrder = call checkOrder response
  Then match isAscendingOrder == true
