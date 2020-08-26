Feature:  getFixtures DateFormats: Querying getFixtures with fromDate and toDate
 
@E2E @getFixtures @PositiveCases @REWORK
Scenario Outline: <TESTID>: Positive Cases - Querying getFixtures with fromDate and toDate [<FROMDATE> - <TODATE>]
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
  Then match <ASSERTCRUMB> contains expectedResponse.data.getFixtures
  And match expectedResponse.data.getFixtures contains <ASSERTCRUMB>
  And status <STATUSCODE>


  Examples:
    | TESTID        | FROMDATE                    | ASSERTCRUMB               | TODATE                     | REQUESTFNAME      | RESPONSEFNAME                            |  STATUSCODE  | EXECUTEONENVS               |
    | E2E-00001     | '2020-06-14'                | response.data.getFixtures | '2020-06-15'               | 'fromDate-toDate' | 'fromDate-toDate/Positive/' + targetEnv  |  200         | 'qa,staging,prod,prodGreen' |
    | E2E-00002     | '2020/06/14'                | response.data.getFixtures | '2020/06/15'               | 'fromDate-toDate' | 'fromDate-toDate/Positive/' + targetEnv  |  200         | 'qa,staging,prod,prodGreen' |
    | E2E-00003     | '2020-06-14T23:59:59.000Z'  | response.data.getFixtures | '2020-06-15T23:59:59.000Z' | 'fromDate-toDate' | 'fromDate-toDate/Positive/' + targetEnv  |  200         | 'qa,staging,prod,prodGreen' |
    | E2E-00004     | '2020-06-14'                | response.data.getFixtures | '2020-06-15T23:59:59.000Z' | 'fromDate-toDate' | 'fromDate-toDate/Positive/' + targetEnv  |  200         | 'qa,staging,prod,prodGreen' |

@E2E @getFixtures @ErrorCases @REWORK
Scenario Outline: <TESTID>: Error Cases - Querying getFixtures with fromDate and toDate [<FROMDATE> - <TODATE>]
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
    | TESTID        | FROMDATE      | TODATE       | ASSERTCRUMB | REQUESTFNAME                     | STATUSCODE  | RESPONSEFNAME                                 | EXECUTEONENVS               |
    | E2E-00007     | '2020-04-04'  | 'abcd-ef-gh' | response    | 'fromDate-toDate'                | 200         | 'fromDate-toDate/Errors/ErrInvalid'           | 'qa,staging,prod,prodGreen' |
    | E2E-00009     | '2099-04-06'  | '2099-04-07' | response    | 'fromDate-toDate'                | 200         | 'fromDate-toDate/Errors/ErrNoSched'           | 'qa,staging,prod,prodGreen' |
    | E2E-00012     | '2020-04-06'  | '2020-04-07' | response    | 'fromDate-toDate-noSubselection' | 200         | 'fromDate-toDate/Errors/ErrNoSubselection'    | 'qa,staging,prod,prodGreen' |