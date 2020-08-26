Feature:  getTeams: Querying getTeams with league Ids
 
@E2E @getTeams @PositiveCases @REWORK
Scenario Outline: <TESTID>: Positive Cases - Querying getTeams with league Ids [<LEAGUEID>]
  * url CIMBLbaseUrl
  * def currentPath = 'classpath:CIMBL/Tests/getTeams/'
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
  Then match <ASSERTCRUMB> contains expectedResponse.data.getTeams
  And match expectedResponse.data.getTeams contains <ASSERTCRUMB>
  And status <STATUSCODE>

  Examples:
    | TESTID      | LEAGUEID  | ASSERTCRUMB             | REQUESTFNAME      | RESPONSEFNAME                       | STATUSCODE  | EXECUTEONENVS               |
    | E2E-00016a  | 25        | response.data.getTeams  | 'leagueId'        | 'leagueId/Positive/25/' + targetEnv | 200         | 'qa,staging,prod,prodGreen' |
    | E2E-00016b  | 26        | response.data.getTeams  | 'leagueId'        | 'leagueId/Positive/26/' + targetEnv | 200         | 'qa,staging,prod,prodGreen' |


# @E2E @getFixtures @ErrorCases @REWORK
# Scenario Outline: <TESTID>: Error Cases - Querying getFixtures with fromDate [<FROMDATE>]
#   * url CIMBLbaseUrl
#   * def currentPath = 'classpath:CIMBL/Tests/getFixtures/'
#   * def validCimblHeader = read('classpath:CIMBL/Auth/' + authType + '.json')
#   * def query = read(currentPath + 'data/requests/' + <REQUESTFNAME> + '.txt')
#   * def expectedResponse = read(currentPath + 'data/responses/' + <RESPONSEFNAME> + '.json')
#   * print expectedResponse
#   * def tags = karate.tags
#   * configure abortedStepsShouldPass = true
#   * eval if (tags.contains('skip' + targetEnv)) {karate.abort()}
#   * eval if (!<EXECUTEONENVS>.contains(targetEnv)) {karate.abort()}
#   * replace query.FROMDATE = <FROMDATE>
#   * def setHeaderParams = { query: #(query), validCimblHeader: #(validCimblHeader) }
#   * def setHeaderResults = call read('classpath:CIMBL/utils/karate/setHeader.feature') setHeaderParams
#   Given configure headers = setHeaderResults.output
#   When request
#   """
#     {
#       query: #(query)
#     }
#   """
#   And method post
#   * print response
#   Then match <ASSERTCRUMB> == expectedResponse
#   And status <STATUSCODE>
# 

#   Examples:
#     | TESTID     | FROMDATE      | ASSERTCRUMB | REQUESTFNAME       | RESPONSEFNAME                       | STATUSCODE  | EXECUTEONENVS               |
#     | E2E-00006  | 'abcd-ef-gh'  | response    | 'fromDateOnly'     | 'fromDate/Errors/ErrInvalid'        | 200         | 'qa,staging,prod,prodGreen' |
#     | E2E-00010  | 'NOTREQUIRED' | response    | 'fromDateMissing'  | 'fromDate/Errors/ErrNotAvailable'   | 200         | 'qa,staging,prod,prodGreen' |
#     | E2E-00011  | 'NOTREQUIRED' | response    | 'unknownParameter' | 'fromDate/Errors/ErrFieldUndefined' | 200         | 'qa,staging,prod,prodGreen' |
#     | E2E-00013  | '"2020-06-04' | response    | 'fromDateOnly'     | 'fromDate/Errors/ErrSyntaxError'    | 400         | 'qa,staging,prod,prodGreen' |