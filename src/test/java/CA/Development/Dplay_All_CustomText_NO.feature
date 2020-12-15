@parallel=false 
Feature:  Dplay_All_CustomText_NO

Background:
  # NEW
  * def TCName = 'Dplay_All_CustomText_NO'
  * def Country = 'Norway'
  * def EpisodeMetadataType = 'Dplay'
  * def AspectRatioSet = 'All'
  * def AWSregion = EnvData[Country]['AWSregion']
  * def WochitMappingTableName = EnvData[Country]['WochitMappingTableName']
  * def WochitMappingTableGSI = EnvData[Country]['WochitMappingTableGSI']
  * def WochitRenditionTableName = EnvData[Country]['WochitRenditionTableName']
  * def MAMAssetsInfoTableName = EnvData[Country]['MAMAssetsInfoTableName']
  # Iconik Stuff Start
  * def Iconik_EpisodeVersionID = EnvData[Country]['Iconik_EpisodeVersionID']
  * def Iconik_EpisodeMetadataObjectID = EnvData[Country]['Iconik_EpisodeMetadataObjectID']
  * def Iconik_AssetID = EnvData[Country]['Iconik_AssetID']
  * def Iconik_SeasonCollectionID = EnvData[Country]['Iconik_SeasonCollectionID']  
  * def Iconik_TriggerRenditionCustomActionName = EnvData[Country]['Iconik_TriggerRenditionCustomActionName'][EpisodeMetadataType]
  * def Iconik_TriggerRenditionCustomActionID = EnvData[Country]['Iconik_TriggerRenditionCustomActionID']
  * def Iconik_TechnicalMetadataID = EnvData[Country]['Iconik_TechnicalMetadataID']
  * def Iconik_TechnicalMetadataObjectID = EnvData[Country]['Iconik_TechnicalMetadataObjectID']
  * def Iconik_TechnicalMetadataObjectName = EnvData[Country]['Iconik_TechnicalMetadataObjectName']
  * def Iconik_SystemDomainID = EnvData[Country]['Iconik_SystemDomainID']
  * def Iconik_UpdateSeasonURL =  EnvData[Country]['Iconik_UpdateSeasonURL']
  * def Iconik_UpdateEpisodeURL =  EnvData[Country]['Iconik_UpdateEpisodeURL'][EpisodeMetadataType]
  # Iconik Stuff End
  * def TCValidationType = 'videoValidation' //videoValidation or imageValidation. Used for custom report table
  * def tcResultWritePath = 'test-classes/' + TCName + '.json'
  * def tcResultReadPath = 'classpath:target/' + tcResultWritePath
  * def finalResultWritePath = 'test-classes/Results.json'
  * def finalResultReadPath = 'classpath:target/' + finalResultWritePath
  * def currentTCPath = 'classpath:CA/TestData/E2ECases/' + AWSregion + '_Region/' + Country + '/' + TCName
  * def FeatureFilePath = 'classpath:CA/Features/ReUsable'
  # Scenario Outline Examples Start
  * def validateTechnicalMetadataTestData = read(currentTCPath + '/ScenarioOutlineExamples/validateTechnicalMetadata.json')[TargetEnv][AspectRatioSet]
  * def validateWochitRenditionTestData = read(currentTCPath + '/ScenarioOutlineExamples/validateWochitRendition.json')[TargetEnv][AspectRatioSet]
  * def validateWochitMappingProcessingTestData = read(currentTCPath + '/ScenarioOutlineExamples/validateWochitMappingProcessing.json')[TargetEnv][AspectRatioSet]
  * def validateWochitMappingIsFiledMovedTestData = read(currentTCPath + '/ScenarioOutlineExamples/validateWochitMappingIsFiledMoved.json')[TargetEnv][AspectRatioSet]
  # Scenario Outline Examples End
  # NEW
  * def GetRenditionHTTPInfoParams =
    """
      {
        URL: #(Iconik_TriggerRenditionCustomActionListURL),
        Iconik_TriggerRenditionCustomActionName: #(Iconik_TriggerRenditionCustomActionName),
        Auth_Token: #(Auth_Token),
        App_ID: #(App_ID)
      }
    """
  * def IconikRenditionURLInfo = call read(FeatureFilePath + '/Iconik.feature@GetRenditionHTTPInfo') GetRenditionHTTPInfoParams
  * def TriggerRenditionURL = IconikRenditionURLInfo.result.URL
  * def IconikCredentials =
    """
      {
        username: #(IconikRenditionURLInfo.result.username),
        password: #(IconikRenditionURLInfo.result.password)
      }
    """
  * print TriggerRenditionURL
  * print IconikCredentials
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
  * def Random_String_Generator = function(){ return java.lang.System.currentTimeMillis() }
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

