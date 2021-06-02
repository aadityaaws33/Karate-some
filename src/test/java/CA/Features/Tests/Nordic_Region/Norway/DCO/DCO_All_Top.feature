@DCOE2E @DCO @E2E @Regression
# @parallel=false      
Feature:  DCO_All_Top

Background:
  * def TCName = 'DCO_All_Top'
  * def Country = 'Norway'
  * def EpisodeMetadataType = 'DCO'
  * def MetadataSet = 'AllTop'
  * def TCValidationType = 'imageValidation' //videoValidation or imageValidation. Used for custom report table
  * def WochitMappingTableGSI = 'country-createdAt-index'
  * callonce read('classpath:CA/Features/ReUsable/Scenarios/Background.feature') { WaitTime: 6000 }

@parallel=false
Scenario: Nordic_Norway_DCO_All_Top - Update Asset Name to Unique
  * def thisAssetTitle = RandomCTA + ' ' + Iconik_AssetName
  * def UpdateAssetNamePayload =
    """
      {
        title: "#(thisAssetTitle)"
      }
    """
  * def Iconik_UpdatedAssetURL = Iconik_AssetAPIURL + '/'+ Iconik_AssetID
  * def updateAssetNameParams =
    """
      {
        URL: "#(Iconik_UpdatedAssetURL)",
        UpdateAssetNamePayload: #(UpdateAssetNamePayload)
      }
    """
  * call read(FeatureFilePath + '/Iconik.feature@RenameAsset') updateAssetNameParams

