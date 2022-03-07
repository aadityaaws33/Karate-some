@Regression @JawwyAR
Feature: Netherlands Phase 2 Non-Partner Rendition

Scenario Outline: Netherlands Phase 2 Partner JAWWY AR Testing for <DURATION>s Video
    * def TCMetadata = 
        """
            {
                TCName: 'EMEAPayTv_JawwyAR_Phase2_<DURATION>s',
                InputMetadata: {
                    Market: 'EMEA PayTv',
                    Phase: 2,
                    Type: 'Show',
                    IconikAspectRatios: <ICONIK ASPECT RATIOS>,
                    ColourSchemes: 'DARK BLUE|TURQUOISE',
                    StrapTypes: 'Standard Logo, CTA & Title|No Strap',
                    StrapInTime: '1',
                    StrapOutTime: '9',
                    TitleCardTypes: 'Generic Text On Background|Title Art Over Key Art',
                    CustomTitle: 'Test_Automation_Netherlands_P2_NonPartner',
                    Original: 'true',
                    PromotionalLine: 'Promo Line',
                    SomeCTA: 'JAWWYAR SOME CTA',
                    CustomStrapOutroCTA: 'TEST AUTOMATION SHOW STRAP OUTRO',
                    LegalText: 'Legal Text',
                    TemplateID: {
                        qa: '619dba528290d6283ecc372a',
                        prod: '61a474ca8290d6283ecc41e5',
                    },
                    Partner: 'JawwyAR'
                },
                IconikMetadata: {
                    IconikCustomActionTitle: {
                        qa: 'QA - SoMe - NL Jawwy AR Trigger',
                        prod: 'Ingest Model Jawwy AR Trigger'
                    },
                    IconikMetadataViewName: {
                        qa: 'NL Phase 2 Partner Metadata - Jawwy AR',
                        prod: 'NL Phase 2 Partner Metadata - Jawwy AR'
                    },
                    IconikMediaType: 'Film',
                    IconikCollectionName: 'SOME QA AUTOMATION',
                    IconikSourceAssetName: #('<ICONIK SOURCE ASSET NAME>' + '_' + TargetEnv.toUpperCase() + '_' + '<DURATION>' + '.mp4'),
                    IconikAssetType: 'VIDEO',
                    IconikRenditionRequestResourcePath: '/E2ECases/EMEA PayTv/Input/IconikRenditionRequest.json'
                }
            }
        """
    # FOR DEVELOPMENT PURPOSES - Set GenerateRandomString to false and use old RandomString and ExpectedDate
    * def SetupParams =
        """
            {
                GenerateRandomString: true,
                RandomString: '1646290833433',
                ExpectedDate: '2022-03-03',
                WaitTime: <WAIT TIME>
            }
        """
    * call read('classpath:CA/Features/Reusable/Steps/Setup.feature') SetupParams
    * configure afterFeature =
        """
            function() {
                karate.call(ReUsableFeaturesPath + '/Steps/Teardown.feature@Teardown', { thisFeatureInfo: karate.info, thisOutputReadPath: OutputReadPath });
            }
        """
    * SetupParams.GenerateRandomString == true? karate.call(ReUsableFeaturesPath + '/Steps/TriggerIconikRendition.feature', { thisOutputWritePath: OutputWritePath, thisOutputReadPath: OutputReadPath }): ''
    * karate.call(ReUsableFeaturesPath + '/Steps/ValidateMAMAssetInfoRecord.feature@ValidateMAMAssetInfoRecord', { thisOutputWritePath: OutputWritePath, thisOutputReadPath: OutputReadPath })
    * karate.call(ReUsableFeaturesPath + '/Steps/ValidateWochitRenditionRecords.feature@ValidateWochitRenditionRecords', { thisOutputWritePath: OutputWritePath, thisOutputReadPath: OutputReadPath, Duration: <DURATION> })
    * karate.call(ReUsableFeaturesPath + '/Steps/ValidateWochitMappingRecords.feature', { thisOutputWritePath: OutputWritePath, thisOutputReadPath: OutputReadPath })

    Examples:
        | WAIT TIME | ICONIK SOURCE ASSET NAME | DURATION |  ICONIK ASPECT RATIOS |
        | 15000     | JAWWYAR_SOME_FILM        |  15       | 16x9                 |
        | 15000     | JAWWYAR_SOME_FILM        |  25       | 1x1                  |
        | 15000     | JAWWYAR_SOME_FILM        |  30       | 9x16                 |