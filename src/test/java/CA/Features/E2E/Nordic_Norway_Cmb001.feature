@Demo
Feature:  Nordic_Norway_Cmb001_Scenario

Background:
    * def currentTCPath = 'classpath:CA/Tests/E2ECases/Nordic_Region/Norway/Nordic_Norway_Cmb001'
    * def FeatureFilePath = 'classpath:CA/Features/ReUsable'
    * def Pause = function(pause){ java.lang.Thread.sleep(pause) }
    * def Random_String_Generator = function(){ return java.lang.System.currentTimeMillis() }
    * def one = callonce read(FeatureFilePath+'/RandomGenerator.feature@SeriesTitle')
    * def RandomSeriesTitle = one.RandomSeriesTitle
    * def two = callonce read(FeatureFilePath+'/RandomGenerator.feature@CallOutText')
    * def RandomCalloutText = two.RandomCalloutText
    * def three = callonce read(FeatureFilePath+'/RandomGenerator.feature@CTA')
    * def RandomCTA = three.RandomCTA


Scenario: Table Item Truncation and Series Title,Call out Text and CTA Generation
    * def result = call read(FeatureFilePath+'/Dynamodb.feature@TruncateTable') {Param_TableName: 'CA_WOCHIT_MAPPING_EU-qa',Param_PrimaryKey: 'ID'}
    * def result = call read(FeatureFilePath+'/Dynamodb.feature@TruncateTable') {Param_TableName: 'CA_WOCHIT_RENDITIONS_EU-qa',Param_PrimaryKey: 'ID'}  


Scenario: Nordic_Norway_Cmb001-Update Season 
    * def UpdateSeasonquery = read(currentTCPath+'/Input/SeasonRequest.json')
    * replace UpdateSeasonquery.SeriesTitle = RandomSeriesTitle
    * def Season_expectedResponse = read(currentTCPath+'/Output/ExpectedSeasonResponse.json')
    * def result = call read(FeatureFilePath+'/UpdateSeason.feature') {SeasonQuery: '#(UpdateSeasonquery)',SeasonExpectedResponse: '#(Season_expectedResponse)',ExpectedSeriesTitle: '#(RandomSeriesTitle)'}

Scenario: Nordic_Norway_Cmb001-Update Episode 
    * def UpdateEpisodequery = read(currentTCPath+'/Input/EpisodeRequest.json')
    * replace UpdateEpisodequery.CallOutText = RandomCalloutText
    * replace UpdateEpisodequery.CTA = RandomCTA
    * def Episode_ExpectedResponse = read(currentTCPath+'/Output/ExpectedEpisodeResponse.json')
    * def result = call read(FeatureFilePath+'/UpdateEpisode.feature') {EpisodeQuery: '#(UpdateEpisodequery)',EpisodeExpectedResponse: '#(Episode_ExpectedResponse)',ExpectedCalloutText: '#(RandomCalloutText)',ExpectedCTA: '#(RandomCTA)'}

Scenario: Nordic_Norway_Cmb001-Rendition
    * def Renditionquery = read(currentTCPath+'/Input/RenditionRequest.json')
    * def Rendition_ExpectedResponse = read(currentTCPath+'/Output/ExpectedRenditionResponse.json')
    * def result = call read(FeatureFilePath+'/Rendition.feature') {RenditionQuery: '#(Renditionquery)',RenditionExpectedResponse: '#(Rendition_ExpectedResponse)'}
    * print '-----------------Polling for Db Update----------------'
    * def result = call read(FeatureFilePath+'/Dynamodb.feature@WaitUntilDBUpdate')

Scenario Outline: Nordic_Norway_Cmb001-Validate Item Counts- MAM Asset Info,Wochit Renditions,Wochit Mapping
    * def result = call read(FeatureFilePath+'/Dynamodb.feature@ItemCountQuery') {Param_TableName: 'CA_MAM_ASSETS_INFO_EU-qa',Param_KeyType: 'Single',Param_Atr1: 'assetId',Param_Atr2: '',Param_Atrvalue1: 'd03eedd4-e345-11ea-9814-0a580a3f06a0',Param_Atrvalue2: '',Param_ExpectedItemCount: <ExpectedMAMAssetInfoCount>}    
    * def result = call read(FeatureFilePath+'/Dynamodb.feature@ItemCountScan') {Param_TableName: 'CA_WOCHIT_MAPPING_EU-qa',Param_Atr1: 'mamAssetInfoReferenceId',Param_Atrvalue1: 'd03eedd4-e345-11ea-9814-0a580a3f06a0',Param_ExpectedItemCount: <ExpectedWocRenditionCount>}    
    * def result = call read(FeatureFilePath+'/Dynamodb.feature@ItemCountScan') {Param_TableName: 'CA_WOCHIT_RENDITIONS_EU-qa',Param_Atr1: 'createdBy',Param_Atrvalue1: 'step-createWochitRenditions-EU-qa',Param_ExpectedItemCount: <ExpectedWochitMappingCount>}
    Examples:
        |ExpectedMAMAssetInfoCount|ExpectedWocRenditionCount|ExpectedWochitMappingCount|
        |       5                 |  3                      |     3                    |

