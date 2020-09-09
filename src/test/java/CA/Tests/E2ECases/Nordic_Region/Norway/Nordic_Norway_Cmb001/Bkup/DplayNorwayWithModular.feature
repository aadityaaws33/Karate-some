Feature:  Dplay Norway CA

Background:
    * def Pause = function(pause){ java.lang.Thread.sleep(pause) }
    * def result = call read('classpath:CA/Features/ReUsable/Dynamodb.feature@TruncateTable') {Param_TableName: 'CA_WOCHIT_MAPPING_EU-qa',Param_PrimaryKey: 'ID'}
    * def result = call read('classpath:CA/Features/ReUsable/Dynamodb.feature@TruncateTable') {Param_TableName: 'CA_WOCHIT_RENDITIONS_EU-qa',Param_PrimaryKey: 'ID'}  
    
    
    
@Module_WithoutRandom
Scenario Outline: Sample POC for Dplay CA with Linear Approach
* def result = call read('classpath:CA/Tests/UpdateSeason/UpdateSeason.feature') {Param_SeriesTitle: '<SeriesTitle>'}
* def result = call read('classpath:CA/Tests/UpdateEpisode/UpdateEpisode.feature') {Param_SeriesTitle: '<SeriesTitle>'}
* print '-------Executed--------'

Examples:
    | SeriesTitle                   | 
    | CA_QA_Automation_28_8_0001    | 


@Module
Scenario Outline: <TestCaseID> ---- <TestcaseDescription> ------Sample POC for Dplay CA Modularized 

* def Random_String_Generator = function(){ return java.lang.System.currentTimeMillis() }
* def RandomString = 'Test-' + Random_String_Generator()
* print '---------------Random Text----------'+RandomString

* def UpdateSeasonquery = read('classpath:CA/Tests/E2ECases/Nordic_Region/Norway/' + <TestCaseID> + '/Input/SeasonRequest.json')
* replace UpdateSeasonquery.SeriesTitle = RandomString
* print '-----------------Query After Replace------------'+UpdateSeasonquery
* def Season_expectedResponse = read('classpath:CA/Tests/E2ECases/Nordic_Region/Norway/' + <TestCaseID> + '/Output/ExpectedSeasonResponse.json')
* def result = call read('classpath:CA/Features/ReUsable/UpdateSeason.feature') {SeasonQuery: '#(UpdateSeasonquery)',SeasonExpectedResponse: '#(Season_expectedResponse)',ExpectedSeriesTitle: '#(RandomString)'}

* def UpdateEpisodequery = read('classpath:CA/Tests/E2ECases/Nordic_Region/Norway/' + <TestCaseID> + '/Input/EpisodeRequest.json')
* replace UpdateEpisodequery.SeriesTitle = RandomString
* print '-----------------Query After Replace------------'+UpdateEpisodequery
* def Episode_ExpectedResponse = read('classpath:CA/Tests/E2ECases/Nordic_Region/Norway/' + <TestCaseID> + '/Output/ExpectedEpisodeResponse.json')
* def result = call read('classpath:CA/Features/ReUsable/UpdateEpisode.feature') {EpisodeQuery: '#(UpdateEpisodequery)',EpisodeExpectedResponse: '#(Episode_ExpectedResponse)',RandomText: '#(RandomString)'}

