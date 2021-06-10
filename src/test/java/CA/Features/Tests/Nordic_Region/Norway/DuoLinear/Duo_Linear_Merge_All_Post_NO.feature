@E2E @Regression @DuoLinear
# @parallel=false    
Feature:  Duo_Linear_Merge_All_Post_NO

Background:
  # NEW
  * def TCName = 'Duo_Linear_Merge_All_Post_NO'
  * def Country = 'Norway'
  * def EpisodeMetadataType = 'DuoLinear'
  * def MetadataSet = 'All'
  * def TCValidationType = 'videoValidation' //videoValidation or imageValidation. Used for custom report table
  * def WochitMappingTableGSI = EnvConfig[Country]['WochitMappingTableGSI']
  * callonce read('classpath:CA/Features/ReUsable/Scenarios/Background.feature') { WaitTime: 5000 }
  * configure afterFeature = 
    """
        function() {
            karate.call(FeatureFilePath + '/Results.feature@updateFinalResults', { updateFinalResultParams: updateFinalResultParams });

            //Trigger Auto-deletion
            var method = '@DeleteDCOImageTestAssets';
            if(EpisodeMetadataType != 'DCO') {
                method = '@DeleteVideoOutputsTestAssets';
            }
            var DeleteAssetParams = {
                SearchKeyword: RandomCTA
            }
            karate.call('classpath:CA/Features/Tests/Misc/Delete_Test_Assets.feature' + method, DeleteAssetParams);
        }
    """
    