@parallel=false
Scenario: Nordic_Norway_DCO_All_Top - Update Asset Metadata 
  * def scenarioName = 'updateAssetMetadata'
  * def UpdateAssetMetadataPayload = read(currentTCPath+'/Input/InitialUpdateDCOImagesMetadataRequest.json')
  * def ExpectedUpdateAssetMetadataResponse = read(currentTCPath+'/Output/InitialExpectedUpdateAssetMetadataResponse.json')
  * def updateAssetMetadataParams =
    """
      {
        URL: '#(Iconik_AssetUpdateMetadataAPIURL)',
        Query: '#(UpdateAssetMetadataPayload)', 
        ExpectedResponse: #(ExpectedUpdateAssetMetadataResponse),
      }
    """
  * def result = call read(FeatureFilePath + '/Iconik.feature@UpdateAssetMetadata') updateAssetMetadataParams
  * def UpdateAssetMetadataPayload = read(currentTCPath+'/Input/FinalUpdateDCOImagesMetadataRequest.json')
  * def ExpectedUpdateAssetMetadataResponse = read(currentTCPath+'/Output/FinalExpectedUpdateAssetMetadataResponse.json')
  * def updateAssetMetadataParams =
    """
      {
        URL: '#(Iconik_AssetUpdateMetadataAPIURL)',
        Query: '#(UpdateAssetMetadataPayload)', 
        ExpectedResponse: #(ExpectedUpdateAssetMetadataResponse),
      }
    """
  * def result = call read(FeatureFilePath + '/Iconik.feature@UpdateAssetMetadata') updateAssetMetadataParams
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
Scenario: Nordic_Norway_DCO_All_Top - Trigger Rendition
  * def scenarioName = 'triggerRendition'
  * def getRenditionRequestMetadataValues =
    """
      function() {
        var metadataValues = karate.read(currentTCPath + '/Input/FinalUpdateDCOImagesMetadataRequest.json');
        return metadataValues['metadata_values'];
        // if(TargetEnv == 'preprod' || TargetEnv == 'prod') {
        //   var metadataValues = karate.read(currentTCPath + '/Input/FinalUpdateDCOImagesMetadataRequest.json');
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

@parallel=false
Scenario: Nordic_Norway_DCO_All_Top - Update Asset Name to Original
  * def UpdateAssetNamePayload =
    """
      {
        title: "#(Iconik_AssetName)"
      }
    """
  * def Iconik_UpdatedAssetURL = Iconik_AssetAPIURL + '/'+ Iconik_AssetID
  * def updateAssetNameParams =
    """
      {
        URL: "#(Iconik_UpdatedAssetURL)",
        UpdateAssetNamePayload: #(UpdateAssetNamePayload)
      }
    """
  * call read(FeatureFilePath + '/Iconik.feature@RenameAsset') updateAssetNameParams
  
@parallel=false
Scenario Outline: Nordic_Norway_DCO_All_Top - Validate Wochit Renditions Table for <ASPECTRATIO>
  * def scenarioName = 'validateWochitRendition' + <ASPECTRATIO>
  * def ExpectedTitle = RandomCTA + ' ' + <FNAMEPREFIX>
  * def Expected_WochitRendition_Entry = read(currentTCPath + '/Output/Expected_WochitRendition_Entry.json')
  * def ExpectedDate = call read(FeatureFilePath + '/Date.feature@GetDateWithOffset') { offset: 0 }
  * def GetItemsViaQueryParams = 
    """
      {
        Param_TableName: #(WochitRenditionTableName),
        Param_QueryInfoList: [
          {
            infoName: 'assetType',
            infoValue: 'IMAGE',
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
            infoName: 'title',
            infoValue: #(ExpectedTitle),
            infoComparator: 'contains',
            infoType: 'filter'
          }
        ],
        Param_GlobalSecondaryIndex: #(WochitRenditionTableGSI),
        AWSregion: #(AWSregion)
      }
    """
  * def ExpectedWidth = <ASPECTRATIO>.replaceAll("'","").split("x")[0]
  * def ExpectedHeight = <ASPECTRATIO>.replaceAll("'","").split("x")[1]
  * json Expected_WochitRendition_Entry = Expected_WochitRendition_Entry
  * def retries = 15
  * def getResult =
    """
      function() {
        var matchResult = null;
        for(var i = 0; i < retries; ++i) {
          // karate.log('Try #' + (i+1) + ' of ' + retries);
          var QueryResults = karate.call(FeatureFilePath + '/Dynamodb.feature@GetItemsViaQuery', GetItemsViaQueryParams);

          var ValidateWochitRenditionPayloadParams = {
            Param_Actual_WochitRendition_Entry: QueryResults.result,
            Param_Expected_WochitRendition_Entry: Expected_WochitRendition_Entry
          };

          matchResult = karate.call(FeatureFilePath + '/Dynamodb.feature@ValidateWochitRenditionPayload', ValidateWochitRenditionPayloadParams);
          // karate.log('Result: ' + matchResult.result);
          if(matchResult.result.pass) {
            break;
          } else {
            // karate.log(Result: ' + matchResult.result);
            karate.log('Try #' + (i+1) + ' of  ' + retries + ': ' + scenarioName + ': Failed. Sleeping for 15s.');
            java.lang.Thread.sleep(15*1000);
          }
        }
        return matchResult;
      }
    """
  * def result = call getResult
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
  Examples:
    | validateWochitRenditionTestData |

Scenario Outline: Nordic_Norway_Dplus_Essential_Panel_9x16_StrapOn_CTASingleLine - Validate Placeholders and their ACLs for <ASPECTRATIO> exist
  * def scenarioName = 'validatePlaceholder' + <ASPECTRATIO>
  * def ExpectedTitle = RandomCTA + ' ' + <FNAMEPREFIX>
  * def ExpectedDate = call read(FeatureFilePath + '/Date.feature@GetDateWithOffset') { offset: 0 }
  * def GetItemsViaQueryParams = 
    """
      {
        Param_TableName: #(WochitMappingTableName),
        Param_QueryInfoList: [
          {
            infoName: 'country',
            infoValue: #(EpisodeMetadataType),
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
            infoName: 'renditionFileName',
            infoValue: #(ExpectedTitle),
            infoComparator: 'contains',
            infoType: 'filter'
          }
        ],
        Param_GlobalSecondaryIndex: #(WochitMappingTableGSI),
        AWSregion: #(AWSregion)
      }
     """
  * def retries = 15
  * def getResult =
    """
      function() {
        var QueryResult = null;
        for(var i = 0; i < retries; ++i) {
          // karate.log('Try #' + (i+1) + ' of ' + retries);
          QueryResult = karate.call(FeatureFilePath + '/Dynamodb.feature@GetItemsViaQuery', GetItemsViaQueryParams);
          var matchResult = karate.match(QueryResult.result.length, 1);
          // karate.log('Result: ' + matchResult.result);
          if(matchResult.pass) {
            break;
          } else {
            // karate.log('Result: ' + QueryResult.result);
            karate.log('Try #' + (i+1) + ' of  ' + retries + ': ' + scenarioName + ': Failed. Sleeping for 15s.');
            java.lang.Thread.sleep(15*1000);
          }
        }
        return QueryResult;
      }
    """
  * def QueryResults = call getResult
  # * print QueryResults.result
  * def RenditionAssetID = QueryResults.result[0]['renditionAssetId']
  * def FullRenditionFileName = QueryResults.result[0]['renditionFileName']
  #### PLACEHOLDER EXISTENCE CHECK ####
  * def GetAssetDataURL = Iconik_AssetAPIURL + '/' + RenditionAssetID
  * def ExpectedAssetDataType = 'PLACEHOLDER'
  * def ExpectedAssetData = read(currentTCPath + '/Output/ExpectedPlaceholderAssetData.json')
  # * print ExpectedAssetData
  * def CheckPlaceholderExistsParams =
    """
      {
        GetAssetDataURL: #(GetAssetDataURL),
        ExpectedAssetData: #(ExpectedAssetData)
      }
    """
  #### PLACEHOLDER ACL CHECK ####
  * def GetAssetACLURL = Iconik_GetAssetACLAPIURL + '/' + RenditionAssetID
  * def ExpectedAssetACL = read(currentTCPath + '/Output/ExpectedACLResponse.json')
  * def ValidateACLExistsParams = 
    """
      {
        GetAssetACLURL: #(GetAssetACLURL),
        ExpectedAssetACL: #(ExpectedAssetACL)
      }
    """
  #### FINAL RESULT ####
  * def getResult = 
    """
      function() {
        var finalResult = {}
        for(var i = 0; i < retries; ++i) {
          finalResult = {
            message: [],
            pass: true
          };
          var PlaceholderCheckResult = karate.call(FeatureFilePath + '/Iconik.feature@ValidatePlaceholderExists', CheckPlaceholderExistsParams);
          // karate.log(PlaceholderCheckResult.result);
          var PlaceholderACLCheckResult = karate.call(FeatureFilePath + '/Iconik.feature@ValidateACLExists', ValidateACLExistsParams);
          // karate.log(PlaceholderACLCheckResult);
          if(!PlaceholderCheckResult.result.pass) {
            finalResult.message.append(PlacehodlerCheckResult.result.message);
            finalResult.pass = false;
          }
          if(!PlaceholderACLCheckResult.result.pass) {
            finalResult.message.append(PlaceholderACLCheckResult.result.message);
            finalResult.pass = false;
          }
          // karate.log(karate.pretty(finalResult));
          if(finalResult.pass) {
            break;
          } else {
            // karate.log('Result: ' + finalResult);
            karate.log('Try #' + (i+1) + ' of  ' + retries + ': ' + scenarioName + ': Failed. Sleeping for 15s.');
            java.lang.Thread.sleep(15*1000);
          }
        }
        return finalResult;
      }
    """
  * def result = call getResult
  * def updateParams = 
    """
      { 
        tcName: #(TCName), 
        scenarioName: #(scenarioName), 
        result: #(result), 
        tcResultReadPath: #(tcResultReadPath), 
        tcResultWritePath: #(tcResultWritePath) 
      }
    """
  * call read(FeatureFilePath + '/Results.feature@updateResult') { updateParams: #(updateParams) })
  Examples:
    | validateWochitMappingIsFiledMovedTestData |

Scenario Outline: Nordic_Norway_DCO_All_Top - Validate MAM Asset Info table entry for Composite View ID:  <COMPOSITEVIEWID>
  * def scenarioName = 'validateTechnicalMetadata'
  * def Expected_MAMAssetInfo_Entry = read(currentTCPath + '/Output/Expected_MAMAssetInfo_Entry.json')
  * def ExpectedTitle = RandomCTA + ' ' + Iconik_AssetName
  * def ExpectedDate = call read(FeatureFilePath + '/Date.feature@GetDateWithOffset') { offset: 0 }
  * def ValidateItemViaQueryParams = 
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
            infoName: 'createdAt',
            infoValue: #(ExpectedDate.result),
            infoComparator: 'begins',
            infoType: 'filter'
          },
          {
            infoName: 'assetTitle',
            infoValue: #(ExpectedTitle),
            infoComparator: '=',
            infoType: 'filter'
          },
          {
            infoName: 'compositeViewsId',
            infoValue: <COMPOSITEVIEWID>,
            infoComparator: '=',
            infoType: 'key'
          }
        ],
        Param_GlobalSecondaryIndex: '',
        Param_ExpectedResponse: #(Expected_MAMAssetInfo_Entry),
        AWSregion: #(AWSregion)
      }
    """
  * def retries = 15
  * def getResult =
    """
      function() {
        var matchResult = null;
        for(var i = 0; i < retries; ++i) {
          // karate.log('Try #' + (i+1) + ' of ' + retries);
          matchResult = karate.call(FeatureFilePath + '/Dynamodb.feature@ValidateItemViaQuery', ValidateItemViaQueryParams);
          // karate.log('Result: ' + matchResult.result);
          if(matchResult.result.pass) {
            break;
          } else {
            // karate.log('Result: ' + matchResult.result);
            karate.log('Try #' + (i+1) + ' of  ' + retries + ': ' + scenarioName + ': Failed. Sleeping for 15s.');
            java.lang.Thread.sleep(15*1000);
          }
        }
        return matchResult;
      }
    """
  * def result = call getResult
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
  Examples:
    | validateTechnicalMetadataTestData |

