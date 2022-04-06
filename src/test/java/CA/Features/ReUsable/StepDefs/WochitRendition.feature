Feature: Wochit Rendition-related functions

Background:
    * def thisFile = 'classpath:CA/Features/ReUsable/StepDefs/WochitRendition.feature'

@FormExpectedWochitRenditionRecords
Scenario: Form Expected Wochit Rendition Record
    * def formExpectedWochitRenditionRecords =
        """
            function(ExpectedRenditionFileNames, InputMetadata, Config, IconikMetadata) {
                var ExpectedRecords = [];
                for(var i in ExpectedRenditionFileNames) {
                    var thisRenditionStatus = 'FINISHED';
                    if(Config.IconikConfig.TestUser == 'QA_AUTOMATION_USER') {
                        thisRenditionStatus = 'PROCESSING';
                    }

                    var thisTemplateID = InputMetadata.TemplateID[TargetEnv];

                    // Format: <TITLE>|<STRAPTYPE>|<BACKGROUND COLOUR>
                    var dataSplit = ExpectedRenditionFileNames[i].split('|');
                    var thisTitle = "#? _.contains('" + dataSplit[0] + "')";
                    var thisStrapType = dataSplit[1];

                    // EMEA_SHARED_SOME_FILM_QA.mp4-
                    // ASPECT_16_9-
                    // Generic Text On Background
                    // -CTA
                    // -No Strap [not always]
                    // -MegogoBG
                    // -edfbb.mp4
                    var titleSplit = dataSplit[0].split('-');
                    var thisTitleCardType = titleSplit[2];
                    var thisCTA = titleSplit[3];

                    var thisPartner = InputMetadata.Partner;
                    
                    var thisOriginalLine = 'off';
                    if(InputMetadata.Original == 'true') {
                        thisOriginalLine = 'on';
                    }
                    var thisCustomTitle = InputMetadata.CustomTitle;
                    var thisPromotionalLine = InputMetadata.PromotionalLine;
                    var thisLegalText = InputMetadata.LegalText;
                    var thisStrapInTime = InputMetadata.StrapInTime;
                    var thisStrapOutTime = InputMetadata.StrapOutTime;

                    var thisOutroType = 'No Endboard';
                    if(thisTitleCardType != 'No Endboard') {
                        if(thisPartner == 'NONE' || thisPartner == null) {
                            if(InputMetadata.SomeCTA == null && InputMetadata.CustomStrapOutroCTA == null) {
                                thisOutroType = 'SHo Standard No CTA';
                            } else if(InputMetadata.SomeCTA != null || InputMetadata.CustomStrapOutroCTA != null) {
                                thisOutroType = 'SHo Standard'
                            }
                        } else {
                            if(InputMetadata.SomeCTA == null && InputMetadata.CustomStrapOutroCTA == null) {
                                thisOutroType = 'SHo Ingest Model No CTA';
                            } else if(InputMetadata.SomeCTA != null || InputMetadata.CustomStrapOutroCTA != null) {
                                thisOutroType = 'SHo Ingest Model'
                            }
                        }
                    }

                    var GenreTrainTexts = {
                        'Finland': 'Dokumentit + Urheilu + Reality + Rikos + Moottorit',
                        'Norway': 'Sport + Dokumentarer + Humor + Reality + Krim',
                        'Sweden': 'Dokumentärer + Reality + Sport + Humor + Crime',
                        'Denmark': 'Dokumentarer + Serier + Sport + Reality + Krimi',
                        'Netherlands': 'Documentaries + Reality + Sport + Love + True Crime',
                        'EMEA PayTv': 'Documentaries + Reality + Sport + Love + True Crime'
                    }
                    var thisGenreTrainText = GenreTrainTexts[InputMetadata.Market];

                    var thisBackgroundColour = dataSplit[2];
                    
                    var thisTitleArt = ' ';
                    if(thisTitleCardType.contains('Title')) {
                        thisTitleArt = '#notnull';
                    }

                    var thisKeyArt = ' ';
                    if(thisTitleCardType.contains('Key')) {
                        thisKeyArt = '#notnull';
                    }

                    var thisAffiliateLogo = ' ';
                    if(thisPartner != 'NONE') {
                        thisAffiliateLogo = '#notnull';
                    }

                    var thisAspectRatio = titleSplit[1];
                    
                    var thisCollectionName = IconikMetadata.IconikCollectionName;

                    var thisExpectedRecordParams = {
                        RenditionStatus: thisRenditionStatus,
                        TemplateID: thisTemplateID,
                        Title: thisTitle,
                        TitleCardType: thisTitleCardType,
                        StrapType: thisStrapType,
                        OriginalLine: thisOriginalLine,
                        CustomTitle: thisCustomTitle,
                        PromotionalLine: thisPromotionalLine,
                        LegalText: thisLegalText,
                        StrapInTime: thisStrapInTime,
                        StrapOutTime: thisStrapOutTime,
                        CTA: thisCTA,
                        OutroType: thisOutroType,
                        GenreTrainText: thisGenreTrainText,
                        BackgroundColour: thisBackgroundColour,
                        TitleArt: thisTitleArt,
                        KeyArt: thisKeyArt,
                        AffiliateLogo: thisAffiliateLogo,
                        AspectRatio: thisAspectRatio,
                        CollectionName: thisCollectionName
                    }

                    if(Config.IconikConfig.TestUser != 'QA_AUTOMATION_USER') {
                        thisExpectedRecordParams.WochitResponse = '#notnull'
                    }

                    var thisExpectedRecord = karate.call(thisFile + '@LoadExpectedRecord', thisExpectedRecordParams).result;
                    var thisRecord = {
                        Title: dataSplit[0],
                        Identifier: ExpectedRenditionFileNames[i],
                        Expected: thisExpectedRecord
                    }
                    ExpectedRecords.push(thisRecord)
                }
                return ExpectedRecords
            }
        """
    * def result = formExpectedWochitRenditionRecords(ExpectedRenditionFileNames, InputMetadata, Config, IconikMetadata)

