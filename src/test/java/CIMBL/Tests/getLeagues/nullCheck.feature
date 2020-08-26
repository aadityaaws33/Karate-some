Feature:  getLeagues: Querying getLeagues with league Ids
 
@E2E @getLeagues @NullFieldCheck @REWORK
Scenario Outline: <TESTID>: Positive Cases - Querying getLeagues with league Ids NO NULL FIELDS [<LEAGUEID>]
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
  Then match each <ASSERTCRUMB> == expectedResponse
  And status <STATUSCODE>


  Examples:
    | TESTID      | LEAGUEID  | ASSERTCRUMB                        | REQUESTFNAME             | RESPONSEFNAME                   | STATUSCODE  | EXECUTEONENVS               |
    | E2E-00015a  | 25        | response.data.getLeagues           | 'leagueIdNoTeams'        | 'nullCheck/nullCheckNoTeams'    | 200         | 'qa,staging,prod,prodGreen' |
    | E2E-00015b  | 26        | response.data.getLeagues[0].teams  | 'leagueIdWithTeams'      | 'nullCheck/nullCheckWithTeams'  | 200         | 'qa,staging,prod,prodGreen' |
    | E2E-00015c  | 'null'    | response.data.getLeagues           | 'leagueIdNoTeams'        | 'nullCheck/nullCheckNoTeams'    | 200         | 'qa,staging,prod,prodGreen' |

