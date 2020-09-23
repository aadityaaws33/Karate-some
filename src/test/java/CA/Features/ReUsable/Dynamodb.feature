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
* def ItemCount =
    """
    function()
    {
        var ItemCount = Java.type('CA.utils.java.DynamoDBUtils');
        var ItCnt = new ItemCount();
        return ItCnt.Query_GetTableItemCount(Param_TableName,Param_KeyType,Param_Atr1,Param_Atr2,Param_Atrvalue1,Param_Atrvalue2);
    }
    """
* def temp = call ItemCount
#* print '----------------Actual Item Count------------'+temp
#* print '---------------Expected Item Count-----------'+Param_ExpectedItemCount
* def result = temp == Param_ExpectedItemCount?'Pass':'Fail'


@ItemCountScan
Scenario: Get Item Count of Table with Scan
#* print '-------------------Dynamo DB Feature and Item Count-------------'
* def ItemCount =
    """
    function()
    {
        var ItemCount = Java.type('CA.utils.java.DynamoDBUtils');
        var ItCnt = new ItemCount();
        return ItCnt.Scan_GetTableItemCount(Param_TableName,Param_Atr1,Param_Atrvalue1,Param_Operator);
    }
    """
* def temp = call ItemCount
#* print '----------------Actual Item Count------------'+temp
#* print '---------------Expected Item Count-----------'+Param_ExpectedItemCount
* def result = temp == Param_ExpectedItemCount?'Pass':'Fail'

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
#* print '----------------Temp in ValidatePassedItem------------'+temp


@GetItemMAMAssetInfo
Scenario: Get Item Count of Table with Scan
#* print '-------------------GetItemMAMAssetInfo-------------'
* def ItemCount =
    """
    function()
    {
        var ItemCount = Java.type('CA.utils.java.DynamoDBUtils');
        var ItCnt = new ItemCount();
         return ItCnt.getitem_PartionKey_SortKey(Param_TableName,Param_PartitionKey,Param_SortKey,ParamPartionKeyVal,ParamSortKeyVal);
    }
    """
* def QueryJson = call ItemCount
* def ItemResponse = get[0] QueryJson
* def evalItemResponse = 
  """
    function() {
      if (
        ItemResponse.contains(Param_TechMetaData)
      ) {
        return 'Pass'
      } else {
        return 'Fail'
      }
    }
  """
* def result = call evalItemResponse
# * match ItemResponse contains Param_TechMetaData
# * print QueryJson
#* print 
#* def ActualTechMetaData = get[0] QueryJson.technicalMetadata
#* assert ActualTechMetaData == Param_TechMetaData
#--------Backup------
#* json jsonVar = temp
#* def QueryJson = get[0] jsonVar
#-----To be Replaced-------
#* def temp = call ItemCount
#* json jsonVar = temp
#* def QueryJson = get[0] jsonVar
#-----To be Replaced-------
#* print '----------jsonVar---------------'+ jsonVar
#* print '------------------Get Json Value----------'+QueryJson
#* print '---------Country Value-------'+karate.jsonPath(QueryJson,"$.technicalMetadata")
#* print '---------Country Value--------'+karate.jsonPath(response,"$.metadata_values.no-dplay-SeriesTitle.field_values[0].value")
# ------Working---------* def kitnums = get[0] QueryJson.technicalMetadata
# ------Working---------* def kitnums = get[0] QueryJson.technicalMetadata.name
#* print '------------Gettng Country-------'+ActualTechMetaData
#--------Backup------


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
* def ItemCount =
    """
    function()
    {
        var ItemCount = Java.type('CA.utils.java.DynamoDBUtils');
        var ItCnt = new ItemCount();
        return ItCnt.Scan_DB_WochitRendition(Param_TableName,Param_ScanAttr1,Param_ScanVal1,Param_ScanAttr2,Param_ScanVal2);
    }
    """
* def QueryJson = call ItemCount
* def ItemResponse = get[0] QueryJson
#* print '-----------Response in Feature File-----------'+ItemResponse
* def evalItemResponse =
  """
    function() {
      if(
        ItemResponse.contains(Param_Expected_Status) &&
        ItemResponse.contains(Param_Expected_Item_AspectRatio_TemplateID) &&
        ItemResponse.contains(Param_Expected_VideoUpdates)
      ) {
        return 'Pass'
      } else {
        return 'Fail'
      }
    }
  """
* def result = call evalItemResponse
# * match ItemResponse contains Param_Expected_Status
# * match ItemResponse contains Param_Expected_Item_AspectRatio_TemplateID
# * match ItemResponse contains Param_Expected_VideoUpdates


@ValidateWochitMappingPayload
Scenario: Get Item Count of Table with Scan
#* print '-------------------Dynamo DB Get Item-------------'
* def ItemCount =
    """
    function()
    {
        var ItemCount = Java.type('CA.utils.java.DynamoDBUtils');
        var ItCnt = new ItemCount();
        return ItCnt.Scan_DB_WochitMapping(Param_TableName,Param_ScanAttr1,Param_ScanVal1);
    }
    """
* def QueryJson = call ItemCount
* print QueryJson
* def ItemResponse = get[0] QueryJson
* def evalItemResponse =
  """
    function() {
      if(
        ItemResponse.contains(Param_Expected_Status)
      ) {
        return 'Pass'
      } else {
        return 'Fail'
      }
    }
  """
* def result = call evalItemResponse
# * match ItemResponse contains Param_Expected_Status

#* print '-----------Response in Feature File-----------'+ItemResponse
#* match ItemResponse contains Param_Expected_Item_AspectRatio_TemplateID
#* match ItemResponse contains Param_Expected_VideoUpdates


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
* def result = itemCount > 0?'Pass':'Fail'



