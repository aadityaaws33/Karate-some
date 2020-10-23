@E2E @Japan @parallel=false
Feature:  Dplay_All_CustomText_JP

Background:
    * def TCName = 'Dplay_All_CustomText_JP'
    * def WochitMappingTableName = 'CA_WOCHIT_MAPPING_APAC-qa'
    * def WochitRenditionTableName = 'CA_WOCHIT_RENDITIONS_APAC-qa'
    * def MAMAssetsInfoTableName = 'CA_MAM_ASSETS_INFO_APAC-qa'
    * def AWSregion = 'APAC'
    * def TCAssetID = AssetIDJapan
    * def TriggerRenditionURL = TriggerRenditionURLJapan
    * def Iconik_CollectionID = Iconik_CollectionIDJapan
    * def TCValidationType = 'videoValidation' //videoValidation or imageValidation. Used for custom report table
    * def tcResultWritePath = 'test-classes/' + TCName + '.json'
    * def tcResultReadPath = 'classpath:target/' + tcResultWritePath
    * def finalResultWritePath = 'test-classes/Results.json'
    * def finalResultReadPath = 'classpath:target/' + finalResultWritePath
    * def currentTCPath = 'classpath:CA/TestData/E2ECases/APAC_Region/Japan/' + TCName
    * def FeatureFilePath = 'classpath:CA/Features/ReUsable'
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
    * def Random_String_Generator = function(){ return java.lang.System.currentTimeMillis() }
    * def RandomSeriesTitle = 'QA Series Japan'
    * def two = callonce read(FeatureFilePath+'/RandomGenerator.feature@CallOutText')
    * def RandomCalloutText = 'ジェスナーはここにいた' + two.RandomCalloutText
    * def three = callonce read(FeatureFilePath+'/RandomGenerator.feature@CTA')
    * def RandomCTA = 'ジェスナーはここにいた' + three.RandomCTA
    * print RandomSeriesTitle, RandomCalloutText, RandomCTA
    * configure afterFeature = 
      """
        function() {
          karate.call(FeatureFilePath + '/Results.feature@updateFinalResults', { updateFinalResultParams: updateFinalResultParams });
        }
      """

Scenario: APAC_Japan_Dplay_All_DropDownList_JP - Trigger Rendition
  * def scenarioName = 'triggerRendition'
  * def Renditionquery = read(currentTCPath+'/Input/RenditionRequest.json')
  * def Rendition_ExpectedResponse = read(currentTCPath+'/Output/ExpectedRenditionResponse.json')
  * def renditionParams = 
    """
      {
        URL: #(TriggerRenditionURL),
        RenditionQuery: '#(Renditionquery)',
        RenditionExpectedResponse: '#(Rendition_ExpectedResponse)'
      }
    """
  * def result = call read(FeatureFilePath+'/Rendition.feature') renditionParams
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
  * call Pause 60000

Scenario: APAC_Japan_Dplay_All_DropDownList_JP - Validate Item Counts - MAM Asset Info
  * def scenarioName = "validateMAM"
  * def ExpectedMAMAssetInfoCount = 3
  * def itemCountQueryParams = 
    """
      {
        Param_TableName: #(MAMAssetsInfoTableName),
        Param_KeyType: 'Single',
        Param_Atr1: 'assetId',
        Param_Atr2: '',
        Param_Atrvalue1: #(TCAssetID),
        Param_Atrvalue2: '',
        Param_ExpectedItemCount: #(ExpectedMAMAssetInfoCount)
      }
    """
  * def result = call read(FeatureFilePath+'/Dynamodb.feature@ItemCountQuery') itemCountQueryParams
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

Scenario: APAC_Japan_Dplay_All_DropDownList_JP - Validate Item Counts - Wochit Rendition
  * def scenarioName = "validateWochitRenditionCount"
  * def ExpectedWocRenditionCount = 3
  * def ExpectedTitle = RandomCalloutText+'-'+RandomCTA
  * def itemCountScanParams = 
    """
      {
        Param_TableName: #(WochitRenditionTableName),
        Param_Atr1: 'videoUpdates.title',
        Param_Atrvalue1: #(ExpectedTitle),
        Param_Operator: 'contains',
        Param_ExpectedItemCount: #(ExpectedWocRenditionCount)
      }    
    """
  * def result = call read(FeatureFilePath+'/Dynamodb.feature@ItemCountScan') itemCountScanParams
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

Scenario: APAC_Japan_Dplay_All_DropDownList_JP - Validate Item Counts - Wochit Mapping
  * def scenarioName = "validateWochitMappingCount"
  * def ExpectedWochitMappingCount = 3
  * def ExpectedTitle = RandomCalloutText+'-'+RandomCTA
  * def itemCountScanParams =
    """
      {
        Param_TableName: #(WochitMappingTableName),
        Param_Atr1: 'renditionFileName',
        Param_Atrvalue1: #(ExpectedTitle),
        Param_Operator: 'containsforcount',
        Param_ExpectedItemCount: #(ExpectedWochitMappingCount)
      }    
    """
  * def result = call read(FeatureFilePath+'/Dynamodb.feature@ItemCountScan') itemCountScanParams
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
  
