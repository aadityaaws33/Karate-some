@Demo @parallel=false
Feature:  Dplay_All_CustomText_NO

Background:
    * def TCName = 'Dplay_All_CustomText_NO'
    * def tcResultWritePath = 'test-classes/' + TCName + '.json'
    * def tcResultReadPath = 'classpath:target/' + tcResultWritePath
    * def finalResultWritePath = 'test-classes/Results.json'
    * def finalResultReadPath = 'classpath:target/' + finalResultWritePath
    * def currentTCPath = 'classpath:CA/TestData/E2ECases/Nordic_Region/Norway/' + TCName
    * def FeatureFilePath = 'classpath:CA/Features/ReUsable'
    * def placeholderParams = { tcResultReadPath: #(tcResultReadPath), tcResultWritePath: #(tcResultWritePath), tcName: #(TCName) }
    * def updateFinalResultParams = { tcResultReadPath: #(tcResultReadPath), tcResultWritePath: #(tcResultWritePath), tcName: #(TCName), finalResultReadPath: #(finalResultReadPath), finalResultWritePath: #(finalResultWritePath) }
    * call read(FeatureFilePath + '/Results.feature@setPlaceholder') { placeholderParams: #(placeholderParams) })
    # * call read(FeatureFilePath + '/Results.feature@shouldContinue') { placeholderParams: #(updateFinalResultParams) })
    * def Pause = function(pause){ java.lang.Thread.sleep(pause) }
    * def Random_String_Generator = function(){ return java.lang.System.currentTimeMillis() }
    * def one = callonce read(FeatureFilePath+'/RandomGenerator.feature@SeriesTitle')
    * def RandomSeriesTitle = one.RandomSeriesTitle
    * def two = callonce read(FeatureFilePath+'/RandomGenerator.feature@CallOutText')
    * def RandomCalloutText = two.RandomCalloutText
    * def three = callonce read(FeatureFilePath+'/RandomGenerator.feature@CTA')
    * def RandomCTA = three.RandomCTA
    * configure afterFeature = 
      """
        function() {
          karate.call(FeatureFilePath + '/Results.feature@updateFinalResults', { updateFinalResultParams: updateFinalResultParams });
        }
      """



#Scenario: Table Item Truncation and Series Title,Call out Text and CTA Generation
    #* def result = call read(FeatureFilePath+'/Dynamodb.feature@TruncateTable') {Param_TableName: 'CA_WOCHIT_MAPPING_EU-qa',Param_PrimaryKey: 'ID'}
    #* def result = call read(FeatureFilePath+'/Dynamodb.feature@TruncateTable') {Param_TableName: 'CA_WOCHIT_RENDITIONS_EU-qa',Param_PrimaryKey: 'ID'}  

Scenario: Nordic_Norway_Dplay_All_CustomText_NO-Update Season 
  * def scenarioName = 'updateSeason'
  * def UpdateSeasonquery = read(currentTCPath+'/Input/SeasonRequest.json')
  * replace UpdateSeasonquery.SeriesTitle = RandomSeriesTitle
  * def Season_expectedResponse = read(currentTCPath+'/Output/ExpectedSeasonResponse.json')
  * def result = call read(FeatureFilePath+'/UpdateSeason.feature') {SeasonQuery: '#(UpdateSeasonquery)',SeasonExpectedResponse: '#(Season_expectedResponse)',ExpectedSeriesTitle: '#(RandomSeriesTitle)'}
  * def updateParams = { tcName: #(TCName), scenarioName: #(scenarioName), result: #(result.result), tcResultReadPath: #(tcResultReadPath), tcResultWritePath: #(tcResultWritePath) }
  * call read(FeatureFilePath + '/Results.feature@updateResult') { updateParams: #(updateParams) })

Scenario: Nordic_Norway_Dplay_All_CustomText_NO-Update Episode 
  * def scenarioName = 'updateEpisode'
  * def UpdateEpisodequery = read(currentTCPath+'/Input/EpisodeRequest.json')
  * replace UpdateEpisodequery.CallOutText = RandomCalloutText
  * replace UpdateEpisodequery.CTA = RandomCTA
  * def Episode_ExpectedResponse = read(currentTCPath+'/Output/ExpectedEpisodeResponse.json')
  * def result = call read(FeatureFilePath+'/UpdateEpisode.feature') {EpisodeQuery: '#(UpdateEpisodequery)',EpisodeExpectedResponse: '#(Episode_ExpectedResponse)',ExpectedCalloutText: '#(RandomCalloutText)',ExpectedCTA: '#(RandomCTA)'}
  * def updateParams = { tcName: #(TCName), scenarioName: #(scenarioName), result: #(result.result), tcResultReadPath: #(tcResultReadPath), tcResultWritePath: #(tcResultWritePath) }
  * call read(FeatureFilePath + '/Results.feature@updateResult') { updateParams: #(updateParams) })

Scenario: Nordic_Norway_Dplay_All_CustomText_NO-Rendition
  * def scenarioName = 'rendition'
  * def RenditionFileName = 'DAQ CA Test_1-dplay_16x9-'+RandomCalloutText+'-'+RandomCTA
  * def Renditionquery = read(currentTCPath+'/Input/RenditionRequest.json')
  * def Rendition_ExpectedResponse = read(currentTCPath+'/Output/ExpectedRenditionResponse.json')
  * def result = call read(FeatureFilePath+'/Rendition.feature') {RenditionQuery: '#(Renditionquery)',RenditionExpectedResponse: '#(Rendition_ExpectedResponse)'}
  * print '-----------------Polling for Db Update----------------'
  * def result = call read(FeatureFilePath+'/Dynamodb.feature@WaitUntilDBUpdate') {Param_ScanAtr: 'videoUpdates.title',Param_ScanVal: '#(RenditionFileName)'}
  * def updateParams = { tcName: #(TCName), scenarioName: #(scenarioName), result: #(result.result), tcResultReadPath: #(tcResultReadPath), tcResultWritePath: #(tcResultWritePath) }
  * call read(FeatureFilePath + '/Results.feature@updateResult') { updateParams: #(updateParams) })
    
Scenario: Nordic_Norway_Dplay_All_CustomText_NO-Validate Item Counts- MAM Asset Info
  * def scenarioName = "validateMAM"
  * def ExpectedMAMAssetInfoCount = 5
  * def result = call read(FeatureFilePath+'/Dynamodb.feature@ItemCountQuery') {Param_TableName: 'CA_MAM_ASSETS_INFO_EU-qa',Param_KeyType: 'Single',Param_Atr1: 'assetId',Param_Atr2: '',Param_Atrvalue1: 'd03eedd4-e345-11ea-9814-0a580a3f06a0',Param_Atrvalue2: '',Param_ExpectedItemCount: #(ExpectedMAMAssetInfoCount)}
  * def updateParams = { tcName: #(TCName), scenarioName: #(scenarioName), result: #(result.result), tcResultReadPath: #(tcResultReadPath), tcResultWritePath: #(tcResultWritePath) }
  * call read(FeatureFilePath + '/Results.feature@updateResult') { updateParams: #(updateParams) })

Scenario: Nordic_Norway_Dplay_All_CustomText_NO-Validate Item Counts- Wochit Mapping
  * def scenarioName = "validateWochitMappingCount"
  * def CTA = RandomCTA
  * def ExpectedWocRenditionCount = 3
  * def result = call read(FeatureFilePath+'/Dynamodb.feature@ItemCountScan') {Param_TableName: 'CA_WOCHIT_RENDITIONS_EU-qa',Param_Atr1: 'videoUpdates.title',Param_Atrvalue1: '#(CTA)' ,Param_Operator: 'contains',Param_ExpectedItemCount: #(ExpectedWocRenditionCount)}    
  * def updateParams = { tcName: #(TCName), scenarioName: #(scenarioName), result: #(result.result), tcResultReadPath: #(tcResultReadPath), tcResultWritePath: #(tcResultWritePath) }
  * call read(FeatureFilePath + '/Results.feature@updateResult') { updateParams: #(updateParams) })

Scenario: Nordic_Norway_Dplay_All_CustomText_NO-Validate Item Counts- Wochit Renditions
  * def scenarioName = "validateWochitRenditionCount"
  * def CTA = RandomCTA
  * def ExpectedWochitMappingCount = 3
  * def result = call read(FeatureFilePath+'/Dynamodb.feature@ItemCountScan') {Param_TableName: 'CA_WOCHIT_MAPPING_EU-qa',Param_Atr1: 'renditionFileName',Param_Atrvalue1: '#(CTA)' ,Param_Operator: 'containsforcount',Param_ExpectedItemCount: #(ExpectedWochitMappingCount)}    
  * def updateParams = { tcName: #(TCName), scenarioName: #(scenarioName), result: #(result.result), tcResultReadPath: #(tcResultReadPath), tcResultWritePath: #(tcResultWritePath) }
  * call read(FeatureFilePath + '/Results.feature@updateResult') { updateParams: #(updateParams) })

Scenario Outline: Nordic_Norway_Dplay_All_CustomText_NO - Validate Wochit Renditions Table for <ASPECTRATIO>
  * def scenarioName = 'validateWochitRendition' + <ASPECTRATIO>
  * def Expected_VideoUpdates = read(currentTCPath+'/Output/'+<VideoUpdatesFileName>)
  * replace Expected_VideoUpdates.TTBR = RandomSeriesTitle
  * replace Expected_VideoUpdates.CallOutText = RandomCalloutText
  * replace Expected_VideoUpdates.CTA = RandomCTA
  * replace Expected_VideoUpdates.AR = <ASPECTRATIO>
  * def Expected_TimelineItems = read(currentTCPath+'/Output/Expected_TimelineItems.txt')
  * def Expected_Status = read(currentTCPath+'/Output/Expected_Status.txt')
  * def Expected_Item_AspectRatio_TemplateID = read(currentTCPath+'/Output/'+<ARTemplateIDFilename>)
  * def RenditionFileName = <FileNameSuffix>+'-'+RandomCalloutText+'-'+RandomCTA
  * def result = call read(FeatureFilePath+'/Dynamodb.feature@ValidateWochitRenditionPayload') {Param_TableName: 'CA_WOCHIT_RENDITIONS_EU-qa',Param_ScanAttr1:'videoUpdates.title',Param_ScanVal1:'#(RenditionFileName)',Param_ScanAttr2:'aspectRatio',Param_ScanVal2:<ScanVal>,Param_Expected_VideoUpdates:'#(Expected_VideoUpdates)',Param_Expected_Item_AspectRatio_TemplateID: '#(Expected_Item_AspectRatio_TemplateID)',Param_Expected_TimelineItems:'#(Expected_TimelineItems)',Param_Expected_Status:'#(Expected_Status)'}
  * def updateParams = { tcName: #(TCName), scenarioName: #(scenarioName), result: #(result.result), tcResultReadPath: #(tcResultReadPath), tcResultWritePath: #(tcResultWritePath) }
  * call read(FeatureFilePath + '/Results.feature@updateResult') { updateParams: #(updateParams) })
  # * def result = call read(FeatureFilePath+'/UpdateCustomReport.feature@UpdateReport') {ParamID: 'Nordic_Norway_Dplay_All_CustomText_NO',ParamCell: <CustomReportCell>}
Examples:
  | ASPECTRATIO   | VideoUpdatesFileName                | ARTemplateIDFilename                            |ScanVal        |FileNameSuffix            |CustomReportCell|
  | '16x9'        | 'Expected_VideoUpdates.txt'         | 'Expected16_9_Item_AspectRatio_TemplateID.txt'  |'ASPECT_16_9'  |'DAQ CA Test_1-dplay_16x9'|7               |
  | '4x5'         | 'Expected_VideoUpdates.txt'         | 'Expected4_5_Item_AspectRatio_TemplateID.txt'   |'ASPECT_4_5'   |'DAQ CA Test_1-dplay_4x5' |8               |
  | '1x1'         | 'Expected_VideoUpdates_1_1.txt'     | 'Expected1_1_Item_AspectRatio_TemplateID.txt'   |'ASPECT_1_1'   |'DAQ CA Test_1-dplay_1x1' |9               |          


Scenario Outline: Nordic_Norway_Dplay_All_CustomText_NO-Validate Technical Metadata for Sort Key <PARAMSORTVAL>
  * def scenarioName = 'validateTechnicalMetadata'
  * def TechMetaData_expectedResponse = read(currentTCPath+'/Output/ExpectedTechMetaData.txt')
  * def result = call read(FeatureFilePath+'/Dynamodb.feature@GetItemMAMAssetInfo') {Param_TableName: 'CA_MAM_ASSETS_INFO_EU-qa',Param_PartitionKey: 'assetId', Param_SortKey: 'compositeViewsId',ParamPartionKeyVal: 'd03eedd4-e345-11ea-9814-0a580a3f06a0', ParamSortKeyVal: <PARAMSORTVAL>,Param_TechMetaData:'#(TechMetaData_expectedResponse)'}
  * def updateParams = { tcName: #(TCName), scenarioName: #(scenarioName), result: #(result.result), tcResultReadPath: #(tcResultReadPath), tcResultWritePath: #(tcResultWritePath) }
  * call read(FeatureFilePath + '/Results.feature@updateResult') { updateParams: #(updateParams) })
  # * def result = call read(FeatureFilePath+'/UpdateCustomReport.feature@UpdateReport') {ParamID: 'Nordic_Norway_Dplay_All_CustomText_NO',ParamCell: 10}
    Examples:
    | PARAMSORTVAL                                                               |
    |'e1706402-934f-11ea-b2e1-0a580a3cb9b9\|a86a5f8c-c5ae-11ea-8c30-0a580a3ebc6b'|
    |'adb2fec4-934d-11ea-bcbe-0a580a3c65d4\|4cf68d80-890c-11ea-bdcd-0a580a3c35b3'|
    |'becf5274-8908-11ea-8e56-0a580a3c10cd\|ec70917e-8909-11ea-95eb-0a580a3f8e05'|
    |'c7197d98-8907-11ea-983a-0a580a3d1fe6\|3a32b7ae-8908-11ea-958b-0a580a3c10cd'|
    |'e1706402-934f-11ea-b2e1-0a580a3cb9b9\|a86a5f8c-c5ae-11ea-8c30-0a580a3ebc6b'|
    


Scenario Outline: Nordic_Norway_Dplay_All_CustomText_NO - Validate Wochit Mapping Table for Aspect Ratio <ASPECTRATIO> Rendition Status 
* def scenarioName = 'validateWochitMapping' + <ASPECTRATIO>
* def Expected_Status = read(currentTCPath+'/Output/Expected_Status_WochitMapping.txt')
* def RenditionFileName = <ASPECTRATIO>+'-'+RandomCalloutText+'-'+RandomCTA
* def result = call read(FeatureFilePath+'/Dynamodb.feature@ValidateWochitMappingPayload') {Param_TableName: 'CA_WOCHIT_MAPPING_EU-qa',Param_ScanAttr1:'renditionFileName',Param_ScanVal1:'#(RenditionFileName)',Param_Expected_Status:'#(Expected_Status)'}
* def updateParams = { tcName: #(TCName), scenarioName: #(scenarioName), result: #(result.result), tcResultReadPath: #(tcResultReadPath), tcResultWritePath: #(tcResultWritePath) }
* call read(FeatureFilePath + '/Results.feature@updateResult') { updateParams: #(updateParams) })
# * def result = call read(FeatureFilePath+'/UpdateCustomReport.feature@UpdateReport') {ParamID: 'Nordic_Norway_Dplay_All_CustomText_NO',ParamCell: <CustomReportCell>}

Examples:
    | ASPECTRATIO                     | CustomReportCell |
    | 'DAQ CA Test_1-dplay_16x9'      | 11               |
    | 'DAQ CA Test_1-dplay_4x5'       | 12               |
    | 'DAQ CA Test_1-dplay_1x1'       | 13               |
