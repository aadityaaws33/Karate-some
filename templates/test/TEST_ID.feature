Feature:  TEST_ID: DESCRIPTION

# [ TEST CODE ]
# @Regression
# Scenario: TEST_ID: DESCRIPTION
#     When def result = karate.callSingle('classpath:CIMBL/Tests/TEST_ID/TEST_ID.feature')
#     Then match result.testStatus == 'pass'

Background:
  * url CIMBLbaseUrl
  * def currentPath = 'classpath:CIMBL/Tests/TEST_ID/'
  * def validCimblHeader = read('classpath:CIMBL/Auth/' + authType + '.json')
  * def query = read(currentPath + 'data/requests/request.txt')
  * def expectedResponse = read(currentPath + 'data/responses/' + targetEnv + '.json')
  * print expectedResponse
  * def setHeaderParams = { query: #(query), validCimblHeader: #(validCimblHeader) }
  * def setHeaderResults = call read('classpath:CIMBL/utils/karate/setHeader.feature') setHeaderParams

@E2E @TEST_ID
Scenario: TEST_ID: DESCRIPTION
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
  # POSITIVE CASES
  # Then match response.data.getFixtures contains expectedResponse.data.getFixtures
  # And match expectedResponse.data.getFixtures contains response.data.getFixtures
  # ERROR HANDLING CASES
  # Then match response == expectedResponse
  And status 200
