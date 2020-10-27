@E2E @Norway @parallel=false @Demo
Feature:  Dplay_All_CustomText_NO

Background:
    * def TCName = 'Dplay_All_CustomText_NO'
    * def AWSregion = 'Nordic'
    * def TCAssetID = AssetIDNorway
    * def TCValidationType = 'videoValidation' //videoValidation or imageValidation. Used for custom report table
    * def tcResultWritePath = 'test-classes/' + TCName + '.json'
    * def tcResultReadPath = 'classpath:target/' + tcResultWritePath
    * def finalResultWritePath = 'test-classes/Results.json'
    * def finalResultReadPath = 'classpath:target/' + finalResultWritePath
    * def currentTCPath = 'classpath:CA/TestData/E2ECases/Nordic_Region/Norway/' + TCName
    * def FeatureFilePath = 'classpath:CA/Features/ReUsable'
    * def WochitMappingTableName = 'CA_WOCHIT_MAPPING_EU-qa'
    * def WochitRenditionTableName = 'CA_WOCHIT_RENDITIONS_EU-qa'
    * def MAMAssetsInfoTableName = 'CA_MAM_ASSETS_INFO_EU-qa'
    * def SeasonURL = UpdateSeasonURLNorway
    * def EpisodeURL = UpdateEpisodeURLNorway
    * def Iconik_CustomAction = Iconik_CustomActionNorway
    * def GetRenditionHTTPInfoParams =
      """
        {
          URL: #(Iconik_CustomActionListURL),
          Iconik_CustomAction: #(Iconik_CustomAction),
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
    * def Iconik_CollectionID = Iconik_CollectionIDNorway
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



#Scenario: Table Item Truncation and Series Title,Call out Text and CTA Generation
    #* def result = call read(FeatureFilePath+'/Dynamodb.feature@TruncateTable') {Param_TableName: 'CA_WOCHIT_MAPPING_EU-qa',Param_PrimaryKey: 'ID'}
    #* def result = call read(FeatureFilePath+'/Dynamodb.feature@TruncateTable') {Param_TableName: 'CA_WOCHIT_RENDITIONS_EU-qa',Param_PrimaryKey: 'ID'}  

Scenario: Nordic_Norway_Dplay_All_DropDownList_NO - Update Season 
  * def scenarioName = 'updateSeason'
  * def UpdateSeasonquery = read(currentTCPath+'/Input/SeasonRequest.json')
  * replace UpdateSeasonquery.SeriesTitle = RandomSeriesTitle
  * def Season_expectedResponse = read(currentTCPath+'/Output/ExpectedSeasonResponse.json')
  * def updateSeasonParams =
    """
      {
        URL: '#(SeasonURL)',
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

Scenario: Nordic_Norway_Dplay_All_DropDownList_NO - Update Episode 
  * def scenarioName = 'updateEpisode'
  * def UpdateEpisodequery = read(currentTCPath+'/Input/EpisodeRequest.json')
  * replace UpdateEpisodequery.CallOutText = RandomCalloutText
  * replace UpdateEpisodequery.CTA = RandomCTA
  * def Episode_ExpectedResponse = read(currentTCPath+'/Output/ExpectedEpisodeResponse.json')
  * def updateEpisodeParams =
    """
      {
        URL: '#(EpisodeURL)',
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
  * call Pause 60000
    
Scenario: Nordic_Norway_Dplay_All_CustomText_NO - Validate Item Counts - MAM Asset Info
  * def scenarioName = "validateMAM"
  * def ExpectedMAMAssetInfoCount = 5
  * def itemCountQueryParams = 
    """
      {
        Param_TableName: #(MAMAssetsInfoTableName),
        Param_KeyType: 'Single',
        Param_Atr1: 'assetId',
        Param_Atr2: '',
        Param_Atrvalue1: #(TCAssetID),
        Param_Atrvalue2: '',
        Param_ExpectedItemCount: #(ExpectedMAMAssetInfoCount),
         AWSregion: #(AWSregion)
      }
    """
  * def result = call read(FeatureFilePath+'/Dynamodb.feature@ItemCountQuery') itemCountQueryParams
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

Scenario: Nordic_Norway_Dplay_All_CustomText_NO - Validate Item Counts - Wochit Rendition
  * def scenarioName = "validateWochitRenditionCount"
  * def ExpectedWocRenditionCount = 3
  * def ExpectedTitle = RandomCalloutText+'-'+RandomCTA
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

Scenario: Nordic_Norway_Dplay_All_CustomText_NO - Validate Item Counts - Wochit Mapping
  * def scenarioName = "validateWochitMappingCount"
  * def ExpectedWochitMappingCount = 3
  * def ExpectedTitle = RandomCalloutText+'-'+RandomCTA
  * def itemCountScanParams =
    """
      {
        Param_TableName: #(WochitMappingTableName),
        Param_Atr1: 'renditionFileName',
        Param_Atrvalue1: #(ExpectedTitle),
        Param_Operator: 'containsforcount',
        Param_ExpectedItemCount: #(ExpectedWochitMappingCount),
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

Scenario Outline: Nordic_Norway_Dplay_All_CustomText_NO - Validate Wochit Renditions Table for <ASPECTRATIO>
  * def scenarioName = 'validateWochitRendition' + <ASPECTRATIO>
  * def RenditionFileName = <FileNameSuffix>+'-'+RandomCalloutText+'-'+RandomCTA
  * def Expected_WochitRendition_Entry = read(currentTCPath + '/Output/Expected_WochitRendition_Entry.json')
  * def validateRenditionPayloadParams =
    """
      {
        Param_TableName: #(WochitRenditionTableName),
        Param_ScanAttr1: 'videoUpdates.title',
        Param_ScanVal1: #(RenditionFileName),
        Param_ScanAttr2:'aspectRatio',
        Param_ScanVal2: <ScanVal>,
        Expected_WochitRendition_Entry: #(Expected_WochitRendition_Entry),
         AWSregion: #(AWSregion)
      }
    """
  * def result = call read(FeatureFilePath+'/Dynamodb.feature@ValidateWochitRenditionPayload') validateRenditionPayloadParams
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
    | ASPECTRATIO   | TEMPLATEID               | ScanVal      | FileNameSuffix             |
    | '16x9'        | 5ebb4c377f8c3b07249d5e80 | ASPECT_16_9  | 'DAQ CA Test_1-dplay_16x9' |
    | '4x5'         | 5ebb596b7f8c3b07249d5e8b | ASPECT_4_5   | 'DAQ CA Test_1-dplay_4x5'  |
    | '1x1'         | 5ebb5b25eff13f1e3a9c4399 | ASPECT_1_1   | 'DAQ CA Test_1-dplay_1x1'  |

Scenario Outline: Nordic_Norway_Dplay_All_CustomText_NO - Validate Technical Metadata for Sort Key <COMPOSITEVIEWID>
  * def scenarioName = 'validateTechnicalMetadata'
  * def Expected_MAMAssetInfo_Entry = read(currentTCPath + '/Output/Expected_MAMAssetInfo_Entry.json')
  * def getItemMAMAssetInfoParams = 
    """
      {
        Param_TableName: #(MAMAssetsInfoTableName),
        Param_PartitionKey: 'assetId', 
        Param_SortKey: 'compositeViewsId',
        ParamPartionKeyVal: #(TCAssetID), 
        ParamSortKeyVal: <COMPOSITEVIEWID>,
        Expected_MAMAssetInfo_Entry: #(Expected_MAMAssetInfo_Entry),
         AWSregion: #(AWSregion)
      }
    """
  * def result = call read(FeatureFilePath+'/Dynamodb.feature@GetItemMAMAssetInfo') getItemMAMAssetInfoParams
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
    | COMPOSITEVIEWID                                                            |
    | e1706402-934f-11ea-b2e1-0a580a3cb9b9\|a86a5f8c-c5ae-11ea-8c30-0a580a3ebc6b |
    | adb2fec4-934d-11ea-bcbe-0a580a3c65d4\|4cf68d80-890c-11ea-bdcd-0a580a3c35b3 |
    | c7197d98-8907-11ea-983a-0a580a3d1fe6\|3a32b7ae-8908-11ea-958b-0a580a3c10cd |

Scenario Outline: Nordic_Norway_Dplay_All_CustomText_NO - Validate Wochit Mapping Table for Aspect Ratio <ASPECTRATIO> Rendition Status 
  * def scenarioName = 'validateWochitMapping' + <ASPECTRATIO>
  * def RenditionFileName = <FNAMEPREFIX>+'-'+RandomCalloutText+'-'+RandomCTA
  * def Expected_WochitMapping_Entry = read(currentTCPath + '/Output/Expected_WochitMapping_Entry.json')
  * def validateWochitMappingPayloadParams =
    """
      {
        Param_TableName: #(WochitMappingTableName),
        Param_ScanAttr1: 'renditionFileName',
        Param_ScanVal1: #(RenditionFileName),
        Expected_WochitMapping_Entry: #(Expected_WochitMapping_Entry),
         AWSregion: #(AWSregion)
      }
    """
  * def result = call read(FeatureFilePath+'/Dynamodb.feature@ValidateWochitMappingPayload') validateWochitMappingPayloadParams
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
    | FNAMEPREFIX                     | ASPECTRATIO    |
    | 'DAQ CA Test_1-dplay_16x9'      | '16x9'         | 
    | 'DAQ CA Test_1-dplay_4x5'       | '4x5'          |
    | 'DAQ CA Test_1-dplay_1x1'       | '1x1'          |
