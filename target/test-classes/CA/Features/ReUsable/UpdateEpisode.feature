Feature:  Update Episode

Background: 
* url UpdateEpisodeURL
* header Auth-Token = Auth_Token
* header App-ID = App_ID
@DPLAY
Scenario: Modular Update Season
    * print '--------------Episode Request-----------'+EpisodeQuery
    When request EpisodeQuery
    And method put
    * print '----------Episode Response------------->'+EpisodeExpectedResponse
    Then status 200
    And match response == EpisodeExpectedResponse
    And match karate.jsonPath(response,"$.metadata_values['no-dplay-CalloutText-multi'].field_values[0].value") == RandomText
    And match karate.jsonPath(response,"$.metadata_values['no-dplay-CtaText-multi'].field_values[0].value") == RandomText

   