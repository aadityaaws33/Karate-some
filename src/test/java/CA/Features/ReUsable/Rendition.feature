Feature: Rendition

Background: 
* url TriggerRenditionURL
* header Auth-Token = Auth_Token
* header App-ID = App_ID

Scenario: Rendition
#* print '--------------Season Request-----------'+RenditionQuery
When request RenditionQuery
And method post
#* print '----------Season Response------------->'+RenditionExpectedResponse
Then status 200
#And match response contains RenditionExpectedResponse
#* print '----------First------------->'+karate.jsonPath(response,"$.mamAssetInfo[0].seasonMetadata.data.no-dplay-SeriesTitle")
#* print '----------Second------------->'+karate.jsonPath(response,"$.mamAssetInfo[1].seasonMetadata.data.no-dplay-SeriesTitle")
#* print '----------Third------------->'+karate.jsonPath(response,"$.mamAssetInfo[2].seasonMetadata.data.no-dplay-SeriesTitle")

#* print '----------First------------->'+karate.jsonPath(response,JsonValidation1)
#* print '----------Second------------->'+karate.jsonPath(response,JsonValidation2)
#* print '----------Third------------->'+karate.jsonPath(response,JsonValidation3)

#And match karate.jsonPath(response,"$.mamAssetInfo[0].seasonMetadata.data.no-dplay-SeriesTitle") == RandomText

