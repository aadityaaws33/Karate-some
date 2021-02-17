Feature: Iconik functionalities

@GetRenditionHTTPInfo
Scenario: Get Rendition URL from custom action list via Iconik API
  * def getRenditionHTTPInfo =
    """
      function (resp) {
        var url = '';
        var respObjects = resp['objects'];
        for(var index in respObjects) {
          var actionSet = respObjects[index];
          if(actionSet['id'] == Iconik_TriggerRenditionCustomActionID) {
            url = actionSet['url'];
            break;
          }
        }
        var finalResp = {
          URL: url
        }
        return finalResp
      }
    """
  Given url URL
  And header Auth-Token = Iconik_AuthToken
  And header App-ID = Iconik_AppID
  When method get
  * print response
  Then def result = call getRenditionHTTPInfo response

@GetAppTokenInfo
Scenario: Get Authentication Token from Application Token via Iconik API
  * def getAppTokenInfo =
    """
      function (resp) {
        var finalResp = {
          Iconik_AuthToken: resp['token'],
          Iconik_AppID: resp['app_id']
        }
        return finalResp
      }
    """
  Given url URL
  And header Content-Type = 'application/json'
  And request GetAppTokenInfoPayload
  When method post
  * print response
  Then def result = call getAppTokenInfo response

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
  When header Auth-Token = Iconik_AuthToken
  And header App-ID = Iconik_AppID
  # And header Authorization = call formAuthHeader IconikCredentials
  And request RenditionRequestPayload
  And method post
  Then def result = karate.match('response contains RenditionExpectedResponse')