Scenario: Nordic_Norway_Dplay_All_CustomText_NO - Update Season 
  * def scenarioName = 'updateSeason'
  * def UpdateSeasonquery = read(currentTCPath+'/Input/SeasonRequest.json')
  * replace UpdateSeasonquery.SeriesTitle = RandomSeriesTitle
  * def Season_expectedResponse = read(currentTCPath+'/Output/ExpectedSeasonResponse.json')
  * def updateSeasonParams =
    """
      {
        URL: '#(Iconik_UpdateSeasonURL)',
        Query: '#(UpdateSeasonquery)', 
        ExpectedResponse: #(Season_expectedResponse),
      }
    """
  * def result = call read(FeatureFilePath+'/UpdateSeason.feature') updateSeasonParams
  * print result
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

Scenario: Nordic_Norway_Dplay_All_CustomText_NO - Update Episode 
  * def scenarioName = 'updateEpisode'
  * def UpdateEpisodequery = read(currentTCPath+'/Input/EpisodeRequest.json')
  * replace UpdateEpisodequery.CallOutText = RandomCalloutText
  * replace UpdateEpisodequery.CTA = RandomCTA
  * def Episode_ExpectedResponse = read(currentTCPath+'/Output/ExpectedEpisodeResponse.json')
  * def updateEpisodeParams =
    """
      {
        URL: '#(Iconik_UpdateEpisodeURL)',
        Query: '#(UpdateEpisodequery)',
        ExpectedResponse: '#(Episode_ExpectedResponse)'
      }
    """
  * def result = call read(FeatureFilePath+'/UpdateEpisode.feature') updateEpisodeParams
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

Scenario: Nordic_Norway_Dplay_All_CustomText_NO - Trigger Rendition
  * def scenarioName = 'triggerRendition'
  * def getRenditionRequestMetadataValues =
    """
      function() {
        if(TargetEnv == 'preprod') {
          var metadataValues = karate.read(currentTCPath + '/Input/EpisodeRequest.json');
          return metadataValues['metadata_values'];
        } else {
          return null;
        }
      }
    """
  * def RenditionRequestMetadataValues = call getRenditionRequestMetadataValues
  * def Renditionquery = read(currentTCPath+'/Input/RenditionRequest.json')
  * def Rendition_ExpectedResponse = read(currentTCPath+'/Output/ExpectedRenditionResponse.json')
  * def renditionParams = 
    """
      {
        URL: #(TriggerRenditionURL),
        RenditionQuery: '#(Renditionquery)',
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
  * call Pause 35000
    
# Scenario: Nordic_Norway_Dplay_All_CustomText_NO - Validate Item Counts - MAM Asset Info
#   * def scenarioName = "validateMAM"
#   * def ExpectedMAMAssetInfoCount = 5
#   * def ValidateItemCountViaQueryParams = 
#     """
#       {
#         Param_TableName: #(MAMAssetsInfoTableName),
#         Param_QueryInfoList: [
#           {
#             infoName: 'assetId',
#             infoValue: #(Iconik_AssetID),
#             infoComparator: '=',
#             infoType: 'key'
#           }
#         ],
#         Param_GlobalSecondaryIndex: '',
#         Param_ExpectedItemCount: #(ExpectedMAMAssetInfoCount),
#         AWSregion: #(AWSregion)
#       }
#     """
#   * def result = call read(FeatureFilePath+'/Dynamodb.feature@ValidateItemCountViaQuery') ValidateItemCountViaQueryParams
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

