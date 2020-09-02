package CA.utils.java;

import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

import com.amazonaws.services.dynamodbv2.AmazonDynamoDB;
import com.amazonaws.services.dynamodbv2.AmazonDynamoDBClientBuilder;
import com.amazonaws.services.dynamodbv2.document.DynamoDB;
import com.amazonaws.services.dynamodbv2.document.Item;
import com.amazonaws.services.dynamodbv2.document.ItemCollection;
import com.amazonaws.services.dynamodbv2.document.PrimaryKey;
import com.amazonaws.services.dynamodbv2.document.QueryOutcome;
import com.amazonaws.services.dynamodbv2.document.ScanOutcome;
import com.amazonaws.services.dynamodbv2.document.Table;
import com.amazonaws.services.dynamodbv2.document.spec.QuerySpec;
import com.amazonaws.services.dynamodbv2.document.spec.ScanSpec;
import com.amazonaws.services.dynamodbv2.document.utils.ValueMap;
import com.amazonaws.services.dynamodbv2.model.AttributeValue;
import com.amazonaws.services.dynamodbv2.model.ScanRequest;
import com.amazonaws.services.dynamodbv2.model.ScanResult;


public class DynamoDBUtils {

    public static void main(final String[] args) {
        //Scan_DB("CA_MAM_ASSETS_INFO_EU-qa","d03eedd4-e345-11ea-9814-0a580a3f06a0","6be501e6-890b-11ea-958b-0a580a3c10cd|4cf68d80-890c-11ea-bdcd-0a580a3c35b3");
        // Query_DB("CA_MAM_ASSETS_INFO_EU-qa","d03eedd4-e345-11ea-9814-0a580a3f06a0","6be501e6-890b-11ea-958b-0a580a3c10cd|4cf68d80-890c-11ea-bdcd-0a580a3c35b3");
        //TruncateTable("CA_WOCHIT_MAPPING_EU-qa","ID");
        //TruncateTable("CA_WOCHIT_RENDITIONS_EU-qa","ID");
       // GetTableItemCount_Old("CA_MAM_ASSETS_INFO_EU-qa","d03eedd4-e345-11ea-9814-0a580a3f06a0","6be501e6-890b-11ea-958b-0a580a3c10cd|4cf68d80-890c-11ea-bdcd-0a580a3c35b3");
     // int Count = Scan_GetTableItemCount("CA_WOCHIT_MAPPING_EU-qa", "Single", "ID", "", "", "");
      //System.out.println("---------Count---------"+Count);
       Query_GetTableItemCount("CA_WOCHIT_MAPPING_EU-qa","ID");
      //System.out.println("---------Count---------"+Count);

  }

  public static void Call_DB_old() {
      final AmazonDynamoDB client = AmazonDynamoDBClientBuilder.standard().withRegion("eu-west-1").build();
      final ScanRequest scanRequest = new ScanRequest().withTableName("CA_MAM_ASSETS_INFO_EU-qa")
              .withFilterExpression("assetId > : d03eedd4-e345-11ea-9814-0a580a3f06a0");
      final ScanResult result = client.scan(scanRequest);
      for (final Map<String, AttributeValue> item : result.getItems()) {
          System.out.println(item);
      }
  }

  public static void Scan_DB(String TableName, String AssetID, String CompositeViewsID) {
      AmazonDynamoDB client = AmazonDynamoDBClientBuilder.standard().withRegion("eu-west-1").build();
      DynamoDB dynamoDB = new DynamoDB(client);
      Table table = dynamoDB.getTable(TableName);
      ScanSpec scanSpec = new ScanSpec().withFilterExpression("assetId = :aid AND compositeViewsId = :cid")
              .withValueMap(new ValueMap().withString(":aid", AssetID).withString(":cid", CompositeViewsID));

      ItemCollection<ScanOutcome> items = null;
      Iterator<Item> iter = null;
      Item item = null;

      try {
          items = table.scan(scanSpec);
          iter = items.iterator();
          while (iter.hasNext()) {
              item = iter.next();
              System.out.println(item.toJSONPretty());
              System.out.println("------------------While Loop Ends------------");

          }

      } catch (final Exception e) {
          System.err.println("Unable to scan the table:");
          System.err.println(e.getMessage());
      }

      System.out.println("--------------Size of Scan---------" + items.getAccumulatedItemCount());

  }

