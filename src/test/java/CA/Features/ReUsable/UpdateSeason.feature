Feature:  Update Season

Background: 
* url UpdateSeasonURL
* header Auth-Token = Auth_Token
* header App-ID = App_ID
* def evalResp = 
  """
    function(respObject) {
      var result = 'Fail';
      if(karate.match(respObject, SeasonExpectedResponse)) {
        result = 'Pass';
      }
      return result;
    }
  """
@DPLAY
Scenario: Modular Update Season
#* print '--------------Season Request-----------'+SeasonQuery
When request SeasonQuery
And method put
#* print '----------Season Response------------->'+SeasonExpectedResponse
Then def result = call evalResp response

