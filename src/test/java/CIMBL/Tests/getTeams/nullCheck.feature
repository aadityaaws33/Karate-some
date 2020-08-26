Feature:  getTeams: Querying getTeams with league Ids
 
@E2E @getTeams @NullFieldCheck @REWORK
Scenario Outline: <TESTID>: Positive Cases - Querying getTeams with league Ids NO NULL FIELDS [<LEAGUEID>]
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
  Then match each <ASSERTCRUMB> == expectedResponse
  And status <STATUSCODE>


  Examples:
    | TESTID      | LEAGUEID  | ASSERTCRUMB            | REQUESTFNAME    | RESPONSEFNAME          | STATUSCODE  | EXECUTEONENVS               |
    | E2E-00017a  | 25        | response.data.getTeams | 'leagueId'      | 'nullCheck/nullCheck'  | 200         | 'qa,staging,prod,prodGreen' |
    | E2E-00017b  | 26        | response.data.getTeams | 'leagueId'      | 'nullCheck/nullCheck'  | 200         | 'qa,staging,prod,prodGreen' |

