Feature:  Dplay Norway CA

Background:
    #* def Pause = function(pause){ java.lang.Thread.sleep(pause) }
    #* def result = call read('classpath:CA/Features/ReUsable/Dynamodb.feature@TruncateTable') {Param_TableName: 'CA_WOCHIT_MAPPING_EU-qa',Param_PrimaryKey: 'ID'}
    #* def result = call read('classpath:CA/Features/ReUsable/Dynamodb.feature@TruncateTable') {Param_TableName: 'CA_WOCHIT_RENDITIONS_EU-qa',Param_PrimaryKey: 'ID'}  
    #* Pause(5000)  
    * def result = call read('classpath:CA/Features/ReUsable/Dynamodb.feature@ItemCount') {Param_TableName: 'CA_WOCHIT_MAPPING_EU-qa',Param_PrimaryKey: 'ID'}    
    * def result = call read('classpath:CA/Features/ReUsable/Dynamodb.feature@ItemCount') {Param_TableName: 'CA_WOCHIT_RENDITIONS_EU-qa',Param_PrimaryKey: 'ID'}  

    #* def result = call read('classpath:CA/Features/ReUsable/Dynamodb.feature@TruncateTable')
    
    
    
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
* def result = call read('classpath:CA/Features/ReUsable/Rendition.feature') {RenditionQuery: '#(Renditionquery)',RenditionExpectedResponse: '#(Rendition_ExpectedResponse)',RandomText: '#(RandomString)',JsonValidation1:<JsonPath1>,JsonValidation2:<JsonPath2>,JsonValidation3:<JsonPath3>}

* def result = call read('classpath:CA/Features/ReUsable/Dynamodb.feature@ItemCountScan') {Param_TableName: 'CA_MAM_ASSETS_INFO_EU-qa',Param_KeyType: 'Single',Param_Atr1: 'assetId',Param_Atr2: '',Param_Atrvalue1: 'd03eedd4-e345-11ea-9814-0a580a3f06a0',Param_Atrvalue2: '',Param_ExpectedMAMAssetInfoItemCount: <ExpectedMAMAssetInfoCount>}    
* def result = call read('classpath:CA/Features/ReUsable/Dynamodb.feature@ItemCount') {Param_TableName: 'CA_WOCHIT_MAPPING_EU-qa',Param_PrimaryKey: 'ID',Param_ExpectedItemCount: <ExpectedWocRenditionCount>}    
* def result = call read('classpath:CA/Features/ReUsable/Dynamodb.feature@ItemCount') {Param_TableName: 'CA_WOCHIT_RENDITIONS_EU-qa',Param_PrimaryKey: 'ID',Param_ExpectedItemCount: <ExpectedWochitMappingCount>}
* print '-------Executed--------'
Examples:
    | TestCaseID   | TestcaseDescription | JsonPath1                                                    | JsonPath2                                                     |        JsonPath3                                              | ExpectedMAMAssetInfoCount|ExpectedWocRenditionCount|ExpectedWochitMappingCount|
    | 'E2E00001'   | Combination1        |"$.mamAssetInfo[0].seasonMetadata.data.no-dplay-SeriesTitle"  |"$.mamAssetInfo[1].seasonMetadata.data.no-dplay-SeriesTitle"   |"$.mamAssetInfo[2].seasonMetadata.data.no-dplay-SeriesTitle"   |       5                  |  3                      |     3                    |



@Sample
Scenario: Sample Scenario
* print '-----------Sample Scenario-----------'