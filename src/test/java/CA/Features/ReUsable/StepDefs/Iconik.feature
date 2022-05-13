Feature: Iconik functionalities

Background:
    * def thisFile = 'classpath:CA/Features/ReUsable/StepDefs/Iconik.feature'

@GetAppTokenData
Scenario: Get Authentication Token from Application Token via Iconik API
    * def getAppTokenData =
        """
        function (resp) {
            var finalResp = {
                AuthToken: resp['token'],
                AppID: resp['app_id']
            }
            return finalResp
        }
        """
    * def GetAppTokenDataPayload =
        """
        {
            app_name: #(IconikConfig.AppTokenName),
            email: #(IconikConfig.AdminEmail),
            password: #(IconikConfig.AdminPassword)
        }
        """
    Given url IconikConfig.URL.GetAppTokenAPI
    And header Content-Type = 'application/json'
    And request GetAppTokenDataPayload
    When method post
    And def result = getAppTokenData(response)
    Then assert result.error == null

@GetCustomActionData
Scenario: Get Custom Action Data
    * def GetCustomActionDataParams = 
        """
            {
                thisURL: #(URL),
                thisQuery: null,
                thisMethod: get,
                thisStatus: 200,
                IconikAuthToken: #(IconikAuthToken),
                IconikAppID: #(IconikAppID)
            }
        """
    * def getCustomActionData =
        """
            function(GetCustomActionDataParams, CustomActionTitle) {
                var customActionData = karate.call(thisFile + '@ExecuteHTTPRequest', GetCustomActionDataParams).result;
                if(customActionData.pass == false) {
                    return customActionData
                }
                var thisPath = "$.*.*[?(@.title contains '" + CustomActionTitle + "')]";
                var thisCustomActionData = karate.jsonPath(customActionData.response, thisPath)[0];
                customActionData.response = thisCustomActionData
                return customActionData
            }
        """
    * def result = getCustomActionData(GetCustomActionDataParams, CustomActionTitle)

@SearchForAssetData
Scenario: Search for Asset Data
    * def ThisQuery = 
        """
            {
                query: "#(IconikMetadata.IconikSourceAssetName)",
                doc_types: [
                    "assets"
                ],
                filter: {
                    operator: "AND",
                    terms: [
                        {
                            name: "status",
                            value: "ACTIVE"
                        }
                    ]
                },
                facets_filters: [],
                search_fields: [
                    "title",
                ],
                include_fields: [
                    "id",
                    "status",
                    "files",
                    "title"
                ],
                facets: [],
                sort: [
                    {
                        "name": "date_created",
                        "order": "desc"
                    }
                ]
            }
        """
    * def GetSearchAssetDataParams = 
        """
            {
                thisURL: #(URL),
                thisQuery: #(ThisQuery),
                thisMethod: post,
                thisStatus: 200,
                IconikAuthToken: #(IconikAuthToken),
                IconikAppID: #(IconikAppID)
            }
        """
    * def getSearchAssetData =
        """
            function(GetSearchAssetDataParams, IconikMetadata) {
                var thisSearchAssetData = null;
                var thisPage = '/v1/search/?page=1&per_page=150';
                while(true) {
                    karate.log(GetSearchAssetDataParams);
                    thisSearchAssetData = karate.call(thisFile + '@ExecuteHTTPRequest', GetSearchAssetDataParams).result;
                    if(thisSearchAssetData.pass == false) {
                        return thisSearchAssetData;
                    }
                    var thisPath = "$.objects[?(@.title == \"" + IconikMetadata.IconikSourceAssetName + "\")]";
                    var thisFilteredAssetData = karate.jsonPath(thisSearchAssetData.response, thisPath);
                    // var thisPath = "$.[?(@.files[0].directory_path contains \"" + IconikMetadata.IconikMediaType + \""')]";
                    // var thisPath = "$.*.files[?(@.directory_path contains \"" + IconikMetadata.IconikMediaType + "\")]";
                    
                    if(thisFilteredAssetData.length == 0) {
                        if(thisSearchAssetData.response.next_url != null) {
                            GetSearchAssetDataParams.thisURL = GetSearchAssetDataParams.thisURL.split('/API/search/v1')[0] + thisSearchAssetData.response.next_url;
                        } else {
                            thisSearchAssetData.response = thisFilteredAssetData;
                            return thisSearchAssetData;
                        }
                    } else {
                        thisSearchAssetData.response = thisFilteredAssetData[0];
                        return thisSearchAssetData
                    }
                    Pause(1000);
                }

            }
        """
    * def result = getSearchAssetData(GetSearchAssetDataParams, IconikMetadata)

