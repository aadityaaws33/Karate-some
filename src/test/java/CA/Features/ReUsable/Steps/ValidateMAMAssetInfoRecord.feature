Feature: MAM Asset Info Record Validation

Background:
    * def thisFile = 'classpath:CA/Features/ReUsable/Steps/ValidateMAMAssetInfoRecord.feature'
    * def thisTCMetadata = karate.read(thisOutputReadPath + '/TCMetadata.json')

@ValidateMAMAssetInfoRecord
Scenario: Main
    # SEARCH AND VALIDATE MAM ASSET INFO RECORD
    * def ExpectedMAMAssetRecord = karate.read(ResourcesPath + '/E2ECases/' + thisTCMetadata.InputMetadata.Country +  '/Expected/MAMAssetInfoRecord.json')
    * karate.log(ExpectedMAMAssetRecord)
    * karate.write(karate.pretty(ExpectedMAMAssetRecord), OutputWritePath + '/DynamoDBRecords/MAMAssetInfoRecord-Expected.json')
    * def ValidateItemViaQueryParams =
        """
            {
                Param_TableName: #(thisTCMetadata.Config.DynamoDBConfig.MAMAssetInfo.TableName),
                Param_QueryAttributeList: [
                    {
                        attributeName: 'assetId',
                        attributeValue: '#(thisTCMetadata.IconikMetadata.IconikAssetId)',
                        attributeComparator: '=',
                        attributeType: 'key'
                    },
                    {
                        attributeName: 'createdAt',
                        attributeValue: '#(ExpectedDate)',
                        attributeComparator: '>=',
                        attributeType: 'filter'
                    },
                    {
                        attributeName: 'assetTitle',
                        attributeValue: '#(thisTCMetadata.IconikMetadata.IconikSourceAssetName)',
                        attributeComparator: '=',
                        attributeType: 'filter'
                    }
                ],
                Param_GlobalSecondaryIndex: '',
                Param_ExpectedResponse: #(ExpectedMAMAssetRecord),
                AWSRegion: #(thisTCMetadata.Config.AWSRegion),
                Retries: 120,
                RetryDuration: 10000,
                WriteToFile: true,
                WritePath: #(OutputWritePath + '/DynamoDBRecords/MAMAssetInfoRecord.json'),
                ShortCircuit: null,
                TCName: '#(thisTCMetadata.TCName)'
            }
        """
    * def validationResult = karate.call(ReUsableFeaturesPath + '/StepDefs/DynamoDB.feature@ValidateItemViaQuery',  ValidateItemViaQueryParams).result
    * thisTCMetadata.Expected.MAMAssetID = thisTCMetadata.IconikMetadata.IconikAssetId
    * updateThisTCMetadata(thisTCMetadata)
    * validationResult.pass == true? karate.log('[PASSED] MAM Asset Info Record Validation - ' + thisTCMetadata.TCName) : karate.fail('[FAILED] MAM Asset Info Record Validation - ' + thisTCMetadata.TCName + ': ' + karate.pretty(validateItemViaQueryResponse.message))