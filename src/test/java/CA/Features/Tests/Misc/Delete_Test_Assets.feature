@DeleteTestAssets
Feature: Delete test assets after all the executions have finished

Background:
    * def Countries = [ 'Norway' ]
    # --- Functions
    * def setSearchKeyword =
        """
            function() {
                try {
                    return SearchKeyword
                } catch(e) {
                    return 'CTA'
                }
            }
        """
    * def getCollectionIDs = 
        """
           function(data) {
                var collectionIDs = [];
                var countries = data.countries;
                var collectionType = data.collectionType;
                for(var index in countries) {
                    var country = countries[index];
                    collectionIDs.push(EnvConfig[country][collectionType]);
                }
                return collectionIDs;
           } 
        """
    * def getAssetIDs =
        """
            function(collectionIDs) {
                for(i in collectionIDs) {
                    var CollectionID = collectionIDs[i];
                    var filterTerms = [
                        {
                            name: 'in_collections',
                            value: CollectionID
                        },
                        {
                            name: 'status',
                            value: 'ACTIVE'
                        }
                    ]
                    var searchQuery = karate.read(CurrentTCPath + '/GETSearchRequest.json')
                    searchQuery.filter.terms = karate.toJson(filterTerms);
                    var SearchForAssetsParams = {
                        URL: '',
                        Query: searchQuery
                    }
                    var results = [];
                    var page = 1;
                    while (true) {
                        SearchForAssetsParams.URL = Iconik_SearchAPIURL + '&page=' + page;
                        var searchResult = karate.call(FeatureFilePath + '/Iconik.feature@SearchForAssets', SearchForAssetsParams);
                        var thisPath = '$.objects.*.id';
                        var searchedAssetIDs = karate.jsonPath(searchResult.result, thisPath);
                        for(var j in searchedAssetIDs) {
                            results.push(searchedAssetIDs[j]);
                        }
                        if(page >= searchResult.result.pages) {
                            break
                        } 
                        page++;
                    }
                    return results
                }
            }
        """
    # --- Directories
    * def CurrentTCPath = 'classpath:CA/TestData/E2ECases/Misc'
    * def FeatureFilePath = 'classpath:CA/Features/ReUsable/Methods'
    # --- Iconik
    * def Iconik_SeasonCollectionIDs = call getCollectionIDs { countries: #(Countries), collectionType: 'Iconik_SeasonCollectionID' }
    * def Iconik_VideoOutputsCollectionIDs = call getCollectionIDs { countries: #(Countries), collectionType: 'Iconik_VideoOutputsCollectionID' }
    * def Iconik_GetAppTokenInfoURL = EnvConfig['Common']['Iconik_GetAppTokenInfoURL']
    * def Iconik_DeleteAssetAPIURL = EnvConfig['Common']['Iconik_DeleteAssetAPIURL']
    * def Iconik_SearchAPIURL = EnvConfig['Common']['Iconik_SearchAPIURL']
    * def Iconik_AppTokenName = EnvConfig['Common']['Iconik_AppTokenName']
    * def Iconik_AdminEmail = eval("SecretsData['Iconik-AdminEmail" + TargetEnv + "']")
    * def Iconik_AdminPassword = eval("SecretsData['Iconik-AdminPassword" + TargetEnv + "']")
    * def Iconik_GetAppTokenInfoPayload = 
        """
        {
            "app_name": #(Iconik_AppTokenName),
            "email":  #(Iconik_AdminEmail),
            "password": #(Iconik_AdminPassword)
        }
        """
    * def GetAppTokenInfoParams =
        """
        {
            URL: "#(Iconik_GetAppTokenInfoURL)",
            GetAppTokenInfoPayload: #(Iconik_GetAppTokenInfoPayload)
        }
        """
    * def IconikAuthenticationInfo = callonce read(FeatureFilePath + '/Iconik.feature@GetAppTokenInfo') GetAppTokenInfoParams
    * def Iconik_AuthToken = IconikAuthenticationInfo.result.Iconik_AuthToken
    * def Iconik_AppID = IconikAuthenticationInfo.result.Iconik_AppID

@DeleteDCOImageTestAssets
Scenario: Delete all DCO Image Test Assets
    * def SearchKeyword = call setSearchKeyword
    * def SearchFields = [ 'id' ]
    * def deleteAssetList = call getAssetIDs Iconik_SeasonCollectionIDs
    * def DeleteAssetParams =
        """
        {
            URL: #(Iconik_DeleteAssetAPIURL),
            Query: {
                ids: #(deleteAssetList)
            }
        }
        """
    * call read(FeatureFilePath + '/Iconik.feature@DeleteAsset') DeleteAssetParams

@DeleteVideoOutputsTestAssets
Scenario: Delete all Video-Outputs Test Assets
    * def SearchKeyword = call setSearchKeyword
    * def SearchFields = [ 'id' ]
    * def deleteAssetList = call getAssetIDs Iconik_VideoOutputsCollectionIDs
    * def DeleteAssetParams =
        """
        {
            URL: #(Iconik_DeleteAssetAPIURL),
            Query: {
                ids: #(deleteAssetList)
            }
        }
        """
    * call read(FeatureFilePath + '/Iconik.feature@DeleteAsset') DeleteAssetParams