Feature: Rendition

Background: 
  * url URL
  * header Auth-Token = Auth_Token
  * header App-ID = App_ID
  * def formAuthHeader = 
    """
      function (creds) {
        var temp = creds.username + ':' + creds.password;
        var Base64 = Java.type('java.util.Base64');
        var encoded = Base64.getEncoder().encodeToString(temp.bytes);
        return 'Basic ' + encoded;
      }
    """
  * header Authorization = call formAuthHeader IconikCredentials
Scenario: Rendition
#* print '--------------Season Request-----------'+RenditionQuery
When request RenditionQuery
And method post
Then def result = karate.match('response contains RenditionExpectedResponse')