@SearchForAssetIDList
Scenario: Search for Asset name and return a list of IDs that contains it
    * def ThisQuery = 
        """
            {
                query: "#(SearchKeyword)",
                doc_types: [
                    "assets"
                ],
                facets_filters: [],
                search_fields: [
                    "title",
                    "files"
                ],
                include_fields: [
                    "id",
                    "status",
                    "files",
                    "title"
                ],
                facets: [],
                sort: [
                    {
                        "name": "date_created",
                        "order": "desc"
                    }
                ]
            }
        """
    * def GetSearchAssetDataParams = 
        """
            {
                thisURL: #(URL),
                thisQuery: #(ThisQuery),
                thisMethod: post,
                thisStatus: 200,
                IconikAuthToken: #(IconikAuthToken),
                IconikAppID: #(IconikAppID)
            }
        """
    * def searchForAssetIDList =
        """
            function() {
                var finalAssetIDList = [];

                while(true) {
                    karate.log(GetSearchAssetDataParams);
                    thisSearchAssetData = karate.call(thisFile + '@ExecuteHTTPRequest', GetSearchAssetDataParams).result;
                    if(thisSearchAssetData.pass == false) {
                        return thisSearchAssetData;
                    }
                    var thisPath = "$.objects.*.id";
                    var thisFilteredAssetIDs = karate.jsonPath(thisSearchAssetData.response, thisPath);
                    finalAssetIDList = finalAssetIDList.concat(thisFilteredAssetIDs);
                    if(thisSearchAssetData.response.next_url != null) {
                        GetSearchAssetDataParams.thisURL = GetSearchAssetDataParams.thisURL.split('/v1')[0] + thisSearchAssetData.response.next_url;
                        Pause(1000);
                    } else {
                        break;
                    }
                }

                return finalAssetIDList;
            }
        """
    * def result = searchForAssetIDList()

@BulkDeleteAssets
Scenario: Bulk Deletion of Iconik Assets
    * def ThisQuery =
        """
            {
                "content_only": true,
                "object_ids": #(RenditionAssetIDs),
                "object_type": "assets"
            }
        """
    * def BulkDeleteAssetsParams = 
        """
            {
                thisURL: #(URL),
                thisQuery: #(ThisQuery),
                thisMethod: post,
                thisStatus: 200,
                IconikAuthToken: #(IconikAuthToken),
                IconikAppID: #(IconikAppID)
            }
        """
    * karate.call(thisFile + '@ExecuteHTTPRequest', BulkDeleteAssetsParams).result;

