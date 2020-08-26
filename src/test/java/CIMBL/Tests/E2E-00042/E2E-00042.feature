Feature:  E2E-00042: Querying getLeagueStandings should return correct league standings
          SKIPPED: until bold.dk fixtures are updated correctly
# IMPORTANT NOTE
# THIS IS AN EXCEPTION FROM THE DATA-DRIVEN APPROACH DUE TO THE REASON THAT IT HAS TO DO A WHITEBOX TESTING
# BY CREATING A DYNAMIC EXPECTED RESPONSE BASED ON CONTENTFULCONFIG.JSON and SMCAPI's TEAMS and LEAGUE STANDINGS
# IF YOU ARE RUNNING THIS IN YOUR LOCAL MACHINE, MAKE SURE THAT YOU RUN gimme-aws-creds TO REFRESH YOUR CREDENTIALS
# AND MAKE SURE YOU ARE USING THE APPROPRIATE TENANT
# e.g.
# Dev and QA env - Dev Tenant
# Staging and Prod env - Prod Tenant

# [ TEST CODE ]
# @Regression
# Scenario: E2E-00042: Querying getLeagueStandings should return correct league standings
#     When def result = karate.callSingle('classpath:CIMBL/Tests/E2E-00042/E2E-00042.feature')
#     Then match result.testStatus == 'pass'

Background:
  # FUNCTION DEFINITIONS:
  * def transformSMCResponse = 
    """
      function(smcResponse) {
        var teams = smcResponse['teams']['team'];
        var standings = smcResponse['standings'];
        var contentfulConfigTeams = contentfulConfig['teams'];
        var thisResp = [];
        for(var i in standings){
          for(var j in teams) {
            if(standings[i]['teamId'] == teams[j]['team-id']) {
              standings[i]['external-id'] = teams[j]['external-id'];
              break
            }
          }
        }
        for(var index in standings) {
          var item = standings[index];
          var cimblTeamName = contentfulConfigTeams[item['external-id']][1];
          karate.log(item['team-name'] + ' vs ' + cimblTeamName);
          var resp = {
            goalsDifference: item['goal-differential'],
            goalsFor: item['goals-scored'],
            lost: item['losses'],
            won: item['wins'],
            position: item['position'],
            id: item['teamId'].toString(),
            team: {
              name: cimblTeamName
            },
            drawn: item['draws'],
            goalsAgainst: item['goals-conceded'],
            played: item['games-played'],
            points: item['points'],
          };
          thisResp.push(resp);
        };
        return thisResp;
      }
    """
  # Step 1: Download and read contentfulConfig.json
  * karate.callSingle('classpath:CIMBL/utils/karate/getContentfulConfig.feature')
  * def contentfulConfig = read('classpath:CIMBL/downloads/contentfulConfig.json')
  * def currentPath = 'classpath:CIMBL/Tests/E2E-00042/'
  * def validCimblHeader = read('classpath:CIMBL/Auth/' + authType + '.json')
  * def query = read(currentPath + 'data/requests/request.txt')  

@E2E @E2E-00042
Scenario Outline: E2E-00042: Querying getLeagueStandings should return correct league standings (league Id: <LEAGUEID>)
  * print targetEnv
  * def tags = karate.tags
  * configure abortedStepsShouldPass = true
  * eval if (tags.contains('skip' + targetEnv)) {karate.abort()}
  # Step 2: get league standings from SMC API
  * configure headers = 
    """
      {
        "x-ibm-client-id": #(SMCAPIKey)
      }
    """
  * url SMCbaseUrl + <LEAGUEID> + '/standings'
  * method get
  * def standings = response
  # Step 3: get teams data from SMC API
  * url SMCbaseUrl + <LEAGUEID> + '/teams'
  * method get
  * def teams = response
  * def smcResponse = 
    """
      {
        standings: #(standings),
        teams: #(teams)
      }
    """
  # Step 4: Generate expected response dynamically
  * def expectedResponse = call transformSMCResponse smcResponse
  * print expectedResponse
  # Step 5: Get CIMBL's actual response for getLeagueStanding
  * replace query.LEAGUEID = <LEAGUEID>
  * url CIMBLbaseUrl
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
  # Step 6: Do the assertions
  And match expectedResponse contains response.data.getLeaguesStandings
  And match response.data.getLeaguesStandings contains expectedResponse
  And status 200
  * def testStatus = 'pass'
  
  Examples:
  | LEAGUEID   |
  | '25'       |
  | '26'       |