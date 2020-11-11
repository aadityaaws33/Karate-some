@E2E @Netherlands @predefined @parallel=false @THIS
Feature:  Dplay_All_DropDownList_NL

Background:
  # * def TCName = 'Dplay_All_DropDownList_NL'
  # * def AWSregion = 'Nordic'
  # * def Iconik_AssetID = AssetIDNetherlands
  # * def TCValidationType = 'videoValidation' //videoValidation or imageValidation. Used for custom report table
  # * def tcResultWritePath = 'test-classes/' + TCName + '.json'
  # * def tcResultReadPath = 'classpath:target/' + tcResultWritePath
  # * def finalResultWritePath = 'test-classes/Results.json'
  # * def finalResultReadPath = 'classpath:target/' + finalResultWritePath
  # * def currentTCPath = 'classpath:CA/TestData/E2ECases/Nordic_Region/Netherlands/' + TCName
  # * def FeatureFilePath = 'classpath:CA/Features/ReUsable'
  # * def WochitMappingTableName = 'CA_WOCHIT_MAPPING_EU-qa'
  # * def WochitRenditionTableName = 'CA_WOCHIT_RENDITIONS_EU-qa'
  # * def MAMAssetsInfoTableName = 'CA_MAM_ASSETS_INFO_EU-qa'
  # * def Iconik_UpdateSeasonURL = UpdateSeasonURLNetherlands
  # * def Iconik_UpdateEpisodeURL = UpdateEpisodeURLNetherlands
  # * def Iconik_CustomAction = Iconik_CustomActionNorway
  
  # NEW
  * def TCName = 'Dplay_All_DropDownList_NL'
  * def Country = 'Netherlands'
  * def AWSregion = EnvData[Country]['AWSregion']
  * def WochitMappingTableName = EnvData[Country]['WochitMappingTableName']
  * def WochitRenditionTableName = EnvData[Country]['WochitRenditionTableName']
  * def MAMAssetsInfoTableName = EnvData[Country]['MAMAssetsInfoTableName']
  # Iconik Stuff Start
  * def Iconik_EpisodeVersionID = EnvData[Country]['Iconik_EpisodeVersionID']
  * def Iconik_EpisodeObjectID = EnvData[Country]['Iconik_EpisodeObjectID']
  * def Iconik_AssetID = EnvData[Country]['Iconik_AssetID']
  * def Iconik_CollectionID = EnvData[Country]['Iconik_CollectionID']
  * def Iconik_CustomAction = EnvData[Country]['Iconik_CustomAction']
  * def Iconik_CustomActionID = EnvData[Country]['Iconik_CustomActionID']
  * def Iconik_MetadataID = EnvData[Country]['Iconik_MetadataID']
  * def Iconik_MetadataObjectID = EnvData[Country]['Iconik_MetadataObjectID']
  * def Iconik_MetadataObjectName = EnvData[Country]['Iconik_MetadataObjectName']
  * def Iconik_SystemDomainID = EnvData[Country]['Iconik_SystemDomainID']
  * def Iconik_UpdateSeasonURL =  EnvData[Country]['Iconik_UpdateSeasonURL']
  * def Iconik_UpdateEpisodeURL =  EnvData[Country]['Iconik_UpdateEpisodeURL']
  # Iconik Stuff End
  * def TCValidationType = 'videoValidation' //videoValidation or imageValidation. Used for custom report table
  * def tcResultWritePath = 'test-classes/' + TCName + '.json'
  * def tcResultReadPath = 'classpath:target/' + tcResultWritePath
  * def finalResultWritePath = 'test-classes/Results.json'
  * def finalResultReadPath = 'classpath:target/' + finalResultWritePath
  * def currentTCPath = 'classpath:CA/TestData/E2ECases/' + AWSregion + '_Region/' + Country + '/' + TCName
  * def FeatureFilePath = 'classpath:CA/Features/ReUsable'
  # NEW



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
  * def chooseCalloutFromList = 
    """
      function() {
        predefinedList = [
          'Nieuw seizoen',
          'Nieuwe serie',
          'Nieuwe aflevering',
          'Alle seizoenen',
          'Hele seizoen'
        ];
        return predefinedList[Math.floor(Math.random()*predefinedList.length)];
      }
    """
  * def chooseCTAFromList =
    """
      function() {
        predefinedList = [
          'Probeer 7 dagen gratis',
          'Kijk nu vooruit op Dplay.nl',
          'Kijk nu op Dplay.nl',
          'Kijk nu exclusief op Dplay.nl'
        ];
        return predefinedList[Math.floor(Math.random()*predefinedList.length)];
      }
    """
  * def one = callonce read(FeatureFilePath+'/RandomGenerator.feature@SeriesTitle')
  * def RandomSeriesTitle = one.RandomSeriesTitle
  # * def two = callonce read(FeatureFilePath+'/RandomGenerator.feature@CallOutText')
  * def RandomCalloutText = callonce chooseCalloutFromList
  # * def three = callonce read(FeatureFilePath+'/RandomGenerator.feature@CTA')
  * def RandomCTA = callonce chooseCTAFromList
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