@BuildIconikRenditionRequest
Scenario: Build Iconik Rendition Request
    * def buildFieldValues =
        """
            function(data, type) {
                var fieldValues = [];
                if(data == null || data ==='') {
                    return karate.toJson(fieldValues)
                }
                var dataSplit = data.split('|');
                for(var i in dataSplit) {
                    var thisFieldValue = {}
                    if(type.toLowerCase() == 'label+value') {
                        var label = dataSplit[i];
                        thisFieldValue.label = label
                    }
                    var value = dataSplit[i];
                    thisFieldValue.value = value;

                    fieldValues.push(thisFieldValue);
                }

                return karate.toJson(fieldValues)
            }
        """
    * def buildAspectRatioFieldValues =
        """
            function(InputMetadataIconikAspectRatios) {
                var aspectRatioFieldValues = buildFieldValues(InputMetadataIconikAspectRatios, 'label+value');
                for(var i in aspectRatioFieldValues) {
                    aspectRatioFieldValues[i].value = 'ASPECT_' + aspectRatioFieldValues[i].value.replace('x', '_');
                }

                return aspectRatioFieldValues
            }
        """
    * def buildColourSchemeFieldValues =
        """
            function(InputMetadataColourSchemes) {
                var colourSchemeFieldValues = buildFieldValues(InputMetadataColourSchemes, 'label+value');
                return colourSchemeFieldValues
            }
        """
    * def buildStrapTypeFieldValues =
        """
            function(InputMetadataStrapTypes) {
                var strapTypeFieldValues = buildFieldValues(InputMetadataStrapTypes, 'label+value');
                return strapTypeFieldValues
            }
        """
    * def buildTitleCardTypeFieldValues =
        """
            function(InputMetadataTitleCardType) {
                var titleCardTypeFieldValues = buildFieldValues(InputMetadataTitleCardType, 'label+value');
                return titleCardTypeFieldValues
            }
        """
    * def buildSomeCTAFieldValues =
        """
            function(InputMetadataSomeCTA) {
                var someCTAFieldValues = buildFieldValues(InputMetadataSomeCTA, 'label+value');
                return someCTAFieldValues
            }
        """
    * def buildIconikRenditionRequest =
        """
            function(TCMetadata) {
                var IconikRenditionRequest = karate.read(ResourcesPath + TCMetadata.IconikMetadata.IconikRenditionRequestResourcePath);
                var countryCode = {
                    'Netherlands': 'nl',
                    'Norway': 'no',
                    'Sweden': 'se',
                    'Denmark': 'dk',
                    'EMEA PayTv': 'nl'
                }

                IconikRenditionRequest.metadata_values['dplus-some-AspectRatio'].field_values = buildAspectRatioFieldValues(TCMetadata.InputMetadata.IconikAspectRatios);
                IconikRenditionRequest.metadata_values['dplus-some-ColourScheme'].field_values = buildColourSchemeFieldValues(TCMetadata.InputMetadata.ColourSchemes);
                IconikRenditionRequest.metadata_values['dplus-some-StrapType'].field_values = buildStrapTypeFieldValues(TCMetadata.InputMetadata.StrapTypes);
                IconikRenditionRequest.metadata_values['dplus-some-TitleCardType'].field_values = buildTitleCardTypeFieldValues(TCMetadata.InputMetadata.TitleCardTypes);
                IconikRenditionRequest.metadata_values[countryCode[TCMetadata.InputMetadata.Market] + '-dplus-some-CTA'].field_values = buildSomeCTAFieldValues(TCMetadata.InputMetadata.SomeCTA);


                return IconikRenditionRequest
            }
        """
    * def result = buildIconikRenditionRequest(TCMetadata)

@TriggerRendition
Scenario: Trigger Rendition
    * def TriggerRenditionParams =
        """
        {
            thisURL: #(URL),
            thisQuery: #(Query),
            thisMethod: post,
            thisStatus: 200,
            IconikAuthToken: #(IconikAuthToken),
            IconikAppID: #(IconikAppID)
        }
        """
    * def result = karate.call(thisFile + '@ExecuteHTTPRequest', TriggerRenditionParams).result

@ExecuteHTTPRequest
Scenario: Execute an HTTP request to Iconik
    Given url thisURL
    And header Auth-Token = IconikAuthToken
    And header App-ID = IconikAppID
    When request thisQuery
    And method thisMethod
    Then def matchStatus = karate.match(responseStatus, thisStatus)
    And def result =
        """
            {
                response: #(response),
                message: #(matchStatus.message),
                pass: #(matchStatus.pass)
            }
        """

# @GetAssetData
# Scenario: Get Asset Data
#     * def GetAssetDataParams = 
#         """
#         {
#             thisURL: #(URL),
#             thisQuery: #(Query),
#             thisMethod: get,
#             thisStatus: 200
#         }
#         """
#     * def resp = call read(thisFile + '@ExecuteHTTPRequest') GetAssetDataParams
#     * def result = resp.result

