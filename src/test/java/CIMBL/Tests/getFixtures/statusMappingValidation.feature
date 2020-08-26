Feature:  getFixtures Status Mapping: Querying getFixtures to validate status mapping via contentfulConfig.js vs SMC response

# IMPORTANT NOTE
# THIS IS AN EXCEPTION FROM THE DATA-DRIVEN APPROACH DUE TO THE REASON THAT IT HAS TO DO A WHITEBOX TESTING
# BY CREATING A DYNAMIC EXPECTED RESPONSE BASED ON CONTENTFULCONFIG.JSON
# IF YOU ARE RUNNING THIS IN YOUR LOCAL MACHINE, MAKE SURE THAT YOU RUN gimme-aws-creds TO REFRESH YOUR CREDENTIALS
# AND MAKE SURE YOU ARE USING THE APPROPRIATE TENANT
# e.g.
# Dev and QA env - Dev Tenant
# Staging and Prod env - Prod Tenant

# [ TEST CODE ]
# @Regression
# Scenario: E2E-00018: Querying getFixtures to validate status mapping via contentfulConfig.js vs SMC response
#     When def result = karate.callSingle('classpath:CIMBL/Tests/E2E-00018/E2E-00018.feature')
#     Then match result.testStatus == 'pass'

Background:
  

@E2E @getFixtures @StatusMappingValidation @REWORK
Scenario Outline: <TESTID>: Querying getFixtures to validate status mapping via contentfulConfig.js vs SMC response [<LEAGUEID>]
  * def tags = karate.tags
  * configure abortedStepsShouldPass = true
  * eval if (tags.contains('skip' + targetEnv)) {karate.abort()}
  * eval if (!<EXECUTEONENVS>.contains(targetEnv)) {karate.abort()}
  # Step 1. Call SMC API for match information
  * configure headers = 
    """
      {
        "x-ibm-client-id": #(SMCAPIKey)
      }
    """
  * url SMCbaseUrl + <LEAGUEID> + '/matches'
  * method get
  * def transformSMCResponse = 
    """
      function(SMCResponse) {
        karate.log(SMCResponse);
        var thisResp = [];
          // var SMCResponse = eval('SMCResponse'+leagueIds[i]); 
        for(var index in SMCResponse) {
          var item = SMCResponse[index];
          if (item['kickoff'].contains(<FROMDATE>) || item['kickoff'].contains(<TODATE>)) {
            var resp = {
              date: item['kickoff'],
              id: item['match-id'].toString(),
              goal: item['goals-home'] + ' - ' + item['goals-away'],
              status: contentfulConfig['status'][item['status']]
            }
            thisResp.push(resp);
          }
        }
        return thisResp;
      }
    """
  # Step 2. Download contentfulConfig.json
  * def output = karate.callSingle('classpath:CIMBL/utils/karate/getContentfulConfig.feature')
  * print output
  * def contentfulConfig = read('classpath:CIMBL/downloads/contentfulConfig.json')
  # Step 3. Create expected response
  * def expectedResponse = call transformSMCResponse response
  * print expectedResponse
  # Step 4. Query CIMBL endpoint
  * url CIMBLbaseUrl
  * def currentPath = 'classpath:CIMBL/Tests/getFixtures/'
  * def validCimblHeader = read('classpath:CIMBL/Auth/' + authType + '.json')
  * def query = read(currentPath + 'data/requests/' + <REQUESTFNAME> + '.txt')
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
  And match expectedResponse contains response.data.getFixtures
  And match response.data.getFixtures contains expectedResponse
  And status <STATUSCODE>

  Examples:
    | TESTID      | LEAGUEID |  FROMDATE     | TODATE       | ASSERTCRUMB               | REQUESTFNAME      | RESPONSEFNAME   |  STATUSCODE  | EXECUTEONENVS               |
    | E2E-00018a  | '25'     |  '2020-06-14' | '2020-06-15' | response.data.getFixtures | 'statusMapping'   | 'NOTREQUIRED'   |  200         | 'qa,staging,prod,prodGreen' |
    | E2E-00018b  | '26'     |  '2020-06-16' | '2020-06-16' | response.data.getFixtures | 'statusMapping'   | 'NOTREQUIRED'   |  200         | 'qa,staging,prod,prodGreen' |