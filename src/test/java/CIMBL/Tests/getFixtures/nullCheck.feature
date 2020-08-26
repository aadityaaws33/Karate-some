Feature:  getFixtures DateFormats: Querying getFixtures with fromDate and toDate
 
@E2E @getFixtures @NullFieldCheck @REWORK
Scenario Outline: <TESTID>: Positive Cases - Querying getFixtures with fromDate and toDate NO NULL FIELDS [<FROMDATE> - <TODATE>]
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
  Then match each <ASSERTCRUMB> == expectedResponse
  And status <STATUSCODE>


  Examples:
    | TESTID      | FROMDATE     | TODATE       | ASSERTCRUMB                               | REQUESTFNAME         | RESPONSEFNAME                  |  STATUSCODE  | EXECUTEONENVS               |
    | E2E-00008a  | '2020-06-14' | '2020-06-15' | response.data.getFixtures                 | 'nullCheckNoTeams'   | 'nullCheck/nullCheckNoTeams'   |  200         | 'qa,staging,prod,prodGreen' |
    | E2E-00008b  | '2020-06-14' | '2020-06-15' | response.data.getFixtures[0].league.teams | 'nullCheckWithTeams' | 'nullCheck/nullCheckWithTeams' |  200         | 'qa,staging,prod,prodGreen' |

