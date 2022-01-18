Feature: Iconik functionalities

Background:
  * def thisFile = 'classpath:CA/Features/ReUsable/Methods/Iconik.feature'

@GetRenditionHTTPInfo @report=false
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
  Then def result = call getRenditionHTTPInfo response

@GetAppTokenInfo @report=false
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
  Then def result = call getAppTokenInfo response

@TriggerRendition
Scenario: Rendition
  Given url URL
  When header Auth-Token = Iconik_AuthToken
  And header App-ID = Iconik_AppID
  And request RenditionRequestPayload
  And method post
  Then def matchResult = karate.match('response contains RenditionExpectedResponse')
  And def result =
    """
      {
        "response": #(response),
        "message": #(matchResult.message),
        "pass": #(matchResult.pass)
      }
    """

@RenameAsset
Scenario: Rename Asset
  Given url URL
  When header Auth-Token = Iconik_AuthToken
  And header App-ID = Iconik_AppID
  And request UpdateAssetNamePayload
  And method put
  Then status 200

@UpdateAssetMetadata
Scenario: Update AssetMetadata & validate response
  * url URL
  * header Auth-Token = Iconik_AuthToken
  * header App-ID = Iconik_AppID
  * request Query
  * method put
  # * print response
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
  # * print result

@ExecuteHTTPRequest
Scenario: Execute an HTTP request to Iconik
  Given url thisURL
  And header Auth-Token = Iconik_AuthToken
  And header App-ID = Iconik_AppID
  When request thisQuery
  And method thisMethod
  Then assert responseStatus == thisStatus
  * def result = response

@GetAssetData
Scenario: Get Asset Data
  * def GetAssetDataParams = 
    """
      {
        thisURL: #(URL),
        thisQuery: #(Query),
        thisMethod: get,
        thisStatus: 200
      }
    """
  * def resp = call read(thisFile + '@ExecuteHTTPRequest') GetAssetDataParams
  * def result = resp.result

@SearchForAssets
Scenario: Search for Assets
  * def SearchForAssetParams = 
    """
      {
        thisURL: #(URL),
        thisQuery: #(Query),
        thisMethod: post,
        thisStatus: 200
      }
    """
  * def resp = call read(thisFile + '@ExecuteHTTPRequest') SearchForAssetParams
  * def result = resp.result

@DeleteAsset
Scenario: Delete Asset
  * def DeleteAssetParams = 
    """
      {
        thisURL: #(URL),
        thisQuery: #(Query),
        thisMethod: post,
        thisStatus: 204
      }
    """
  * def resp = call read(thisFile + '@ExecuteHTTPRequest') DeleteAssetParams
  * def result = resp.result

@GetAssetACL
Scenario: Get Asset User Group ACL
  * def GetAssetACLParams =
    """
      {
        thisURL: #(URL),
        thisQuery: null,
        thisMethod: get,
        thisStatus: 200
      }
    """
  * def resp = call read(thisFile + '@ExecuteHTTPRequest') GetAssetACLParams
  * def result = resp.result

@ValidatePlaceholderExists
Scenario: Check if placeholder exists
  * def GetAssetDataParams =
    """
      {
        URL: #(GetAssetDataURL)
      }
    """
  * def AssetData = call read(FeatureFilePath + '/Iconik.feature@GetAssetData') GetAssetDataParams
  # * print AssetData.result
  * def result = karate.match('AssetData.result contains ExpectedAssetData')
  * print result

@ValidateACLExists
Scenario: Check if ACL exists in an assetId
  * def GetAssetsUserGroupACLParams = 
    """
      {
        URL: #(GetAssetACLURL),
      }
    """
  * def AssetACL = call read(FeatureFilePath + '/Iconik.feature@GetAssetACL') GetAssetsUserGroupACLParams
  * def result = karate.match('AssetACL.result contains ExpectedAssetACL')
  * print result