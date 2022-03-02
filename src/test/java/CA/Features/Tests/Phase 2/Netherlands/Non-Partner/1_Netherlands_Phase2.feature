@Regression
Feature: Netherlands Phase 2 Non-Partner Rendition

Scenario Outline: Netherlands Phase 2 Non-partner Testing for <DURATION>s Video
    * def TCMetadata = 
        """
            {
                TCName: 'Netherlands_Phase2_NonPartner_<DURATION>s',
                InputMetadata: {
                    Market: 'Netherlands',
                    Phase: 2,
                    Type: 'Show',
                    IconikAspectRatios: '<ICONIK ASPECT RATIOS>',
                    ColourSchemes: 'DARK BLUE|TURQUOISE',
                    StrapTypes: 'Standard Logo, CTA & Title|No Strap',
                    StrapInTime: '1',
                    StrapOutTime: '9',
                    TitleCardTypes: 'Generic Text On Background|Title Art Over Key Art',
                    CustomTitle: 'Test_Automation_Netherlands_P2_NonPartner',
                    Original: 'true',
                    PromotionalLine: 'Promo Line',
                    SomeCTA: 'binnenkort',
                    CustomStrapOutroCTA: 'TEST AUTOMATION SHOW STRAP OUTRO',
                    LegalText: 'Legal Text',
                    TemplateID: '619dcc43a4c6857058c001a1',
                    Partner: 'NONE'
                },
                IconikMetadata: {
                    IconikCustomActionTitle: {
                        qa: 'QA - SoMe - NL Trigger'
                    },
                    IconikMetadataViewName: {
                        qa: 'NL Phase 2 SoMe Metadata'
                    },
                    IconikMediaType: 'Show',
                    IconikCollectionName: 'SOME QA AUTOMATION',
                    IconikSourceAssetName: #('<ICONIK SOURCE ASSET NAME>' + '_' + TargetEnv.toUpperCase() + '_' + '<DURATION>' + '.mp4'),
                    IconikAssetType: 'VIDEO',
                    IconikRenditionRequestResourcePath: '/E2ECases/Netherlands/Input/IconikRenditionRequest.json'
                }
            }
        """
    # FOR DEVELOPMENT PURPOSES - Set GenerateRandomString to false and use old RandomString and ExpectedDate
    * def SetupParams =
        """
            {
                GenerateRandomString: true,
                RandomString: '1645525424634',
                ExpectedDate: '2022-02-22',
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
        |DURATION| ICONIK SOURCE ASSET NAME | ICONIK ASPECT RATIOS | WAIT TIME |
        | 15     | NL_SOME_SHOW_AUTOMATION  | 16x9                 | 0         |
        | 25     | NL_SOME_SHOW_AUTOMATION  | 1x1                  | 10000     |
        | 30     | NL_SOME_SHOW_AUTOMATION  | 9x16                 | 20000     |