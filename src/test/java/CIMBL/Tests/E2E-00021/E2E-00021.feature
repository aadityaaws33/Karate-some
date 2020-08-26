Feature:  E2E-00021: Querying getFixtures with a valid team filter

# [ TEST CODE ]
# @Regression
# Scenario: E2E-00021: Querying getFixtures with a valid team filter
#     When def result = karate.callSingle('classpath:CIMBL/Tests/E2E-00021/E2E-00021.feature')
#     Then match result.testStatus == 'pass'

Background:
  * url CIMBLbaseUrl
  * def currentPath = 'classpath:CIMBL/Tests/E2E-00021/'
  * def validCimblHeader = read('classpath:CIMBL/Auth/' + authType + '.json')
  * def query = read(currentPath + 'data/requests/request.txt')
  * def expectedResponse = read(currentPath + 'data/responses/' + targetEnv + '.json')
  * print expectedResponse
  * def setHeaderParams = { query: #(query), validCimblHeader: #(validCimblHeader) }
  * def setHeaderResults = call read('classpath:CIMBL/utils/karate/setHeader.feature') setHeaderParams

@E2E @E2E-00021
Scenario: E2E-00021: Querying getFixtures with a valid team filter
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
  Then match response.data.getFixtures contains expectedResponse.data.getFixtures
  And match expectedResponse.data.getFixtures contains response.data.getFixtures
  And status 200
