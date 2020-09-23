Feature:  Update Episode

Background: 
* url UpdateEpisodeURL
* header Auth-Token = Auth_Token
* header App-ID = App_ID
* def evalResp = 
  """
    function(respObject) {
      var result = 'Pass';
      var actualCalloutText = karate.jsonPath(response,"$.metadata_values['no-dplay-CalloutText-multi'].field_values[0].value");
      var actualCTA = karate.jsonPath(response,"$.metadata_values['no-dplay-CtaText-multi'].field_values[0].value");
      if(
        !karate.match(response, EpisodeExpectedResponse) ||
        !karate.match(actualCalloutText, ExpectedCalloutText) ||
        !karate.match(actualCTA, ExpectedCTA)
      ) {
        result = 'Fail';
      }
      return result;
    }
  """
@DPLAY
Scenario: Modular Update Season
    * def result = 'Pass'
    * print '--------------Episode Request-----------'+EpisodeQuery
    When request EpisodeQuery
    And method put
    * print '----------Episode Response------------->'+EpisodeExpectedResponse
    Then status 200
    And def result = call evalResp response
    # And match response == EpisodeExpectedResponse
    # And match karate.jsonPath(response,"$.metadata_values['no-dplay-CalloutText-multi'].field_values[0].value") == ExpectedCalloutText
    # And match karate.jsonPath(response,"$.metadata_values['no-dplay-CtaText-multi'].field_values[0].value") == ExpectedCTA

   