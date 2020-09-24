Feature: Dynamo DB Related Features

Background:
    * def Pause = function(pause){ java.lang.Thread.sleep(pause) }
    
@TruncateTable
Scenario: Truncate Table
#* print '-------------------Dynamo DB Feature and Truncate Table Scenario-------------'
* def TruncateTable =
    """
    function()
    {
        var TrTable = Java.type('CA.utils.java.DynamoDBUtils');
        var Trt = new TrTable();
        return Trt.TruncateTable(Param_TableName,Param_PrimaryKey);
    }
    """
* def temp = call TruncateTable


@ItemCountQuery
Scenario: Get Item Count of Table with Scan
#* print '-------------------Dynamo DB Feature and Item Count-------------'
* def getItemCountQuery =
    """
    function()
    {
        var ItemCount = Java.type('CA.utils.java.DynamoDBUtils');
        var ItCnt = new ItemCount();
        return ItCnt.Query_GetTableItemCount(Param_TableName,Param_KeyType,Param_Atr1,Param_Atr2,Param_Atrvalue1,Param_Atrvalue2);
    }
    """
* def itemCount = call getItemCountQuery
* print itemCount
* def result = karate.match(itemCount, Param_ExpectedItemCount)
* print result
#* print '----------------Actual Item Count------------'+temp
#* print '---------------Expected Item Count-----------'+Param_ExpectedItemCount


@ItemCountScan
Scenario: Get Item Count of Table with Scan
#* print '-------------------Dynamo DB Feature and Item Count-------------'
* def getItemCountScan =
    """
    function()
    {
        var ItemCount = Java.type('CA.utils.java.DynamoDBUtils');
        var ItCnt = new ItemCount();
        return ItCnt.Scan_GetTableItemCount(Param_TableName,Param_Atr1,Param_Atrvalue1,Param_Operator);
    }
    """
* def itemCount = call getItemCountScan
* print itemCount
* def result = karate.match(itemCount, Param_ExpectedItemCount)
* print result
#* print '----------------Actual Item Count------------'+temp
#* print '---------------Expected Item Count-----------'+Param_ExpectedItemCount

@ValidatePassedItem
Scenario: Get Item Count of Table with Scan
#* print '-------------------Dynamo DB Validate Item-------------'
#* print '-----------------Expected from Json---------------'+Param_TechMetaDataExpected
* def ItemCount =
    """
    function()
    {
        var ItemCount = Java.type('CA.utils.java.DynamoDBUtils');
        var ItCnt = new ItemCount();
         ItCnt.Scan_ValidateItem(Param_TableName,Param_Atr1,Param_Atrvalue1,Param_TechMetaDataExpected);
    }
    """
* def temp = call ItemCount
* print temp
#* print '----------------Temp in ValidatePassedItem------------'+temp


@GetItemMAMAssetInfo
Scenario: Get Item Count of Table with Scan
  #* print '-------------------GetItemMAMAssetInfo-------------'
  * def scanMAMAssetInfo =
    """
      function()
      {
        var ItemCount = Java.type('CA.utils.java.DynamoDBUtils');
        var ItCnt = new ItemCount();
        var result = ItCnt.getitem_PartionKey_SortKey(
          Param_TableName,
          Param_PartitionKey,
          Param_SortKey,
          ParamPartionKeyVal,
          ParamSortKeyVal
        );
        karate.log(result);
        return JSON.parse(result[0]);
      }
    """
  * def scanResult = call scanMAMAssetInfo
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
  * def result = call getMatchResult
  * print result

@ScanGetItem
Scenario: Get Item Count of Table with Scan
#* print '-------------------Dynamo DB Get Item-------------'
* def ItemCount =
    """
    function()
    {
        var ItemCount = Java.type('CA.utils.java.DynamoDBUtils');
        var ItCnt = new ItemCount();
        return ItCnt.Scan_DB_GetSingleItem(Param_TableName,Param_ScanAttr,Param_ScanVal,'');
    }
    """
* def QueryJson = call ItemCount
* print QueryJson
* def ItemResponse = get[0] QueryJson
#* print '-------------ActualResponse-----------'+ItemResponse
#* print '-------------ExpectedResponse-----------'+QueryJsonExpected
#* match ItemResponse contains '#(QueryJsonExpected)'
* match ItemResponse contains QueryJsonExpected
#* match QueryJsonExpected contains ItemResponse

