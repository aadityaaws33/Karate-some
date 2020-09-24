Feature: Isolated

Background:
    * def TCName = 'Dplay_All_DropDownList_NL'
    * def TCAssetID = AssetIDNetherlands
    * def SeasonURL = UpdateSeasonURLNetherlands
    * def EpisodeURL = UpdateEpisodeURLNetherlands
    * def TriggerRenditionURL = TriggerRenditionURLNetherlands
    * def TCValidationType = 'videoValidation' //videoValidation or imageValidation. Used for custom report table
    * def tcResultWritePath = 'test-classes/' + TCName + '.json'
    * def tcResultReadPath = 'classpath:target/' + tcResultWritePath
    * def finalResultWritePath = 'test-classes/Results.json'
    * def finalResultReadPath = 'classpath:target/' + finalResultWritePath
    * def currentTCPath = 'classpath:CA/TestData/E2ECases/Nordic_Region/Netherlands/' + TCName
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
@Isolated
Scenario Outline: Nordic_Netherlands_Dplay_All_DropDownList_NL - Validate Technical Metadata for Composite View ID: <COMPOSITEVIEWID>
  * def scenarioName = 'validateTechnicalMetadata'
  * def TechMetaData_expectedResponse = read(currentTCPath+'/Output/ExpectedTechMetaData.txt')
  * def Expected_MAMAssetInfo_Entry = read(currentTCPath + '/Output/Expected_MAMAssetInfo_Entry.json')
  * def getItemMAMAssetInfoParams = 
    """
      {
        Param_TableName: 'CA_MAM_ASSETS_INFO_EU-qa',
        Param_PartitionKey: 'assetId', 
        Param_SortKey: 'compositeViewsId',
        ParamPartionKeyVal: #(TCAssetID), 
        ParamSortKeyVal: <COMPOSITEVIEWID>,
        Expected_MAMAssetInfo_Entry: #(Expected_MAMAssetInfo_Entry)
      }
    """
  # DYNAMODB FEATURE START

  * def scanResult = read(currentTCPath + '/MockResults/Expected_MAMAssetInfo_Entry' + <X> + '.json')
  * print scanResult
  * def getMatchResult = 
    """
      function() {
        var matchRes = karate.match('scanResult contains Expected_MAMAssetInfo_Entry');
        if(!matchRes['pass']) {
          karate.log('Initial matching failed');
          for(var key in scanResult) {
            var thisRes = '';
            expectedValue = Expected_MAMAssetInfo_Entry[key];
            actualValue = scanResult[key];
            if(key == 'assetMetadata' || key == 'seasonMetadata' || key == 'seriesMetadata') {
              for(var assetMetadataKey in actualValue) {
                expectedAssetMetadataValue = expectedValue[assetMetadataKey];
                actualAssetMetadataValue = actualValue[assetMetadataKey];
                if(assetMetadataKey == 'data') {
                  for(var dataKey in actualAssetMetadataValue) {
                    expectedDataField = expectedAssetMetadataValue[dataKey];
                    actualDataField = actualAssetMetadataValue[dataKey];
                    thisRes = karate.match('actualDataField contains expectedDataField');
                    karate.log(key,'[',assetMetadataKey,']','[',dataKey,']', thisRes);
                    if(!thisRes['pass']) {
                      break;
                    }
                  }
                } else {
                  thisRes = karate.match('actualAssetMetadataValue contains expectedAssetMetadataValue');
                  karate.log(key,'[',assetMetadataKey,']', thisRes);
                }
                if(!thisRes['pass']) {
                  break;
                }
              }
            } else {
              thisRes = karate.match('actualValue contains expectedValue');
              karate.log(key, thisRes);
            }
            matchRes = thisRes;
            if(!matchRes['pass']) {
              break;
            }
          }
        }
        return matchRes;
      }
    """
  * def matchResult = call getMatchResult
  * def result = { result: #(matchResult) }
  * print result

  # DYNAMODB FEATURE END
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
    | COMPOSITEVIEWID                                                            | X | 
    | 83a5bfc2-e771-11ea-afed-0a580a3c2c48\|1f708f46-e771-11ea-b4dd-0a580a3c8cb3 | 1 |
    | 49074474-e773-11ea-8e77-0a580a3f8ee8\|1f708f46-e771-11ea-b4dd-0a580a3c8cb3 | 2 |
    | e472d33e-e772-11ea-9b92-0a580a3f8d44\|861202d8-e772-11ea-abaf-0a580a3cf01e | 3 |