# @GetRenditionHTTPInfo
# Scenario: Get Rendition URL from custom action list via Iconik API
#     * def getRenditionHTTPInfo =
#         """
#         function (resp) {
#             var url = '';
#             var respObjects = resp['objects'];
#             for(var index in respObjects) {
#             var actionSet = respObjects[index];
#             if(actionSet['id'] == Iconik_TriggerRenditionCustomActionID) {
#                 url = actionSet['url'];
#                 break;
#             }
#             }
#             var finalResp = {
#             URL: url
#             }
#             return finalResp
#         }
#         """
#     Given url URL
#     And header Auth-Token = IconikAuthToken
#     And header App-ID = IconikAppID
#     When method get
#     Then def result = call getRenditionHTTPInfo response




# @RenameAsset
# Scenario: Rename Asset
#     Given url URL
#     When header Auth-Token = IconikAuthToken
#     And header App-ID = IconikAppID
#     And request UpdateAssetNamePayload
#     And method put
#     Then status 200

# @UpdateAssetMetadata
# Scenario: Update AssetMetadata & validate response
#     * url URL
#     * header Auth-Token = IconikAuthToken
#     * header App-ID = IconikAppID
#     * request Query
#     * method put
#     # * print response
#     * def getMatchResult = 
#         """
#         function() {
#             var matchRes = karate.match('response contains ExpectedResponse');
#             if(!matchRes['pass']) {
#             karate.log('Initial matching failed');
#             for(var key in response) {
#                 var thisRes = '';
#                 expectedValue = ExpectedResponse[key];
#                 actualValue = response[key];
#                 if(key == 'metadata_values') {
#                 for(var videoUpdatesKey in actualValue) {
#                     actualVideoField = actualValue[videoUpdatesKey];
#                     expectedVideoField = expectedValue[videoUpdatesKey];
#                     thisRes = karate.match('actualVideoField contains expectedVideoField');
#                     karate.log(key + '[' + videoUpdatesKey + ']: ' + thisRes);
#                     if(!thisRes['pass']) {
#                     break;
#                     }
#                 }
#                 } else {
#                 thisRes = karate.match('actualValue contains expectedValue');
#                 }
#                 karate.log(key + ': ' + thisRes);
#                 matchRes = thisRes;
#                 if(!matchRes['pass']) {
#                 break;
#                 }
#             }
#             }
#             return matchRes;
#         }
#         """
#     * def result = call getMatchResult
#     # * print result

# @ExecuteHTTPRequest
# Scenario: Execute an HTTP request to Iconik
#     Given url thisURL
#     And header Auth-Token = IconikAuthToken
#     And header App-ID = IconikAppID
#     When request thisQuery
#     And method thisMethod
#     Then assert responseStatus == thisStatus
#     * def result = response

# @GetAssetData
# Scenario: Get Asset Data
#     * def GetAssetDataParams = 
#         """
#         {
#             thisURL: #(URL),
#             thisQuery: #(Query),
#             thisMethod: get,
#             thisStatus: 200
#         }
#         """
#     * def resp = call read(thisFile + '@ExecuteHTTPRequest') GetAssetDataParams
#     * def result = resp.result

# @SearchForAssets
# Scenario: Search for Assets
#     * def SearchForAssetParams = 
#         """
#         {
#             thisURL: #(URL),
#             thisQuery: #(Query),
#             thisMethod: post,
#             thisStatus: 200
#         }
#         """
#     * def resp = call read(thisFile + '@ExecuteHTTPRequest') SearchForAssetParams
#     * def result = resp.result

# @DeleteAssetCollection
# Scenario: Delete Asset
#     * def DeleteAssetParams = 
#         """
#         {
#             thisURL: #(URL),
#             thisQuery: #(Query),
#             thisMethod: post,
#             thisStatus: #(ExpectedStatusCode)
#         }
#         """
#     * def resp = call read(thisFile + '@ExecuteHTTPRequest') DeleteAssetParams
#     * def result = resp.result
#     * print result

