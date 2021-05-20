@JESS @E2E @Regression @DuoLinear @Norway @parallel=false  
Feature:  Duo_Linear_Merge_All_NoTag_NO

Background:
  # NEW
  * def TCName = 'Duo_Linear_Merge_All_NoTag_NO'
  * def Country = 'Norway'
  * def EpisodeMetadataType = 'DuoLinear'
  * def MetadataSet = 'AllNoTag'
  * def AWSregion = EnvConfig[Country]['AWSregion']
  * def WochitMappingTableName = EnvConfig[Country]['WochitMappingTableName']
  * def WochitMappingTableGSI = EnvConfig[Country]['WochitMappingTableGSI']
  * def WochitRenditionTableName = EnvConfig[Country]['WochitRenditionTableName']
  * def WochitRenditionTableGSI = EnvConfig[Country]['WochitRenditionTableGSI']
  * def MAMAssetsInfoTableName = EnvConfig[Country]['MAMAssetsInfoTableName']
  * def TCValidationType = 'videoValidation' //videoValidation or imageValidation. Used for custom report table
  # Paths Start
  * def tcResultWritePath = 'test-classes/' + TCName + '.json'
  * def tcResultReadPath = 'classpath:target/' + tcResultWritePath
  * def finalResultWritePath = 'test-classes/Results.json'
  * def finalResultReadPath = 'classpath:target/' + finalResultWritePath
  * def currentTCPath = 'classpath:CA/TestData/E2ECases/' + AWSregion + '_Region/' + Country + '/' + TCName
  * def FeatureFilePath = 'classpath:CA/Features/ReUsable/Methods'
  # Paths End
  # Iconik Stuff Start
  * def Iconik_EpisodeVersionID = EnvConfig[Country]['Iconik_EpisodeVersionID']
  * def Iconik_EpisodeMetadataObjectID = EnvConfig[Country]['Iconik_EpisodeMetadataObjectID']
  * def Iconik_AssetID = EnvConfig[Country]['Iconik_AssetID'][EpisodeMetadataType][MetadataSet]
  * def Iconik_MetadataViewID = EnvConfig[Country]['Iconik_MetadataViewID'][EpisodeMetadataType]
  * def Iconik_SeasonCollectionID = EnvConfig[Country]['Iconik_SeasonCollectionID']
  * def Iconik_TriggerRenditionCustomActionID = EnvConfig[Country]['Iconik_TriggerRenditionCustomActionID'][EpisodeMetadataType]
  * def Iconik_TechnicalMetadataID = EnvConfig[Country]['Iconik_TechnicalMetadataID']
  * def Iconik_TechnicalMetadataObjectID = EnvConfig[Country]['Iconik_TechnicalMetadataObjectID']
  * def Iconik_AssetName = EnvConfig[Country]['Iconik_AssetName'][EpisodeMetadataType][MetadataSet]
  * def Iconik_SystemDomainID = EnvConfig[Country]['Iconik_SystemDomainID']
  * def Iconik_UserId = EnvConfig['Common']['Iconik_UserId'][TargetTag]
  * def Iconik_TriggerRenditionCustomActionListURL = EnvConfig['Common']['Iconik_TriggerRenditionCustomActionListURL']
  * def Iconik_GetAppTokenInfoURL = EnvConfig['Common']['Iconik_GetAppTokenInfoURL']
  * def Iconik_AssetAPIURL = EnvConfig['Common']['Iconik_AssetAPIURL']
  * def Iconik_AssetMetadataAPIURL = EnvConfig['Common']['Iconik_AssetMetadataAPIURL']
  * def Iconik_AssetUpdateMetadataAPIURL = Iconik_AssetMetadataAPIURL + '/' + Iconik_AssetID + '/views/' + Iconik_MetadataViewID
  * def Iconik_AppTokenName = EnvConfig['Common']['Iconik_AppTokenName']
  * def Iconik_AdminEmail = eval("SecretsData['Iconik-AdminEmail" + TargetEnv + "']")
  * def Iconik_AdminPassword = eval("SecretsData['Iconik-AdminPassword" + TargetEnv + "']")
  * def Iconik_GetAppTokenInfoPayload = 
    """
      {
        "app_name": #(Iconik_AppTokenName),
        "email":  #(Iconik_AdminEmail),
        "password": #(Iconik_AdminPassword)
      }
    """
  * def CheckIconikUserNameAttr =
    """
      function(iconikUserName) {
        var result = true;
        if(TargetTag == 'E2E') {
          if(iconikUserName == null) {
            result = false;
          }
        }
        return result;
      }
    """
  * def GetAppTokenInfoParams =
    """
      {
        URL: "#(Iconik_GetAppTokenInfoURL)",
        GetAppTokenInfoPayload: #(Iconik_GetAppTokenInfoPayload)
      }
    """
  * def IconikAuthenticationInfo = callonce read(FeatureFilePath + '/Iconik.feature@GetAppTokenInfo') GetAppTokenInfoParams
  * def Iconik_AuthToken = IconikAuthenticationInfo.result.Iconik_AuthToken
  * def Iconik_AppID = IconikAuthenticationInfo.result.Iconik_AppID
  * def GetRenditionHTTPInfoParams =
    """
      {
        URL: #(Iconik_TriggerRenditionCustomActionListURL),
        Iconik_TriggerRenditionCustomActionID: #(Iconik_TriggerRenditionCustomActionID),
        Iconik_AuthToken: #(Iconik_AuthToken),
        Iconik_AppID: #(Iconik_AppID)
      }
    """
  * def IconikRenditionURLInfo = call read(FeatureFilePath + '/Iconik.feature@GetRenditionHTTPInfo') GetRenditionHTTPInfoParams
  * def TriggerRenditionURL = IconikRenditionURLInfo.result.URL
  * print TriggerRenditionURL
  # Iconik Stuff End
  # Scenario Outline Examples Start
  * def validateTechnicalMetadataTestData = read(currentTCPath + '/ScenarioOutlineExamples/validateTechnicalMetadata.json')[TargetEnv][MetadataSet]
  * def validateWochitRenditionTestData = read(currentTCPath + '/ScenarioOutlineExamples/validateWochitRendition.json')[TargetEnv][MetadataSet]
  * def validateWochitMappingProcessingTestData = read(currentTCPath + '/ScenarioOutlineExamples/validateWochitMappingProcessing.json')[TargetEnv][MetadataSet]
  * def validateWochitMappingIsFiledMovedTestData = read(currentTCPath + '/ScenarioOutlineExamples/validateWochitMappingIsFiledMoved.json')[TargetEnv][MetadataSet]
  # Scenario Outline Examples End
  # Expected Item Counts Start
  * def ExpectedMAMAssetInfoCount = read(currentTCPath + '/Output/ExpectedItemCounts.json')[TargetEnv][MetadataSet]['ExpectedMAMAssetInfoCount']
  * def ExpectedWochitRenditionCount = read(currentTCPath + '/Output/ExpectedItemCounts.json')[TargetEnv][MetadataSet]['ExpectedWochitRenditionCount']
  * def ExpectedWochitMappingCount = read(currentTCPath + '/Output/ExpectedItemCounts.json')[TargetEnv][MetadataSet]['ExpectedWochitMappingCount']
  # Expected Item Counts End
  # S3 Stuff
  * def AssetBucketName = EnvConfig['Common']['S3']['AssetBucketName']
  * def RenditionsFolderName = EnvConfig['Common']['S3']['RenditionsFolderName']
  * def S3Region = EnvConfig['Common']['S3']['Region']
  # S3 Stuff End
  * def placeholderParams = 
    """
      { 
        tcResultReadPath: #(tcResultReadPath), 
        tcResultWritePath: #(tcResultWritePath), 
        tcName: #(TCName),
        tcValidationType: #(TCValidationType)
      }
    """
  * def updateFinalResultParams = 
    """
      { 
        tcResultReadPath: #(tcResultReadPath), 
        tcResultWritePath: #(tcResultWritePath), 
        tcName: #(TCName), 
        finalResultReadPath: #(finalResultReadPath), 
        finalResultWritePath: #(finalResultWritePath) 
      }
    """
  * call read(FeatureFilePath + '/Results.feature@setPlaceholder') { placeholderParams: #(placeholderParams) })
  # * call read(FeatureFilePath + '/Results.feature@shouldContinue') { placeholderParams: #(updateFinalResultParams) })
  * def Pause = 
    """
      function(pause){ 
        karate.log('Pausing for ' + pause + ' milliseconds');
        java.lang.Thread.sleep(pause);
      }
    """
  * callonce Pause 8000
  * def one = callonce read(FeatureFilePath+'/RandomGenerator.feature@SeriesTitle')
  * def RandomSeriesTitle = one.RandomSeriesTitle
  * def two = callonce read(FeatureFilePath+'/RandomGenerator.feature@CallOutText')
  * def RandomCalloutText = two.RandomCalloutText
  * def three = callonce read(FeatureFilePath+'/RandomGenerator.feature@CTA')
  * def RandomCTA = three.RandomCTA
  * print RandomSeriesTitle, RandomCalloutText, RandomCTA
  * configure afterFeature = 
    """
      function() {
        karate.call(FeatureFilePath + '/Results.feature@updateFinalResults', { updateFinalResultParams: updateFinalResultParams });
      }
    """

Scenario: Nordic_Norway_Duo_Linear_Merge_All_NoTag_NO - Trigger Rendition
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
  * def result = call read(FeatureFilePath+'/Iconik.feature@TriggerRendition') renditionParams
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


Scenario Outline: Nordic_Norway_Duo_Linear_Merge_All_NoTag_NO - Validate Wochit Renditions Table for <ASPECTRATIO>
  * def scenarioName = 'validateWochitRendition' + <ASPECTRATIO>
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
          templateName += 'pre';
        }
        else if(expectedTitle.contains('post')) {
          templateName += 'post';
        }
        else {
          templateName += 'woendboard';
        }

        templateName += '.json';

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
  * def retries = 3
  * def getResult =
    """
      function() {
        var matchResult = null;
        for(var i = 0; i < retries; ++i) {
          karate.log('Try #' + (i+1) + ' of ' + retries);
          var QueryResults = karate.call(FeatureFilePath+'/Dynamodb.feature@GetItemsViaQuery', GetItemsViaQueryParams);

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

          var FilteredQueryResults = karate.call(FeatureFilePath+'/Dynamodb.feature@FilterQueryResults', FilterQueryResultsParams);
          
          var ValidateWochitRenditionPayloadParams = {
            Param_Actual_WochitRendition_Entry: FilteredQueryResults.result,
            Param_Expected_WochitRendition_Entry: Expected_WochitRendition_Entry
          };

          matchResult = karate.call(FeatureFilePath+'/Dynamodb.feature@ValidateWochitRenditionPayload', ValidateWochitRenditionPayloadParams);
          karate.log('Result: ' + matchResult.result);
          if(matchResult.result.pass) {
            break;
          } else {
            karate.log('Failed. Sleeping for 10s.');
            java.lang.Thread.sleep(10*1000);
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

Scenario Outline: Nordic_Norway_Duo_Linear_Merge_All_NoTag_NO - Validate Technical Metadata for Sort Key <COMPOSITEVIEWID>
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
  * def retries = 3
  * def getResult =
    """
      function() {
        var matchResult = null;
        for(var i = 0; i < retries; ++i) {
          karate.log('Try #' + (i+1) + ' of ' + retries);
          matchResult = karate.call(FeatureFilePath+'/Dynamodb.feature@ValidateItemViaQuery', ValidateItemViaQueryParams);
          karate.log('Result: ' + matchResult.result);
          if(matchResult.result.pass) {
            break;
          } else {
            karate.log('Failed. Sleeping for 10s.');
            java.lang.Thread.sleep(10*1000);
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

Scenario Outline: Nordic_Norway_Duo_Linear_Merge_All_NoTag_NO - PROCESSING - Validate Wochit Mapping Table for Aspect Ratio <ASPECTRATIO> [wochitRenditionStatus: <RENDITIONSTATUS> - isRenditionMoved: <ISRENDITIONMOVED>]
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
  # * def result = call read(FeatureFilePath+'/Dynamodb.feature@ValidateItemViaQuery') ValidateItemViaQueryParams
  * def retries = 3
  * def getResult =
    """
      function() {
        var matchResult = null;
        for(var i = 0; i < retries; ++i) {
          karate.log('Try #' + (i+1) + ' of ' + retries);
          matchResult = karate.call(FeatureFilePath+'/Dynamodb.feature@ValidateItemViaQuery', ValidateItemViaQueryParams);
          karate.log('Result: ' + matchResult.result);
          if(matchResult.result.pass) {
            break;
          } else {
            karate.log('Failed. Sleeping for 10s.');
            java.lang.Thread.sleep(10*1000);
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
    
Scenario: Nordic_Norway_Duo_Linear_Merge_All_NoTag_NO - Validate Item Counts - MAM Asset Info
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
  * def retries = 3
  * def getResult =
    """
      function() {
        var matchResult = null;
        for(var i = 0; i < retries; ++i) {
          karate.log('Try #' + (i+1) + ' of ' + retries);
          var QueryResults = karate.call(FeatureFilePath+'/Dynamodb.feature@GetItemsViaQuery', GetItemsViaQueryParams);
          matchResult = karate.match(QueryResults.result.length, ExpectedMAMAssetInfoCount);
          karate.log('Result: ' + matchResult);
          if(matchResult.pass) {
            break;
          } else {
            karate.log('Failed. Sleeping for 10s.');
            java.lang.Thread.sleep(10*1000);
          }
        }
        return  matchResult;
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

Scenario: Nordic_Norway_Duo_Linear_Merge_All_NoTag_NO - Validate Item Counts - Wochit Rendition
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
  * def retries = 3
  * def getResult =
    """
      function() {
        var matchResult = null;
        for(var i = 0; i < retries; ++i) {
          karate.log('Try #' + (i+1) + ' of ' + retries);
          var QueryResults = karate.call(FeatureFilePath+'/Dynamodb.feature@GetItemsViaQuery', GetItemsViaQueryParams);

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

          var FilteredQueryResults = karate.call(FeatureFilePath+'/Dynamodb.feature@FilterQueryResults', FilterQueryResultsParams);
          matchResult = karate.match(FilteredQueryResults.result.length, ExpectedWochitRenditionCount);
          karate.log(matchResult);
          if(matchResult.pass) {
            break;
          } else {
            karate.log('Failed. Sleeping for 10s.');
            java.lang.Thread.sleep(10*1000);
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

Scenario: Nordic_Norway_Duo_Linear_Merge_All_NoTag_NO - Validate Item Counts - Wochit Mapping
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
  * def retries = 3
  * def getResult =
    """
      function() {
        var matchResult = null;
        for(var i = 0; i < retries; ++i) {
          karate.log('Try #' + (i+1) + ' of ' + retries);
          var QueryResults = karate.call(FeatureFilePath+'/Dynamodb.feature@GetItemsViaQuery', GetItemsViaQueryParams);
          matchResult = karate.match(QueryResults.result.length, ExpectedWochitRenditionCount);
          karate.log('Result: ' + matchResult);
          if(matchResult.pass) {
            break;
          } else {
            karate.log('Failed. Sleeping for 10s.');
            java.lang.Thread.sleep(10*1000);
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

Scenario: Hard wait for PROCESSING to FINISH
  # RUN ONLY IN E2E, DO NOT RUN IN REGRESSION
  * configure abortedStepsShouldPass = true
  * eval if (!TargetTag.contains('E2E')) {karate.abort()}
  # ---------
  * call Pause 60000*4

Scenario Outline: Nordic_Norway_Duo_Linear_Merge_All_NoTag_NO - FINISHED - Validate Wochit Mapping Table for Aspect Ratio <ASPECTRATIO> [wochitRenditionStatus: <RENDITIONSTATUS> - isRenditionMoved: <ISRENDITIONMOVED>]
  # RUN ONLY IN E2E, DO NOT RUN IN REGRESSION
  * configure abortedStepsShouldPass = true
  * eval if (!TargetTag.contains('E2E')) {karate.abort()}
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
  * def retries = 3
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
          karate.log('Try #' + (i+1) + ' of ' + retries);
          resp = karate.call(FeatureFilePath+'/Dynamodb.feature@ValidateItemViaQuery', ValidateItemViaQueryParams);
          if(resp['result']['pass']) {
            break;
          } else {
            karate.log('Failed. Sleeping for 1 minute.');
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

Scenario Outline: Nordic_Norway_Duo_Linear_Merge_All_NoTag_NO - Validate if <ASPECTRATIO> Asset exists
  # RUN ONLY IN E2E, DO NOT RUN IN REGRESSION
  * configure abortedStepsShouldPass = true
  * eval if (!TargetTag.contains('E2E')) {karate.abort()}
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
  * def QueryResults = call read(FeatureFilePath+'/Dynamodb.feature@GetItemsViaQuery') ValidateItemViaQueryParams
  * def FullExpectedTitle = QueryResults.result[0]['renditionFileName'] + '.mp4'
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
  * def retries = 3
  * def getResult = 
    """
      function() {
        var matchResult = null;
        for(var i = 0; i < retries; ++i) {
          karate.log('Try #' + (i+1) + ' of ' + retries);
          // matchResult = karate.call(FeatureFilePath+'/Dynamodb.feature@ValidateItemViaQuery', ValidateItemViaQueryParams);
          matchResult = validateS3ObjectExists();
          karate.log(matchResult)
          if(matchResult.pass) {
            break;
          } else {
            karate.log('Failed. Sleeping for 30s.');
            java.lang.Thread.sleep(30*1000);
          }

        }
        return matchResult;
      }
    """
  * def result = call getResult
  # * def result = call validateS3ObjectExists
  * print result
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