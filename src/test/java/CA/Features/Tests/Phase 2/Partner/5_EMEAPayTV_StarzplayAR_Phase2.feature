@Regression @StarzplayAR
Feature: Netherlands Phase 2 Non-Partner Rendition
# TOTAL: 48 Renditions
Scenario Outline: Netherlands Phase 2 Partner STARZPLAY AR Testing for <DURATION>s Video
    * json TCMetadata = karate.read('classpath:CA/Resources/E2ECases/EMEA PayTv/Metadata/5_EMEAPayTV_StarzplayAR_Phase2.json')
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
                TCNamePrefix: 'EMEAPayTV_StarzplayAR_Phase2'
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
        | WAIT TIME | ICONIK SOURCE ASSET NAME     | DURATION |  ICONIK ASPECT RATIOS |
        | 20000     | STARZPLAYAR_SOME_FILM        |  15       | 16x9                 |
        | 20000     | STARZPLAYAR_SOME_FILM        |  25       | 1x1                  |
        | 20000     | STARZPLAYAR_SOME_FILM        |  30       | 9x16                 |