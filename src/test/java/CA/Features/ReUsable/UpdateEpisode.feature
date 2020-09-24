@parallel=false
Feature:  Update Episode

Background: 
  * url URL
  * header Auth-Token = Auth_Token
  * header App-ID = App_ID
  * request Query
  * method put

@DPLAY
Scenario: Update Episode: Check null fields and specific metadata_values
  * print response
  * def result = karate.match('response contains ExpectedResponse')
  * print result