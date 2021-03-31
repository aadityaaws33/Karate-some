@DPLUS @E2E @Regression @Norway @parallel=false  
Feature:  Dplus_Essential_StrapOut_Lessthan_StrapIn

Background:
  # NEW
  * def TCName = 'Dplus_Essential_StrapOut_Lessthan_StrapIn'
  * def Country = 'Norway'
  * def EpisodeMetadataType = 'Dplus'
  * def MetadataSet = 'StrapOutLessthanStrapIn'
  * def AWSregion = EnvData[Country]['AWSregion']
  * def WochitMappingTableName = EnvData[Country]['WochitMappingTableName']
  * def WochitMappingTableGSI = 'wochitRenditionStatus-createdAt-Index'
  * def WochitRenditionTableName = EnvData[Country]['WochitRenditionTableName']
  * def MAMAssetsInfoTableName = EnvData[Country]['MAMAssetsInfoTableName']
  # Iconik Stuff Start
  * def Iconik_EpisodeVersionID = EnvData[Country]['Iconik_EpisodeVersionID']
  * def Iconik_EpisodeMetadataObjectID = EnvData[Country]['Iconik_EpisodeMetadataObjectID']
  * def Iconik_AssetID = EnvData[Country]['Iconik_AssetID'][EpisodeMetadataType][MetadataSet]
  * def Iconik_SeasonCollectionID = EnvData[Country]['Iconik_SeasonCollectionID']
  * def Iconik_TriggerRenditionCustomActionID = EnvData[Country]['Iconik_TriggerRenditionCustomActionID'][EpisodeMetadataType]
  * def Iconik_TechnicalMetadataID = EnvData[Country]['Iconik_TechnicalMetadataID']
  * def Iconik_TechnicalMetadataObjectID = EnvData[Country]['Iconik_TechnicalMetadataObjectID']
  * def Iconik_AssetName = EnvData[Country]['Iconik_AssetName'][EpisodeMetadataType][MetadataSet]
  * def Iconik_SystemDomainID = EnvData[Country]['Iconik_SystemDomainID']
  * def Iconik_UpdateSeasonURL =  EnvData[Country]['Iconik_UpdateSeasonURL']
  * def Iconik_UserId = EnvData['Common']['Iconik_UserId'][TargetTag]
  * def Iconik_TriggerRenditionCustomActionListURL = EnvData['Common']['Iconik_TriggerRenditionCustomActionListURL']
  * def Iconik_GetAppTokenInfoURL = EnvData['Common']['Iconik_GetAppTokenInfoURL']
  * def Iconik_AssetAPIURL = EnvData['Common']['Iconik_AssetAPIURL']
  * def Iconik_AppTokenName = EnvData['Common']['Iconik_AppTokenName']
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
  # Iconik Stuff End
  * def TCValidationType = 'videoValidation' //videoValidation or imageValidation. Used for custom report table
  * def tcResultWritePath = 'test-classes/' + TCName + '.json'
  * def tcResultReadPath = 'classpath:target/' + tcResultWritePath
  * def finalResultWritePath = 'test-classes/Results.json'
  * def finalResultReadPath = 'classpath:target/' + finalResultWritePath
  * def currentTCPath = 'classpath:CA/TestData/E2ECases/' + AWSregion + '_Region/' + Country + '/' + TCName
  * def FeatureFilePath = 'classpath:CA/Features/ReUsable'
  # S3 Stuff
  * def AssetBucketName = EnvData['Common']['S3']['AssetBucketName']
  * def RenditionsFolderName = EnvData['Common']['S3']['RenditionsFolderName']
  * def S3Region = EnvData['Common']['S3']['Region']
  # S3 Stuff End
  # NEW
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
  * print TriggerRenditionURL
  * def placeholderParams = 
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
  * call read(FeatureFilePath + '/Results.feature@setPlaceholder') { placeholderParams: #(placeholderParams) })
  # * call read(FeatureFilePath + '/Results.feature@shouldContinue') { placeholderParams: #(updateFinalResultParams) })
  * def Pause = 
    """
      function(pause){ 
        karate.log('Pausing for ' + pause + ' milliseconds');
        java.lang.Thread.sleep(pause);
      }
    """
  * callonce Pause 4000
  * def one = callonce read(FeatureFilePath+'/RandomGenerator.feature@SeriesTitle')
  * def RandomSeriesTitle = one.RandomSeriesTitle
  * def two = callonce read(FeatureFilePath+'/RandomGenerator.feature@CallOutText')
  * def RandomCalloutText = two.RandomCalloutText
  * def three = callonce read(FeatureFilePath+'/RandomGenerator.feature@CTA')
  * def RandomCTA = three.RandomCTA
  * print RandomSeriesTitle, RandomCalloutText, RandomCTA
  * configure afterFeature = 
    """
      function() {
        karate.call(FeatureFilePath + '/Results.feature@updateFinalResults', { updateFinalResultParams: updateFinalResultParams });
      }
    """

Scenario: Nordic_Norway_Dplus_Essential_StrapOut_Lessthan_StrapIn - Update Asset Name to Unique
  * def thisAssetTitle = RandomCTA + ' ' + Iconik_AssetName
  * def UpdateAssetNamePayload =
    """
      {
        title: "#(thisAssetTitle)"
      }
    """
  * def updateAssetURL = Iconik_AssetAPIURL + '/'+ Iconik_AssetID
  * def updateAssetNameParams =
    """
      {
        URL: "#(updateAssetURL)",
        UpdateAssetNamePayload: #(UpdateAssetNamePayload)
      }
    """
  * call read(FeatureFilePath+'/Iconik.feature@RenameAsset') updateAssetNameParams
  * call Pause 1000

# Scenario: Nordic_Norway_Dplus_Essential_StrapOut_Lessthan_StrapIn - Update Season 
#   * def scenarioName = 'updateSeason'
#   * def UpdateSeasonquery = read(currentTCPath+'/Input/SeasonRequest.json')
#   * replace UpdateSeasonquery.SeriesTitle = RandomSeriesTitle
#   * def Season_expectedResponse = read(currentTCPath+'/Output/ExpectedSeasonResponse.json')
#   * def updateSeasonParams =
#     """
#       {
#         URL: '#(Iconik_UpdateSeasonURL)',
#         Query: '#(UpdateSeasonquery)', 
#         ExpectedResponse: #(Season_expectedResponse),
#       }
#     """
#   * def result = call read(FeatureFilePath+'/UpdateSeason.feature') updateSeasonParams
#   * print result
#   * def updateParams = 
#     """
#       { 
#         tcName: #(TCName),
#         scenarioName: #(scenarioName),
#         result: #(result.result),
#         tcResultReadPath: #(tcResultReadPath),
#         tcResultWritePath: #(tcResultWritePath)
#       }
#     """
#   * call read(FeatureFilePath + '/Results.feature@updateResult') { updateParams: #(updateParams) })

Scenario: Nordic_Norway_Dplus_Essential_StrapOut_Lessthan_StrapIn - Trigger Rendition
  * def scenarioName = 'triggerRendition'
  * def getRenditionRequestMetadataValues =
    """
      function() {
        var metadataValues = karate.read(currentTCPath + '/Input/EpisodeRequest.json');
        return metadataValues['metadata_values'];
        // if(TargetEnv == 'preprod' || TargetEnv == 'prod') {
        //   var metadataValues = karate.read(currentTCPath + '/Input/EpisodeRequest.json');
        //   return metadataValues['metadata_values'];
        // } else {
        //   return null;
        // }
      }
    """
  * def RenditionRequestMetadataValues = call getRenditionRequestMetadataValues
  * def RenditionRequestPayload = read(currentTCPath+'/Input/RenditionRequest.json')
  * def Rendition_ExpectedResponse = read(currentTCPath+'/Output/ExpectedRenditionResponse.json')
  * def renditionParams = 
    """
      {
        URL: #(TriggerRenditionURL),
        RenditionRequestPayload: '#(RenditionRequestPayload)',
        RenditionExpectedResponse: '#(Rendition_ExpectedResponse)',
        IconikCredentials: #(IconikCredentials)
      }
    """
  * def result = call read(FeatureFilePath+'/Iconik.feature@TriggerRendition') renditionParams
  * def updateParams = 
    """
      { 
        tcName: #(TCName), 
        scenarioName: #(scenarioName), 
        result: #(result.result), 
        tcResultReadPath: #(tcResultReadPath), 
        tcResultWritePath: #(tcResultWritePath) 
      }
    """
  * call read(FeatureFilePath + '/Results.feature@updateResult') { updateParams: #(updateParams) })
  * call Pause 60000

Scenario: Nordic_Norway_Dplus_Essential_StrapOut_Lessthan_StrapIn - Validate Item Counts - MAM Asset Info
  * def scenarioName = "validateMAM"
  * def ExpectedMAMAssetInfoCount = 0
  * def ExpectedTitle = RandomCTA + ' ' + Iconik_AssetName
  * def ValidateItemCountViaQueryParams = 
    """
      {
        Param_TableName: #(MAMAssetsInfoTableName),
        Param_QueryInfoList: [
          {
            infoName: 'assetId',
            infoValue: #(Iconik_AssetID),
            infoComparator: '=',
            infoType: 'key'
          },
          {
            infoName: 'assetTitle',
            infoValue: #(ExpectedTitle),
            infoComparator: '=',
            infoType: 'filter'
          }
        ],
        Param_GlobalSecondaryIndex: '',
        Param_ExpectedItemCount: #(ExpectedMAMAssetInfoCount),
        AWSregion: #(AWSregion)
      }
    """
  * def result = call read(FeatureFilePath+'/Dynamodb.feature@ValidateItemCountViaQuery') ValidateItemCountViaQueryParams
  * def updateParams = 
    """
      { 
        tcName: #(TCName), 
        scenarioName: #(scenarioName), 
        result: #(result.result), 
        tcResultReadPath: #(tcResultReadPath), 
        tcResultWritePath: #(tcResultWritePath) 
      }
    """
  * call read(FeatureFilePath + '/Results.feature@updateResult') { updateParams: #(updateParams) })

Scenario: Nordic_Norway_Dplus_Essential_StrapOut_Lessthan_StrapIn - Validate Item Counts - Wochit Rendition
  * def scenarioName = "validateWochitRenditionCount"
  * def ExpectedWocRenditionCount = 0
  * def ExpectedTitle = RandomCTA + ' ' + Iconik_AssetName
  * def itemCountScanParams = 
    """
      {
        Param_TableName: #(WochitRenditionTableName),
        Param_Atr1: 'videoUpdates.title',
        Param_Atrvalue1: #(ExpectedTitle),
        Param_Operator: 'contains',
        Param_ExpectedItemCount: #(ExpectedWocRenditionCount),
        AWSregion: #(AWSregion)
      }    
    """
  * def result = call read(FeatureFilePath+'/Dynamodb.feature@ItemCountScan') itemCountScanParams
  * def updateParams = 
    """
      { 
        tcName: #(TCName), 
        scenarioName: #(scenarioName), 
        result: #(result.result), 
        tcResultReadPath: #(tcResultReadPath), 
        tcResultWritePath: #(tcResultWritePath) 
      }
    """
  * call read(FeatureFilePath + '/Results.feature@updateResult') { updateParams: #(updateParams) })

Scenario: Nordic_Norway_Dplus_Essential_StrapOut_Lessthan_StrapIn - Validate Wochit Mapping Table Failure
  * def scenarioName = 'validateWochitMappingFailure'
  * def RenditionFileName = RandomCTA + ' ' + Iconik_AssetName
  * def Expected_WochitMapping_Entry = read(currentTCPath + '/Output/Expected_WochitMapping_Entry.json')
  * def ValidateItemViaScanParams =
    """
      {
        Param_TableName: #(WochitMappingTableName),
        Param_ScanAttr1: 'sourceAssetName',
        Param_ScanVal1: #(RenditionFileName),
        Expected_WochitRendition_Entry: #(Expected_WochitMapping_Entry),
        AWSregion: #(AWSregion)
      }
    """
  * def result = call read(FeatureFilePath+'/Dynamodb.feature@ValidateWochitMappingPayload') ValidateItemViaScanParams
  * def updateParams = 
    """
      { 
        tcName: #(TCName), 
        scenarioName: #(scenarioName), 
        result: #(result.result), 
        tcResultReadPath: #(tcResultReadPath), 
        tcResultWritePath: #(tcResultWritePath) 
      }
    """
  * call read(FeatureFilePath + '/Results.feature@updateResult') { updateParams: #(updateParams) })

Scenario: Nordic_Norway_Dplus_Essential_StrapOut_Lessthan_StrapIn - Update Asset Name to Original
  * def UpdateAssetNamePayload =
    """
      {
        title: "#(Iconik_AssetName)"
      }
    """
  * def updateAssetURL = Iconik_AssetAPIURL + '/'+ Iconik_AssetID
  * def updateAssetNameParams =
    """
      {
        URL: "#(updateAssetURL)",
        UpdateAssetNamePayload: #(UpdateAssetNamePayload)
      }
    """
  * call read(FeatureFilePath+'/Iconik.feature@RenameAsset') updateAssetNameParams
  * call Pause 1000