Scenario: Nordic_Norway_Cmb001-Validate Technical Metadata
    * def TechMetaData_expectedResponse = read('classpath:CA/Tests/E2ECases/Nordic_Region/Norway/Nordic_Norway_Cmb001/Output/ExpectedTechMetaData.txt')
    * def result = call read(FeatureFilePath+'/Dynamodb.feature@GetItemMAMAssetInfo') {Param_TableName: 'CA_MAM_ASSETS_INFO_EU-qa',Param_PartitionKey: 'assetId', Param_SortKey: 'compositeViewsId',ParamPartionKeyVal: 'd03eedd4-e345-11ea-9814-0a580a3f06a0', ParamSortKeyVal: 'e1706402-934f-11ea-b2e1-0a580a3cb9b9|a86a5f8c-c5ae-11ea-8c30-0a580a3ebc6b',Param_TechMetaData:'#(TechMetaData_expectedResponse)'}
    * def result = call read(FeatureFilePath+'/Dynamodb.feature@GetItemMAMAssetInfo') {Param_TableName: 'CA_MAM_ASSETS_INFO_EU-qa',Param_PartitionKey: 'assetId', Param_SortKey: 'compositeViewsId',ParamPartionKeyVal: 'd03eedd4-e345-11ea-9814-0a580a3f06a0', ParamSortKeyVal: 'adb2fec4-934d-11ea-bcbe-0a580a3c65d4|4cf68d80-890c-11ea-bdcd-0a580a3c35b3',Param_TechMetaData:'#(TechMetaData_expectedResponse)'}
    * def result = call read(FeatureFilePath+'/Dynamodb.feature@GetItemMAMAssetInfo') {Param_TableName: 'CA_MAM_ASSETS_INFO_EU-qa',Param_PartitionKey: 'assetId', Param_SortKey: 'compositeViewsId',ParamPartionKeyVal: 'd03eedd4-e345-11ea-9814-0a580a3f06a0', ParamSortKeyVal: 'becf5274-8908-11ea-8e56-0a580a3c10cd|ec70917e-8909-11ea-95eb-0a580a3f8e05',Param_TechMetaData:'#(TechMetaData_expectedResponse)'}
    * def result = call read(FeatureFilePath+'/Dynamodb.feature@GetItemMAMAssetInfo') {Param_TableName: 'CA_MAM_ASSETS_INFO_EU-qa',Param_PartitionKey: 'assetId', Param_SortKey: 'compositeViewsId',ParamPartionKeyVal: 'd03eedd4-e345-11ea-9814-0a580a3f06a0', ParamSortKeyVal: 'c7197d98-8907-11ea-983a-0a580a3d1fe6|3a32b7ae-8908-11ea-958b-0a580a3c10cd',Param_TechMetaData:'#(TechMetaData_expectedResponse)'}
    * def result = call read(FeatureFilePath+'/Dynamodb.feature@GetItemMAMAssetInfo') {Param_TableName: 'CA_MAM_ASSETS_INFO_EU-qa',Param_PartitionKey: 'assetId', Param_SortKey: 'compositeViewsId',ParamPartionKeyVal: 'd03eedd4-e345-11ea-9814-0a580a3f06a0', ParamSortKeyVal: 'e1706402-934f-11ea-b2e1-0a580a3cb9b9|a86a5f8c-c5ae-11ea-8c30-0a580a3ebc6b',Param_TechMetaData:'#(TechMetaData_expectedResponse)'}

Scenario Outline: Nordic_Norway_Cmb001 - Validate Wochit Renditions Table for <ASPECTRATIO>
     * def Expected_VideoUpdates = read(currentTCPath+'/Output/'+<VideoUpdatesFileName>)
    * replace Expected_VideoUpdates.TTBR = RandomSeriesTitle
    * replace Expected_VideoUpdates.CallOutText = RandomCalloutText
    * replace Expected_VideoUpdates.CTA = RandomCTA
    * replace Expected_VideoUpdates.AR = <ASPECTRATIO>
    * def Expected_TimelineItems = read(currentTCPath+'/Output/Expected_TimelineItems.txt')
    * def Expected_Status = read(currentTCPath+'/Output/Expected_Status.txt')
    * def Expected_Item_AspectRatio_TemplateID = read(currentTCPath+'/Output/'+<ARTemplateIDFilename>)
    * def result = call read(FeatureFilePath+'/Dynamodb.feature@ValidateWochitPayload') {Param_TableName: 'CA_WOCHIT_RENDITIONS_EU-qa',Param_ScanAttr:'aspectRatio',Param_ScanVal:<ScanVal>,Param_Expected_VideoUpdates:'#(Expected_VideoUpdates)',Param_Expected_Item_AspectRatio_TemplateID: '#(Expected_Item_AspectRatio_TemplateID)',Param_Expected_TimelineItems:'#(Expected_TimelineItems)',Param_Expected_Status:'#(Expected_Status)'}
Examples:
    | ASPECTRATIO   | VideoUpdatesFileName                | ARTemplateIDFilename                            |ScanVal      |
    | '16x9'        | 'Expected_VideoUpdates.txt'         | 'Expected16_9_Item_AspectRatio_TemplateID.txt'  |ASPECT_16_9  |
    | '4x5'         | 'Expected_VideoUpdates.txt'         | 'Expected4_5_Item_AspectRatio_TemplateID.txt'   |ASPECT_4_5   |
    | '1x1'         | 'Expected_VideoUpdates_1_1.txt'     | 'Expected1_1_Item_AspectRatio_TemplateID.txt'   |ASPECT_1_1   |