@ValidateWochitPayload
Scenario: Get Item Count of Table with Scan
#* print '-------------------Dynamo DB Get Item-------------'
* def ItemCount =
    """
    function()
    {
        var ItemCount = Java.type('CA.utils.java.DynamoDBUtils');
        var ItCnt = new ItemCount();
        return ItCnt.Scan_WochitRendition(Param_TableName,Param_ScanAttr1,Param_ScanVal1,Param_ScanAttr2,Param_ScanVal2);
    }
    """
* def QueryJson = call ItemCount
* print QueryJson
* def ItemResponse = get[0] QueryJson
* match ItemResponse contains Param_Expected_Status
* match ItemResponse contains Param_Expected_Item_AspectRatio_TemplateID
* match ItemResponse contains Param_Expected_VideoUpdates

#-----TBI
#* print '-------------ActualResponse-----------'+ItemResponse
#* print '-------------ExpectedResponse-----------'+QueryJsonExpected
#* match ItemResponse contains '#(QueryJsonExpected)'
#* match ItemResponse contains Param_Expected_TimelineItems
#* match QueryJsonExpected contains ItemResponse
#-----TBI

@ValidateWochitRenditionPayload
Scenario: Get Item Count of Table with Scan
  #* print '-------------------Dynamo DB Get Item-------------'
  * def scanWochitRendition =
    """
      function()
      {
        var ItemCount = Java.type('CA.utils.java.DynamoDBUtils');
        var ItCnt = new ItemCount();
        var result = ItCnt.Scan_DB_WochitRendition(
          Param_TableName,
          Param_ScanAttr1,
          Param_ScanVal1,
          Param_ScanAttr2,
          Param_ScanVal2
        );
        karate.log(result);
        return JSON.parse(result[0]);
      }
    """
  * def scanResult = call scanWochitRendition
  * print scanResult
  * def getMatchResult = 
    """
      function() {
        var matchRes = karate.match('scanResult contains Expected_WochitRendition_Entry');
        if(!matchRes['pass']) {
          karate.log('Initial matching failed');
          for(var key in scanResult) {
            var thisRes = '';
            expectedValue = Expected_WochitRendition_Entry[key];
            actualValue = scanResult[key];
            if(key == 'videoUpdates') {
              for(var videoUpdatesKey in actualValue) {
                actualVideoField = actualValue[videoUpdatesKey];
                expectedVideoField = expectedValue[videoUpdatesKey];
                thisRes = karate.match('actualVideoField contains expectedVideoField');
                karate.log(key + '[' + videoUpdatesKey + ']: ' + thisRes);
                if(!thisRes['pass']) {
                  break;
                }
              }
            } else {
              thisRes = karate.match('actualValue contains expectedValue');
            }
            karate.log(key + ': ' + thisRes);
            matchRes = thisRes;
            if(!matchRes['pass']) {
              break;
            }
          }
        }
        return matchRes;
      }
    """
  * def result = call getMatchResult
  * print result


@ValidateWochitMappingPayload
Scenario: Get Item Count of Table with Scan
  #* print '-------------------Dynamo DB Get Item-------------'
  * def scanWochitMapping =
      """
      function()
      {
          var ItemCount = Java.type('CA.utils.java.DynamoDBUtils');
          var ItCnt = new ItemCount();
          var result = ItCnt.Scan_DB_WochitMapping(
            Param_TableName,
            Param_ScanAttr1,
            Param_ScanVal1
          );
          return JSON.parse(result[0]);
      }
      """
  * def scanResult = call scanWochitMapping
  * print scanResult
  * def getMatchResult = 
    """
      function() {
        var matchRes = karate.match('scanResult contains Expected_WochitMapping_Entry');
        if(!matchRes['pass']) {
          karate.log('Initial matching failed');
          for(var key in scanResult) {
            var thisRes = '';
            expectedValue = Expected_WochitMapping_Entry[key];
            actualValue = scanResult[key];
            thisRes = karate.match('actualValue contains expectedValue');
            karate.log(key + ': ' + thisRes);
            matchRes = thisRes;
            if(!matchRes['pass']) {
              break;
            }
          }
        }
        return matchRes;
      }
    """
  * def result = call getMatchResult
  * print result

@WaitUntilDBUpdate
Scenario: Wait for DB Update
#* print '-------------------WaitUntilDBUpdate-------------'
* def getItemCount =
    """
    function()
    {
        var dynamoDBUtilsClass = Java.type('CA.utils.java.DynamoDBUtils');
        var dynamoDB = new dynamoDBUtilsClass();
        var itemCount = dynamoDB.WaitforDBUpdate(Param_ScanAtr,Param_ScanVal);
        return itemCount
    }
    """
* def itemCount = call getItemCount
* def result = karate.match('itemCount > 0')
* print result



