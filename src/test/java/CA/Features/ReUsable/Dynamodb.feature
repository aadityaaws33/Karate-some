Feature: Dynamo DB Related Features

@TruncateTable
Scenario: Truncate Table
* print '-------------------Dynamo DB Feature and Truncate Table Scenario-------------'
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

@ItemCount
Scenario: Get Item Count of Table
* print '-------------------Dynamo DB Feature and Item Count-------------'
* def TruncateTable =
    """
    function()
    {
        var ItemCount = Java.type('CA.utils.java.DynamoDBUtils');
        var ItCnt = new ItemCount();
        return ItCnt.GetTableItemCount(Param_TableName,Param_PrimaryKey);
    }
    """
* def temp = call TruncateTable
