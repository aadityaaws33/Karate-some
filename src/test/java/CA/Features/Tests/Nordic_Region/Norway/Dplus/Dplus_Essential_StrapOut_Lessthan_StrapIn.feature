@E2E @Regression @Norway @parallel=false @Edge @Dplus
Feature:  Dplus_Essential_StrapOut_Lessthan_StrapIn

Background:
  # NEW
  * def TCName = 'Dplus_Essential_StrapOut_Lessthan_StrapIn'
  * def Country = 'Norway'
  * def EpisodeMetadataType = 'Dplus'
  * def MetadataSet = 'StrapOutLessthanStrapIn'
  * def TCValidationType = 'videoValidation' //videoValidation or imageValidation. Used for custom report table
  * def WochitMappingTableGSI = 'wochitRenditionStatus-createdAt-index'
  * callonce read('classpath:CA/Features/ReUsable/Scenarios/Background.feature') { WaitTime: 4000 }

@parallel=false
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
  * call read(FeatureFilePath + '/Iconik.feature@RenameAsset') updateAssetNameParams
  * call Pause 1000

@parallel=false
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
  * def result = call read(FeatureFilePath + '/Iconik.feature@TriggerRendition') renditionParams
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
  * call Pause 20000

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
  * def result = call read(FeatureFilePath + '/Dynamodb.feature@ValidateItemCountViaQuery') ValidateItemCountViaQueryParams
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
  * def QueryResults = call read(FeatureFilePath + '/Dynamodb.feature@GetItemsViaQuery') GetItemsViaQueryParams
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
  * def FilteredQueryResults = call read(FeatureFilePath + '/Dynamodb.feature@FilterQueryResults') FilterQueryResultsParams
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
  * def Expected_WochitMapping_Entry = read(currentTCPath + '/Output/Expected_WochitMapping_Entry.json')
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
  * def QueryResults = call read(FeatureFilePath + '/Dynamodb.feature@GetItemsViaQuery') GetItemsViaQueryParams
  * def ValidateWochitMappingPayloadParams =
    """
      {
        Param_Actual_WochitMapping_Entry: #(QueryResults.result),
        Param_Expected_WochitMapping_Entry: #(Expected_WochitMapping_Entry),
      }
    """
  * def result = call read(FeatureFilePath + '/Dynamodb.feature@ValidateWochitMappingPayload') ValidateWochitMappingPayloadParams
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

@parallel=false
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
  * call read(FeatureFilePath + '/Iconik.feature@RenameAsset') updateAssetNameParams