@Regression @StarzplayAR
Feature: Netherlands Phase 2 Non-Partner Rendition
# TOTAL: 48 Renditions
Scenario Outline: Netherlands Phase 2 Partner STARZPLAY AR Testing for <DURATION>s Video
    * def TCMetadata = 
        """
            {
                TCName: 'EMEAPayTv_StarzplayAR_Phase2_<DURATION>s',
                InputMetadata: {
                    Market: 'EMEA PayTv',
                    Phase: 2,
                    Type: 'Show',
                    IconikAspectRatios: <ICONIK ASPECT RATIOS>,
                    ColourSchemes: 'DARK BLUE',
                    StrapTypes: 'Standard Logo, CTA & Title',
                    StrapInTime: '1',
                    StrapOutTime: '9',
                    TitleCardTypes: 'Generic Text On Background|Title Art Over Key Art',
                    CustomTitle: 'Test_Automation_Netherlands_P2_NonPartner',
                    Original: 'true',
                    PromotionalLine: 'Promo Line',
                    SomeCTA: 'STARZPLAY SOME CTA',
                    CustomStrapOutroCTA: 'TEST AUTOMATION SHOW STRAP OUTRO',
                    LegalText: 'Legal Text',
                    TemplateID: {
                        qa: '619dba528290d6283ecc372a',
                        prod: '61a474ca8290d6283ecc41e5',
                    },
                    Partner: 'StarzplayAR'
                },
                IconikMetadata: {
                    IconikCustomActionTitle: {
                        qa: 'QA - SoMe - NL Starzplay AR Trigger',
                        prod: 'Ingest Model Starzplay AR trigger'
                    },
                    IconikMetadataViewName: {
                        qa: 'NL Phase 2 Partner Metadata - Starzplay AR',
                        prod: 'NL Phase 2 Partner Metadata - Starzplay AR'
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
                RandomString: '1648446956578',
                ExpectedDate: '2022-03-28',
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
        | 20000     | STARZPLAYAR_SOME_FILM        |  15       | 16x9                 |
        | 20000     | STARZPLAYAR_SOME_FILM        |  25       | 1x1                  |
        | 20000     | STARZPLAYAR_SOME_FILM        |  30       | 9x16                 |