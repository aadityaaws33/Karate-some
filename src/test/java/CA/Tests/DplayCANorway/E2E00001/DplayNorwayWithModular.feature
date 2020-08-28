Feature:  Dplay Norway CA

Background:
    * def Pause = function(pause){ java.lang.Thread.sleep(pause) }
    
@Module_WithoutRandom
Scenario Outline: Sample POC for Dplay CA 
* def result = call read('classpath:CA/Tests/UpdateSeason/UpdateSeason.feature') {Param_SeriesTitle: '<SeriesTitle>'}
* def result = call read('classpath:CA/Tests/UpdateEpisode/UpdateEpisode.feature') {Param_SeriesTitle: '<SeriesTitle>'}
* print '-------Executed--------'

Examples:
    | SeriesTitle                   | 
    | CA_QA_Automation_28_8_0001    | 


@Module
Scenario: Sample POC for Dplay CA 
* def Random_String_Generator = function(){ return java.lang.System.currentTimeMillis() }
* def RandomString = 'Test-' + Random_String_Generator()
* print '---------------Random Text----------'+RandomString

* def UpdateSeasonquery = read('classpath:CA/Tests/DplayCANorway/E2E00001/data/SeasonRequest.json')
* replace UpdateSeasonquery.SeriesTitle = RandomString
* print '-----------------Query After Replace------------'+UpdateSeasonquery
* def Season_expectedResponse = read('classpath:CA/Tests/DplayCANorway/E2E00001/data/ExpectedSeasonResponse.json')
* def result = call read('classpath:CA/Tests/UpdateSeason/UpdateSeason.feature') {SeasonQuery: '#(UpdateSeasonquery)',SeasonExpectedResponse: '#(Season_expectedResponse)',ExpectedSeriesTitle: '#(RandomString)'}

* def UpdateEpisodequery = read('classpath:CA/Tests/DplayCANorway/E2E00001/data/EpisodeRequest.json')
* replace UpdateEpisodequery.SeriesTitle = RandomString
* print '-----------------Query After Replace------------'+UpdateEpisodequery
* def Episode_ExpectedResponse = read('classpath:CA/Tests/DplayCANorway/E2E00001/data/ExpectedEpisodeResponse.json')
* def result = call read('classpath:CA/Tests/UpdateEpisode/UpdateEpisode.feature') {EpisodeQuery: '#(UpdateEpisodequery)',EpisodeExpectedResponse: '#(Episode_ExpectedResponse)',RandomText: '#(RandomString)'}
* print '-------Executed--------'