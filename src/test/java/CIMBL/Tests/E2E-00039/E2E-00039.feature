Feature:  E2E-00039: Querying getFixtures with a combination of filters where team.id.eq is valid and league.id.eq is a non-existing id

# [ TEST CODE ]
# @Regression
# Scenario: E2E-00039: Querying getFixtures with a combination of filters where team.id.eq is valid and league.id.eq is a non-existing id
#     When def result = karate.callSingle('classpath:CIMBL/Tests/E2E-00039/E2E-00039.feature')
#     Then match result.testStatus == 'pass'

Background:
  * url CIMBLbaseUrl
  * def currentPath = 'classpath:CIMBL/Tests/E2E-00039/'
  * def validCimblHeader = read('classpath:CIMBL/Auth/' + authType + '.json')
  * def query = read(currentPath + 'data/requests/request.txt')
  * def expectedResponse = read(currentPath + 'data/responses/' + targetEnv + '.json')
  * print expectedResponse
  * def setHeaderParams = { query: #(query), validCimblHeader: #(validCimblHeader) }
  * def setHeaderResults = call read('classpath:CIMBL/utils/karate/setHeader.feature') setHeaderParams

@E2E @E2E-00039
Scenario: E2E-00039: Querying getFixtures with a combination of filters where team.id.eq is valid and league.id.eq is a non-existing id
  * def tags = karate.tags
  * configure abortedStepsShouldPass = true
  * eval if (tags.contains('skip' + targetEnv)) {karate.abort()}
  Given configure headers = setHeaderResults.output
  When request
  """
    {
      query: #(query)
    }
  """
  And method post
  * print response
  Then match response == expectedResponse
  And status 200
