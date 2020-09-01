Feature:  Update Season

Background: 
* url UpdateSeasonURL
* header Auth-Token = Auth_Token
* header App-ID = App_ID
 
@DPLAY
Scenario: Modular Update Season
* print '--------------Season Request-----------'+SeasonQuery
When request SeasonQuery
And method put
* print '----------Season Response------------->'+SeasonExpectedResponse
Then status 200
And match response contains SeasonExpectedResponse
And match karate.jsonPath(response,"$.metadata_values.no-dplay-SeriesTitle.field_values[0].value") == ExpectedSeriesTitle