# @GetAssetACL
# Scenario: Get Asset User Group ACL
#     * def GetAssetACLParams =
#         """
#         {
#             thisURL: #(URL),
#             thisQuery: null,
#             thisMethod: get,
#             thisStatus: 200
#         }
#         """
#     * def resp = call read(thisFile + '@ExecuteHTTPRequest') GetAssetACLParams
#     * def result = resp.result

# @ValidatePlaceholderExists
# Scenario: Check if placeholder exists
#     * def GetAssetDataParams =
#         """
#         {
#             URL: #(GetAssetDataURL)
#         }
#         """
#     * def AssetData = call read(thisFile + '@GetAssetData') GetAssetDataParams
#     # * print AssetData.result
#     * def result = karate.match('AssetData.result contains ExpectedAssetData')
#     * print result

# @ValidateACLExists
# Scenario: Check if ACL exists in an assetId
#     * def GetAssetsUserGroupACLParams = 
#         """
#         {
#             URL: #(GetAssetACLURL),
#         }
#         """
#     * def AssetACL = call read(thisFile + '@GetAssetACL') GetAssetsUserGroupACLParams
#     * def result = karate.match('AssetACL.result contains ExpectedAssetACL')
#     * print result

# @ValidateCollectionHeirarchy
# Scenario: Validate Collection Heirarchy
#     * def execute =
#         """
#             function(trailerIDList) {
#                 var result = {
#                     message: [],
#                     pass: true
#                 };
#                 for(var i in trailerIDList) {
#                     var trailerId = trailerIDList[i];
#                     var trailerIdAssetDBrecord = karate.read('classpath:' + ResultsPath + '/OAPAssetDB/' + trailerId + '.json');

#                     // Build expectedCollectionHeirarchy array
#                     // Push collection ID to array if it is not null
#                     var expectedCollectionHeirarchy = [];
#                     try {
#                         var trailerIDIconikObjectIDs = trailerIdAssetDBrecord.iconikObjectIds;
#                     } catch(e) {
#                         var errMsg = 'Failed to validate Iconik Heirarchy for ' + trailerId + ': ' + e
#                         result.message.push(trailerId + ': ' + errMsg);
#                         result.pass = false
#                         continue;
#                     }
                    
#                     // karate.log(trailerId + ' iconikObjectIDs: ' + karate.pretty(trailerIDIconikObjectIDs));
#                     // ORDERED LIST, CANNOT DO DYNAMICALLY
#                     // FIRST IN, LAST OUT
#                     var expectedHeirarchyCollectionKeys = [
#                     'showTitleCollectionId',
#                     'seasonCollectionId',
#                     'episodeCollectionId',
#                     'mediaAssetCollectionId',
#                     'outputCollectionId'
#                     ]

#                     var actualTrailerIconikObjectIDkeys = karate.jsonPath(trailerIDIconikObjectIDs, '$.*~');

#                     for(var key in expectedHeirarchyCollectionKeys) {
#                     if(actualTrailerIconikObjectIDkeys.contains(expectedHeirarchyCollectionKeys.key)) {
#                         expectedCollectionHeirarchy.push(trailerIDIconikObjectIDs.key);
#                     }
#                     }               
                    
#                     for(var j = expectedCollectionHeirarchy.length - 1; j >= 0; j--) {
#                         var collectionID = expectedCollectionHeirarchy[j];
#                         var thisURL = IconikAssetDataAPIUrl + '/collections/' + collectionID;
#                         var getAssetDataParams = {
#                             URL: thisURL,
#                             thisQuery: ''
#                         }
#                         var assetData = karate.call(ReUsableFeaturesPath + '/StepDefs/Iconik.feature@GetAssetData', getAssetDataParams);
#                         var assetDataParentCollections = assetData.result.parents;
                        
#                         // API response: parents -> OAP / COUNTRY / FILM -OR- SHOW / ...
#                         // need to offset first 3 because they are not in assetDB record
#                         for(var k = assetDataParentCollections.length - 1; k >= 3; k--) {
#                             var actualParentCollectionIndex = k;
#                             var actualParentID = assetDataParentCollections[actualParentCollectionIndex];
#                             var expectedParentCollectionIndex = j - (assetDataParentCollections.length - k);
#                             var expectedParentID = expectedCollectionHeirarchy[expectedParentCollectionIndex];
#                             var thisResult = karate.match(expectedParentID, actualParentID);