Scenario Outline: Nordic_Norway_DCO_All_Top - PROCESSING - Validate Wochit Mapping table entry for Aspect Ratio: <ASPECTRATIO> [wochitRenditionStatus: <RENDITIONSTATUS> - isRenditionMoved: <ISRENDITIONMOVED>]
  * def scenarioName = 'validateWochitMappingProcessing' + <ASPECTRATIO>
  * def ExpectedTitle = RandomCTA + ' ' + <FNAMEPREFIX>
  * def Expected_WochitMapping_Entry = read(currentTCPath + '/Output/Expected_WochitMapping_Entry.json')
  * def ExpectedDate = call read(FeatureFilePath + '/Date.feature@GetDateWithOffset') { offset: 0 }
  * def ValidateItemViaQueryParams = 
    """
      {
        Param_TableName: #(WochitMappingTableName),
        Param_QueryInfoList: [
          {
            infoName: 'country',
            infoValue: #(EpisodeMetadataType),
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
            infoName: 'renditionFileName',
            infoValue: #(ExpectedTitle),
            infoComparator: 'contains',
            infoType: 'filter'
          }
        ],
        Param_GlobalSecondaryIndex: #(WochitMappingTableGSI),
        Param_ExpectedResponse: #(Expected_WochitMapping_Entry),
        AWSregion: #(AWSregion)
      }
    """
  * def retries = 15
  * def getResult =
    """
      function() {
        var matchResult = null;
        for(var i = 0; i < retries; ++i) {
          // karate.log('Try #' + (i+1) + ' of ' + retries);
          matchResult = karate.call(FeatureFilePath + '/Dynamodb.feature@ValidateItemViaQuery', ValidateItemViaQueryParams);
          // karate.log('Result: ' + matchResult.result);
          if(matchResult.result.pass) {
            break;
          } else {
            // karate.log('Result: ' + matchResult.result);
            karate.log('Try #' + (i+1) + ' of  ' + retries + ': ' + scenarioName + ': Failed. Sleeping for 15s.');
            java.lang.Thread.sleep(15*1000);
          }
        }
        return matchResult;
      }
    """
  * def result = call getResult
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
  Examples:
    | validateWochitMappingProcessingTestData |