* def Renditionquery = read('classpath:CA/Tests/E2ECases/Nordic_Region/Norway/' + <TestCaseID> + '/Input/RenditionRequest.json')
#* replace UpdateEpisodequery.SeriesTitle = RandomString
#* print '-----------------Query After Replace------------'+UpdateEpisodequery
* def Rendition_ExpectedResponse = read('classpath:CA/Tests/E2ECases/Nordic_Region/Norway/' + <TestCaseID> + '/Output/ExpectedRenditionResponse.json')
#* def result = call read('classpath:CA/Features/ReUsable/Rendition.feature') {RenditionQuery: '#(Renditionquery)',RenditionExpectedResponse: '#(Rendition_ExpectedResponse)',RandomText: '#(RandomString)',JsonValidation1:<JsonPath1>,JsonValidation2:<JsonPath2>,JsonValidation3:<JsonPath3>}
* def result = call read('classpath:CA/Features/ReUsable/Rendition.feature') {RenditionQuery: '#(Renditionquery)',RenditionExpectedResponse: '#(Rendition_ExpectedResponse)'}
* Pause(20000)
* def result = call read('classpath:CA/Features/ReUsable/Dynamodb.feature@ItemCountQuery') {Param_TableName: 'CA_MAM_ASSETS_INFO_EU-qa',Param_KeyType: 'Single',Param_Atr1: 'assetId',Param_Atr2: '',Param_Atrvalue1: 'd03eedd4-e345-11ea-9814-0a580a3f06a0',Param_Atrvalue2: '',Param_ExpectedItemCount: <ExpectedMAMAssetInfoCount>}    
* def result = call read('classpath:CA/Features/ReUsable/Dynamodb.feature@ItemCountScan') {Param_TableName: 'CA_WOCHIT_MAPPING_EU-qa',Param_Atr1: 'mamAssetInfoReferenceId',Param_Atrvalue1: 'd03eedd4-e345-11ea-9814-0a580a3f06a0',Param_ExpectedItemCount: <ExpectedWocRenditionCount>}    
* def result = call read('classpath:CA/Features/ReUsable/Dynamodb.feature@ItemCountScan') {Param_TableName: 'CA_WOCHIT_RENDITIONS_EU-qa',Param_Atr1: 'createdBy',Param_Atrvalue1: 'step-createWochitRenditions-EU-qa',Param_ExpectedItemCount: <ExpectedWochitMappingCount>}