#                             if(!thisResult.pass) {
#                                 result.pass = false;
#                                 if(thisResult.path) {
#                                     errMsg = thisResult.message.replace('$', thisResult.path);
#                                 } else {
#                                     errMsg = thisResult.message;
#                                 }
#                                 result.message.push(trailerId + ': ' + errMsg);
#                                 break;
#                             }
#                         }
#                         if(!result.pass) {
#                             break;
#                         }
#                     }
#                     if(!result.pass) {
#                         break;
#                     }
#                 }
#                 return result;
#             }
#         """
#     * def validateCollectionHeirarchy =
#         """
#         function(trailerIDList) {
#             var thisResult = {};
#             for(var i = 0; i < Retries; i++) {
#             thisResult = execute(trailerIDList);
            
#             if(thisResult.pass) {
#                 break;
#             }
#             else {
#                 karate.log('Try #' + (i+1) + ' of ' + Retries + ': Failed. Sleeping for ' + RetryDuration + ' ms. - ' + karate.pretty(thisResult));
#                 Pause(RetryDuration);
#             }
#             }
#             return thisResult
#         }
#         """
#     * def result = validateCollectionHeirarchy(TrailerIDs)

# @GetAssetDetailsByTrailerIDs
# Scenario: Get AssetIDs from AssetDB by TrailerID
#     * def getAssetIDsByTrailer =
#         """
#             function(trailerIDList) {
#                 for(var i in trailerIDList) {
#                     var trailerId = trailerIDList[i];
#                     var trailerIdAssetDBrecord = karate.read('classpath:' + ResultsPath + '/OAPAssetDB/' + trailerId + '.json');
                    
#                     // Build Assets array
#                     // Push asset ID to array if it is not null
#                     var expectedIconikPlaceholderAssets = [];
#                     var expectedCollectionHeirarchy = [];

#                     try {
#                         var trailerIDIconikObjectIDs = trailerIdAssetDBrecord.iconikObjectIds;
#                         var trailerIDassociatedFiles = trailerIdAssetDBrecord.associatedFiles;
#                     } catch(e) {
#                         karate.fail('Failed to validate get asset details by trailerID for ' + trailerId + ': ' + e);
#                         continue;
#                     }

#                     for(var j in trailerIDIconikObjectIDs) {
#                         if(j.contains('AssetId') && trailerIDIconikObjectIDs[j] != null) {
#                             var thisAssetID = trailerIDIconikObjectIDs[j];
#                             var thisAssetName = trailerIDassociatedFiles[j.replace('AssetId', 'FileName')] == null?trailerIDassociatedFiles[j.replace('AssetId', 'Filename')]:trailerIDassociatedFiles[j.replace('AssetId', 'FileName')];
#                             var thisAssetType = j.replace('AssetId', '').replace('source','').toUpperCase();
#                             var thisAssetDuration = trailerIdAssetDBrecord['duration'];
#                             var thisTrailerId = trailerIdAssetDBrecord.trailerId;
#                             var thisAssetSet = {
#                                 assetType: thisAssetType,
#                                 assetId: thisAssetID,
#                                 assetName: thisAssetName,
#                                 assetDuration: thisAssetDuration,
#                                 trailerId: thisTrailerId
#                             }
#                             expectedIconikPlaceholderAssets.push(thisAssetSet);
#                         }
#                     } 
#                     return expectedIconikPlaceholderAssets;
#                 }
#             }
#         """
#     * def result = getAssetIDsByTrailer(TrailerIDs)

# @ValidateIconikPlaceholders
# Scenario: Validate Placeholders
#   * def execute =
#     """
#         function(trailerIDList) {
#             var result = {
#                 message: [],
#                 pass: true
#             };