Scenario: Nordic_Norway_DCO_All_Top - Validate Item Counts - MAM Asset Info
  * def scenarioName = "validateMAMAssetCount"
  * def thisAssetTitle = RandomCTA + ' ' + Iconik_AssetName
  * def ExpectedDate = call read(FeatureFilePath + '/Date.feature@GetDateWithOffset') { offset: 0 }
  * def GetItemsViaQueryParams = 
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
            infoName: 'createdAt',
            infoValue: #(ExpectedDate.result),
            infoComparator: 'begins',
            infoType: 'filter'
          }
          {
            infoName: 'assetTitle',
            infoValue: #(thisAssetTitle),
            infoComparator: 'contains',
            infoType: 'filter'
          }
        ],
        Param_GlobalSecondaryIndex: '',
        AWSregion: #(AWSregion)
      }
    """
  * def retries = 15
  * def getResult =
    """
      function() {
        var matchResult = null;
        for(var i = 0; i < retries; ++i) {
          // karate.log('Try #' + (i+1) + ' of ' + retries);
          var QueryResults = karate.call(FeatureFilePath + '/Dynamodb.feature@GetItemsViaQuery', GetItemsViaQueryParams);
          matchResult = karate.match(QueryResults.result.length, ExpectedMAMAssetInfoCount);
          // karate.log('Result: ' + matchResult);
          if(matchResult.pass) {
            break;
          } else {
            // karate.log('Result: ' + matchResult);
            karate.log('Try #' + (i+1) + ' of  ' + retries + ': ' + scenarioName + ': Failed. Sleeping for 15s.');
            java.lang.Thread.sleep(15*1000);
          }
        }
        return matchResult;
      }
    """
  * def result = call getResult
  * def updateParams = 
    """
      { 
        tcName: #(TCName), 
        scenarioName: #(scenarioName), 
        result: #(result), 
        tcResultReadPath: #(tcResultReadPath), 
        tcResultWritePath: #(tcResultWritePath) 
      }
    """
  * call read(FeatureFilePath + '/Results.feature@updateResult') { updateParams: #(updateParams) })

Scenario: Nordic_Norway_DCO_All_Top - Validate Item Counts - Wochit Rendition
  * def scenarioName = "validateWochitRenditionCount"
  * def ExpectedTitle = RandomCTA
  * def ExpectedDate = call read(FeatureFilePath + '/Date.feature@GetDateWithOffset') { offset: 0 }
  * def GetItemsViaQueryParams = 
    """
      {
        Param_TableName: #(WochitRenditionTableName),
        Param_QueryInfoList: [
          {
            infoName: 'assetType',
            infoValue: 'IMAGE',
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
            infoName: 'title',
            infoValue: #(ExpectedTitle),
            infoComparator: 'contains',
            infoType: 'filter'
          }
        ],
        Param_GlobalSecondaryIndex: #(WochitRenditionTableGSI),
        AWSregion: #(AWSregion)
      }
    """
  * def retries = 15
  * def getResult =
    """
      function() {
        var matchResult = null;
        for(var i = 0; i < retries; ++i) {
          // karate.log('Try #' + (i+1) + ' of ' + retries);
          var QueryResults = karate.call(FeatureFilePath + '/Dynamodb.feature@GetItemsViaQuery', GetItemsViaQueryParams);
          matchResult = karate.match(QueryResults.result.length, ExpectedWochitRenditionCount);
          // karate.log('Result: ' + matchResult);
          if(matchResult.pass) {
            break;
          } else {
            // karate.log('Result: ' + matchResult);
            karate.log('Try #' + (i+1) + ' of  ' + retries + ': ' + scenarioName + ': Failed. Sleeping for 15s.');
            java.lang.Thread.sleep(15*1000);
          }
        }
        return matchResult;
      }
    """
  * def result = call getResult
  * def updateParams = 
    """
      { 
        tcName: #(TCName), 
        scenarioName: #(scenarioName), 
        result: #(result), 
        tcResultReadPath: #(tcResultReadPath), 
        tcResultWritePath: #(tcResultWritePath) 
      }
    """
  * call read(FeatureFilePath + '/Results.feature@updateResult') { updateParams: #(updateParams) })

Scenario: Nordic_Norway_DCO_All_Top - Validate Item Counts - Wochit Mapping
  * def scenarioName = "validateWochitMappingCount"
  * def ExpectedTitle = RandomCTA
  * def ExpectedDate = call read(FeatureFilePath + '/Date.feature@GetDateWithOffset') { offset: 0 }
  * def GetItemsViaQueryParams = 
    """
      {
        Param_TableName: #(WochitMappingTableName),
        Param_QueryInfoList: [
          {
            infoName: 'country',
            infoValue: #(EpisodeMetadataType),
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
            infoName: 'renditionFileName',
            infoValue: #(ExpectedTitle),
            infoComparator: 'contains',
            infoType: 'filter'
          }
        ],
        Param_GlobalSecondaryIndex: #(WochitMappingTableGSI),
        Param_ExpectedItemCount: #(ExpectedWochitMappingCount),
        AWSregion: #(AWSregion)
      }
    """
  * def retries = 15
  * def getResult =
    """
      function() {
        var matchResult = null;
        for(var i = 0; i < retries; ++i) {
          // karate.log('Try #' + (i+1) + ' of ' + retries);
          var QueryResults = karate.call(FeatureFilePath + '/Dynamodb.feature@GetItemsViaQuery', GetItemsViaQueryParams);
          matchResult = karate.match(QueryResults.result.length, ExpectedWochitMappingCount);
          // karate.log('Result: ' + matchResult);
          if(matchResult.pass) {
            break;
          } else {
            // karate.log('Result: ' + matchResult);
            karate.log('Try #' + (i+1) + ' of  ' + retries + ': ' + scenarioName + ': Failed. Sleeping for 15s.');
            java.lang.Thread.sleep(15*1000);
          }
        }
        return matchResult;
      }
    """
  * def result = call getResult
  * def updateParams = 
    """
      { 
        tcName: #(TCName), 
        scenarioName: #(scenarioName), 
        result: #(result), 
        tcResultReadPath: #(tcResultReadPath), 
        tcResultWritePath: #(tcResultWritePath) 
      }
    """
  * call read(FeatureFilePath + '/Results.feature@updateResult') { updateParams: #(updateParams) })

@parallel=false
Scenario: Hard wait for PROCESSING to FINISH
  # RUN ONLY IN E2E, DO NOT RUN IN REGRESSION
  * configure abortedStepsShouldPass = true
  * eval if (!TargetTag.contains('E2E')) {karate.abort();}
  # ---------
  * call Pause 60000*4

Scenario Outline: Nordic_Norway_DCO_All_Top - FINISHED - Validate Wochit Mapping table entry for Aspect Ratio: <ASPECTRATIO> [wochitRenditionStatus: <RENDITIONSTATUS> - isRenditionMoved: <ISRENDITIONMOVED>]
  # RUN ONLY IN E2E, DO NOT RUN IN REGRESSION
  * configure abortedStepsShouldPass = true
  * eval if (!TargetTag.contains('E2E')) {karate.abort();}
  # ---------
  * def scenarioName = 'validateWochitMappingIsFiledMoved' + <ASPECTRATIO>
  * def ExpectedTitle = RandomCTA + ' ' + <FNAMEPREFIX>
  * def Expected_WochitMapping_Entry = read(currentTCPath + '/Output/Expected_WochitMapping_Entry.json')
  * def ExpectedDate = call read(FeatureFilePath + '/Date.feature@GetDateWithOffset') { offset: 0 }
  * def ValidateItemViaQueryParams = 
    """
      {
        Param_TableName: #(WochitMappingTableName),
        Param_QueryInfoList: [
          {
            infoName: 'country',
            infoValue: #(EpisodeMetadataType),
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
            infoName: 'renditionFileName',
            infoValue: #(ExpectedTitle),
            infoComparator: 'contains',
            infoType: 'filter'
          }
        ],
        Param_GlobalSecondaryIndex: #(WochitMappingTableGSI),
        Param_ExpectedResponse: #(Expected_WochitMapping_Entry),
        AWSregion: #(AWSregion)
      }
    """
  * def retries = 15
  * def getResult = 
    """
      function() {
        var matchResult = null;
        for(var i = 0; i < retries; ++i) {
          // karate.log('Try #' + (i+1) + ' of ' + retries);
          matchResult = karate.call(FeatureFilePath + '/Dynamodb.feature@ValidateItemViaQuery', ValidateItemViaQueryParams);
          if(matchResult.result.pass) {
            break;
          } else {
            // karate.log('Result: ' + matchResult.result);
            karate.log('Try #' + (i+1) + ' of  ' + retries + ': ' + scenarioName + ': Failed. Sleeping for 30s.');
            java.lang.Thread.sleep(30*1000);
          }

        }
        return matchResult;
      }
    """
  * def result = call getResult
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
  Examples:
    | validateWochitMappingIsFiledMovedTestData |

Scenario Outline: Nordic_Norway_DCO_All_Top - Validate if <ASPECTRATIO> S3 Asset exists
  # RUN ONLY IN E2E, DO NOT RUN IN REGRESSION
  * configure abortedStepsShouldPass = true
  * eval if (!TargetTag.contains('E2E')) {karate.abort();}
  # ---------
  * def scenarioName = 'validateS3AssetExists' + <ASPECTRATIO>
  * def ExpectedTitle = RandomCTA + ' ' + <FNAMEPREFIX>
  * def ExpectedDate = call read(FeatureFilePath + '/Date.feature@GetDateWithOffset') { offset: 0 }
  * def ValidateItemViaQueryParams = 
    """
      {
        Param_TableName: #(WochitMappingTableName),
        Param_QueryInfoList: [
          {
            infoName: 'country',
            infoValue: #(EpisodeMetadataType),
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
            infoName: 'renditionFileName',
            infoValue: #(ExpectedTitle),
            infoComparator: 'contains',
            infoType: 'filter'
          }
        ],
        Param_GlobalSecondaryIndex: #(WochitMappingTableGSI),
        AWSregion: #(AWSregion)
      }
    """
  * def QueryResults = call read(FeatureFilePath + '/Dynamodb.feature@GetItemsViaQuery') ValidateItemViaQueryParams
  * def FullRenditionFileName = QueryResults.result[0]['renditionFileName'] + '.png'
  * def validateS3ObjectExists =
    """
      function() {
        var AWSUtilsClass = Java.type('AWSUtils.AWSUtils');
        var AWSUtils = new AWSUtilsClass();
        var FullObjectKey = RenditionsFolderName + '/' + FullRenditionFileName;
        karate.log('Full Object Key: ' + FullObjectKey);

        var isExist = AWSUtils.isS3ObjectExists(
          AssetBucketName,
          FullObjectKey,
          S3Region
        )
        
        var finalResult = {
          result: isExist,
          pass: isExist
        }

        return finalResult;
      }
    """
  * def retries = 15
  * def getResult = 
    """
      function() {
        var matchResult = null;
        for(var i = 0; i < retries; ++i) {
          // karate.log('Try #' + (i+1) + ' of ' + retries);
          // matchResult = karate.call(FeatureFilePath + '/Dynamodb.feature@ValidateItemViaQuery', ValidateItemViaQueryParams);
          matchResult = validateS3ObjectExists();
          if(matchResult.pass) {
            break;
          } else {
            // karate.log('Result: ' + matchResult)
            karate.log('Try #' + (i+1) + ' of  ' + retries + ': ' + scenarioName + ': Failed. Sleeping for 30s.');
            java.lang.Thread.sleep(30*1000);
          }

        }
        return matchResult;
      }
    """
  * def result = call getResult
  # * def result = call validateS3ObjectExists
  # * print result
  * def updateParams = 
    """
      { 
        tcName: #(TCName), 
        scenarioName: #(scenarioName), 
        result: #(result), 
        tcResultReadPath: #(tcResultReadPath), 
        tcResultWritePath: #(tcResultWritePath) 
      }
    """
  * call read(FeatureFilePath + '/Results.feature@updateResult') { updateParams: #(updateParams) })
  Examples:
    | validateWochitMappingIsFiledMovedTestData |

Scenario Outline: Nordic_Norway_Dplus_Essential_Panel_9x16_StrapOn_CTASingleLine - Validate Associated Assets and their ACLs for <ASPECTRATIO> exist
  # RUN ONLY IN E2E, DO NOT RUN IN REGRESSION
  * configure abortedStepsShouldPass = true
  * eval if (!TargetTag.contains('E2E')) {karate.abort();}
  # ---------
  * def scenarioName = 'validatePlaceholder' + <ASPECTRATIO>
  * def ExpectedTitle = RandomCTA + ' ' + <FNAMEPREFIX>
  * def ExpectedDate = call read(FeatureFilePath + '/Date.feature@GetDateWithOffset') { offset: 0 }
  * def GetItemsViaQueryParams = 
    """
      {
        Param_TableName: #(WochitMappingTableName),
        Param_QueryInfoList: [
          {
            infoName: 'country',
            infoValue: #(EpisodeMetadataType),
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
            infoName: 'renditionFileName',
            infoValue: #(ExpectedTitle),
            infoComparator: 'contains',
            infoType: 'filter'
          }
        ],
        Param_GlobalSecondaryIndex: #(WochitMappingTableGSI),
        AWSregion: #(AWSregion)
      }
     """
  * def retries = 15
  * def getResult =
    """
      function() {
        var QueryResult = null;
        for(var i = 0; i < retries; ++i) {
          // karate.log('Try #' + (i+1) + ' of ' + retries);
          QueryResult = karate.call(FeatureFilePath + '/Dynamodb.feature@GetItemsViaQuery', GetItemsViaQueryParams);
          var matchResult = karate.match(QueryResult.result.length, 1);
          // karate.log('Result: ' + matchResult.result);
          if(matchResult.pass) {
            break;
          } else {
            // karate.log('Result: ' + QueryResult.result);
            karate.log('Try #' + (i+1) + ' of  ' + retries + ': ' + scenarioName + ': Failed. Sleeping for 15s.');
            java.lang.Thread.sleep(15*1000);
          }
        }
        return QueryResult;
      }
    """
  * def QueryResults = call getResult
  # * print QueryResults.result
  * def RenditionAssetID = QueryResults.result[0]['renditionAssetId']
  * def FullRenditionFileName = QueryResults.result[0]['renditionFileName']
  #### PLACEHOLDER EXISTENCE CHECK ####
  * def GetAssetDataURL = Iconik_AssetAPIURL + '/' + RenditionAssetID
  * def ExpectedAssetDataType = 'ASSET'
  * def ExpectedAssetData = read(currentTCPath + '/Output/ExpectedAssociatedAssetData.json')
  * def CheckPlaceholderExistsParams =
    """
      {
        GetAssetDataURL: #(GetAssetDataURL),
        ExpectedAssetData: #(ExpectedAssetData)
      }
    """
  #### PLACEHOLDER ACL CHECK ####
  * def GetAssetACLURL = Iconik_GetAssetACLAPIURL + '/' + RenditionAssetID
  * def ExpectedAssetACL = read(currentTCPath + '/Output/ExpectedACLResponse.json')
  * def ValidateACLExistsParams = 
    """
      {
        GetAssetACLURL: #(GetAssetACLURL),
        ExpectedAssetACL: #(ExpectedAssetACL)
      }
    """
  #### FINAL RESULT ####
  * def getResult = 
    """
      function() {
        var finalResult = {
          message: [],
          pass: true
        };
        for(var i = 0; i < retries; ++i) {
          var PlaceholderCheckResult = karate.call(FeatureFilePath + '/Iconik.feature@ValidatePlaceholderExists', CheckPlaceholderExistsParams);
          // karate.log(PlaceholderCheckResult.result);
          var PlaceholderACLCheckResult = karate.call(FeatureFilePath + '/Iconik.feature@ValidateACLExists', ValidateACLExistsParams);
          // karate.log(PlaceholderACLCheckResult);
          // var result = PlaceholderCheckResult.result.pass &&  PlaceholderACLCheckResult.result.pass;
          if(!PlaceholderCheckResult.result.pass) {
            finalResult.message.append(PlacehodlerCheckResult.result.message);
            finalResult.pass = false;
          }
          if(!PlaceholderACLCheckResult.result.pass) {
            finalResult.message.append(PlaceholderACLCheckResult.result.message);
            finalResult.pass = false;
          }
          
          if(finalResult.pass) {
            break;
          } else {
            // karate.log('Result: ' + finalResult);
            karate.log('Try #' + (i+1) + ' of  ' + retries + ': ' + scenarioName + ': Failed. Sleeping for 15s.');
            java.lang.Thread.sleep(15*1000);
          }
        }
        return finalResult;
      }
    """
  * def result = call getResult
  * def updateParams = 
    """
      { 
        tcName: #(TCName), 
        scenarioName: #(scenarioName), 
        result: #(result), 
        tcResultReadPath: #(tcResultReadPath), 
        tcResultWritePath: #(tcResultWritePath) 
      }
    """
  * call read(FeatureFilePath + '/Results.feature@updateResult') { updateParams: #(updateParams) })
  Examples:
    | validateWochitMappingIsFiledMovedTestData |