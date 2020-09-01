Feature:  Dplay Norway CA

Background:
    * def Pause = function(pause){ java.lang.Thread.sleep(pause) }
    
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


* print '-------Executed--------'
Examples:
    | TestCaseID   | TestcaseDescription | JsonPath1                                                    | JsonPath2                                                     |        JsonPath3                                              |
    | 'E2E00001'   | Combination1        |"$.mamAssetInfo[0].seasonMetadata.data.no-dplay-SeriesTitle"  |"$.mamAssetInfo[1].seasonMetadata.data.no-dplay-SeriesTitle"   |"$.mamAssetInfo[2].seasonMetadata.data.no-dplay-SeriesTitle"   |