#             var expectedIconikPlaceholderAssets = karate.call(thisFile + '@GetAssetDetailsByTrailerIDs', {TrailerIDs: trailerIDList}).result;
#             for(var j in expectedIconikPlaceholderAssets) {
#                 var trailerId = expectedIconikPlaceholderAssets[j]['trailerId'];
#                 var expectedAssetID = expectedIconikPlaceholderAssets[j]['assetId'];
#                 var expectedAssetName = expectedIconikPlaceholderAssets[j]['assetName'];
#                 var expectedAssetType = expectedIconikPlaceholderAssets[j]['assetType'];
                

#                 var thisURL = IconikAssetDataAPIUrl + '/assets/' + expectedAssetID;
#                 var ExpectedPlaceholderAssetData = read(ResourcesPath + '/Iconik/ExpectedPlaceholderAssetData.json')
#                 ExpectedPlaceholderAssetData.title = expectedAssetName;
#                 ExpectedPlaceholderAssetData.external_id = expectedAssetName;
#                 ExpectedPlaceholderAssetData.id = expectedAssetID;  
               
#                 // Environment-specific modifications to expected record
#                 // QA_AUTOMATION_USER
#                 //if(TargetEnv == 'dev' || TargetEnv == 'qa') {
#                 if(TestUser == 'QA_AUTOMATION_USER') {
#                     ExpectedPlaceholderAssetData.is_online = '#ignore';
#                     ExpectedPlaceholderAssetData.versions[0].is_online = '#ignore';
#                     ExpectedPlaceholderAssetData.type = '#ignore';
#                 } else {
#                     if(WochitStage == 'preWochit' || WochitStage == 'metadataUpdate' || WochitStage == 'versionTypeUpdate' || WochitStage == 'versionTypeDelete') {
#                         ExpectedPlaceholderAssetData.type = 'PLACEHOLDER';
#                     } else {
#                         ExpectedPlaceholderAssetData.type = 'ASSET';
#                     }

#                     if(WochitStage == 'versionTypeDelete' && expectedAssetType == 'VIDEO') {
#                         ExpectedPlaceholderAssetData.type = 'ASSET';
#                     }

#                     if(WochitStage == 'preWochit' || WochitStage == 'metadataUpdate' || WochitStage == 'versionTypeUpdate' || WochitStage == 'versionTypeDelete') {
#                         ExpectedPlaceholderAssetData.is_online = '#ignore';
#                         ExpectedPlaceholderAssetData.versions[0].is_online = '#ignore';
#                     } else {
#                         ExpectedPlaceholderAssetData.is_online = true;
#                         ExpectedPlaceholderAssetData.versions[0].is_online = true;
#                     }
#                 }
#                 var ValidatePlaceholderExistsParams = {
#                     GetAssetDataURL: thisURL,
#                     ExpectedAssetData: ExpectedPlaceholderAssetData
#                 }

#                 var thisResult = karate.call(ReUsableFeaturesPath + '/StepDefs/Iconik.feature@ValidatePlaceholderExists', ValidatePlaceholderExistsParams);
#                 if(!thisResult.result.pass) {
#                     if(thisResult.result.path) {
#                         errMsg = thisResult.result.message.replace(thisResult.result.path);
#                     } else {
#                         errMsg = thisResult.result.message;
#                     }
#                     result.message.push(trailerId + '[' + expectedAssetType + '/' + expectedAssetID + ']' + ': ' + errMsg);
#                     result.pass = false;
#                 }
#             }
#             return result;
#         }
#     """
#   * def validatePlaceholders =
#     """
#       function(trailerIDList) {
#         var thisResult = {};
#         for(var i = 0; i < Retries; i++) {
#           thisResult = execute(trailerIDList);
          
#           if(thisResult.pass) {
#             break;
#           }
#           else {
#             karate.log('Try #' + (i+1) + ' of ' + Retries + ': Failed. Sleeping for ' + RetryDuration + ' ms. - ' + karate.pretty(thisResult));
#             Pause(RetryDuration);
#           }
#         }
#         return thisResult;
#       }
#     """
#   * def result = validatePlaceholders(TrailerIDs)

