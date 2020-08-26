Feature:  getLeagues: Querying getLeagues with league Ids
 
@E2E @getLeagues @PositiveCases @REWORK
Scenario Outline: <TESTID>: Positive Cases - Querying getLeagues with league Ids [<LEAGUEID>]
  * url CIMBLbaseUrl
  * def currentPath = 'classpath:CIMBL/Tests/getLeagues/'
  * def validCimblHeader = read('classpath:CIMBL/Auth/' + authType + '.json')
  * def query = read(currentPath + 'data/requests/' + <REQUESTFNAME> + '.txt')
  * def expectedResponse = read(currentPath + 'data/responses/' + <RESPONSEFNAME> + '.json')
  * print expectedResponse
  * def tags = karate.tags
  * configure abortedStepsShouldPass = true
  * eval if (tags.contains('skip' + targetEnv)) {karate.abort()}
  * eval if (!<EXECUTEONENVS>.contains(targetEnv)) {karate.abort()}
  * replace query.LEAGUEID = <LEAGUEID>
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
  Then match <ASSERTCRUMB> contains expectedResponse.data.getLeagues
  And match expectedResponse.data.getLeagues contains <ASSERTCRUMB>
  And status <STATUSCODE>


  Examples:
    | TESTID      | LEAGUEID  | ASSERTCRUMB               | REQUESTFNAME      | RESPONSEFNAME                       | STATUSCODE  | EXECUTEONENVS               |
    | E2E-00014a  | 25        | response.data.getLeagues  | 'leagueId'        | 'leagueId/Positive/25/' + targetEnv | 200         | 'qa,staging,prod,prodGreen' |
    | E2E-00014b  | 26        | response.data.getLeagues  | 'leagueId'        | 'leagueId/Positive/26/' + targetEnv | 200         | 'qa,staging,prod,prodGreen' |


@E2E @getLeagues @ErrorCases @REWORK
Scenario Outline: <TESTID>: Error Cases - Querying getLeagues with league Ids [<LEAGUEID>]
  * url CIMBLbaseUrl
  * def currentPath = 'classpath:CIMBL/Tests/getLeagues/'
  * def validCimblHeader = read('classpath:CIMBL/Auth/' + authType + '.json')
  * def query = read(currentPath + 'data/requests/' + <REQUESTFNAME> + '.txt')
  * def expectedResponse = read(currentPath + 'data/responses/' + <RESPONSEFNAME> + '.json')
  * print expectedResponse
  * def tags = karate.tags
  * configure abortedStepsShouldPass = true
  * eval if (tags.contains('skip' + targetEnv)) {karate.abort()}
  * eval if (!<EXECUTEONENVS>.contains(targetEnv)) {karate.abort()}
  * replace query.LEAGUEID = <LEAGUEID>
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
  Then match <ASSERTCRUMB> contains expectedResponse.data.getLeagues
  And match expectedResponse.data.getLeagues contains <ASSERTCRUMB>
  And status <STATUSCODE>


  Examples:
    | TESTID     | LEAGUEID    | ASSERTCRUMB               | REQUESTFNAME       | RESPONSEFNAME                               | STATUSCODE  | EXECUTEONENVS               |
    | E2E-00019  | 'null'      | response.data.getLeagues  | 'leagueIdNoTeams'  | 'leagueId/Errors/allLeagues/' + targetEnv   | 200         | 'qa,staging,prod,prodGreen' |
    | E2E-00020  | '""'        | response.data.getLeagues  | 'leagueId'         | 'leagueId/Errors/ErrInvalidLeague'          | 200         | 'qa,staging,prod,prodGreen' |