# Scenario: Nordic_Norway_Dplay_All_CustomText_NO - Validate Item Counts - Wochit Rendition
#   * def scenarioName = "validateWochitRenditionCount"
#   * def ExpectedWocRenditionCount = 3
#   * def ExpectedTitle = RandomCalloutText+'-'+RandomCTA
#   * def itemCountScanParams = 
#     """
#       {
#         Param_TableName: #(WochitRenditionTableName),
#         Param_Atr1: 'videoUpdates.title',
#         Param_Atrvalue1: #(ExpectedTitle),
#         Param_Operator: 'contains',
#         Param_ExpectedItemCount: #(ExpectedWocRenditionCount),
#         AWSregion: #(AWSregion)
#       }    
#     """
#   * def result = call read(FeatureFilePath+'/Dynamodb.feature@ItemCountScan') itemCountScanParams
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

# Scenario: Nordic_Norway_Dplay_All_CustomText_NO - Validate Item Counts - Wochit Mapping
#   * def scenarioName = "validateWochitMappingCount"
#   * def ExpectedWochitMappingCount = 3
#   * def ExpectedTitle = RandomCalloutText+'-'+RandomCTA
#   * def ValidateItemCountViaQueryParams = 
#     """
#       {
#         Param_TableName: #(WochitMappingTableName),
#         Param_QueryInfoList: [
#           {
#             infoName: 'mamAssetInfoReferenceId',
#             infoValue: #(Iconik_AssetID),
#             infoComparator: '=',
#             infoType: 'key'
#           },
#           {
#             infoName: 'renditionFileName',
#             infoValue: #(ExpectedTitle),
#             infoComparator: 'contains',
#             infoType: 'filter'
#           }
#         ],
#         Param_GlobalSecondaryIndex: #(WochitMappingTableGSI),
#         Param_ExpectedItemCount: #(ExpectedWochitMappingCount),
#         AWSregion: #(AWSregion)
#       }
#     """
#   * def result = call read(FeatureFilePath+'/Dynamodb.feature@ValidateItemCountViaQuery') ValidateItemCountViaQueryParams
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

# Scenario Outline: Nordic_Norway_Dplay_All_CustomText_NO - Validate Wochit Renditions Table for <ASPECTRATIO>
#   * def scenarioName = 'validateWochitRendition' + <ASPECTRATIO>
#   * def RenditionFileName = <FNAMEPREFIX>+'-'+RandomCalloutText+'-'+RandomCTA
#   * def Expected_WochitRendition_Entry = read(currentTCPath + '/Output/Expected_WochitRendition_Entry.json')
#   * def validateRenditionPayloadParams =
#     """
#       {
#         Param_TableName: #(WochitRenditionTableName),
#         Param_ScanAttr1: 'videoUpdates.title',
#         Param_ScanVal1: #(RenditionFileName),
#         Param_ScanAttr2:'aspectRatio',
#         Param_ScanVal2: <ScanVal>,
#         Expected_WochitRendition_Entry: #(Expected_WochitRendition_Entry),
#          AWSregion: #(AWSregion)
#       }
#     """
#   * def result = call read(FeatureFilePath+'/Dynamodb.feature@ValidateWochitRenditionPayload') validateRenditionPayloadParams
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
#   Examples:
#     | validateWochitRenditionTestData |

# Scenario Outline: Nordic_Norway_Dplay_All_CustomText_NO - Validate Technical Metadata for Sort Key <COMPOSITEVIEWID>
#   * def scenarioName = 'validateTechnicalMetadata'
#   * def Expected_MAMAssetInfo_Entry = read(currentTCPath + '/Output/Expected_MAMAssetInfo_Entry.json')
#   * def ValidateItemViaQueryParams = 
#     """
#       {
#         Param_TableName: #(MAMAssetsInfoTableName),
#         Param_QueryInfoList: [
#           {
#             infoName: 'assetId',
#             infoValue: #(Iconik_AssetID),
#             infoComparator: '=',
#             infoType: 'key'
#           },
#           {
#             infoName: 'compositeViewsId',
#             infoValue: <COMPOSITEVIEWID>,
#             infoComparator: '=',
#             infoType: 'key'
#           }
#         ],
#         Param_GlobalSecondaryIndex: '',
#         Param_ExpectedResponse: #(Expected_MAMAssetInfo_Entry),
#         AWSregion: #(AWSregion)
#       }
#     """
#   * def result = call read(FeatureFilePath+'/Dynamodb.feature@ValidateItemViaQuery') ValidateItemViaQueryParams
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
#   Examples:
#     | validateTechnicalMetadataTestData |

