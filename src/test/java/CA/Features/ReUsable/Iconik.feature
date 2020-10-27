Feature: Iconik functionalities

@GetRenditionHTTPInfo
Scenario: Get custom action list from Iconik
  * def getRenditionHTTPInfo =
    """
      function (resp) {
        var url = '';
        var respObjects = resp['objects'];
        for(var index in respObjects) {
          var actionSet = respObjects[index];
          if(actionSet['title'] == Iconik_CustomAction) {
            url = actionSet['url'];
            break;
          }
        }
        // SPLIT USERNAME AND PASSWORD
        var creds = url.split('\/\/')[1].split('@')[0];
        var username = creds.split(':')[0];
        var password = creds.split(':')[1];
        
        // SPLIT URL endpoint
        var protocol = url.split('\/\/')[0];
        var endpoint = url.split('\/\/')[1].split('@')[1];
        var finalResp = {
          URL: protocol + '//' + endpoint,
          username: username,
          password: password
        }
        return finalResp
      }
    """
  Given url URL
  And header Auth-Token = Auth_Token
  And header App-ID = App_ID
  When method get
  * print response
  Then def result = call getRenditionHTTPInfo response

@TriggerRendition
Scenario: Rendition
  * def formAuthHeader = 
    """
      function (creds) {
        var temp = creds.username + ':' + creds.password;
        var Base64 = Java.type('java.util.Base64');
        var encoded = Base64.getEncoder().encodeToString(temp.bytes);
        return 'Basic ' + encoded;
      }
    """
  Given url URL
  When header Auth-Token = Auth_Token
  And header App-ID = App_ID
  And header Authorization = call formAuthHeader IconikCredentials
  And request RenditionQuery
  And method post
  Then def result = karate.match('response contains RenditionExpectedResponse')