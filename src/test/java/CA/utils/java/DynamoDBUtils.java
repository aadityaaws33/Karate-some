package CA.utils.java;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
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
import com.amazonaws.services.dynamodbv2.document.api.GetItemApi;
import com.amazonaws.services.dynamodbv2.document.internal.IteratorSupport;
import com.amazonaws.services.dynamodbv2.document.spec.QuerySpec;
import com.amazonaws.services.dynamodbv2.document.spec.ScanSpec;
import com.amazonaws.services.dynamodbv2.document.utils.ValueMap;
import com.amazonaws.services.dynamodbv2.model.AttributeValue;
import com.amazonaws.services.dynamodbv2.model.GetItemRequest;
import com.amazonaws.services.dynamodbv2.model.GetItemResult;
import com.amazonaws.services.dynamodbv2.model.ScanRequest;
import com.amazonaws.services.dynamodbv2.model.ScanResult;
import com.amazonaws.services.s3.model.JSONOutput;
import com.google.gson.JsonObject;
import com.intuit.karate.Json;

import org.junit.Assert;


public class DynamoDBUtils {

    //public static void main(final String[] args) {
        //List<String> resultlist = new ArrayList<>();
        //Scan_DB("CA_MAM_ASSETS_INFO_EU-qa","d03eedd4-e345-11ea-9814-0a580a3f06a0","6be501e6-890b-11ea-958b-0a580a3c10cd|4cf68d80-890c-11ea-bdcd-0a580a3c35b3");
        // Query_DB("CA_MAM_ASSETS_INFO_EU-qa","d03eedd4-e345-11ea-9814-0a580a3f06a0","6be501e6-890b-11ea-958b-0a580a3c10cd|4cf68d80-890c-11ea-bdcd-0a580a3c35b3");
        //TruncateTable("CA_WOCHIT_MAPPING_EU-qa","ID");
        //TruncateTable("CA_WOCHIT_RENDITIONS_EU-qa","ID");
       // GetTableItemCount_Old("CA_MAM_ASSETS_INFO_EU-qa","d03eedd4-e345-11ea-9814-0a580a3f06a0","6be501e6-890b-11ea-958b-0a580a3c10cd|4cf68d80-890c-11ea-bdcd-0a580a3c35b3");
     // int Count = Scan_GetTableItemCount("CA_WOCHIT_MAPPING_EU-qa", "Single", "ID", "", "", "");
      //System.out.println("---------Count---------"+Count);
     //Query_GetTableItemCount("CA_WOCHIT_MAPPING_EU-qa","ID");
      //System.out.println("---------Count---------"+Count);
      
       //System.out.println(getitem("CA_MAM_ASSETS_INFO_EU-qa", "assetId",""));
       //resultlist = getitem("CA_MAM_ASSETS_INFO_EU-qa");
       //System.out.println("Size of list in main--------"+ resultlist.size());
       //System.out.println("Value of list in main -------"+ resultlist.get(0));
       
    //}

   

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

   public int Query_GetTableItemCount(String TableName, String KeyType, String AtrName1, String AtrName2,
           String AtrVal1, String AtrVal2) {
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

       if (KeyType.contentEquals("Single")) {
           nameMap.put("#atr1", AtrName1);
           valueMap.put(":atrv1", AtrVal1);
           querySpec = new QuerySpec().withKeyConditionExpression("#atr1 = :atrv1").withNameMap(nameMap)
                   .withValueMap(valueMap);

       } else {
           nameMap.put("#atr1", AtrName1);
           nameMap.put("#atr2", AtrName2);
           valueMap.put(":atrv1", AtrVal1);
           valueMap.put(":atrv2", AtrVal2);
           querySpec = new QuerySpec().withKeyConditionExpression("#atr1 = :atrv1 AND #atr2 = :atrv2")
                   .withNameMap(nameMap).withValueMap(valueMap);
       }
       try {
           items = table.query(querySpec);
           iterator = items.iterator();
           while (iterator.hasNext()) {
               item = iterator.next();
               // System.out.println(item.toJSONPretty());
               // System.out.println("------------------While Loop Ends------------");

           }
       } catch (final Exception e) {
           System.err.println("Unable to Query the table:");
           System.err.println(e.getMessage());
       }
       // System.out.println("---------Get Query Count----------
       // "+items.getAccumulatedItemCount());

       return items.getAccumulatedItemCount();
   }

