@Regression @NLNonPartner
Feature: Netherlands Phase 2 Non-Partner Rendition
Scenario Outline: Netherlands Phase 2 Non-partner Testing for <DURATION>s Video
    # FOR DEVELOPMENT PURPOSES - Set GenerateRandomString to false and use old RandomString and ExpectedDate
    * json TCMetadata = karate.read('classpath:CA/Resources/E2ECases/Netherlands/Metadata/1_Netherlands_Phase2.json')
    * def SetupParams =
        """
            {
                GenerateRandomString: true,
                RandomString: '1648009605267',
                ExpectedDate: '2022-03-23',
                WaitTime: <WAIT TIME>,
                IconikSrcAssetName: <ICONIK SOURCE ASSET NAME>,
                IconikARatios: <ICONIK ASPECT RATIOS>,
                Duration: <DURATION>,
                TCNamePrefix: 'Netherlands_Phase2_NonPartner'
            }
        """
    * call read('classpath:CA/Features/ReUsable/Steps/Setup.feature') SetupParams
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
        | WAIT TIME | ICONIK SOURCE ASSET NAME | DURATION | ICONIK ASPECT RATIOS | 
        | 0         | NL_SOME_SHOW_AUTOMATION  |  15      | 16x9                 | 
        | 0         | NL_SOME_SHOW_AUTOMATION  |  25      | 1x1                  | 
        | 0         | NL_SOME_SHOW_AUTOMATION  |  30      | 9x16                 | 