#-----------Tech Meta Data with Text Comparison---------
#* def TechMetaData_expectedResponse = read('classpath:CA/Tests/E2ECases/Nordic_Region/Norway/' + <TestCaseID> + '/Output/ExpectedTechMetaData.txt')
#* def result = call read('classpath:CA/Features/ReUsable/Dynamodb.feature@ValidatePassedItem') {Param_TableName: 'CA_MAM_ASSETS_INFO_EU-qa',Param_KeyType: 'Single',Param_Atr1: 'assetId',Param_Atr2: '',Param_Atrvalue1: 'd03eedd4-e345-11ea-9814-0a580a3f06a0',Param_Atrvalue2: '',Param_TechMetaDataExpected: '#(TechMetaData_expectedResponse)'}
#* def result = call read('classpath:CA/Features/ReUsable/Dynamodb.feature@GetItem') {Param_TableName: 'CA_MAM_ASSETS_INFO_EU-qa'}
#-----------Tech Meta Data with File Comparison---------
* def Episode_ExpectedResponse = read('classpath:CA/Tests/E2ECases/Nordic_Region/Norway/' + <TestCaseID> + '/Output/ExpectedTechMetaData.txt')
* print '----------TechMetaData_expectedResponse in Calling Scenario--------------'+TechMetaData_expectedResponse
* def result = call read('classpath:CA/Features/ReUsable/Dynamodb.feature@@GetItemMAMAssetInfo') {Param_TableName: 'CA_MAM_ASSETS_INFO_EU-qa',Param_PartitionKey: 'assetId', Param_SortKey: 'compositeViewsId',ParamPartionKeyVal: 'd03eedd4-e345-11ea-9814-0a580a3f06a0', ParamSortKeyVal: 'e1706402-934f-11ea-b2e1-0a580a3cb9b9|a86a5f8c-c5ae-11ea-8c30-0a580a3ebc6b',Param_TechMetaData:'#(TechMetaData_expectedResponse)'}
* def result = call read('classpath:CA/Features/ReUsable/Dynamodb.feature@@GetItemMAMAssetInfo') {Param_TableName: 'CA_MAM_ASSETS_INFO_EU-qa',Param_PartitionKey: 'assetId', Param_SortKey: 'compositeViewsId',ParamPartionKeyVal: 'd03eedd4-e345-11ea-9814-0a580a3f06a0', ParamSortKeyVal: 'adb2fec4-934d-11ea-bcbe-0a580a3c65d4|4cf68d80-890c-11ea-bdcd-0a580a3c35b3',Param_TechMetaData:'#(TechMetaData_expectedResponse)'}
* def result = call read('classpath:CA/Features/ReUsable/Dynamodb.feature@@GetItemMAMAssetInfo') {Param_TableName: 'CA_MAM_ASSETS_INFO_EU-qa',Param_PartitionKey: 'assetId', Param_SortKey: 'compositeViewsId',ParamPartionKeyVal: 'd03eedd4-e345-11ea-9814-0a580a3f06a0', ParamSortKeyVal: 'becf5274-8908-11ea-8e56-0a580a3c10cd|ec70917e-8909-11ea-95eb-0a580a3f8e05',Param_TechMetaData:'#(TechMetaData_expectedResponse)'}
* def result = call read('classpath:CA/Features/ReUsable/Dynamodb.feature@@GetItemMAMAssetInfo') {Param_TableName: 'CA_MAM_ASSETS_INFO_EU-qa',Param_PartitionKey: 'assetId', Param_SortKey: 'compositeViewsId',ParamPartionKeyVal: 'd03eedd4-e345-11ea-9814-0a580a3f06a0', ParamSortKeyVal: 'c7197d98-8907-11ea-983a-0a580a3d1fe6|3a32b7ae-8908-11ea-958b-0a580a3c10cd',Param_TechMetaData:'#(TechMetaData_expectedResponse)'}
* def result = call read('classpath:CA/Features/ReUsable/Dynamodb.feature@@GetItemMAMAssetInfo') {Param_TableName: 'CA_MAM_ASSETS_INFO_EU-qa',Param_PartitionKey: 'assetId', Param_SortKey: 'compositeViewsId',ParamPartionKeyVal: 'd03eedd4-e345-11ea-9814-0a580a3f06a0', ParamSortKeyVal: 'e1706402-934f-11ea-b2e1-0a580a3cb9b9|a86a5f8c-c5ae-11ea-8c30-0a580a3ebc6b',Param_TechMetaData:'#(TechMetaData_expectedResponse)'}

* def QueryJsonExpected = read('classpath:CA/Tests/E2ECases/Nordic_Region/Norway/' + <TestCaseID> +'/Output/Expected16_9_Item.txt')
* replace QueryJsonExpected.TBR = RandomString
* print '-------QueryJsonExpected After Replace--------'+QueryJsonExpected
#* print '----------TechMetaData_expectedResponse in Calling Scenario--------------'+QueryJsonExpected
* def result = call read('classpath:CA/Features/ReUsable/Dynamodb.feature@ScanGetItem') {Param_TableName: 'CA_WOCHIT_RENDITIONS_EU-qa',Param_ScanAttr:'aspectRatio',Param_ScanVal:'ASPECT_16_9',QueryJsonExpected:'#(QueryJsonExpected)'}

* print '-------Executed--------'
Examples:
    | TestCaseID   | TestcaseDescription | ExpectedMAMAssetInfoCount|ExpectedWocRenditionCount|ExpectedWochitMappingCount|
    | 'E2E00001'   | Combination1        |       5                  |  3                      |     3                    |