# Scenario Outline: Nordic_Norway_Dplay_All_CustomText_NO - Validate Wochit Mapping Table for Aspect Ratio <ASPECTRATIO> [wochitRenditionStatus: <RENDITIONSTATUS> - isRenditionMoved: <ISRENDITIONMOVED>]
#   * def scenarioName = 'validateWochitMappingProcessing' + <ASPECTRATIO>
#   * def RenditionFileName = <FNAMEPREFIX>+'-'+RandomCalloutText+'-'+RandomCTA
#   * def Expected_WochitMapping_Entry = read(currentTCPath + '/Output/Expected_WochitMapping_Entry.json')
#   * def ValidateItemViaQueryParams = 
#     """
#       {
#         Param_TableName: #(WochitMappingTableName),
#         Param_QueryInfoList: [
#           {
#             infoName: 'mamAssetInfoReferenceId',
#             infoValue: #(Iconik_AssetID),
#             infoComparator: '=',
#             infoType: 'key'
#           },
#           {
#             infoName: 'renditionFileName',
#             infoValue: #(RenditionFileName),
#             infoComparator: 'contains',
#             infoType: 'filter'
#           }
#         ],
#         Param_GlobalSecondaryIndex: #(WochitMappingTableGSI),
#         Param_ExpectedResponse: #(Expected_WochitMapping_Entry),
#         AWSregion: #(AWSregion)
#       }
#     """
#   * def result = call read(FeatureFilePath+'/Dynamodb.feature@ValidateItemViaQuery') ValidateItemViaQueryParams
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
#   Examples:
#     | validateWochitMappingProcessingTestData |

# Scenario Outline: Nordic_Norway_Dplay_All_CustomText_NO - Validate Wochit Mapping Table for Aspect Ratio <ASPECTRATIO> [wochitRenditionStatus: <RENDITIONSTATUS> - isRenditionMoved: <ISRENDITIONMOVED>]
#   # RUN ONLY IN E2E, DO NOT RUN IN REGRESSION
#   * configure abortedStepsShouldPass = true
#   * eval if (TargetTag.contains('Regression') || TargetTag.contains('WIP')) {karate.abort()}
#   # ---------
#   * def scenarioName = 'validateWochitMappingIsFiledMoved' + <ASPECTRATIO>
#   * def RenditionFileName = <FNAMEPREFIX>+'-'+RandomCalloutText+'-'+RandomCTA
#   * def Expected_WochitMapping_Entry = read(currentTCPath + '/Output/Expected_WochitMapping_Entry.json')
#   * def retries = 10
#   * def ValidateItemViaQueryParams = 
#     """
#       {
#         Param_TableName: #(WochitMappingTableName),
#         Param_QueryInfoList: [
#           {
#             infoName: 'mamAssetInfoReferenceId',
#             infoValue: #(Iconik_AssetID),
#             infoComparator: '=',
#             infoType: 'key'
#           },
#           {
#             infoName: 'renditionFileName',
#             infoValue: #(RenditionFileName),
#             infoComparator: 'contains',
#             infoType: 'filter'
#           }
#         ],
#         Param_GlobalSecondaryIndex: #(WochitMappingTableGSI),
#         Param_ExpectedResponse: #(Expected_WochitMapping_Entry),
#         AWSregion: #(AWSregion)
#       }
#     """
#   * def getResult = 
#     """
#       function() {
#         var resp = null;
#         for(var i = 0; i < retries; i++) {
#           karate.log('Try #' + (i+1) + ' of ' + retries);
#           resp = karate.call(FeatureFilePath+'/Dynamodb.feature@ValidateItemViaQuery', ValidateItemViaQueryParams);
#           if(resp['result']['pass']) {
#             break;
#           } else {
#             karate.log('Failed. Sleeping for 1 minute.');
#             java.lang.Thread.sleep(60*1000);
#           }

#         }
#         return resp;
#       }
#     """
#   * def result = call getResult
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
#   Examples:
#     | validateWochitMappingIsFiledMovedTestData |
