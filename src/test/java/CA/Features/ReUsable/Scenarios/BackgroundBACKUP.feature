Feature: Background

Scenario: Background
    # DynamoDB Table Stuff Start
    * def AWSregion = EnvConfig[Country]['AWSregion']
    * def WochitMappingTableName = EnvConfig[Country]['WochitMappingTableName']
    * def WochitRenditionTableName = EnvConfig[Country]['WochitRenditionTableName']
    * def WochitRenditionTableGSI = EnvConfig[Country]['WochitRenditionTableGSI']
    * def MAMAssetsInfoTableName = EnvConfig[Country]['MAMAssetsInfoTableName']
    * def CAIconikConfigTableName = EnvConfig[Country]['CAIconikConfigTableName']
    * def CAIconikConfigACLID = (EpisodeMetadataType == 'DCO'? EnvConfig[Country]['CAIconikConfigACLIDDCO']:EnvConfig[Country]['CAIconikConfigACLID' + Country.toUpperCase()])
    # DynamoDB Table Stuff End
    # Paths Start
    * def tcResultWritePath = 'test-classes/' + TCName + '.json'
    * def tcResultReadPath = 'classpath:target/' + tcResultWritePath
    * def finalResultWritePath = 'test-classes/Results.json'
    * def finalResultReadPath = 'classpath:target/' + finalResultWritePath
    * def currentTCPath = 'classpath:CA/TestData/E2ECases/' + AWSregion + '_Region/' + Country + '/' + TCName
    * def FeatureFilePath = 'classpath:CA/Features/ReUsable/Methods'
    # Paths End
    # Iconik Stuff Start
    * def Iconik_EpisodeVersionID = EnvConfig[Country]['Iconik_EpisodeVersionID']
    * def Iconik_EpisodeMetadataObjectID = EnvConfig[Country]['Iconik_EpisodeMetadataObjectID']
    * def Iconik_AssetID = EnvConfig[Country]['Iconik_AssetID'][EpisodeMetadataType][MetadataSet]
    * def Iconik_MetadataViewID = EnvConfig[Country]['Iconik_MetadataViewID'][EpisodeMetadataType]
    * def Iconik_SeasonCollectionID = EnvConfig[Country]['Iconik_SeasonCollectionID']
    * def Iconik_TriggerRenditionCustomActionID = EnvConfig[Country]['Iconik_TriggerRenditionCustomActionID'][EpisodeMetadataType]
    * def Iconik_TechnicalMetadataID = EnvConfig[Country]['Iconik_TechnicalMetadataID']
    * def Iconik_TechnicalMetadataObjectID = EnvConfig[Country]['Iconik_TechnicalMetadataObjectID']
    * def Iconik_AssetName = EnvConfig[Country]['Iconik_AssetName'][EpisodeMetadataType][MetadataSet]
    * def Iconik_SystemDomainID = EnvConfig[Country]['Iconik_SystemDomainID']
    * def Iconik_UserId = EnvConfig['Common']['Iconik_UserId'][TargetTag]
    * def Iconik_TriggerRenditionCustomActionListURL = EnvConfig['Common']['Iconik_TriggerRenditionCustomActionListURL']
    * def Iconik_GetAppTokenInfoURL = EnvConfig['Common']['Iconik_GetAppTokenInfoURL']
    * def Iconik_AssetAPIURL = EnvConfig['Common']['Iconik_AssetAPIURL']
    * def Iconik_AssetMetadataAPIURL = EnvConfig['Common']['Iconik_AssetMetadataAPIURL']
    * def Iconik_AssetUpdateMetadataAPIURL = Iconik_AssetMetadataAPIURL + '/' + Iconik_AssetID + '/views/' + Iconik_MetadataViewID
    * def Iconik_GetAssetACLAPIURL = EnvConfig['Common']['Iconik_GetAssetACLAPIURL']
    * def Iconik_AppTokenName = EnvConfig['Common']['Iconik_AppTokenName']
    * def Iconik_AdminEmail = eval("SecretsData['Iconik-AdminEmail" + TargetEnv + "']")
    * def Iconik_AdminPassword = eval("SecretsData['Iconik-AdminPassword" + TargetEnv + "']")
    * def Iconik_GetAppTokenInfoPayload = 
        """
            {
                "app_name": #(Iconik_AppTokenName),
                "email":    #(Iconik_AdminEmail),
                "password": #(Iconik_AdminPassword)
            }
        """
    * def CheckIconikUserNameAttr =
        """
            function(iconikUserName) {
                var result = true;
                if(TargetTag == 'E2E') {
                    if(iconikUserName == null) {
                        result = false;
                    }
                }
                return result;
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
    * def GetRenditionHTTPInfoParams =
        """
            {
                URL: #(Iconik_TriggerRenditionCustomActionListURL),
                Iconik_TriggerRenditionCustomActionID: #(Iconik_TriggerRenditionCustomActionID),
                Iconik_AuthToken: #(Iconik_AuthToken),
                Iconik_AppID: #(Iconik_AppID)
            }
        """
    * def IconikRenditionURLInfo = call read(FeatureFilePath + '/Iconik.feature@GetRenditionHTTPInfo') GetRenditionHTTPInfoParams
    * def TriggerRenditionURL = IconikRenditionURLInfo.result.URL
    * def GetIconikACLParams =
        """
            {
                Param_TableName: #(CAIconikConfigTableName),
                Param_QueryInfoList: [
                    {
                        infoName: 'ID',
                        infoValue: #(CAIconikConfigACLID),
                        infoComparator: '=',
                        infoType: 'key'
                    }
                ],
                Param_GlobalSecondaryIndex: '',
                AWSregion: #(AWSregion)
            }
        """
    * def getIconikACL =
        """
            function(params) {
                var result = karate.call(FeatureFilePath + '/Dynamodb.feature@GetItemsViaQuery', params);
                return result.result[0].userGroupId;
            }
        """
    * def ExpectedIconikACLUserGroupId = callonce getIconikACL GetIconikACLParams
    # Iconik Stuff End
    # Scenario Outline Examples Start
    * def readFile = 
        """
            function(thisPath) {
                try {
                    return karate.read(thisPath);
                } catch (e) {
                    var empty = {};
                    empty[TargetEnv] = {};
                    empty[TargetEnv][MetadataSet] = {
                        ExpectedMAMAssetInfoCount: 0,
                        ExpectedWochitRenditionCount: 0,
                        ExpectedWochitMappingCount: 0
                    };
                    return empty
                }
            }
        """
    * def validateTechnicalMetadataTestData = readFile(currentTCPath + '/ScenarioOutlineExamples/validateTechnicalMetadata.json')[TargetEnv][MetadataSet]
    * def validateWochitRenditionTestData = readFile(currentTCPath + '/ScenarioOutlineExamples/validateWochitRendition.json')[TargetEnv][MetadataSet]
    * def validateWochitMappingProcessingTestData = readFile(currentTCPath + '/ScenarioOutlineExamples/validateWochitMappingProcessing.json')[TargetEnv][MetadataSet]
    * def validateWochitMappingIsFiledMovedTestData = readFile(currentTCPath + '/ScenarioOutlineExamples/validateWochitMappingIsFiledMoved.json')[TargetEnv][MetadataSet]
    # Scenario Outline Examples End
    # Expected Item Counts Start
    * def ExpectedMAMAssetInfoCount = readFile(currentTCPath + '/Output/ExpectedItemCounts.json')[TargetEnv][MetadataSet]['ExpectedMAMAssetInfoCount']
    * def ExpectedWochitRenditionCount = readFile(currentTCPath + '/Output/ExpectedItemCounts.json')[TargetEnv][MetadataSet]['ExpectedWochitRenditionCount']
    * def ExpectedWochitMappingCount = readFile(currentTCPath + '/Output/ExpectedItemCounts.json')[TargetEnv][MetadataSet]['ExpectedWochitMappingCount']
    # Expected Item Counts End
    # Expected Asset Properties End
    # S3 Stuff
    * def AssetBucketName = EnvConfig['Common']['S3']['AssetBucketName']
    * def RenditionsFolderName = EnvConfig['Common']['S3']['RenditionsFolderName']
    * def S3Region = EnvConfig['Common']['S3']['Region']
    # S3 Stuff End
    * def customReportplaceholderParams = 
        """
            { 
                tcResultReadPath: #(tcResultReadPath), 
                tcResultWritePath: #(tcResultWritePath), 
                tcName: #(TCName),
                tcValidationType: #(TCValidationType)
            }
        """
    * def updateFinalResultParams = 
        """
            { 
                tcResultReadPath: #(tcResultReadPath), 
                tcResultWritePath: #(tcResultWritePath), 
                tcName: #(TCName), 
                finalResultReadPath: #(finalResultReadPath), 
                finalResultWritePath: #(finalResultWritePath) 
            }
        """
    * callonce read(FeatureFilePath + '/Results.feature@setPlaceholder') { customReportplaceholderParams: #(customReportplaceholderParams) })
    # * call read(FeatureFilePath + '/Results.feature@shouldContinue') { customReportplaceholderParams: #(updateFinalResultParams) })
    * def Pause = 
        """
            function(pause){ 
                karate.log('Pausing for ' + pause + ' milliseconds');
                java.lang.Thread.sleep(pause);
            }
        """
    * callonce Pause WaitTime
    * def one = callonce read(FeatureFilePath + '/RandomGenerator.feature@SeriesTitle')
    * def RandomSeriesTitle = one.RandomSeriesTitle
    * def two = callonce read(FeatureFilePath + '/RandomGenerator.feature@CallOutText')
    * def RandomCalloutText = two.RandomCalloutText
    * def three = callonce read(FeatureFilePath + '/RandomGenerator.feature@CTA')
    * def RandomCTA = three.RandomCTA
    * print RandomSeriesTitle, RandomCalloutText, RandomCTA
    * def generateExpectedTitle =
        """
            function(fnameprefix) {
                var finalExpectedTitle = fnameprefix.replace('CTA', RandomCTA);
                finalExpectedTitle = finalExpectedTitle.replace('COT', RandomCalloutText);

                return finalExpectedTitle
            }
        """
    * configure afterFeature = 
        """
            function() {
                karate.call(FeatureFilePath + '/Results.feature@updateFinalResults', { updateFinalResultParams: updateFinalResultParams });

                //Trigger Auto-deletion
                var method = '@DeleteDCOImageTestAssets';
                if(EpisodeMetadataType != 'DCO') {
                    method = '@DeleteVideoOutputsTestAssets';
                }
                var DeleteAssetParams = {
                    SearchKeyword: RandomCTA
                }
                karate.call('classpath:CA/Features/Tests/Misc/Delete_Test_Assets.feature' + method, DeleteAssetParams);
            }
        """