   public int Scan_GetTableItemCount(String TableName, String AtrName1, String AtrVal1) {
       AmazonDynamoDB client = AmazonDynamoDBClientBuilder.standard().withRegion("eu-west-1").build();
       DynamoDB dynamoDB = new DynamoDB(client);
       Table table = dynamoDB.getTable(TableName);
       HashMap<String, String> nameMap = new HashMap<String, String>();
       HashMap<String, Object> valueMap = new HashMap<String, Object>();
       nameMap.put("#atr1", AtrName1);
       valueMap.put(":atrv1", AtrVal1);

       ScanSpec scanSpec = new ScanSpec().withFilterExpression("#atr1 = :atrv1").withNameMap(nameMap)
               .withValueMap(valueMap);

       ItemCollection<ScanOutcome> items = null;
       Iterator<Item> iter = null;
       Item item = null;

       try {
           items = table.scan(scanSpec);
           // System.out.println("-------Get Max Result Size---------"+
           // items.getMaxResultSize() );
           iter = items.iterator();
           while (iter.hasNext()) {
               item = iter.next();
               // System.out.println(item.toJSONPretty());
               // System.out.println("------------------While Loop Ends------------");

           }

       } catch (final Exception e) {
           System.err.println("Unable to scan the table:");
           System.err.println(e.getMessage());
       }

       // System.out.println("--------------Size of Scan---------" +
       // items.getAccumulatedItemCount());
       return items.getAccumulatedItemCount();

   }

   public void Scan_ValidateItem(String TableName, String AtrName1, String AtrVal1, String ExpectedText) {
       System.out.println("-------------Inside Scan_ValidateItem----------");
       AmazonDynamoDB client = AmazonDynamoDBClientBuilder.standard().withRegion("eu-west-1").build();
       DynamoDB dynamoDB = new DynamoDB(client);

       Table table = dynamoDB.getTable(TableName);

       HashMap<String, String> nameMap = new HashMap<String, String>();
       HashMap<String, Object> valueMap = new HashMap<String, Object>();
       nameMap.put("#atr1", AtrName1);
       valueMap.put(":atrv1", AtrVal1);

       ScanSpec scanSpec = new ScanSpec().withFilterExpression("#atr1 = :atrv1").withNameMap(nameMap)
               .withValueMap(valueMap);
       ItemCollection<ScanOutcome> items = null;
       Iterator<Item> iter = null;
       Item item = null;

       try {
           items = table.scan(scanSpec);
           // System.out.println("-------Get Max Result Size---------"+
           // items.getMaxResultSize() );
           iter = items.iterator();

           while (iter.hasNext()) {

               item = iter.next();
               System.out.println("-------------Printing Item-----------");
               System.out.println("-------------Printing Tech metadata Value--------" + item.toString().substring(
                       item.toString().indexOf("technicalMetadata") + 19, item.toString().indexOf("modifiedAt") - 2));
               Assert.assertEquals(ExpectedText, item.toString().substring(
                       item.toString().indexOf("technicalMetadata") + 19, item.toString().indexOf("modifiedAt") - 2));
               // System.out.println("-------Expected Tech Meta Data from Json--------"+
               // item.toString().substring(item.toString().indexOf("technicalMetadata")+19,
               // item.toString().length()));
               // System.out.println("-------Actual Tech Meta Data from Json--------"+
               // ExpectedText);
               // Assert.assertTrue("Contains Expected Value",
               // item.toString().substring(item.toString().indexOf("technicalMetadata")+4,
               // item.toString().length()).contains(ExpectedText));
               // System.out.println();
               System.out.println("-------------End of Printing Item-----------");
               // System.out.println("------------------While Loop Ends------------");

           }

       } catch (final Exception e) {
           System.err.println("Unable to scan the table:");
           System.err.println(e.getMessage());
       }

       // System.out.println("--------------Size of Scan---------" +
       // items.getAccumulatedItemCount());
       // return items.getAccumulatedItemCount();
   }

   public List<String> getitem(String TableName)
    {

        List<String> moviesJsonList = new ArrayList<>();
         AmazonDynamoDB client = AmazonDynamoDBClientBuilder.standard().withRegion("eu-west-1").build();
         DynamoDB dynamoDB = new DynamoDB(client);
        Table table = dynamoDB.getTable(TableName);
        String result = "";

        //String replyId = forumName + "#" + threadSubject;

        QuerySpec spec = new QuerySpec().withKeyConditionExpression("assetId = :a_id AND compositeViewsId = :c_id")
            .withValueMap(new ValueMap().withString(":a_id", "d03eedd4-e345-11ea-9814-0a580a3f06a0").withString(":c_id", "e1706402-934f-11ea-b2e1-0a580a3cb9b9|a86a5f8c-c5ae-11ea-8c30-0a580a3ebc6b"));

            IteratorSupport<Item, QueryOutcome> iterator = table.query(spec).iterator();
            while (iterator.hasNext()) {
                Item movieItem = iterator.next();
                //System.out.println("MAM Asset Info ====================>" + movieItem.toJSONPretty());
                //moviesJsonList.add(movieItem.toJSONPretty());
                moviesJsonList.add(movieItem.toJSONPretty());
            }
            return moviesJsonList;
    }

}