@parallel=false
Scenario: Nordic_Norway_Duo_Linear_Merge_All_Post_NO - Trigger Rendition
  * def scenarioName = 'triggerRendition'
  * def getRenditionRequestMetadataValues =
    """
      function() {
        var metadataValues = karate.read(currentTCPath + '/Input/EpisodeRequest.json');
        return metadataValues['metadata_values'];
        // if(TargetEnv == 'preprod' || TargetEnv == 'prod') {
        //   var metadataValues = karate.read(currentTCPath + '/Input/EpisodeRequest.json');
        //   return metadataValues['metadata_values'];
        // } else {
        //   return null;
        // }
      }
    """
  * def RenditionRequestMetadataValues = call getRenditionRequestMetadataValues
  * def RenditionRequestPayload = read(currentTCPath+'/Input/RenditionRequest.json')
  * def Rendition_ExpectedResponse = read(currentTCPath+'/Output/ExpectedRenditionResponse.json')
  * def renditionParams = 
    """
      {
        URL: #(TriggerRenditionURL),
        RenditionRequestPayload: '#(RenditionRequestPayload)',
        RenditionExpectedResponse: '#(Rendition_ExpectedResponse)',
        IconikCredentials: #(IconikCredentials)
      }
    """
  * def result = call read(FeatureFilePath + '/Iconik.feature@TriggerRendition') renditionParams
  * def updateParams = 
    """
      { 
        tcName: #(TCName), 
        scenarioName: #(scenarioName), 
        result: #(result.result), 
        tcResultReadPath: #(tcResultReadPath), 
        tcResultWritePath: #(tcResultWritePath) 
      }
    """
  * call read(FeatureFilePath + '/Results.feature@updateResult') { updateParams: #(updateParams) })
  # * call Pause 60000*4

@parallel=false
Scenario Outline: Nordic_Norway_Duo_Linear_Merge_All_Post_NO - Validate Wochit Renditions Table for <ASPECTRATIO>
  * def scenarioName = 'validateWochitRendition' + <ASPECTRATIO>
  * def ExpectedTitle = call generateExpectedTitle <FNAMEPREFIX>
  * def getCalloutText =
    """
      function(expectedTitle) {
        var finalCalloutText = RandomCalloutText;
        if(expectedTitle.contains('PREMIERE')) {
          finalCalloutText = 'PREMIERE'
        }
        return finalCalloutText;
      }
    """
  * def RandomCalloutText = call getCalloutText ExpectedTitle
  * def getLinkedFieldsList =
    """
      function(expectedTitle) {
        var templateName = '';
        if(expectedTitle.contains('duo')) {
          templateName += 'duo_';
        }
        else if(expectedTitle.contains('linear')) {
          templateName += 'linear_';
        }
        else {
          karate.fail(expectedTitle + ' is not a Duo/Linear tempalte!');
        }

        if(expectedTitle.contains('9x16')) {
          templateName += '9x16_';
        }
        else {
          templateName += 'All_';
        }

        if(expectedTitle.contains('pre')) {
          templateName += 'pre.json'
        }
        else {
          templateName += 'post.json'
        }

        var linkedFieldsList = karate.read(currentTCPath + '/Output/LinkedFields/' + templateName);
        return linkedFieldsList;
      }
    """
  * def Expected_Linked_Fields = call getLinkedFieldsList ExpectedTitle
  * def Expected_WochitRendition_Entry = read(currentTCPath + '/Output/Expected_WochitRendition_Entry.json')
  * def ExpectedDate = call read(FeatureFilePath + '/Date.feature@GetDateWithOffset') { offset: 0 }
  * def GetItemsViaQueryParams = 
    """
      {
        Param_TableName: #(WochitRenditionTableName),
        Param_QueryInfoList: [
          {
            infoName: 'assetType',
            infoValue: 'VIDEO',
            infoComparator: '=',
            infoType: 'key'
          },
          {
            infoName: 'createdAt',
            infoValue: #(ExpectedDate.result),
            infoComparator: 'begins',
            infoType: 'key'
          }
        ],
        Param_GlobalSecondaryIndex: #(WochitRenditionTableGSI),
        AWSregion: #(AWSregion)
      }
    """
  * def retries = 15
  * def getResult =
    """
      function() {
        var matchResult = null;
        for(var i = 0; i < retries; ++i) {
          // karate.log('Try #' + (i+1) + ' of ' + retries);
          var QueryResults = karate.call(FeatureFilePath + '/Dynamodb.feature@GetItemsViaQuery', GetItemsViaQueryParams);

          var FilterQueryResultsParams = {
            Param_QueryResults: QueryResults.result,
            Param_FilterNestedInfoList: [
              {
                infoName: 'videoUpdates.title',
                infoValue: ExpectedTitle,
                infoComparator: 'contains'
              }        
            ]
          }

          var FilteredQueryResults = karate.call(FeatureFilePath + '/Dynamodb.feature@FilterQueryResults', FilterQueryResultsParams);
          
          var ValidateWochitRenditionPayloadParams = {
            Param_Actual_WochitRendition_Entry: FilteredQueryResults.result,
            Param_Expected_WochitRendition_Entry: Expected_WochitRendition_Entry
          };

          matchResult = karate.call(FeatureFilePath + '/Dynamodb.feature@ValidateWochitRenditionPayload', ValidateWochitRenditionPayloadParams);
          // karate.log('Result: ' + matchResult.result);
          if(matchResult.result.pass) {
            break;
          } else {
            // karate.log('Result: ' + matchResult.result);
            karate.log('Try #' + (i+1) + ' of  ' + retries + ': ' + scenarioName + ': Failed. Sleeping for 15s.');
            java.lang.Thread.sleep(15*1000);
          }
        }
        return matchResult;
      }
    """
  * def result = call getResult
  * def updateParams = 
    """
      { 
        tcName: #(TCName), 
        scenarioName: #(scenarioName), 
        result: #(result.result), 
        tcResultReadPath: #(tcResultReadPath), 
        tcResultWritePath: #(tcResultWritePath) 
      }
    """
  * call read(FeatureFilePath + '/Results.feature@updateResult') { updateParams: #(updateParams) })
  Examples:
    | validateWochitRenditionTestData |

Scenario Outline: Nordic_Norway_Duo_Linear_Merge_All_Post_NO - Validate Placeholders and their ACLs for <ASPECTRATIO> exist
  * def scenarioName = 'validatePlaceholder' + <ASPECTRATIO>
  * def ExpectedTitle = call generateExpectedTitle <FNAMEPREFIX>
  * def ExpectedDate = call read(FeatureFilePath + '/Date.feature@GetDateWithOffset') { offset: 0 }
  * def GetItemsViaQueryParams = 
    """
      {
          Param_TableName: #(WochitMappingTableName),
          Param_QueryInfoList: [
            {
              infoName: 'mamAssetInfoReferenceId',
              infoValue: #(Iconik_AssetID),
              infoComparator: '=',
              infoType: 'key'
            },
            {
              infoName: 'createdAt',
              infoValue: #(ExpectedDate.result),
              infoComparator: 'begins',
              infoType: 'key'
            },  
            {
              infoName: 'renditionFileName',
              infoValue: #(ExpectedTitle),
              infoComparator: 'contains',
              infoType: 'filter'
            },
            {
              infoName: 'seasonCollectionId',
              infoValue: #(Iconik_SeasonCollectionID),
              infoComparator: 'contains',
              infoType: 'filter'
            }
         ],
         Param_GlobalSecondaryIndex: #(WochitMappingTableGSI),
         AWSregion: #(AWSregion)
       }
     """
  * def retries = 15
  * def getResult =
    """
      function() {
        var QueryResult = null;
        for(var i = 0; i < retries; ++i) {
          // karate.log('Try #' + (i+1) + ' of ' + retries);
          QueryResult = karate.call(FeatureFilePath + '/Dynamodb.feature@GetItemsViaQuery', GetItemsViaQueryParams);
          var matchResult = karate.match(QueryResult.result.length, 1);
          // karate.log('Result: ' + matchResult.result);
          if(matchResult.pass) {
            break;
          } else {
            // karate.log('Result: ' + QueryResult.result);
            karate.log('Try #' + (i+1) + ' of  ' + retries + ': ' + scenarioName + ': Failed. Sleeping for 15s.');
            java.lang.Thread.sleep(15*1000);
          }
        }
        return QueryResult;
      }
    """
  * def QueryResults = call getResult
  # * print QueryResults.result
  * def RenditionAssetID = QueryResults.result[0]['renditionAssetId']
  * def FullRenditionFileName = QueryResults.result[0]['renditionFileName']
  #### PLACEHOLDER EXISTENCE CHECK ####
  * def GetAssetDataURL = Iconik_AssetAPIURL + '/' + RenditionAssetID
  * def ExpectedAssetDataType = 'PLACEHOLDER'
  * def ExpectedAssetData = read(currentTCPath + '/Output/ExpectedPlaceholderAssetData.json')
  * def CheckPlaceholderExistsParams =
    """
      {
        GetAssetDataURL: #(GetAssetDataURL),
        ExpectedAssetData: #(ExpectedAssetData)
      }
    """
  #### PLACEHOLDER ACL CHECK ####
  * def GetAssetACLURL = Iconik_GetAssetACLAPIURL + '/' + RenditionAssetID
  * def ExpectedAssetACL = read(currentTCPath + '/Output/ExpectedACLResponse.json')
  * def ValidateACLExistsParams = 
    """
      {
        GetAssetACLURL: #(GetAssetACLURL),
        ExpectedAssetACL: #(ExpectedAssetACL)
      }
    """
  #### FINAL RESULT ####
  * def getResult = 
    """
      function() {
        var finalResult = {
          message: [],
          pass: true
        };
        for(var i = 0; i < retries; ++i) {
          var PlaceholderCheckResult = karate.call(FeatureFilePath + '/Iconik.feature@ValidatePlaceholderExists', CheckPlaceholderExistsParams);
          // karate.log(PlaceholderCheckResult.result);
          var PlaceholderACLCheckResult = karate.call(FeatureFilePath + '/Iconik.feature@ValidateACLExists', ValidateACLExistsParams);
          // karate.log(PlaceholderACLCheckResult);
          // var result = PlaceholderCheckResult.result.pass &&  PlaceholderACLCheckResult.result.pass;
          if(!PlaceholderCheckResult.result.pass) {
            finalResult.message.push(PlaceholderCheckResult.result.message);
            finalResult.pass = false;
          }
          if(!PlaceholderACLCheckResult.result.pass) {
            finalResult.message.push(PlaceholderACLCheckResult.result.message);
            finalResult.pass = false;
          }
          
          if(finalResult.pass) {
            break;
          } else {
            // karate.log('Result: ' + finalResult);
            karate.log('Try #' + (i+1) + ' of  ' + retries + ': ' + scenarioName + ': Failed. Sleeping for 15s.');
            java.lang.Thread.sleep(15*1000);
          }
        }
        return finalResult;
      }
    """
  * def result = call getResult
  * def updateParams = 
    """
      { 
        tcName: #(TCName), 
        scenarioName: #(scenarioName), 
        result: #(result), 
        tcResultReadPath: #(tcResultReadPath), 
        tcResultWritePath: #(tcResultWritePath) 
      }
    """
  * call read(FeatureFilePath + '/Results.feature@updateResult') { updateParams: #(updateParams) })
  Examples:
    | validateWochitMappingIsFiledMovedTestData |

Scenario Outline: Nordic_Norway_Duo_Linear_Merge_All_Post_NO - Validate Technical Metadata for Sort Key <COMPOSITEVIEWID>
  * def scenarioName = 'validateTechnicalMetadata'
  * def Expected_MAMAssetInfo_Entry = read(currentTCPath + '/Output/Expected_MAMAssetInfo_Entry.json')
  * def ValidateItemViaQueryParams = 
    """
      {
        Param_TableName: #(MAMAssetsInfoTableName),
        Param_QueryInfoList: [
          {
            infoName: 'assetId',
            infoValue: #(Iconik_AssetID),
            infoComparator: '=',
            infoType: 'key'
          },
          {
            infoName: 'assetTitle',
            infoValue: #(Iconik_AssetName),
            infoComparator: '=',
            infoType: 'filter'
          },
          {
            infoName: 'compositeViewsId',
            infoValue: <COMPOSITEVIEWID>,
            infoComparator: '=',
            infoType: 'key'
          }
        ],
        Param_GlobalSecondaryIndex: '',
        Param_ExpectedResponse: #(Expected_MAMAssetInfo_Entry),
        AWSregion: #(AWSregion)
      }
    """
  # * def result = call read(FeatureFilePath + '/Dynamodb.feature@ValidateItemViaQuery') ValidateItemViaQueryParams
  * def retries = 15
  * def getResult =
    """
      function() {
        var matchResult = null;
        for(var i = 0; i < retries; ++i) {
          // karate.log('Try #' + (i+1) + ' of ' + retries);
          matchResult = karate.call(FeatureFilePath + '/Dynamodb.feature@ValidateItemViaQuery', ValidateItemViaQueryParams);
          // karate.log('Result: ' + matchResult.result);
          if(matchResult.result.pass) {
            break;
          } else {
            // karate.log('Result: ' + matchResult.result);
            karate.log('Try #' + (i+1) + ' of  ' + retries + ': ' + scenarioName + ': Failed. Sleeping for 15s.');
            java.lang.Thread.sleep(15*1000);
          }
        }
        return matchResult;
      }
    """
  * def result = call getResult
  * def updateParams = 
    """
      { 
        tcName: #(TCName), 
        scenarioName: #(scenarioName), 
        result: #(result.result), 
        tcResultReadPath: #(tcResultReadPath), 
        tcResultWritePath: #(tcResultWritePath) 
      }
    """
  * call read(FeatureFilePath + '/Results.feature@updateResult') { updateParams: #(updateParams) })
  Examples:
    | validateTechnicalMetadataTestData |

Scenario Outline: Nordic_Norway_Duo_Linear_Merge_All_Post_NO - PROCESSING - Validate Wochit Mapping Table for Aspect Ratio <ASPECTRATIO> [wochitRenditionStatus: <RENDITIONSTATUS> - isRenditionMoved: <ISRENDITIONMOVED>]
  * def scenarioName = 'validateWochitMappingProcessing' + <ASPECTRATIO>
  * def generateExpectedTitle =
  """
    function(fnameprefix) {
      var finalExpectedTitle = fnameprefix.replace('CTA', RandomCTA);
      finalExpectedTitle = finalExpectedTitle.replace('COT', RandomCalloutText);

      return finalExpectedTitle
    }
  """
  * def ExpectedTitle = call generateExpectedTitle <FNAMEPREFIX>
  * def getCalloutText =
    """
      function(renditionFileName) {
        var finalCalloutText = RandomCalloutText;
        if(renditionFileName.contains('PREMIERE')) {
          finalCalloutText = 'PREMIERE'
        }
        return finalCalloutText;
      }
    """
  * def RandomCalloutText = call getCalloutText ExpectedTitle
  * def Expected_WochitMapping_Entry = read(currentTCPath + '/Output/Expected_WochitMapping_Entry.json')
  * def ValidateItemViaQueryParams = 
    """
      {
        Param_TableName: #(WochitMappingTableName),
        Param_QueryInfoList: [
          {
            infoName: 'mamAssetInfoReferenceId',
            infoValue: #(Iconik_AssetID),
            infoComparator: '=',
            infoType: 'key'
          },
          {
            infoName: 'renditionFileName',
            infoValue: #(ExpectedTitle),
            infoComparator: 'contains',
            infoType: 'filter'
          },
          {
            infoName: 'seasonCollectionId',
            infoValue: #(Iconik_SeasonCollectionID),
            infoComparator: 'contains',
            infoType: 'filter'
          }
        ],
        Param_GlobalSecondaryIndex: #(WochitMappingTableGSI),
        Param_ExpectedResponse: #(Expected_WochitMapping_Entry),
        AWSregion: #(AWSregion)
      }
    """
  # * def result = call read(FeatureFilePath + '/Dynamodb.feature@ValidateItemViaQuery') ValidateItemViaQueryParams
  * def retries = 15
  * def getResult =
    """
      function() {
        var matchResult = null;
        for(var i = 0; i < retries; ++i) {
          // karate.log('Try #' + (i+1) + ' of ' + retries);
          matchResult = karate.call(FeatureFilePath + '/Dynamodb.feature@ValidateItemViaQuery', ValidateItemViaQueryParams);
          // karate.log('Result: ' + matchResult.result);
          if(matchResult.result.pass) {
            break;
          } else {
            // karate.log('Result: ' + matchResult.result);
            karate.log('Try #' + (i+1) + ' of  ' + retries + ': ' + scenarioName + ': Failed. Sleeping for 15s.');
            java.lang.Thread.sleep(15*1000);
          }
        }
        return matchResult;
      }
    """
  * def result = call getResult
  * def updateParams = 
    """
      { 
        tcName: #(TCName), 
        scenarioName: #(scenarioName), 
        result: #(result.result), 
        tcResultReadPath: #(tcResultReadPath), 
        tcResultWritePath: #(tcResultWritePath) 
      }
    """
  * call read(FeatureFilePath + '/Results.feature@updateResult') { updateParams: #(updateParams) })
  Examples:
    | validateWochitMappingProcessingTestData |
    
Scenario: Nordic_Norway_Duo_Linear_Merge_All_Post_NO - Validate Item Counts - MAM Asset Info
  * def scenarioName = "validateMAMAssetCount"
  * def ExpectedDate = call read(FeatureFilePath + '/Date.feature@GetDateWithOffset') { offset: 0 }
  * def GetItemsViaQueryParams = 
    """
      {
        Param_TableName: #(MAMAssetsInfoTableName),
        Param_QueryInfoList: [
          {
            infoName: 'assetId',
            infoValue: #(Iconik_AssetID),
            infoComparator: '=',
            infoType: 'key'
          },
          {
            infoName: 'createdAt',
            infoValue: #(ExpectedDate.result),
            infoComparator: 'begins',
            infoType: 'filter'
          }
          {
            infoName: 'assetTitle',
            infoValue: #(Iconik_AssetName),
            infoComparator: '=',
            infoType: 'filter'
          }
        ],
        Param_GlobalSecondaryIndex: '',
        Param_ExpectedItemCount: #(ExpectedMAMAssetInfoCount),
        AWSregion: #(AWSregion)
      }
    """
  * def retries = 15
  * def getResult =
    """
      function() {
        var matchResult = null;
        for(var i = 0; i < retries; ++i) {
          // karate.log('Try #' + (i+1) + ' of ' + retries);
          var QueryResults = karate.call(FeatureFilePath + '/Dynamodb.feature@GetItemsViaQuery', GetItemsViaQueryParams);
          matchResult = karate.match(QueryResults.result.length, ExpectedMAMAssetInfoCount);
          // karate.log('Result: ' + matchResult);
          if(matchResult.pass) {
            break;
          } else {
            // karate.log('Result: ' + matchResult);
            karate.log('Try #' + (i+1) + ' of  ' + retries + ': ' + scenarioName + ': Failed. Sleeping for 15s.');
            java.lang.Thread.sleep(15*1000);
          }
        }
        return matchResult;
      }
    """
  * def result = call getResult
  * def updateParams = 
    """
      { 
        tcName: #(TCName), 
        scenarioName: #(scenarioName), 
        result: #(result), 
        tcResultReadPath: #(tcResultReadPath), 
        tcResultWritePath: #(tcResultWritePath) 
      }
    """
  * call read(FeatureFilePath + '/Results.feature@updateResult') { updateParams: #(updateParams) })

Scenario: Nordic_Norway_Duo_Linear_Merge_All_Post_NO - Validate Item Counts - Wochit Rendition
  * def scenarioName = "validateWochitRenditionCount"
  * def ExpectedTitle = RandomCTA
  * def ExpectedDate = call read(FeatureFilePath + '/Date.feature@GetDateWithOffset') { offset: 0 }
  * def GetItemsViaQueryParams = 
    """
      {
        Param_TableName: #(WochitRenditionTableName),
        Param_QueryInfoList: [
          {
            infoName: 'assetType',
            infoValue: 'VIDEO',
            infoComparator: '=',
            infoType: 'key'
          },
          {
            infoName: 'createdAt',
            infoValue: #(ExpectedDate.result),
            infoComparator: 'begins',
            infoType: 'key'
          }
        ],
        Param_GlobalSecondaryIndex: #(WochitRenditionTableGSI),
        AWSregion: #(AWSregion)
      }
    """
  * def retries = 15
  * def getResult =
    """
      function() {
        var matchResult = null;
        for(var i = 0; i < retries; ++i) {
          // karate.log('Try #' + (i+1) + ' of ' + retries);
          var QueryResults = karate.call(FeatureFilePath + '/Dynamodb.feature@GetItemsViaQuery', GetItemsViaQueryParams);

          var FilterQueryResultsParams = {
            Param_QueryResults: QueryResults.result,
            Param_FilterNestedInfoList: [
              {
                infoName: 'videoUpdates.title',
                infoValue: ExpectedTitle,
                infoComparator: 'contains'
              }        
            ]
          }

          var FilteredQueryResults = karate.call(FeatureFilePath + '/Dynamodb.feature@FilterQueryResults', FilterQueryResultsParams);
          matchResult = karate.match(FilteredQueryResults.result.length, ExpectedWochitRenditionCount);
          // karate.log(matchResult);
          if(matchResult.pass) {
            break;
          } else {
            // karate.log('Result: ' + matchResult);
            karate.log('Try #' + (i+1) + ' of  ' + retries + ': ' + scenarioName + ': Failed. Sleeping for 15s.');
            java.lang.Thread.sleep(15*1000);
          }
        }
        return matchResult;
      }
    """
  * def result = call getResult
  * def updateParams = 
    """
      { 
        tcName: #(TCName), 
        scenarioName: #(scenarioName), 
        result: #(result), 
        tcResultReadPath: #(tcResultReadPath), 
        tcResultWritePath: #(tcResultWritePath) 
      }
    """
  * call read(FeatureFilePath + '/Results.feature@updateResult') { updateParams: #(updateParams) })

Scenario: Nordic_Norway_Duo_Linear_Merge_All_Post_NO - Validate Item Counts - Wochit Mapping
 * def scenarioName = "validateWochitMappingCount"
  * def ExpectedTitle = RandomCTA
  * def ExpectedDate = call read(FeatureFilePath + '/Date.feature@GetDateWithOffset') { offset: 0 }
  * def GetItemsViaQueryParams = 
    """
      {
        Param_TableName: #(WochitMappingTableName),
        Param_QueryInfoList: [
          {
            infoName: 'mamAssetInfoReferenceId',
            infoValue: #(Iconik_AssetID),
            infoComparator: '=',
            infoType: 'key'
          },
          {
            infoName: 'createdAt',
            infoValue: #(ExpectedDate.result),
            infoComparator: 'begins',
            infoType: 'key'
          },
          {
            infoName: 'renditionFileName',
            infoValue: #(ExpectedTitle),
            infoComparator: 'contains',
            infoType: 'filter'
          },
          {
            infoName: 'seasonCollectionId',
            infoValue: #(Iconik_SeasonCollectionID),
            infoComparator: 'contains',
            infoType: 'filter'
          }
        ],
        Param_GlobalSecondaryIndex: #(WochitMappingTableGSI),
        Param_ExpectedItemCount: #(ExpectedWochitMappingCount),
        AWSregion: #(AWSregion)
      }
    """
  * def retries = 15
  * def getResult =
    """
      function() {
        var matchResult = null;
        for(var i = 0; i < retries; ++i) {
          // karate.log('Try #' + (i+1) + ' of ' + retries);
          var QueryResults = karate.call(FeatureFilePath + '/Dynamodb.feature@GetItemsViaQuery', GetItemsViaQueryParams);
          matchResult = karate.match(QueryResults.result.length, ExpectedWochitRenditionCount);
          // karate.log('Result: ' + matchResult);
          if(matchResult.pass) {
            break;
          } else {
            // karate.log('Result: ' + matchResult);
            karate.log('Try #' + (i+1) + ' of  ' + retries + ': ' + scenarioName + ': Failed. Sleeping for 15s.');
            java.lang.Thread.sleep(15*1000);
          }
        }
        return matchResult;
      }
    """
  * def result = call getResult
  * def updateParams = 
    """
      { 
        tcName: #(TCName), 
        scenarioName: #(scenarioName), 
        result: #(result), 
        tcResultReadPath: #(tcResultReadPath), 
        tcResultWritePath: #(tcResultWritePath) 
      }
    """
  * call read(FeatureFilePath + '/Results.feature@updateResult') { updateParams: #(updateParams) })

@parallel=false
Scenario: Hard wait for PROCESSING to FINISH
  # RUN ONLY IN E2E, DO NOT RUN IN REGRESSION
  * configure abortedStepsShouldPass = true
  * eval if (!TargetTag.contains('E2E')) {karate.abort();}
  # ---------
  * call Pause 60000*4

Scenario Outline: Nordic_Norway_Duo_Linear_Merge_All_Post_NO - FINISHED - Validate Wochit Mapping Table for Aspect Ratio <ASPECTRATIO> [wochitRenditionStatus: <RENDITIONSTATUS> - isRenditionMoved: <ISRENDITIONMOVED>]
  # RUN ONLY IN E2E, DO NOT RUN IN REGRESSION
  * configure abortedStepsShouldPass = true
  * eval if (!TargetTag.contains('E2E')) {karate.abort();}
  # ---------
  * def scenarioName = 'validateWochitMappingIsFiledMoved' + <ASPECTRATIO>
  * def generateExpectedTitle =
    """
      function(fnameprefix) {
        var finalExpectedTitle = fnameprefix.replace('CTA', RandomCTA);
        finalExpectedTitle = finalExpectedTitle.replace('COT', RandomCalloutText);

        return finalExpectedTitle
      }
    """
  * def ExpectedTitle = call generateExpectedTitle <FNAMEPREFIX>
  * def getCalloutText =
    """
      function(renditionFileName) {
        var finalCalloutText = RandomCalloutText;
        if(renditionFileName.contains('PREMIERE')) {
          finalCalloutText = 'PREMIERE'
        }
        return finalCalloutText;
      }
    """
  * def RandomCalloutText = call getCalloutText ExpectedTitle
  * def Expected_WochitMapping_Entry = read(currentTCPath + '/Output/Expected_WochitMapping_Entry.json')
  * def retries = 15
  * def ValidateItemViaQueryParams = 
    """
      {
        Param_TableName: #(WochitMappingTableName),
        Param_QueryInfoList: [
          {
            infoName: 'mamAssetInfoReferenceId',
            infoValue: #(Iconik_AssetID),
            infoComparator: '=',
            infoType: 'key'
          },
          {
            infoName: 'renditionFileName',
            infoValue: #(ExpectedTitle),
            infoComparator: 'contains',
            infoType: 'filter'
          }
        ],
        Param_GlobalSecondaryIndex: #(WochitMappingTableGSI),
        Param_ExpectedResponse: #(Expected_WochitMapping_Entry),
        AWSregion: #(AWSregion)
      }
    """
  * def getResult = 
    """
      function() {
        var resp = null;
        for(var i = 0; i < retries; ++i) {
          // karate.log('Try #' + (i+1) + ' of ' + retries);
          resp = karate.call(FeatureFilePath + '/Dynamodb.feature@ValidateItemViaQuery', ValidateItemViaQueryParams);
          if(resp['result']['pass']) {
            break;
          } else {
            karate.log(resp.result);
            karate.log('Try #' + (i+1) + ' of  ' + retries + ': ' + scenarioName + ': Failed. Sleeping for 1 minute.');
            java.lang.Thread.sleep(60*1000);
          }

        }
        return resp;
      }
    """
  * def result = call getResult
  * def updateParams = 
    """
      { 
        tcName: #(TCName), 
        scenarioName: #(scenarioName), 
        result: #(result.result), 
        tcResultReadPath: #(tcResultReadPath), 
        tcResultWritePath: #(tcResultWritePath) 
      }
    """
  * call read(FeatureFilePath + '/Results.feature@updateResult') { updateParams: #(updateParams) })
  Examples:
    | validateWochitMappingIsFiledMovedTestData |

Scenario Outline: Nordic_Norway_Duo_Linear_Merge_All_Post_NO - Validate if <ASPECTRATIO> S3 Asset exists
  # RUN ONLY IN E2E, DO NOT RUN IN REGRESSION
  * configure abortedStepsShouldPass = true
  * eval if (!TargetTag.contains('E2E')) {karate.abort();}
  # ---------  
  * def scenarioName = 'validateS3AssetExists' + <ASPECTRATIO>
  * def generateExpectedTitle =
    """
      function(fnameprefix) {
        var finalExpectedTitle = fnameprefix.replace('CTA', RandomCTA);
        finalExpectedTitle = finalExpectedTitle.replace('COT', RandomCalloutText);

        return finalExpectedTitle
      }
    """
  * def ExpectedTitle = call generateExpectedTitle <FNAMEPREFIX>
  * def getCalloutText =
    """
      function(renditionFileName) {
        var finalCalloutText = RandomCalloutText;
        if(renditionFileName.contains('PREMIERE')) {
          finalCalloutText = 'PREMIERE'
        }
        return finalCalloutText;
      }
    """
  * def RandomCalloutText = call getCalloutText ExpectedTitle
  * def ValidateItemViaQueryParams = 
    """
      {
        Param_TableName: #(WochitMappingTableName),
        Param_QueryInfoList: [
          {
            infoName: 'mamAssetInfoReferenceId',
            infoValue: #(Iconik_AssetID),
            infoComparator: '=',
            infoType: 'key'
          },
          {
            infoName: 'renditionFileName',
            infoValue: #(ExpectedTitle),
            infoComparator: 'contains',
            infoType: 'filter'
          }
        ],
        Param_GlobalSecondaryIndex: #(WochitMappingTableGSI),
        AWSregion: #(AWSregion)
      }
    """
  * def QueryResults = call read(FeatureFilePath + '/Dynamodb.feature@GetItemsViaQuery') ValidateItemViaQueryParams
  * def FullExpectedTitle = QueryResults.result[0]['renditionFileName']
  * print FullExpectedTitle
  * def validateS3ObjectExists =
    """
      function() {
        var AWSUtilsClass = Java.type('AWSUtils.AWSUtils');
        var AWSUtils = new AWSUtilsClass();
        var FullObjectKey = RenditionsFolderName + '/' + FullExpectedTitle;
        karate.log('Full Object Key: ' + FullObjectKey);

        var isExist = AWSUtils.isS3ObjectExists(
          AssetBucketName,
          FullObjectKey,
          S3Region
        )
        
        var finalResult = {
          result: isExist,
          pass: isExist
        }

        return finalResult;
      }
    """
  * def retries = 15
  * def getResult = 
    """
      function() {
        var matchResult = null;
        for(var i = 0; i < retries; ++i) {
          // karate.log('Try #' + (i+1) + ' of ' + retries);
          // matchResult = karate.call(FeatureFilePath + '/Dynamodb.feature@ValidateItemViaQuery', ValidateItemViaQueryParams);
          matchResult = validateS3ObjectExists();
          // karate.log(matchResult)
          if(matchResult.pass) {
            break;
          } else {
            // karate.log('Result: ' + matchResult);
            karate.log('Try #' + (i+1) + ' of  ' + retries + ': ' + scenarioName + ': Failed. Sleeping for 30s.');
            java.lang.Thread.sleep(30*1000);
          }

        }
        return matchResult;
      }
    """
  * def result = call getResult
  # * def result = call validateS3ObjectExists
  # * print result
  * def updateParams = 
    """
      { 
        tcName: #(TCName), 
        scenarioName: #(scenarioName), 
        result: #(result), 
        tcResultReadPath: #(tcResultReadPath), 
        tcResultWritePath: #(tcResultWritePath) 
      }
    """
  * call read(FeatureFilePath + '/Results.feature@updateResult') { updateParams: #(updateParams) })
  Examples:
    | validateWochitMappingIsFiledMovedTestData |

Scenario Outline: Nordic_Norway_Duo_Linear_Merge_All_Post_NO - Validate Associated Assets and their ACLs for <ASPECTRATIO> exist
  # RUN ONLY IN E2E, DO NOT RUN IN REGRESSION
  * configure abortedStepsShouldPass = true
  * eval if (!TargetTag.contains('E2E')) {karate.abort();}
  # ---------  
  * def scenarioName = 'validateAssociatedAsset' + <ASPECTRATIO>
  * def ExpectedTitle = call generateExpectedTitle <FNAMEPREFIX>
  * def ExpectedDate = call read(FeatureFilePath + '/Date.feature@GetDateWithOffset') { offset: 0 }
  * def GetItemsViaQueryParams = 
    """
      {
          Param_TableName: #(WochitMappingTableName),
          Param_QueryInfoList: [
            {
              infoName: 'mamAssetInfoReferenceId',
              infoValue: #(Iconik_AssetID),
              infoComparator: '=',
              infoType: 'key'
            },
            {
              infoName: 'createdAt',
              infoValue: #(ExpectedDate.result),
              infoComparator: 'begins',
              infoType: 'key'
            },  
            {
              infoName: 'renditionFileName',
              infoValue: #(ExpectedTitle),
              infoComparator: 'contains',
              infoType: 'filter'
            },
            {
              infoName: 'seasonCollectionId',
              infoValue: #(Iconik_SeasonCollectionID),
              infoComparator: 'contains',
              infoType: 'filter'
            }
         ],
         Param_GlobalSecondaryIndex: #(WochitMappingTableGSI),
         AWSregion: #(AWSregion)
       }
     """
  * def retries = 15
  * def getResult =
    """
      function() {
        var QueryResult = null;
        for(var i = 0; i < retries; ++i) {
          // karate.log('Try #' + (i+1) + ' of ' + retries);
          QueryResult = karate.call(FeatureFilePath + '/Dynamodb.feature@GetItemsViaQuery', GetItemsViaQueryParams);
          var matchResult = karate.match(QueryResult.result.length, 1);
          // karate.log('Result: ' + matchResult.result);
          if(matchResult.pass) {
            break;
          } else {
            karate.log(matchResult);
            karate.log('Try #' + (i+1) + ' of  ' + retries + ': ' + scenarioName + ': Failed. Sleeping for 1 minute.');
            java.lang.Thread.sleep(60*1000);
          }
        }
        return QueryResult;
      }
    """
  * def QueryResults = call getResult
  # * print QueryResults.result
  * def RenditionAssetID = QueryResults.result[0]['renditionAssetId']
  * def FullRenditionFileName = QueryResults.result[0]['renditionFileName']
  #### ASSOCIATED ASSET EXISTENCE CHECK ####
  * def GetAssetDataURL = Iconik_AssetAPIURL + '/' + RenditionAssetID
  * def ExpectedAssetDataType = 'ASSET'
  * def ExpectedAssetData = read(currentTCPath + '/Output/ExpectedAssociatedAssetData.json')
  * def CheckPlaceholderExistsParams =
    """
      {
        GetAssetDataURL: #(GetAssetDataURL),
        ExpectedAssetData: #(ExpectedAssetData)
      }
    """
  #### PLACEHOLDER ACL CHECK ####
  * def GetAssetACLURL = Iconik_GetAssetACLAPIURL + '/' + RenditionAssetID
  * def ExpectedAssetACL = read(currentTCPath + '/Output/ExpectedACLResponse.json')
  * def ValidateACLExistsParams = 
    """
      {
        GetAssetACLURL: #(GetAssetACLURL),
        ExpectedAssetACL: #(ExpectedAssetACL)
      }
    """
  #### FINAL RESULT ####
  * def getResult = 
    """
      function() {
        var finalResult = {
          message: [],
          pass: true
        };
        for(var i = 0; i < retries; ++i) {
          var PlaceholderCheckResult = karate.call(FeatureFilePath + '/Iconik.feature@ValidatePlaceholderExists', CheckPlaceholderExistsParams);
          // karate.log(PlaceholderCheckResult.result);
          var PlaceholderACLCheckResult = karate.call(FeatureFilePath + '/Iconik.feature@ValidateACLExists', ValidateACLExistsParams);
          // karate.log(PlaceholderACLCheckResult);
          // var result = PlaceholderCheckResult.result.pass &&  PlaceholderACLCheckResult.result.pass;
          if(!PlaceholderCheckResult.result.pass) {
            finalResult.message.push(PlaceholderCheckResult.result.message);
            finalResult.pass = false;
          }
          if(!PlaceholderACLCheckResult.result.pass) {
            finalResult.message.push(PlaceholderACLCheckResult.result.message);
            finalResult.pass = false;
          }
          
          if(finalResult.pass) {
            break;
          } else {
            // karate.log('Result: ' + finalResult);
            karate.log('Try #' + (i+1) + ' of  ' + retries + ': ' + scenarioName + ': Failed. Sleeping for 1 minute.');
            java.lang.Thread.sleep(60*1000);
          }
        }
        return finalResult;
      }
    """
  * def result = call getResult
  * def updateParams = 
    """
      { 
        tcName: #(TCName), 
        scenarioName: #(scenarioName), 
        result: #(result), 
        tcResultReadPath: #(tcResultReadPath), 
        tcResultWritePath: #(tcResultWritePath) 
      }
    """
  * call read(FeatureFilePath + '/Results.feature@updateResult') { updateParams: #(updateParams) })
  Examples:
    | validateWochitMappingIsFiledMovedTestData |