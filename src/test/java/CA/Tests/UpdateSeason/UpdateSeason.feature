Feature:  Update Season

Background: 
* print Param_SeriesTitle
* def currentPath = 'classpath:CA/Tests/UpdateSeason/'
* def query = read(currentPath + 'data/request.json')
#* print '----------query Before Replace---------'+query
* replace query.SeriesTitle = Param_SeriesTitle
#* print '----------query After Replace---------'+query
* def expectedResponse = read(currentPath + 'data/ExpectedResponse.json')
#* print '----------expectedResponse before Replace---------'+expectedResponse
#* replace expectedResponse.SeriesTitle = Param_SeriesTitle
#* print '----------expectedResponse After Replace---------'+expectedResponse
* url 'https://app.iconik.io/API/metadata/v1/collections/b78432bc-e03f-11ea-a22d-0a580a3c35aa/views/4cf68d80-890c-11ea-bdcd-0a580a3c35b3/'
* header Auth-Token = 'eyJhbGciOiJIUzI1NiIsImlhdCI6MTU4NjA5NjczOCwiZXhwIjoxOTAxNTU2NzM4fQ.eyJpZCI6IjUyNGFjZTU2LTc3NDktMTFlYS04ZmI4LTBhNTgwYTNjMTBmOSJ9.ixPYfczc55WD0Qzzg4-CcL_ILm89HtXxGBHuZZh0U7U'
* header App-ID = '511aba46-7749-11ea-b4d1-0a580a3ebcc5'
 
@DPLAY
Scenario: Modular Update Season
* print '--------------Season Request-----------'+query
When request query
And method put
* print '----------Season Response------------->'+response
Then status 200
And match response contains expectedResponse
#* print '--------Actual Series Title----------'+ get[0] response.no-dplay-SeriesTitle.field_values[0].value
* print '--------Actual Series Title----------'+karate.jsonPath(response,"$.metadata_values.no-dplay-SeriesTitle.field_values[0].value")
And match karate.jsonPath(response,"$.metadata_values.no-dplay-SeriesTitle.field_values[0].value") == Param_SeriesTitle
