Feature: Dynamo DB Related Features

Background:
    * def Pause = function(pause){ java.lang.Thread.sleep(pause) }
    * def initializeDynamoDBObject = 
      """
        function(thisAWSregion) {
          var dynamoDBUtilsClass = Java.type('CA.utils.java.DynamoDBUtils');
          return new dynamoDBUtilsClass(thisAWSregion)
        }
      """
    * def dynamoDB = callonce initializeDynamoDBObject AWSregion
    
@TruncateTable
Scenario: Truncate Table
#* print '-------------------Dynamo DB Feature and Truncate Table Scenario-------------'
* def TruncateTable =
    """
    function()
    {
      return dynamoDB.TruncateTable(
        Param_TableName,
        Param_PrimaryKey
      );
    }
    """
* def temp = call TruncateTable


@ValidateItemCountViaQuery
Scenario: Validate DynamoDB Item Count via Query
#* print '-------------------Dynamo DB Feature and Item Count-------------'
* def getItemCountQuery =
  """
  function()
  {
    var HashMap = Java.type('java.util.HashMap');
    var Param_QueryInfoListJava = [];
    for(var index in Param_QueryInfoList){
      // Convert J04 Object into Java HashMap
      var Param_QueryInfoItemHashMapJava = new HashMap();
      Param_QueryInfoItemHashMapJava.putAll(Param_QueryInfoList[index]);
      // Append converted Java HashMap to Java List
      Param_QueryInfoListJava.push(
        Param_QueryInfoItemHashMapJava
      );
    }

    return dynamoDB.Query_GetTableItemCount(
      Param_TableName,
      Param_QueryInfoListJava,
      Param_GlobalSecondaryIndex
    );
  }
  """
* def itemCount = call getItemCountQuery
* print itemCount
* def result = karate.match(itemCount, Param_ExpectedItemCount)
* print result
#* print '----------------Actual Item Count------------'+temp
#* print '---------------Expected Item Count-----------'+Param_ExpectedItemCount

@ValidateItemViaQuery
Scenario: Validate DynamoDB Item via Query
#* print '-------------------Dynamo DB Feature and Item Count-------------'
* def getItemsQuery =
  """
  function()
  {
    var HashMap = Java.type('java.util.HashMap');
    var Param_QueryInfoListJava = [];
    for(var index in Param_QueryInfoList){
      // Convert J04 Object into Java HashMap
      var Param_QueryInfoItemHashMapJava = new HashMap();
      Param_QueryInfoItemHashMapJava.putAll(Param_QueryInfoList[index]);
      // Append converted Java HashMap to Java List
      Param_QueryInfoListJava.push(
        Param_QueryInfoItemHashMapJava
      );
    }

    var queryResp = dynamoDB.Query_GetItems(
      Param_TableName,
      Param_QueryInfoListJava,
      Param_GlobalSecondaryIndex
    );

    return JSON.parse(queryResp[0]);

  }
  """
* def queryResult = call getItemsQuery
* print queryResult
* def getMatchResult = 
    """
      function() {
        var matchRes = karate.match('queryResult contains Param_ExpectedResponse');
        if(!matchRes['pass']) {
          karate.log('Initial matching failed');
          for(var key in queryResult) {
            var thisRes = '';
            expectedValue = Param_ExpectedResponse[key];
            actualValue = queryResult[key];
            if(key == 'assetMetadata' || key == 'seasonMetadata' || key == 'seriesMetadata') {
              for(var metadataKey in actualValue) {
                expectedMetadataValue = expectedValue[metadataKey];
                actualMetadataValue = actualValue[metadataKey];
                if(typeof(actualMetadataValue) == 'object') {
                  karate.log(metadataKey + ' TYPE: ' + typeof(actualMetadataValue));
                  karate.log(actualMetadataValue);
                  if(actualMetadataValue.length > 0) {
                    for(var dataKey in actualMetadataValue) {
                      expectedDataField = expectedMetadataValue[dataKey];
                      actualDataField = actualMetadataValue[dataKey];
                      thisRes = karate.match('actualDataField contains expectedDataField');
                      karate.log(key,'[',metadataKey,']','[',dataKey,']', thisRes);
                      if(!thisRes['pass']) {
                        break;
                      }
                    }
                  } else {
                    thisRes = {
                      message: 'Skipping empty object',
                      pass: true
                    }
                  }
                } else {
                  thisRes = karate.match('actualMetadataValue contains expectedMetadataValue');
                  karate.log(key,'[',metadataKey,']', thisRes);
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

@ItemCountScan
Scenario: Get Item Count of Table with Scan
#* print '-------------------Dynamo DB Feature and Item Count-------------'
* def getItemCountScan =
    """
    function()
    {
        return dynamoDB.Scan_GetTableItemCount(
          Param_TableName,
          Param_Atr1,
          Param_Atrvalue1,
          Param_Operator
        );
    }
    """
* def itemList = call getItemCountScan
* print itemList
* def itemCount = itemList.length
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
      return dynamoDB.Scan_ValidateItem(
        Param_TableName,
        Param_Atr1,
        Param_Atrvalue1,
        Param_TechMetaDataExpected);
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
        var result = dynamoDB.getitem_PartionKey_SortKey(
          Param_TableName,
          Param_PartitionKey,
          Param_SortKey,
          ParamPartionKeyVal,
          ParamSortKeyVal
        );
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
              for(var metadataKey in actualValue) {
                expectedMetadataValue = expectedValue[metadataKey];
                actualMetadataValue = actualValue[metadataKey];
                if(typeof(actualMetadataValue) == 'object') {
                  karate.log(metadataKey + ' TYPE: ' + typeof(actualMetadataValue));
                  karate.log(actualMetadataValue);
                  if(actualMetadataValue.length > 0) {
                    for(var dataKey in actualMetadataValue) {
                      expectedDataField = expectedMetadataValue[dataKey];
                      actualDataField = actualMetadataValue[dataKey];
                      thisRes = karate.match('actualDataField contains expectedDataField');
                      karate.log(key,'[',metadataKey,']','[',dataKey,']', thisRes);
                      if(!thisRes['pass']) {
                        break;
                      }
                    }
                  } else {
                    thisRes = {
                      message: 'Skipping empty object',
                      pass: true
                    }
                  }
                } else {
                  thisRes = karate.match('actualMetadataValue contains expectedMetadataValue');
                  karate.log(key,'[',metadataKey,']', thisRes);
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
      return dynamoDB.Scan_DB_GetSingleItem(
        Param_TableName,
        Param_ScanAttr,
        Param_ScanVal,
        ''
      );
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
      return dynamoDB.Scan_WochitRendition(
        Param_TableName,
        Param_ScanAttr1,
        Param_ScanVal1,
        Param_ScanAttr2,
        Param_ScanVal2
      );
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
        var result = dynamoDB.Scan_DB_WochitRendition(
          Param_TableName,
          Param_ScanAttr1,
          Param_ScanVal1,
          Param_ScanAttr2,
          Param_ScanVal2
        );
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
          var result = dynamoDB.Scan_DB_WochitMapping(
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
      return itemCount = dynamoDB.WaitforDBUpdate(
        Param_ScanAtr,
        Param_ScanVal
      );
    }
    """
* def itemCount = call getItemCount
* def result = karate.match('itemCount > 0')
* print result



