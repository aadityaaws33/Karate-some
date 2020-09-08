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
* assert temp == Param_ExpectedItemCount


@ItemCountScan
Scenario: Get Item Count of Table with Scan
#* print '-------------------Dynamo DB Feature and Item Count-------------'
* def ItemCount =
    """
    function()
    {
        var ItemCount = Java.type('CA.utils.java.DynamoDBUtils');
        var ItCnt = new ItemCount();
        return ItCnt.Scan_GetTableItemCount(Param_TableName,Param_Atr1,Param_Atrvalue1);
    }
    """
* def temp = call ItemCount
#* print '----------------Actual Item Count------------'+temp
#* print '---------------Expected Item Count-----------'+Param_ExpectedItemCount
* assert temp == Param_ExpectedItemCount


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
#* print '-------------------Dynamo DB Get Item-------------'
* def ItemCount =
    """
    function()
    {
        var ItemCount = Java.type('CA.utils.java.DynamoDBUtils');
        var ItCnt = new ItemCount();
         return ItCnt.getitem_PartionKey_SortKey(Param_TableName,Param_PartitionKey,Param_SortKey,ParamPartionKeyVal,ParamSortKeyVal);
    }
    """
* def QueryJson = get[0] call ItemCount
* def ActualTechMetaData = get[0] QueryJson.technicalMetadata
* assert ActualTechMetaData == Param_TechMetaData
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
        return ItCnt.Scan_DB_GetSingleItem(Param_TableName,Param_ScanAttr,Param_ScanVal,'');
    }
    """
* def QueryJson = call ItemCount
* def ItemResponse = get[0] QueryJson
#* print '-------------ActualResponse-----------'+ItemResponse
#* print '-------------ExpectedResponse-----------'+QueryJsonExpected
#* match ItemResponse contains '#(QueryJsonExpected)'
#* match ItemResponse contains Param_Expected_VideoUpdates
#* match ItemResponse contains Param_Expected_Item_AspectRatio_TemplateID
* match ItemResponse contains Param_Expected_TimelineItems
* match ItemResponse contains Param_Expected_Status
#* match QueryJsonExpected contains ItemResponse



@WaitUntilDBUpdate
Scenario: Wait for DB Update
#* print '-------------------WaitUntilDBUpdate-------------'
* def ItemCount =
    """
    function()
    {
        var ItemCount = Java.type('CA.utils.java.DynamoDBUtils');
        var ItCnt = new ItemCount();
        ItCnt.WaitforDBUpdate();
    }
    """
* def QueryJson = call ItemCount



