@parallel=false 
Feature: Delete AssetDB Records

Scenario: Delete AssetDB Records
    # * json XMLNodes = read('classpath:' + DownloadsPath + '/' + ExpectedDataFileName)
    # * def TrailerIDs = karate.jsonPath(XMLNodes, '$.trailers._.trailer[*].*.id').length == 0?karate.jsonPath(XMLNodes, '$.trailers._.trailer[*].id'):karate.jsonPath(XMLNodes, '$.trailers._.trailer[*].*.id')
    Given def FormDeleteDBRecordRequestsParams =
        """
            {
                TrailerData: #(TrailerData)
            }
        """
    And def DeleteDBRecordsParams = karate.call(ReUsableFeaturesPath + '/StepDefs/DynamoDB.feature@FormDeleteDBRecordRequests', FormDeleteDBRecordRequestsParams).result
    When def deleteDBRecordStatus = karate.call(ReUsableFeaturesPath + '/StepDefs/DynamoDB.feature@DeleteDBRecords', DeleteDBRecordsParams).result
    Then deleteDBRecordStatus.pass == true?karate.log('[PASSED]: Successfully deleted in DB: ' + TrailerIDs):karate.fail('[FAILED]: ' + deleteDBRecordStatus.message)
