@APIRegression @parallel=false  
Feature:  CA AppSync GraphQL Query: getCountries

Background:
  # PREPROD and PROD ENVs are not ready
  * configure abortedStepsShouldPass = true
  * eval if (TargetEnv.contains('preprod') || TargetEnv.contains('prod')) { karate.log(TargetEnv + ' is not yet ready.'); karate.abort()}
  # ---------
  * def apiName = 'getCountries'
  # Paths
  * def currentTCPath = 'classpath:CA/TestData/APICases/' + apiName
  * def FeatureFilePath = 'classpath:CA/Features/ReUsable'
  # End
  * def appSyncURL = EnvData['AppSync']['URL']
  * def apiKey = EnvData['AppSync']['X-Api-Key']
  * def ExpectedResponse = read(currentTCPath + '/response.json')
  * def HTTPRequest = read(currentTCPath + '/request.json')
  * def HTTPHeaders =
    """
      {
        'Content-Type': 'application/json',
        'X-Api-Key': #(apiKey)
      }
    """

Scenario: CA-BE-00001 getCountries is queried and gives correct response
  * print appSyncURL
  * print apiKey
  Given url appSyncURL
  And headers HTTPHeaders
  When request HTTPRequest
  And method post
  # * print response
  Then match response == ExpectedResponse