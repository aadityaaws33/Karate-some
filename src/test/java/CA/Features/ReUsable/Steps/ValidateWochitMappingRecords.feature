Feature: Wochit Mapping Record Validation

Background:
    * def thisFile = 'classpath:CA/Features/ReUsable/Steps/ValidateWochitMappingRecords.feature'
    * def thisTCMetadata = karate.read(thisOutputReadPath + '/TCMetadata.json')

Scenario: Wochit Mapping Record Validation
    * def ExpectedRenditionFileNames = thisTCMetadata.Expected.WochitRenditionFileNames
    * karate.log(ExpectedRenditionFileNames)
    * def formExpectedWochitMappingRecords =
        """
            function(ExpectedRenditionFileNames, InputMetadata, IconikConfig, Config, IconikMetadata) {
                var expectedWochitMappingRecords = [];
                for(var i in ExpectedRenditionFileNames) {

                    var thisRenditionFileName = ExpectedRenditionFileNames[i] + '.mp4';
                    
                    var thisSeasonCollectionID = '#notnull';
                    var thisSeriesName = '#null';
                    if(thisRenditionFileName.toLowerCase().contains('show')) {
                        thisSeasonCollectionID = '#notnull';
                        thisSeriesName = '#notnull';
                    }

                    var thisUsername = Config.DynamoDBConfig.Username[Config.IconikConfig.TestUser];
                    var thisRenditionStatus = 'COMPLETED';
                    var thisWochitRenditionStatus = 'FINISHED';
                    var thisIsRenditionMoved = 'true'
                    if(thisUsername == 'QA_AUTOMATION_USER') {
                        thisRenditionStatus = 'PROCESSING';
                        thisWochitRenditionStatus = 'PROCESSING';
                        thisIsRenditionMoved = 'false';
                    }

                    var thisMarket = InputMetadata.Country.toUpperCase();
                    var thisMAMAssetInfoReferenceID = IconikMetadata.IconikAssetId;

                    var thisPartner = InputMetadata.Partner;

                    var thisExpectedRecordParams = {
                        RenditionFilename: thisRenditionFileName,
                        RenditionStatus: thisRenditionStatus,
                        IsRenditionMoved: thisIsRenditionMoved,
                        WochitRenditionStatus: thisWochitRenditionStatus,
                        Username: thisUsername,
                        SeasonCollectionID: thisSeasonCollectionID,
                        SeriesName: thisSeriesName,
                        Market: thisMarket,
                        MAMAssetInfoReferenceID: thisMAMAssetInfoReferenceID,
                        Partner: thisPartner,
                        thisTCMetadata: thisTCMetadata
                    }
                    var thisExpectedRecord = karate.call(thisFile + '@LoadExpectedRecord', thisExpectedRecordParams).result;
                    
                    var thisRecord = {
                        Identifier: thisRenditionFileName,
                        Expected: thisExpectedRecord
                    }
                    expectedWochitMappingRecords.push(thisRecord);
                }

                return expectedWochitMappingRecords
            }
        """
    * def ExpectedWochitMappingRecords = formExpectedWochitMappingRecords(ExpectedRenditionFileNames, thisTCMetadata.InputMetadata, thisTCMetadata.IconikConfig, thisTCMetadata.Config, thisTCMetadata.IconikMetadata)
    * karate.log(ExpectedWochitMappingRecords)
    * def validateWochitMappingRecords =
        """
            function(ExpectedWochitMappingRecords, Config, IconikMetadata, ExpectedDate, TCName) {
                var result = {
                    message: [],
                    pass: true
                }

                var WochitMappingIDs = [];
                var IconikRenditionAssetIDs = [];
                for(var i in ExpectedWochitMappingRecords) {
                    var thisRecord = ExpectedWochitMappingRecords[i];
                    var expectedRecord = thisRecord.Expected;
                    karate.write(karate.pretty(expectedRecord), OutputWritePath + '/DynamoDBRecords/WochitMappingRecord' + i + '-Expected.json');
                    var ValidateItemViaQueryParams = {
                        Param_TableName: Config.DynamoDBConfig.WochitMapping.TableName,
                        Param_QueryAttributeList: [
                            {
                                attributeName: 'mamAssetInfoReferenceId',
                                attributeValue: expectedRecord.mamAssetInfoReferenceId,
                                attributeComparator: '=',
                                attributeType: 'key'
                            },
                            {
                                attributeName: 'createdAt',
                                attributeValue: ExpectedDate,
                                attributeComparator: '>=',
                                attributeType: 'key'
                            },
                            {
                                attributeName: 'renditionFileName',
                                attributeValue: expectedRecord.renditionFileName,
                                attributeComparator: 'contains',
                                attributeType: 'filter'
                            }
                        ],
                        Param_GlobalSecondaryIndex: Config.DynamoDBConfig.WochitMapping.GSI,
                        Param_ExpectedResponse: expectedRecord,
                        AWSRegion: Config.AWSRegion,
                        Retries: 120,
                        RetryDuration: 10000,
                        WriteToFile: true,
                        WritePath: OutputWritePath + '/DynamoDBRecords/WochitMappingRecord' + i + '.json',
                        ShortCircuit: {
                            Key: 'renditionStatus',
                            Value: 'FAILED'
                        },
                        TCName: thisTCMetadata.TCName
                    }
                    var thisResult = karate.call(ReUsableFeaturesPath + '/StepDefs/DynamoDB.feature@ValidateItemViaQuery',  ValidateItemViaQueryParams).result;
                    if(!thisResult.pass) {
                        var msg = 'Failed to validate ' + expectedRecord.mamAssetInfoReferenceId;
                        result.message.push(msg)
                        result.pass = false
                        karate.log('[' + TCName + '] - Wochit Rendition Mapping: Validation Failed - ' + msg);
                    } else {
                        karate.log('[' + TCName + '] - Wochit Rendition Mapping: Validation Successful - ' + expectedRecord.renditionFileName);
                    }
                    var thisPath = '$.*.ID';
                    var IDs = karate.jsonPath(thisResult.response, thisPath);
                    WochitMappingIDs = WochitMappingIDs.concat(IDs);

                    thisPath = '$.*.renditionAssetId';
                    var AssetIDs = karate.jsonPath(thisResult.response, thisPath);
                    IconikRenditionAssetIDs = IconikRenditionAssetIDs.concat(AssetIDs);
                }
                
                thisTCMetadata.Expected.WochitMappingIDs = karate.toJson(WochitMappingIDs);
                thisTCMetadata.Expected.IconikRenditionAssetIDs = karate.toJson(IconikRenditionAssetIDs);
                updateThisTCMetadata(thisTCMetadata);

                return result;
            }
        """
    * def validationResult = validateWochitMappingRecords(ExpectedWochitMappingRecords, thisTCMetadata.Config, thisTCMetadata.IconikMetadata, ExpectedDate, thisTCMetadata.TCName)
    * validationResult.pass == true? karate.log('[PASSED] Wochit Mapping Records Validation - ' + thisTCMetadata.TCName) : karate.fail('[FAILED] Wochit Mapping Records Validation - ' + thisTCMetadata.TCName + ': ' + karate.pretty(validationResult))

@LoadExpectedRecord
Scenario: Load Expected Records - Replace all variables in JSON automatically
    * def loadExpectedRecord =
        """
            function(thisTCMetadata) {
                var thisExpectedRecord = karate.read(ResourcesPath + '/E2ECases/' + thisTCMetadata.InputMetadata.Country + '/Expected/WochitMappingRecord.json');

                return thisExpectedRecord
            }
        """
    * def result = loadExpectedRecord(thisTCMetadata)