# @SearchAndDeleteAssets
# Scenario: Search and delete all Iconik assets which contains a particular pattern in its filename
#     * karate.log('Search and Delete for: ' + SearchKeywords)
#     * def searchAndDelete =
#         """
#             function() {
#                 var filterTerms = [
#                     {
#                         name: 'status',
#                         value: 'ACTIVE'
#                     }
#                 ]
                
#                 var thisPath = '$.objects.*.id';
#                 var searchedAssets = [];

#                 for(var i in SearchKeywords) {
#                     var searchQuery = karate.read(ResourcesPath + '/Iconik/GETSearchRequest.json')
#                     searchQuery.filter.terms = karate.toJson(filterTerms);
#                     searchQuery.include_fields = ['id']
#                     searchQuery.query = SearchKeywords[i];
#                     var SearchForAssetsParams = {
#                         URL: '',
#                         Query: searchQuery
#                     }
#                     karate.log('[Searching] ' + SearchKeywords[i]);
#                     var page = 1;

#                     maxPages = 100;
#                     for(var j = 1; j <= maxPages; j++) {
#                         SearchForAssetsParams.URL = IconikSearchAPIUrl + '&page=' + page;
#                         var searchResult = karate.call(ReUsableFeaturesPath + '/StepDefs/Iconik.feature@SearchForAssets', SearchForAssetsParams);
#                         maxPages = searchResult.result.pages;
#                         var thisSearch = karate.jsonPath(searchResult.result, thisPath);
#                         for(var k in thisSearch) {
#                             searchedAssets.push(thisSearch[k]);
#                         }
#                         Pause(1000);
#                     }
#                 }
                
#                 if(searchedAssets.length < 1) {
#                     karate.log('Nothing to delete');
#                 } else {
#                     karate.log('[Deleting] ')
#                     var DeleteAssetParams = {
#                         URL: IconikDeleteQueueAPIUrl + '/assets',
#                         Query: {
#                             ids: searchedAssets
#                         },
#                         ExpectedStatusCode: 204
#                     }
#                     karate.call(ReUsableFeaturesPath + '/StepDefs/Iconik.feature@DeleteAssetCollection', DeleteAssetParams);
#                     Pause(3000);
#                 }
#             }
#         """
#     * searchAndDelete()

# @SetupCheckIconikAssets
# Scenario: Setup: Check Iconik Assets Before Running
#     # * var SearchKeywords = ['after*']
#     * karate.log('Search for: ' + SearchKeywords)
#     * def searchIconikAssets =
#         """
#             function(SearchKeywords) {
#                 var results = [];
                
#                 var filterTerms = [
#                     {
#                         name: 'status',
#                         value: 'ACTIVE'
#                     }
#                 ]
#                 for(var i in SearchKeywords){
#                     var searchQuery = karate.read(ResourcesPath + '/Iconik/GETSearchRequest.json');
#                     searchQuery.filter.terms = karate.toJson(filterTerms);
#                     searchQuery.include_fields = ['id'];
#                     searchQuery.query = SearchKeywords[i];
#                     var SearchForAssetsParams = {
#                         URL: '',
#                         Query: searchQuery
#                     }
                    
#                     karate.log('[Searching] ' + SearchKeywords[i]);
#                     var page = 1;
#                     while (true) {
#                         SearchForAssetsParams.URL = IconikSearchAPIUrl + '&page=' + page;
#                         var searchResult = karate.call(ReUsableFeaturesPath + '/StepDefs/Iconik.feature@SearchForAssets', SearchForAssetsParams);
#                         var thisPath = '$.objects.*.id';
#                         var searchedAssets = karate.jsonPath(searchResult.result, thisPath);
#                         for(var j in searchedAssets) {
#                             results.push(searchedAssets[j]);
#                         }
#                         if(page >= searchResult.result.pages) {
#                             break
#                         } 
#                     }
#                 }
#                 return results;
#             }
        
#         """
#     * def result = searchIconikAssets(SearchKeywords)

