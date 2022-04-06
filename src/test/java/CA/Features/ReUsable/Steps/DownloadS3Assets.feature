Feature: Download Assets from S3

Scenario: Download Assets from S3
    Given def stepName = 'Download Test Assets'
    And def DownloadTestAssetsParams =
        """
            {
                TestAssets: #(TestAssets),
                AssetType: #(AssetType)
            }
        """
    When def downloadTestResults = karate.call(ReUsableFeaturesPath + '/StepDefs/S3.feature@DownloadTestAssets', DownloadTestAssetsParams) //downloadTestAssets(TestAssets, AssetType)
    Then downloadTestResults.pass == true? karate.log('[PASSED] ' + stepName + ': ' + downloadTestResults.message) : karate.fail('[FAILED] ' + stepName + '
    