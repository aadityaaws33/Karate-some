Feature:  getFixtures DateFormats: Querying getFixtures with fromDate, toDate and leagueShortCode
 
@E2E @getFixtures @PositiveCases @REWORK
Scenario Outline: <TESTID>: Positive Cases - Querying getFixtures with fromDate, toDate and leagueShortCode [<FROMDATE> - <TODATE> - <LEAGUESHORTCODE>]
  * url CIMBLbaseUrl
  * def currentPath = 'classpath:CIMBL/Tests/getFixtures/'
  * def validCimblHeader = read('classpath:CIMBL/Auth/' + authType + '.json')
  * def query = read(currentPath + 'data/requests/' + <REQUESTFNAME> + '.txt')
  * def expectedResponse = read(currentPath + 'data/responses/' + <RESPONSEFNAME> + '.json')
  * print expectedResponse
  * def tags = karate.tags
  * configure abortedStepsShouldPass = true
  * eval if (tags.contains('skip' + targetEnv)) {karate.abort()}
  * eval if (!<EXECUTEONENVS>.contains(targetEnv)) {karate.abort()}
  * replace query.FROMDATE = <FROMDATE>
  * replace query.TODATE = <TODATE>
  * replace query.LEAGUESHORTCODE = <LEAGUESHORTCODE>
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
  Then match expectedResponse.data.getFixtures contains <ASSERTCRUMB>
  And status <STATUSCODE>


  Examples:
    | TESTID         | FROMDATE     | TODATE        | LEAGUESHORTCODE   | ASSERTCRUMB               | REQUESTFNAME      | RESPONSEFNAME                            |  STATUSCODE  | EXECUTEONENVS               |
    | E2E-00071a     | '2020-09-11' | '2020-09-13'  | '[ASE]'           | response.data.getFixtures | 'leagueShortCode' | 'leagueShortCode/Positive/' + targetEnv  |  200         | 'qa,staging,prod,prodGreen' |
    | E2E-00071b     | '2020-09-11' | '2020-09-13'  | '[SET]'           | response.data.getFixtures | 'leagueShortCode' | 'leagueShortCode/Positive/' + targetEnv  |  200         | 'qa,staging,prod,prodGreen' |
    | E2E-00072      | '2020-09-11' | '2020-09-13'  | '[]'              | response.data.getFixtures | 'leagueShortCode' | 'leagueShortCode/Errors/blankLeagueShortCode'    |  200         | 'qa,staging,prod,prodGreen' |
    | E2E-00078      | '2020-09-11' | '2020-09-13'  | '[ASE,SET,SLG]'   | response.data.getFixtures | 'leagueShortCode' | 'leagueShortCode/Positive/' + targetEnv  |  200         | 'qa,staging,prod,prodGreen' |
    | E2E-00079      | '2020-09-11' | '2020-09-13'  | '[SLG]'           | response.data.getFixtures | 'leagueShortCode' | 'leagueShortCode/Positive/' + targetEnv  |  200         | 'qa,staging,prod,prodGreen' |

@E2E @getFixtures @ErrorCases @REWORK
Scenario Outline: <TESTID>: Error Cases - Querying getFixtures with fromDate, toDate and leagueShortCode [<FROMDATE> - <TODATE> - <LEAGUESHORTCODE>]
  * url CIMBLbaseUrl
  * def currentPath = 'classpath:CIMBL/Tests/getFixtures/'
  * def validCimblHeader = read('classpath:CIMBL/Auth/' + authType + '.json')
  * def query = read(currentPath + 'data/requests/' + <REQUESTFNAME> + '.txt')
  * def expectedResponse = read(currentPath + 'data/responses/' + <RESPONSEFNAME> + '.json')
  * print expectedResponse
  * def tags = karate.tags
  * configure abortedStepsShouldPass = true
  * eval if (tags.contains('skip' + targetEnv)) {karate.abort()}
  * eval if (!<EXECUTEONENVS>.contains(targetEnv)) {karate.abort()}
  * replace query.FROMDATE = <FROMDATE>
  * replace query.TODATE = <TODATE>
  * replace query.LEAGUESHORTCODE = <LEAGUESHORTCODE>
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
  Then match <ASSERTCRUMB> == expectedResponse
  And status <STATUSCODE>


  Examples:
    | TESTID         | FROMDATE     | TODATE        | LEAGUESHORTCODE                             | ASSERTCRUMB    | REQUESTFNAME      | RESPONSEFNAME                                    |  STATUSCODE  | EXECUTEONENVS               |
    | E2E-00073      | '2020-09-11' | '2020-09-13'  | '"SET"'                                     | response       | 'leagueShortCode' | 'leagueShortCode/Errors/ErrValidationError'      |  200         | 'qa,staging,prod,prodGreen' |
    | E2E-00074      | '2020-09-11' | '2020-09-13'  | '[NONEXISTENT]'                             | response       | 'leagueShortCode' | 'leagueShortCode/Errors/ErrNonExistent'          |  200         | 'qa,staging,prod,prodGreen' |
    | E2E-00078      | '2099-09-11' | '2099-09-13'  | '[SLG],filter: {team : {id: {eq: 7973}}}'   | response       | 'leagueShortCode' | 'leagueShortCode/Errors/ErrNoFixturesAvailable'  |  200         | 'qa,staging,prod,prodGreen' |
    | E2E-00075/80   | '2099-09-11' | '2099-09-13'  | '[SLG]'                                     | response       | 'leagueShortCode' | 'leagueShortCode/Errors/ErrNoFixturesAvailable'  |  200         | 'qa,staging,prod,prodGreen' |
    | E2E-00081      | '2099-09-11' | '2099-09-13'  | '[ASE,SET,SLG]'                             | response       | 'leagueShortCode' | 'leagueShortCode/Errors/ErrNoFixturesAvailable'  |  200         | 'qa,staging,prod,prodGreen' |