@Sample
Scenario: Sample Scenario
* print '-----------Sample Scenario-----------'
#* def QueryJsonExpected = read('classpath:CA/Tests/E2ECases/Nordic_Region/Norway/E2E00001/Output/Expected16_9_Item.txt')
#* replace QueryJsonExpected.TBR = 'Test-1599287152283'
#* print '----------TechMetaData_expectedResponse in Calling Scenario--------------'+QueryJsonExpected
#* def result = call read('classpath:CA/Features/ReUsable/Dynamodb.feature@ScanGetItem') {Param_TableName: 'CA_WOCHIT_RENDITIONS_EU-qa',Param_ScanAttr:'aspectRatio',Param_ScanVal:'ASPECT_16_9',QueryJsonExpected:'#(QueryJsonExpected)'}



Scenario: Nordic_Norway_Cmb001-Validate Technical Metadata
    * def TechMetaData_expectedResponse = read('classpath:CA/Tests/E2ECases/Nordic_Region/Norway/Nordic_Norway_Cmb001/Output/ExpectedTechMetaData.txt')
    * def result = call read(FeatureFilePath+'/Dynamodb.feature@GetItemMAMAssetInfo') {Param_TableName: 'CA_MAM_ASSETS_INFO_EU-qa',Param_PartitionKey: 'assetId', Param_SortKey: 'compositeViewsId',ParamPartionKeyVal: 'd03eedd4-e345-11ea-9814-0a580a3f06a0', ParamSortKeyVal: 'e1706402-934f-11ea-b2e1-0a580a3cb9b9|a86a5f8c-c5ae-11ea-8c30-0a580a3ebc6b',Param_TechMetaData:'#(TechMetaData_expectedResponse)'}
    * def result = call read(FeatureFilePath+'/Dynamodb.feature@GetItemMAMAssetInfo') {Param_TableName: 'CA_MAM_ASSETS_INFO_EU-qa',Param_PartitionKey: 'assetId', Param_SortKey: 'compositeViewsId',ParamPartionKeyVal: 'd03eedd4-e345-11ea-9814-0a580a3f06a0', ParamSortKeyVal: 'adb2fec4-934d-11ea-bcbe-0a580a3c65d4|4cf68d80-890c-11ea-bdcd-0a580a3c35b3',Param_TechMetaData:'#(TechMetaData_expectedResponse)'}
    * def result = call read(FeatureFilePath+'/Dynamodb.feature@GetItemMAMAssetInfo') {Param_TableName: 'CA_MAM_ASSETS_INFO_EU-qa',Param_PartitionKey: 'assetId', Param_SortKey: 'compositeViewsId',ParamPartionKeyVal: 'd03eedd4-e345-11ea-9814-0a580a3f06a0', ParamSortKeyVal: 'becf5274-8908-11ea-8e56-0a580a3c10cd|ec70917e-8909-11ea-95eb-0a580a3f8e05',Param_TechMetaData:'#(TechMetaData_expectedResponse)'}
    * def result = call read(FeatureFilePath+'/Dynamodb.feature@GetItemMAMAssetInfo') {Param_TableName: 'CA_MAM_ASSETS_INFO_EU-qa',Param_PartitionKey: 'assetId', Param_SortKey: 'compositeViewsId',ParamPartionKeyVal: 'd03eedd4-e345-11ea-9814-0a580a3f06a0', ParamSortKeyVal: 'c7197d98-8907-11ea-983a-0a580a3d1fe6|3a32b7ae-8908-11ea-958b-0a580a3c10cd',Param_TechMetaData:'#(TechMetaData_expectedResponse)'}
    * def result = call read(FeatureFilePath+'/Dynamodb.feature@GetItemMAMAssetInfo') {Param_TableName: 'CA_MAM_ASSETS_INFO_EU-qa',Param_PartitionKey: 'assetId', Param_SortKey: 'compositeViewsId',ParamPartionKeyVal: 'd03eedd4-e345-11ea-9814-0a580a3f06a0', ParamSortKeyVal: 'e1706402-934f-11ea-b2e1-0a580a3cb9b9|a86a5f8c-c5ae-11ea-8c30-0a580a3ebc6b',Param_TechMetaData:'#(TechMetaData_expectedResponse)'}