@ValidateWochitRenditionRecords
Scenario: Validate Wochit Rendition Records
    * def validateWochitRenditionRecords =
        """
            function(ExpectedWochitRenditionRecords, Config, ExpectedDate) {
                var result = {
                    message: [],
                    pass: true,
                    validatedFilenames: [],
                    unvalidatedFilenames: []
                }

                var WochitRenditionIDs = [];
                for(i in ExpectedWochitRenditionRecords) {
                    var thisRecord = ExpectedWochitRenditionRecords[i]
                    var searchTitle = thisRecord.Title;
                    var expectedRecord = thisRecord.Expected;
                    karate.write(karate.pretty(expectedRecord), OutputWritePath + '/DynamoDBRecords/WochitRenditionRecord' + i + '-Expected.json');
                    var ValidateItemViaQueryParams = {
                        Param_TableName: Config.DynamoDBConfig.WochitRendition.TableName,
                        Param_QueryAttributeList: [
                            {
                                attributeName: 'assetType',
                                attributeValue: 'VIDEO',
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
                                attributeName: 'title',
                                attributeValue: searchTitle,
                                attributeComparator: 'contains',
                                attributeType: 'filter'
                            },
                            {
                                attributeName: 'aspectRatio',
                                attributeValue: expectedRecord.aspectRatio,
                                attributeComparator: 'contains',
                                attributeType: 'filter'
                            }
                        ],
                        Param_GlobalSecondaryIndex: Config.DynamoDBConfig.WochitRendition.GSI,
                        Param_ExpectedResponse: expectedRecord,
                        AWSRegion: Config.AWSRegion,
                        Retries: 90,
                        RetryDuration: 10000,
                        WriteToFile: true,
                        WritePath: OutputWritePath + '/DynamoDBRecords/WochitRenditionRecord' + i + '.json',
                        ShortCircuit: {
                            Key: 'renditionStatus',
                            Value: 'FAILED'
                        },
                        TCName: thisTCMetadata.TCName
                    }
                    var thisResult = karate.call(ReUsableFeaturesPath + '/StepDefs/DynamoDB.feature@ValidateItemViaQuery',  ValidateItemViaQueryParams).result;
                    if(thisResult.pass == true) {
                        var isSame = false
                        for(var i in thisResult.response) {
                            var thisResp = thisResult.response[i];
                            var thisPath = '$.videoUpdates.linkedFields.*';
                            var RespLinkedFieldValues = karate.jsonPath(thisResp, thisPath);
                            var ExpectedLinkedFieldValues = karate.jsonPath(expectedRecord, thisPath);

                            var ComparisonResult = karate.call(thisFile + '@Compare', {Expected: ExpectedLinkedFieldValues, Actual: RespLinkedFieldValues}).result;
                            karate.log(karate.pretty(ComparisonResult));
                            if(ComparisonResult.pass) {
                                WochitRenditionIDs= WochitRenditionIDs.concat(thisResp.ID);
                                isSame = true
                                result.validatedFilenames.push(thisResp.title);
                                var msg = thisRecord.Identifier;
                                karate.log('[' + thisTCMetadata.TCName + '] - Wochit Rendition Payload: Validation Successful - ' + msg);
                                break;
                            }                           
                        }
                        if(!isSame) {
                            var msg = thisRecord.Identifier + ' - ' + thisResult.message;
                            result.pass = false;
                            result.unvalidatedFilenames.push(msg);
                            karate.log('[' + thisTCMetadata.TCName + '] - Wochit Rendition Payload: Validation Failed - ' + msg);
                        }
                    } else {
                        var msg = thisRecord.Identifier + ' - ' + thisResult.message;
                        result.pass = false;
                        result.unvalidatedFilenames.push(msg);
                        karate.log('[' + thisTCMetadata.TCName + '] - Wochit Rendition Payload: Validation Failed - ' + msg);
                    }
                    Pause(1000);
                }

                //RECORD RENDITION FILENAMES INTO thisTCMetadata!
                thisTCMetadata.Expected.WochitRenditionFileNames = karate.toJson(result.validatedFilenames);
                thisTCMetadata.Expected.WochitRenditionIDs = karate.toJson(WochitRenditionIDs);
                
                //karate.write(karate.pretty(thisTCMetadata), OutputWritePath + '/thisTCMetadata.json');
                updateThisTCMetadata(thisTCMetadata);
                karate.log(result);

                return result
            }
        """
    * def result = validateWochitRenditionRecords(ExpectedWochitRenditionRecords, Config, ExpectedDate)
    
@Compare
Scenario: Compare
    * def result = karate.match('Actual contains deep Expected')

@LoadExpectedRecord
Scenario: Load Expected Records - Replace all variables in JSON automatically
    * def loadExpectedRecord =
        """
            function() {
                var thisExpectedRecord = karate.read(ResourcesPath + '/E2ECases/' + thisTCMetadata.InputMetadata.Market + '/Expected/WochitRenditionRecord.json');
                try {
                    karate.log('Wochit Response Detected.');
                    thisExpectedRecord.wochitResponse = WochitResponse;
                } catch(e) {
                    karate.log('No WochitResponse Detected.');
                }

                return thisExpectedRecord
            }
        """
    * def result = loadExpectedRecord()