  public static void Query_DB(String TableName, String AssetID, String CompositeViewsID) {
      AmazonDynamoDB client = AmazonDynamoDBClientBuilder.standard().withRegion("eu-west-1").build();
      DynamoDB dynamoDB = new DynamoDB(client);
      Table table = dynamoDB.getTable(TableName);
      HashMap<String, String> nameMap = new HashMap<String, String>();
      nameMap.put("#aid", "assetId");
      nameMap.put("#cid", "compositeViewsId");

      HashMap<String, Object> valueMap = new HashMap<String, Object>();
      valueMap.put(":aid", AssetID);
      valueMap.put(":cid", CompositeViewsID);

      QuerySpec querySpec = new QuerySpec().withKeyConditionExpression("#aid = :aid AND #cid = :cid")
              .withNameMap(nameMap).withValueMap(valueMap);

      ItemCollection<QueryOutcome> items = null;
      Iterator<Item> iterator = null;
      Item item = null;

      try {
          System.out.println("Result Set");
          items = table.query(querySpec);

          iterator = items.iterator();
          while (iterator.hasNext()) {
              item = iterator.next();
              // System.out.println(item.toJSONPretty());
              // System.out.println("----------End Loop--------");
          }

      } catch (Exception e) {
          System.err.println("Unable to query movies from 1985");
          System.err.println(e.getMessage());
      }
      System.out.println("---------Get Query Count---------- " + items.getAccumulatedItemCount());

  }

  public void TruncateTable(String TableName, String hashKeyName) {
      AmazonDynamoDB client = AmazonDynamoDBClientBuilder.standard().withRegion("eu-west-1").build();
      DynamoDB dynamoDB = new DynamoDB(client);
      Table table = dynamoDB.getTable(TableName);
      ScanSpec scanSpec = new ScanSpec();
      ItemCollection<ScanOutcome> items = table.scan(scanSpec);
      Iterator<Item> it = items.iterator();
      while (it.hasNext()) {
          Item item = it.next();
          String hashKey = item.getString(hashKeyName);
          PrimaryKey key = new PrimaryKey(hashKeyName, hashKey);
          table.deleteItem(key);
          // System.out.printf("Deleted item with key", hashKey);
      }

  }

  public static void GetTableItemCount_Old(String TableName, String AssetID, String CompositeViewsID) {
      AmazonDynamoDB client = AmazonDynamoDBClientBuilder.standard().withRegion("eu-west-1").build();
      DynamoDB dynamoDB = new DynamoDB(client);
      Table table = dynamoDB.getTable(TableName);
      HashMap<String, String> nameMap = new HashMap<String, String>();
      nameMap.put("#aid", "assetId");
      nameMap.put("#cid", "compositeViewsId");

      HashMap<String, Object> valueMap = new HashMap<String, Object>();
      valueMap.put(":aid", AssetID);
      valueMap.put(":cid", CompositeViewsID);

      QuerySpec querySpec = new QuerySpec().withKeyConditionExpression("#aid = :aid AND #cid = :cid")
              .withNameMap(nameMap).withValueMap(valueMap);

      ItemCollection<QueryOutcome> items = null;
      Iterator<Item> iterator = null;
      Item item = null;
      items = table.query(querySpec);
      System.out.println("---------Get Query Count---------- " + items.getAccumulatedItemCount());

  }

  public int Scan_GetTableItemCount(String TableName, String KeyType, String AtrName1, String AtrName2,String AtrVal1, String AtrVal2)
    {
        System.out.println("---------Inside GetTableItemCount Function--------------");
        AmazonDynamoDB client = AmazonDynamoDBClientBuilder.standard().withRegion("eu-west-1").build();
        DynamoDB dynamoDB = new DynamoDB(client);
        Table table = dynamoDB.getTable(TableName);
        HashMap<String, String> nameMap = new HashMap<String, String>();
        HashMap<String, Object> valueMap = new HashMap<String, Object>();
        ItemCollection<QueryOutcome> items = null;
        Iterator<Item> iterator = null;
        Item item = null;
        QuerySpec querySpec = null;

        if(KeyType.contentEquals("Single"))
        {
            nameMap.put("#atr1", AtrName1);
            valueMap.put(":atrv1", AtrVal1);
             querySpec = new QuerySpec().withKeyConditionExpression("#atr1 = :atrv1").withNameMap(nameMap)
            .withValueMap(valueMap);

        }
        else
        {
            nameMap.put("#atr1", AtrName1);
            nameMap.put("#atr2", AtrName2);

            valueMap.put(":atrv1", AtrVal1);
            valueMap.put(":atrv2", AtrVal2);

             querySpec = new QuerySpec().withKeyConditionExpression("#atr1 = :atrv1 AND #atr2 = :atrv2").withNameMap(nameMap)
            .withValueMap(valueMap);

        }
        try {
            items = table.query(querySpec);
            iterator = items.iterator();
          while (iterator.hasNext()) {
              item = iterator.next();
              //System.out.println(item.toJSONPretty());
              //System.out.println("------------------While Loop Ends------------");

          }
         
      } catch (final Exception e) {
          System.err.println("Unable to scan the table:");
          System.err.println(e.getMessage());
      }
            
            System.out.println("---------Get Query Count---------- "+items.getAccumulatedItemCount());

            return items.getAccumulatedItemCount();
    }

    public static void Query_GetTableItemCount(String TableName,String AtrName1)
    {
        AmazonDynamoDB client = AmazonDynamoDBClientBuilder.standard().withRegion("eu-west-1").build();
        DynamoDB dynamoDB = new DynamoDB(client);
        Table table = dynamoDB.getTable(TableName);
        System.out.println("-----------Describe Count Name---------"+ table.describe().toString());
        
        //return table.getit
    }

}