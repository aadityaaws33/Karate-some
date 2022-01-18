Feature: Download Assets from S3

Scenario: Download Assets from S3
    * def downloadTestAssets =
        """
            function(TestAssets, AssetType) {
                for(i in TestAssets) {
                    var thisTestAsset = TestAssets[i];
                    var thisDownloadFileName = thisTestAsset.replace('Assets/', '');
                    if(AssetType == 'xml') {
                        thisDownloadFileName = ExpectedDataFileName;
                    }


                    var DownloadS3ObjectParams = {
                        S3BucketName: TestAssetsS3.Name,
                        S3Key: TestAssetsS3.Key + '/' +  thisTestAsset,
                        AWSRegion: TestAssetsS3.Region,
                        DownloadPath: DownloadsPath,
                        DownloadFilename: thisDownloadFileName,
                    }
                    var downloadFileStatus = karate.call(ReUsableFeaturesPath + '/StepDefs/S3.feature@DownloadS3Object', DownloadS3ObjectParams);
                    karate.log(downloadFileStatus.result);
                    
                    return downloadFileStatus.result

                }
            }
        """
    Given def stepName = 'Download Test Assets'
    When def downloadTestResults = downloadTestAssets(TestAssets, AssetType)
    Then downloadTestResults.pass == true? karate.log('[PASSED] ' + stepName + ': ' + downloadTestResults.message) : karate.fail('[FAILED] ' + stepName + ': ' + downloadTestResults.message)