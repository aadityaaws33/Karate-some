Feature:  E2E-00069: Querying getTeams should return alphabetically-sorted names

# [ TEST CODE ]
# @Regression
# Scenario: E2E-00069: Querying getTeams should return alphabetically-sorted names
#     When def result = karate.callSingle('classpath:CIMBL/Tests/E2E-00042/E2E-00042.feature')
#     Then match result.testStatus == 'pass'

Background:
  * url CIMBLbaseUrl
  * def currentPath = 'classpath:CIMBL/Tests/E2E-00069/'
  * def validCimblHeader = read('classpath:CIMBL/Auth/' + authType + '.json')
  * def checkOrder = 
    """
      function(resp) {
        var MiscUtilsClass = Java.type('MiscUtils.MiscUtils');
        var MiscUtils = new MiscUtilsClass();
        var getTeamsData = resp.data.getTeams;
        var teamNames = [];
        var sortedRef = [];
        var state = true;

        for(var i in getTeamsData) {
          teamNames.push(getTeamsData[i].name);
          sortedRef.push(getTeamsData[i].name);
        }

        var expectedSortedTeamNames = MiscUtils.sortByAlphabet(sortedRef, 'de');
        
        for(var i in teamNames) {
          if (teamNames[i] != expectedSortedTeamNames[i]) {
            state = false;
            karate.log('getTeams is not sorted in ASCENDING ORDER BY NAME');
            break;
          }
        }

        karate.log(state);
        return state;
      }
    """

@E2E @E2E-00069
Scenario: E2E-00069: Querying getTeams should return alphabetically-sorted names (leagueId:25)
  * def tags = karate.tags
  * configure abortedStepsShouldPass = true
  * eval if (tags.contains('skip' + targetEnv)) {karate.abort()}
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
  * def isAscendingOrder = call checkOrder response
  Then match isAscendingOrder == true

 

@E2E @E2E-00069
Scenario: E2E-00069: Querying getTeams should return alphabetically-sorted names (leagueId:26)
  * def tags = karate.tags
  * configure abortedStepsShouldPass = true
  * eval if (tags.contains('skip' + targetEnv)) {karate.abort()}
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
  * def isAscendingOrder = call checkOrder response
  Then match isAscendingOrder == true

