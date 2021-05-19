@E2E @Regression @Norway @parallel=false  
Feature:  Dplus_Essential_StrapOut_Lessthan_StrapIn

Background:
  # NEW
  * def TCName = 'Dplus_Essential_StrapOut_Lessthan_StrapIn'
  * def Country = 'Norway'
  * def EpisodeMetadataType = 'Dplus'
  * def MetadataSet = 'StrapOutLessthanStrapIn'
  * def AWSregion = EnvConfig[Country]['AWSregion']
  * def WochitMappingTableName = EnvConfig[Country]['WochitMappingTableName']
  * def WochitMappingTableGSI = 'wochitRenditionStatus-createdAt-index'
  * def WochitRenditionTableName = EnvConfig[Country]['WochitRenditionTableName']
  * def WochitRenditionTableGSI = EnvConfig[Country]['WochitRenditionTableGSI']
  * def MAMAssetsInfoTableName = EnvConfig[Country]['MAMAssetsInfoTableName']
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
  * def currentTestDataPath = 'classpath:CA/TestData/E2ECases/' + AWSregion + '_Region/' + Country + '/' + TCName
  * def FeatureFilePath = 'classpath:CA/Features/ReUsable/Methods'
  # S3 Stuff
  * def AssetBucketName = EnvConfig['Common']['S3']['AssetBucketName']
  * def RenditionsFolderName = EnvConfig['Common']['S3']['RenditionsFolderName']
  * def S3Region = EnvConfig['Common']['S3']['Region']
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

Scenario: Nordic_Norway_Dplus_Essential_StrapOut_Lessthan_StrapIn - Trigger Rendition
  * def scenarioName = 'triggerRendition'
  * def getRenditionRequestMetadataValues =
    """
      function() {
        var metadataValues = karate.read(currentTestDataPath + '/Input/EpisodeRequest.json');
        return metadataValues['metadata_values'];
        // if(TargetEnv == 'preprod' || TargetEnv == 'prod') {
        //   var metadataValues = karate.read(currentTestDataPath + '/Input/EpisodeRequest.json');
        //   return metadataValues['metadata_values'];
        // } else {
        //   return null;
        // }
      }
    """
  * def RenditionRequestMetadataValues = call getRenditionRequestMetadataValues
  * def RenditionRequestPayload = read(currentTestDataPath+'/Input/RenditionRequest.json')
  * def Rendition_ExpectedResponse = read(currentTestDataPath+'/Output/ExpectedRenditionResponse.json')
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
  * call Pause 10000

Scenario: Nordic_Norway_Dplus_Essential_StrapOut_Lessthan_StrapIn - Validate Item Counts - MAM Asset Info
  * def scenarioName = "validateMAMAssetCount"
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
  * def ExpectedWochitRenditionCount = 0
  * def ExpectedTitle = RandomCTA + ' ' + Iconik_AssetName
  * def ExpectedDate = call read(FeatureFilePath + '/Date.feature@GetDateWithOffset') { offset: 0 }
  * def GetItemsViaQueryParams = 
    """
      {
        Param_TableName: #(WochitRenditionTableName),
        Param_QueryInfoList: [
          {
            infoName: 'assetType',
            infoValue: 'VIDEO',
            infoComparator: '=',
            infoType: 'key'
          },
          {
            infoName: 'createdAt',
            infoValue: #(ExpectedDate.result),
            infoComparator: 'begins',
            infoType: 'key'
          }
        ],
        Param_GlobalSecondaryIndex: #(WochitRenditionTableGSI),
        AWSregion: #(AWSregion)
      }
    """
  * def QueryResults = call read(FeatureFilePath+'/Dynamodb.feature@GetItemsViaQuery') GetItemsViaQueryParams
  * def FilterQueryResultsParams =
    """
      {
        Param_QueryResults: #(QueryResults.result),
        Param_FilterNestedInfoList: [
          {
            infoName: 'videoUpdates.title',
            infoValue: #(ExpectedTitle),
            infoComparator: 'contains'
          }        
        ]
      }
    """
  * def FilteredQueryResults = call read(FeatureFilePath+'/Dynamodb.feature@FilterQueryResults') FilterQueryResultsParams
  * def matchResult = karate.match(FilteredQueryResults.result.length, ExpectedWochitRenditionCount)
  * def result =
    """
      {
        result:      {
          "response": #(FilteredQueryResults.result.length),
          "message": #(matchResult.message),
          "pass": #(matchResult.pass),
          "path": 'null'
        }
      }
    """
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
  * def ExpectedTitle = RandomCTA + ' ' + Iconik_AssetName
  * def Expected_WochitMapping_Entry = read(currentTestDataPath + '/Output/Expected_WochitMapping_Entry.json')
  * def ExpectedDate = call read(FeatureFilePath + '/Date.feature@GetDateWithOffset') { offset: 0 }
  * def GetItemsViaQueryParams = 
    """
      {
        Param_TableName: #(WochitMappingTableName),
        Param_QueryInfoList: [
          {
            infoName: 'wochitRenditionStatus',
            infoValue: 'FAILED',
            infoComparator: '=',
            infoType: 'key'
          },
          {
            infoName: 'createdAt',
            infoValue: #(ExpectedDate.result),
            infoComparator: 'begins',
            infoType: 'key'
          },
          {
            infoName: 'sourceAssetName',
            infoValue: #(ExpectedTitle),
            infoComparator: 'contains',
            infoType: 'filter'
          }   
        ],
        Param_GlobalSecondaryIndex: #(WochitMappingTableGSI),
        AWSregion: #(AWSregion)
      }
    """
  * def QueryResults = call read(FeatureFilePath+'/Dynamodb.feature@GetItemsViaQuery') GetItemsViaQueryParams
  * def ValidateWochitMappingPayloadParams =
    """
      {
        Param_Actual_WochitMapping_Entry: #(QueryResults.result),
        Param_Expected_WochitMapping_Entry: #(Expected_WochitMapping_Entry),
      }
    """
  * def result = call read(FeatureFilePath+'/Dynamodb.feature@ValidateWochitMappingPayload') ValidateWochitMappingPayloadParams
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