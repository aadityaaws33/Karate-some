@parallel=false
Feature:  Update Episode

Background: 
  * url URL
  * header Auth-Token = Iconik_AuthToken
  * header App-ID = Iconik_AppID
  * request Query
  * method put

@DPLAY
Scenario: Update Episode: Check null fields and specific metadata_values
  * print response
  * def getMatchResult = 
    """
      function() {
        var matchRes = karate.match('response contains ExpectedResponse');
        if(!matchRes['pass']) {
          karate.log('Initial matching failed');
          for(var key in response) {
            var thisRes = '';
            expectedValue = ExpectedResponse[key];
            actualValue = response[key];
            if(key == 'metadata_values') {
              for(var videoUpdatesKey in actualValue) {
                actualVideoField = actualValue[videoUpdatesKey];
                expectedVideoField = expectedValue[videoUpdatesKey];
                thisRes = karate.match('actualVideoField contains expectedVideoField');
                karate.log(key + '[' + videoUpdatesKey + ']: ' + thisRes);
                if(!thisRes['pass']) {
                  break;
                }
              }
            } else {
              thisRes = karate.match('actualValue contains expectedValue');
            }
            karate.log(key + ': ' + thisRes);
            matchRes = thisRes;
            if(!matchRes['pass']) {
              break;
            }
          }
        }
        return matchRes;
      }
    """
  * def result = call getMatchResult
  * print result