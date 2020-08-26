Feature:  E2E-00050: Querying getFixtures with an unauthorized token

# [ TEST CODE ]
# @Regression
# Scenario: E2E-00050: Querying getFixtures with an unauthorized token
#     When def result = karate.callSingle('classpath:CIMBL/Tests/E2E-00050/E2E-00050.feature')
#     Then match result.testStatus == 'pass'

Background:
  * url CIMBLbaseUrl
  * def currentPath = 'classpath:CIMBL/Tests/E2E-00050/'
  * def validCimblHeader = read('classpath:CIMBL/Auth/' + authType + '.json')
  * def query = read(currentPath + 'data/requests/request.txt')
  * def expectedResponse = read(currentPath + 'data/responses/' + targetEnv + '.json')
  * print expectedResponse
  * def setHeaderParams = { query: #(query), validCimblHeader: #(validCimblHeader) }
  * def setHeaderResults = call read('classpath:CIMBL/utils/karate/setHeader.feature') setHeaderParams

@E2E @E2E-00050
Scenario: E2E-00050: Querying getFixtures with an unauthorized token
  * def tags = karate.tags
  * configure abortedStepsShouldPass = true
  * eval if (tags.contains('skip' + targetEnv)) {karate.abort()}
  Given configure headers =
  """
    {
      x-api-key: "invalid api key"
    }
  """
  When request
  """
    {
      query: #(query)
    }
  """
  And method post
  * print response
  Then match response == expectedResponse
  And status 401
