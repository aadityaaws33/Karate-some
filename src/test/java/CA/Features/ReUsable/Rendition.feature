Feature: Rendition

Background: 
* url URL
* header Auth-Token = Auth_Token
* header App-ID = App_ID

Scenario: Rendition
#* print '--------------Season Request-----------'+RenditionQuery
When request RenditionQuery
And method post
Then def result = karate.match('response contains RenditionExpectedResponse')