Scenario: Nordic_Netherlands_Dplay_All_DropDownList_NL - Update Season 
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

Scenario: Nordic_Netherlands_Dplay_All_DropDownList_NL - Update Episode 
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

Scenario: Nordic_Netherlands_Dplay_All_DropDownList_NL - Trigger Rendition
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

Scenario: Nordic_Netherlands_Dplay_All_DropDownList_NL - Validate Item Counts - MAM Asset Info
  * def scenarioName = "validateMAM"
  * def ExpectedMAMAssetInfoCount = 3
  * def itemCountQueryParams = 
    """
      {
        Param_TableName: #(MAMAssetsInfoTableName),
        Param_KeyType: 'Single',
        Param_Atr1: 'assetId',
        Param_Atr2: '',
        Param_Atrvalue1: #(Iconik_AssetID),
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

Scenario: Nordic_Netherlands_Dplay_All_DropDownList_NL - Validate Item Counts - Wochit Rendition
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

Scenario: Nordic_Netherlands_Dplay_All_DropDownList_NL - Validate Item Counts - Wochit Mapping
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
  
Scenario Outline: Nordic_Netherlands_Dplay_All_DropDownList_NL - Validate Wochit Renditions Table for <ASPECTRATIO>
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
    | '16x9'        | 5ebb4c377f8c3b07249d5e80 | ASPECT_16_9  | 'QA_NL_EP1-dplay_16x9'     |
    | '4x5'         | 5ebb596b7f8c3b07249d5e8b | ASPECT_4_5   | 'QA_NL_EP1-dplay_4x5'      |
    | '1x1'         | 5ebb5b25eff13f1e3a9c4399 | ASPECT_1_1   | 'QA_NL_EP1-dplay_1x1'      |      

Scenario Outline: Nordic_Netherlands_Dplay_All_DropDownList_NL - Validate Technical Metadata for Composite View ID: <COMPOSITEVIEWID>
  * def scenarioName = 'validateTechnicalMetadata'
  * def Expected_MAMAssetInfo_Entry = read(currentTCPath + '/Output/Expected_MAMAssetInfo_Entry.json')
  * def getItemMAMAssetInfoParams = 
    """
      {
        Param_TableName: #(MAMAssetsInfoTableName),
        Param_PartitionKey: 'assetId', 
        Param_SortKey: 'compositeViewsId',
        ParamPartionKeyVal: #(Iconik_AssetID), 
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
    | 83a5bfc2-e771-11ea-afed-0a580a3c2c48\|1f708f46-e771-11ea-b4dd-0a580a3c8cb3 |
    | 49074474-e773-11ea-8e77-0a580a3f8ee8\|1f708f46-e771-11ea-b4dd-0a580a3c8cb3 |
    | e472d33e-e772-11ea-9b92-0a580a3f8d44\|861202d8-e772-11ea-abaf-0a580a3cf01e |

Scenario Outline: Nordic_Netherlands_Dplay_All_DropDownList_NL - Validate Wochit Mapping Table for Aspect Ratio <ASPECTRATIO> Rendition Status 
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
    | FNAMEPREFIX                 | ASPECTRATIO |
    | 'QA_NL_EP1-dplay_16x9'      | '16x9'      |
    | 'QA_NL_EP1-dplay_4x5'       | '4x5'       |
    | 'QA_NL_EP1-dplay_1x1'       | '1x1'       |
