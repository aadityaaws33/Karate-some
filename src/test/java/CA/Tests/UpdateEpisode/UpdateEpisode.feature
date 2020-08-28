Feature:  Update Episode

Background: 
* def currentPath = 'classpath:CA/Tests/UpdateEpisode/'
* def query = read(currentPath + 'data/request.json')
* def expectedResponse = read(currentPath + 'data/ExpectedResponse.json')
* url 'https://app.iconik.io/API/metadata/v1/assets/d03eedd4-e345-11ea-9814-0a580a3f06a0/views/6be501e6-890b-11ea-958b-0a580a3c10cd/'
* header Auth-Token = 'eyJhbGciOiJIUzI1NiIsImlhdCI6MTU4NjA5NjczOCwiZXhwIjoxOTAxNTU2NzM4fQ.eyJpZCI6IjUyNGFjZTU2LTc3NDktMTFlYS04ZmI4LTBhNTgwYTNjMTBmOSJ9.ixPYfczc55WD0Qzzg4-CcL_ILm89HtXxGBHuZZh0U7U'
* header App-ID = '511aba46-7749-11ea-b4d1-0a580a3ebcc5'
@DPLAY
Scenario: Modular Update Season
    * print '--------------Episode Request-----------'+query
    When request query
    And method put
    * print '----------Episode Response------------->'+response
    Then status 200
    And match response == expectedResponse
   