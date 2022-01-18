Feature: Teardown

Background:
    * def thisFile = 'classpath:CA/Features/ReUsable/Steps/Teardown.feature'
    * def thisTCMetadata = karate.read(thisOutputReadPath + '/TCMetadata.json')

@Teardown
Scenario: Teardown
    * karate.log(thisFeatureInfo)
    * karate.log(thisTCMetadata)
    # Delete Test Records
    # IF QA_AUTOMATION_USER, DELETE EVERYTHING
    # ELSE LEAVE AS IS
    * thisTCMetadata.Config.IconikConfig.TestUser != 'QA_AUTOMATION_USER'? karate.abort() : ''
    * karate.call(thisFile + '@DeleteMAMAssetInfoRecords', { AWRegion: thisTCMetadata.Config.AWSRegion, MAMAssetTableConfig: thisTCMetadata.Config.DynamoDBConfig.MAMAssetInfo, IconikMetadata: thisTCMetadata.IconikMetadata})
    * karate.call(thisFile + '@DeleteWochitMappingRecords', { AWRegion: thisTCMetadata.Config.AWSRegion, WochitMappingTableConfig: thisTCMetadata.Config.DynamoDBConfig.WochitMapping, WochitMappingIDs: thisTCMetadata.Expected.WochitMappingIDs})
    * karate.call(thisFile + '@DeleteWochitRenditionRecords', { AWRegion: thisTCMetadata.Config.AWSRegion, WochitRenditionTableConfig: thisTCMetadata.Config.DynamoDBConfig.WochitRendition, WochitRenditionIDs: thisTCMetadata.Expected.WochitRenditionIDs})
    * karate.call(thisFile + '@DeleteIconikTestAssets', { thisTCMetadata: thisTCMetadata })

@DeleteWochitRenditionRecords
Scenario: Delete MAM Asset Info Records
    * def DeleteDBRecordsParams =
        """
            {
                Param_TableName: #(WochitRenditionTableConfig.TableName),
                Param_DeleteItemAttributeList: [],
                Retries: 120,
                RetryDuration: 1000,
                AWSRegion: #(AWRegion)
            }
        """
    * def DeleteWochitRenditionRecords =
        """
            function(WochitRenditionIDs) {
                for(var i in WochitRenditionIDs) {
                    var thisDeleteItemAttributeList = [
                        {
                            attributeName: 'ID',
                            attributeValue: WochitRenditionIDs[i],
                            attributeComparator: '=',
                            attributeType: 'key'
                        }
                    ]
                    DeleteDBRecordsParams.Param_DeleteItemAttributeList = thisDeleteItemAttributeList;
                    var result = karate.call(ReUsableFeaturesPath + '/StepDefs/DynamoDB.feature@DeleteDBRecords', DeleteDBRecordsParams);
                }
            }
        """
    * DeleteWochitRenditionRecords(WochitRenditionIDs)

@DeleteWochitMappingRecords
Scenario: Delete MAM Asset Info Records
    * def DeleteDBRecordsParams =
        """
            {
                Param_TableName: #(WochitMappingTableConfig.TableName),
                Param_DeleteItemAttributeList: [],
                Retries: 120,
                RetryDuration: 1000,
                AWSRegion: #(AWRegion)
            }
        """
    * def DeleteWochitMappingRecords =
        """
            function(WochitMappingIDs) {
                for(var i in WochitMappingIDs) {
                    var thisDeleteItemAttributeList = [
                        {
                            attributeName: 'ID',
                            attributeValue: WochitMappingIDs[i],
                            attributeComparator: '=',
                            attributeType: 'key'
                        }
                    ]
                    DeleteDBRecordsParams.Param_DeleteItemAttributeList = thisDeleteItemAttributeList;
                    var result = karate.call(ReUsableFeaturesPath + '/StepDefs/DynamoDB.feature@DeleteDBRecords', DeleteDBRecordsParams);
                }
            }
        """
    * DeleteWochitMappingRecords(WochitMappingIDs)

@DeleteMAMAssetInfoRecords
Scenario: Delete MAM Asset Info Records
    * def DeleteDBRecordsParams =
        """
            {
                Param_TableName: #(MAMAssetTableConfig.TableName),
                Param_DeleteItemAttributeList: [
                    {
                        attributeName: 'assetId',
                        attributeValue: '#(IconikMetadata.IconikAssetId)',
                        attributeComparator: '=',
                        attributeType: 'key'
                    },
                    {
                        attributeName: 'compositeViewsId',
                        attributeValue: '#(IconikMetadata.IconikCustomActionMetadataView)',
                        attributeComparator: '=',
                        attributeType: 'key'
                    },
                ],
                Retries: 120,
                RetryDuration: 1000,
                AWSRegion: #(AWRegion)
            }
        """
    * karate.call(ReUsableFeaturesPath + '/StepDefs/DynamoDB.feature@DeleteDBRecords', DeleteDBRecordsParams)

@DeleteIconikTestAssets
Scenario: Delete Iconik Test DeleteIconikTestAssets
    * def deleteIconikTestRenditionAssets =
        """
            function(RenditionAssetIDs, IconikConfig) {
                karate.log('Asset ID List for Deletion:' + karate.pretty(RenditionAssetIDs));
                var BulkDeleteAssetsParams = {
                    URL: IconikConfig.URL.DeleteQueueAPI + '/bulk/',
                    RenditionAssetIDs: karate.toJson(RenditionAssetIDs),
                    IconikAuthToken: IconikConfig.IconikAuthenticationData.AuthToken,
                    IconikAppID: IconikConfig.IconikAuthenticationData.AppID,
                }
                karate.call(ReUsableFeaturesPath + '/StepDefs/Iconik.feature@BulkDeleteAssets', BulkDeleteAssetsParams);
            }
        """
    * deleteIconikTestRenditionAssets(thisTCMetadata.Expected.IconikRenditionAssetIDs, thisTCMetadata.Config.IconikConfig)
