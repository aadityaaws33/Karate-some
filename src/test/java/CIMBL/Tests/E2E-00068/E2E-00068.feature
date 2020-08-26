Feature:  E2E-00068: Querying getLeagues should return results sorted by id in ascending order

# [ TEST CODE ]
# @Regression
# Scenario: E2E-00068: Querying getLeagues should return results sorted by id in ascending order
#     When def result = karate.callSingle('classpath:CIMBL/Tests/E2E-00068/E2E-00068.feature')
#     Then match result.testStatus == 'pass'

Background:
  * url CIMBLbaseUrl
  * def currentPath = 'classpath:CIMBL/Tests/E2E-00068/'
  * def validCimblHeader = read('classpath:CIMBL/Auth/' + authType + '.json')
  * def query = read(currentPath + 'data/requests/request.txt')
  * def checkOrder = 
    """
      function(resp) {
        var state = true;
        var getLeaguesData = resp.data.getLeagues;

        for(var i = 0; i < getLeaguesData.length - 1; i++) {
          if(getLeaguesData[i].id > getLeaguesData[i+1].id) {
            state = false;
            karate.log('getLeagues is not sorted in ASCENDING ORDER BY ID');
            break;
          }
        }

        karate.log(state);
        return state;
      }
    """
  * def setHeaderParams = { query: #(query), validCimblHeader: #(validCimblHeader) }
  * def setHeaderResults = call read('classpath:CIMBL/utils/karate/setHeader.feature') setHeaderParams
      
@E2E @E2E-00068
Scenario: E2E-00068: Querying getLeagues should return results sorted by id in ascending order
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