Scenario Outline: APAC_Japan_Dplay_All_DropDownList_JP - Validate Wochit Renditions Table for <ASPECTRATIO>
  * def scenarioName = 'validateWochitRendition' + <ASPECTRATIO>
  * def RenditionFileName = <FileNameSuffix>+'-'+RandomCalloutText+'-'+RandomCTA
  * def Expected_WochitRendition_Entry = read(currentTCPath + '/Output/Expected_WochitRendition_Entry.json')
  * def validateRenditionPayloadParams =
    """
      {
        Param_TableName: #(WochitRenditionTableName),
        Param_ScanAttr1: 'videoUpdates.title',
        Param_ScanVal1: #(RenditionFileName),
        Param_ScanAttr2:'aspectRatio',
        Param_ScanVal2: <ScanVal>,
        Expected_WochitRendition_Entry: #(Expected_WochitRendition_Entry)
      }
    """
  * def result = call read(FeatureFilePath+'/Dynamodb.feature@ValidateWochitRenditionPayload') validateRenditionPayloadParams
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
    | ASPECTRATIO   | TEMPLATEID               | ScanVal      | FileNameSuffix                  |
    | '16x9'        | 5ebb4c377f8c3b07249d5e80 | ASPECT_16_9  | 'DAQ CA Test JP-dplay_16x9'     |
    | '4x5'         | 5ebb596b7f8c3b07249d5e8b | ASPECT_4_5   | 'DAQ CA Test JP-dplay_4x5'      |
    | '1x1'         | 5ebb5b25eff13f1e3a9c4399 | ASPECT_1_1   | 'DAQ CA Test JP-dplay_1x1'      |      

Scenario Outline: APAC_Japan_Dplay_All_DropDownList_JP - Validate Technical Metadata for Composite View ID: <COMPOSITEVIEWID>
  * def scenarioName = 'validateTechnicalMetadata'
  * def Expected_MAMAssetInfo_Entry = read(currentTCPath + '/Output/Expected_MAMAssetInfo_Entry.json')
  * def getItemMAMAssetInfoParams = 
    """
      {
        Param_TableName: #(MAMAssetsInfoTableName),
        Param_PartitionKey: 'assetId', 
        Param_SortKey: 'compositeViewsId',
        ParamPartionKeyVal: #(TCAssetID), 
        ParamSortKeyVal: <COMPOSITEVIEWID>,
        Expected_MAMAssetInfo_Entry: #(Expected_MAMAssetInfo_Entry)
      }
    """
  * def result = call read(FeatureFilePath+'/Dynamodb.feature@GetItemMAMAssetInfo') getItemMAMAssetInfoParams
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
    | COMPOSITEVIEWID                                                            |
    | 871e343e-e688-11ea-b4dd-0a580a3c8cb3\|f6df5b2c-e688-11ea-8e77-0a580a3f8ee8 |
    | 104e4cca-e68a-11ea-b0f2-0a580a3c2c48\|38d81b6a-dc64-11ea-8d68-0a580a3d1fd3 |
    | c1903366-dc64-11ea-83ae-0a580a3dd2ae\|38d81b6a-dc64-11ea-8d68-0a580a3d1fd3 |

Scenario Outline: APAC_Japan_Dplay_All_DropDownList_JP - Validate Wochit Mapping Table for Aspect Ratio <ASPECTRATIO> Rendition Status 
  * def scenarioName = 'validateWochitMapping' + <ASPECTRATIO>
  * def RenditionFileName = <FNAMEPREFIX>+'-'+RandomCalloutText+'-'+RandomCTA
  * def Expected_WochitMapping_Entry = read(currentTCPath + '/Output/Expected_WochitMapping_Entry.json')
  * def validateWochitMappingPayloadParams =
    """
      {
        Param_TableName: #(WochitMappingTableName),
        Param_ScanAttr1: 'renditionFileName',
        Param_ScanVal1: '#(RenditionFileName)',
        Expected_WochitMapping_Entry: '#(Expected_WochitMapping_Entry)'
      }
    """
  * def result = call read(FeatureFilePath+'/Dynamodb.feature@ValidateWochitMappingPayload') validateWochitMappingPayloadParams
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
    | FNAMEPREFIX                   | ASPECTRATIO |
    | 'DAQ CA Test JP-dplay_16x9'   | '16x9'      |
    | 'DAQ CA Test JP-dplay_4x5'    | '4x5'       |
    | 'DAQ CA Test JP-dplay_1x1'    | '1x1'       |
