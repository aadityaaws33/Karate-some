package com.automation.ca.backend;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.TimeZone;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;

import com.amazonaws.ClientConfiguration;
import com.amazonaws.retry.PredefinedRetryPolicies;
import com.amazonaws.services.dynamodbv2.AmazonDynamoDB;
import com.amazonaws.services.dynamodbv2.AmazonDynamoDBClientBuilder;
import com.amazonaws.services.dynamodbv2.document.DynamoDB;
import com.amazonaws.services.dynamodbv2.document.Item;
import com.amazonaws.services.dynamodbv2.document.ItemCollection;
import com.amazonaws.services.dynamodbv2.document.PrimaryKey;
import com.amazonaws.services.dynamodbv2.document.QueryOutcome;
import com.amazonaws.services.dynamodbv2.document.ScanOutcome;
import com.amazonaws.services.dynamodbv2.document.Table;
import com.amazonaws.services.dynamodbv2.document.internal.IteratorSupport;
import com.amazonaws.services.dynamodbv2.document.spec.QuerySpec;
import com.amazonaws.services.dynamodbv2.document.spec.ScanSpec;
import com.amazonaws.services.dynamodbv2.document.spec.DeleteItemSpec;
import com.amazonaws.services.dynamodbv2.document.utils.ValueMap;
import com.amazonaws.services.dynamodbv2.model.AttributeValue;
import com.amazonaws.services.dynamodbv2.model.ScanRequest;
import com.amazonaws.services.dynamodbv2.model.ScanResult;
import com.amazonaws.services.dynamodbv2.model.TableDescription;
import com.amazonaws.services.dynamodbv2.document.Index;
import com.amazonaws.services.dynamodbv2.document.DeleteItemOutcome;

import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;
//import org.graalvm.compiler.core.common.SpeculativeExecutionAttacksMitigations_OptionDescriptors;
import org.junit.Assert;

public class DynamoDBUtils {

    // String region = System.getProperty("karate.region");
    public AmazonDynamoDB client;
    public Table table;
    public DynamoDB dynamoDB;
    public Index index;

    public void shutdown() {
        dynamoDB.shutdown();
    }

    /**
     * Creates a ClientConfiguration object for DynamoDB
     * 
     * @return ClientConfiguration object
     */
    private static ClientConfiguration createDynamoDBClientConfiguration() {
        int connectionTimeout = GlobalUtilsConfig.connectionTimeout;
        int clientExecutionTimeout = GlobalUtilsConfig.clientExecutionTimeout;
        int requestTimeout = GlobalUtilsConfig.requestTimeout;
        int socketTimeout = GlobalUtilsConfig.socketTimeout;
        int maxErrorRetries = GlobalUtilsConfig.maxErrorRetries;
        int maxConnections = GlobalUtilsConfig.maxConnections;

        ClientConfiguration clientConfiguration = new ClientConfiguration().withConnectionTimeout(connectionTimeout)
                .withClientExecutionTimeout(clientExecutionTimeout).withRequestTimeout(requestTimeout)
                .withSocketTimeout(socketTimeout).withMaxConnections(maxConnections).withRetryPolicy(
                        PredefinedRetryPolicies.getDynamoDBDefaultRetryPolicyWithCustomMaxRetries(maxErrorRetries));

        // ClientConfiguration.getClientConfiguration(clientConfiguration);

        return clientConfiguration;
    }

    public DynamoDBUtils(String region) {
        dynamoDB = initObject(region);
    }

    public DynamoDB initObject(String region) {
        if (region.contentEquals("Nordic")) {
            client = AmazonDynamoDBClientBuilder.standard().withRegion("eu-west-1")
                    .withClientConfiguration(createDynamoDBClientConfiguration()).build();
        } else if (region.contentEquals("APAC")) {
            client = AmazonDynamoDBClientBuilder.standard().withRegion("ap-southeast-1")
                    .withClientConfiguration(createDynamoDBClientConfiguration()).build();
        }
        return new DynamoDB(client);
    }

    

    // /**
    //  * Delete an Item from a Table
    //  *
    //  * @param TableName                     The dynamoDB table name to be queried
    //  * @param PrimaryPartitionKeyName       The Primary Partition Key
    //  * @param PrimaryPartitionKeyValue      The Value of the Primary Partition Key
    //  * 
    //  * @return Success/Failure message
    //  */
    // public String Delete_Item(String TableName, String PrimaryPartitionKeyName, String PrimaryPartitionKeyValue) {
    //     String result = "Successfully deleted " + PrimaryPartitionKeyValue + " from " + TableName;
    //     try {
    //         table = dynamoDB.getTable(TableName);
    //         // DeleteItemSpec deleteItemSpec = new DeleteItemSpec()
    //         //                                 .withPrimaryKey(new PrimaryKey(PrimaryPartitionKeyName, PrimaryPartitionKeyValue));

    //         // String infoExpression = Query_FormExpression("#attr", ":val", "=");
    //         // HashMap<String, String> attrMap = new HashMap<String, String>();
    //         // HashMap<String, Object> valueMap = new HashMap<String, Object>();
          
    //         // attrMap.put("#attr", PrimaryPartitionKeyName);
    //         // valueMap.put(":val", PrimaryPartitionKeyValue);
            
    //         // System.out.println("INFOEXPRESSION: " + infoExpression.toString());
    //         // System.out.println("ATTR MAP: " + attrMap.toString());
    //         // System.out.println("VAL MAP: " + valueMap.toString());
            

    //         // DeleteItemSpec deleteItemSpec = new DeleteItemSpec()
    //         //                                 .withConditionExpression(infoExpression)
    //         //                                 .withNameMap(attrMap)
    //         //                                 .withValueMap(valueMap);

    //         if (attributeType.contains("key")) {
    //             keyNameMap.put(attributeNameAlias, attributeName);
    //             keyValueMap.put(attributeValueAlias, attributeValue);
    //             if (!keyConditionExpression.isEmpty()) {
    //                 keyConditionExpression += " AND ";
    //             }
    //             ;
    //             keyConditionExpression += infoExpression;
    //         } else if (attributeType.contains("filter")) {
    //             filterNameMap.put(attributeNameAlias, attributeName);
    //             filterValueMap.put(attributeValueAlias, attributeValue);
    //             if (!filterExpression.isEmpty()) {
    //                 filterExpression += " AND ";
    //             }
    //             ;
    //             filterExpression += infoExpression;
    //         }

    //         DeleteItemSpec deleteItemSpec = DeleteItemSpec()
    //         result = table.deleteItem(deleteItemSpec).toString();
    //     } catch (Exception e) {
    //         result = "Failed to delete " + PrimaryPartitionKeyValue + " from " + TableName + ": " + e.getMessage();
    //     }
    //     return result;
    // }

    /**
     * Returns an integer which denotes the number of items as a result of a query
     *
     * @param TableName            The dynamoDB table name to be queried
     * @param QueryAttributeMapList     A List of HashMaps that contain information to
     *                             form the query expression [ { attributeName:
     *                             <PartitionKey/SortKey/FilterKey>, attributeValue:
     *                             <Value>, attributeComparator: <Comparator>, attributeType:
     *                             <key/filter> }, ... ]
     * @param GlobalSecondaryIndex The GSI, if any
     * 
     * @return Number of items resulting from the query
     */
    public int Query_GetTableItemCount(String TableName, List<HashMap<String, String>> QueryAttributeMapList,
            String GlobalSecondaryIndex) {
        return Query_GetItems(TableName, QueryAttributeMapList, GlobalSecondaryIndex).size();
    }

    /**
     * Returns a String which contains an Expression used for a dynamoDB QuerySpec
     *
     * @param attributeNameAlias  The alias used for a name in the expression
     * @param attributeValueAlias The alias used for a value in the expression
     * @param attributeComparator The comparison to be used in the expression
     * @return The full string expression
     */
    public String Form_Expression_String(String attributeNameAlias, String attributeValueAlias, String attributeComparator) {

        String conditionExpression = "";
        if (attributeComparator.contains("contains")) {
            conditionExpression = "contains(" + attributeNameAlias + ", " + attributeValueAlias + ")";
        } else if (attributeComparator.contains("begins")) {
            conditionExpression = "begins_with(" + attributeNameAlias + ", " + attributeValueAlias + ")";
        } else if (attributeComparator.contains("notexists")) {
            conditionExpression = "attribute_not_exists(" + attributeNameAlias + ")";
        } else {
            conditionExpression = attributeNameAlias + " " + attributeComparator + " " + attributeValueAlias;
        }

        return conditionExpression;
    }

    /**
     * Returns a HashMap which contains *Expressions and the Key Name Map and Key Value Map
     *
     * @param QueryAttributeMapList  The list of Attribute Maps
     *
     * @return The full Expression Parameters
     */
    public HashMap<String, Object> Form_Expression_Parameters(List<HashMap<String, String>> QueryAttributeMapList) {
        HashMap<String, String> keyNameMap = new HashMap<String, String>();
        HashMap<String, Object> keyValueMap = new HashMap<String, Object>();
        HashMap<String, String> filterNameMap = new HashMap<String, String>();
        HashMap<String, Object> filterValueMap = new HashMap<String, Object>();

        String keyConditionExpression = ""; // attributeType: key
        String filterExpression = ""; // attributeType: filter

        for (int i = 0; i < QueryAttributeMapList.size(); i++) {
            HashMap<String, String> QueryAttributeMap = (HashMap<String, String>) QueryAttributeMapList.get(i);
            String attributeName = QueryAttributeMap.get("attributeName");
            String attributeValue = QueryAttributeMap.get("attributeValue");
            String attributeComparator = QueryAttributeMap.get("attributeComparator");
            String attributeType = QueryAttributeMap.get("attributeType");
            String attributeNameAlias = "#attr" + (i + 1);
            String attributeValueAlias = ":attrv" + (i + 1);

            String infoExpression = Form_Expression_String(attributeNameAlias, attributeValueAlias, attributeComparator);

            if (attributeType.contains("key")) {
                keyNameMap.put(attributeNameAlias, attributeName);
                keyValueMap.put(attributeValueAlias, attributeValue);
                if (!keyConditionExpression.isEmpty()) {
                    keyConditionExpression += " AND ";
                }
                ;
                keyConditionExpression += infoExpression;
            } else if (attributeType.contains("filter")) {
                filterNameMap.put(attributeNameAlias, attributeName);
                filterValueMap.put(attributeValueAlias, attributeValue);
                if (!filterExpression.isEmpty()) {
                    filterExpression += " AND ";
                }
                ;
                filterExpression += infoExpression;
            }
        }

        final HashMap<String, Object> formedExpressions = new HashMap<String, Object>();
        
        formedExpressions.put("keyConditionExpression", keyConditionExpression);
        formedExpressions.put("keyNameMap", keyNameMap);
        formedExpressions.put("keyValueMap", keyValueMap);

        if(!filterExpression.isBlank()) {
            formedExpressions.put("filterExpression", filterExpression);
            formedExpressions.put("filterNameMap", filterNameMap);
            formedExpressions.put("filterValueMap", filterValueMap);
        }

        return formedExpressions;
        
    }

    /**
     * Returns a list of JSON strings which denotes the results of a query
     * expression
     *
     * @param TableName            The dynamoDB table name to be queried
     * @param QueryAttributeMapList     A List of HashMaps that contain information to
     *                             form the query expression [ { attributeName:
     *                             <PartitionKey/SortKey/FilterKey>, attributeValue:
     *                             <Value>, attributeComparator: <Comparator>, attributeType:
     *                             <key/filter> }, ... ]
     * @param GlobalSecondaryIndex The GSI, if any
     * @return JSON strings resulting from a query
    */
    public String Delete_Items(String TableName, List<HashMap<String, String>> QueryAttributeMapList) {
        String msg = "Successfully deleted.";

        table = dynamoDB.getTable(TableName);     
        
        PrimaryKey thisPrimaryKey = new PrimaryKey();
        for (int i = 0; i < QueryAttributeMapList.size(); i++) {
            HashMap<String, String> QueryAttributeMap = (HashMap<String, String>) QueryAttributeMapList.get(i);
            String attributeName = QueryAttributeMap.get("attributeName");
            String attributeValue = QueryAttributeMap.get("attributeValue");

            thisPrimaryKey.addComponent(attributeName, attributeValue);
        }
        
        // Create Delete Spec
        DeleteItemSpec deleteSpec = new DeleteItemSpec().withPrimaryKey(thisPrimaryKey);

        try {
            table.deleteItem(deleteSpec);
        } catch (final Exception e) {
            System.err.println("Unable to Delete item from the table:");
            System.err.println(e.getMessage());
            msg = e.getMessage();
        }

        // System.out.println(getitemJsonList);
        return msg;
    }

    /**
     * Returns a list of JSON strings which denotes the results of a query
     * expression
     *
     * @param TableName            The dynamoDB table name to be queried
     * @param QueryAttributeMapList     A List of HashMaps that contain information to
     *                             form the query expression [ { attributeName:
     *                             <PartitionKey/SortKey/FilterKey>, attributeValue:
     *                             <Value>, attributeComparator: <Comparator>, attributeType:
     *                             <key/filter> }, ... ]
     * @param GlobalSecondaryIndex The GSI, if any
     * @return JSON strings resulting from a query
     */
    public List<String> Query_GetItems(String TableName, List<HashMap<String, String>> QueryAttributeMapList,
            String GlobalSecondaryIndex) {
        List<String> getitemJsonList = new ArrayList<>();
        ItemCollection<QueryOutcome> items = null;
        Iterator<Item> iterator = null;   

        table = dynamoDB.getTable(TableName);
        if (!GlobalSecondaryIndex.isEmpty()) {
            index = table.getIndex(GlobalSecondaryIndex);
        }

        HashMap<String, Object> formedExpressions = Form_Expression_Parameters(QueryAttributeMapList);
        HashMap<String, String> keyNameMap = (HashMap<String, String>) formedExpressions.get("keyNameMap"); //new HashMap<String, String>();
        HashMap<String, Object> keyValueMap = (HashMap<String, Object>) formedExpressions.get("keyValueMap"); //new HashMap<String, Object>();
        HashMap<String, String> filterNameMap = (HashMap<String, String>) formedExpressions.get("filterNameMap"); //new HashMap<String, String>();
        HashMap<String, Object> filterValueMap = (HashMap<String, Object>) formedExpressions.get("filterValueMap"); //new HashMap<String, Object>();
        String keyConditionExpression = formedExpressions.get("keyConditionExpression").toString(); // attributeType: key
        String filterExpression = formedExpressions.get("filterExpression").toString(); // attributeType: filter

        // Create Query Spec
        QuerySpec querySpec = new QuerySpec();
        if (!keyConditionExpression.isEmpty()) {
            querySpec.withKeyConditionExpression(keyConditionExpression).withNameMap(keyNameMap)
                    .withValueMap(keyValueMap);
        }
        if (!filterExpression.isEmpty()) {
            // Fuse key Maps with filter Maps
            filterNameMap.putAll(keyNameMap);
            filterValueMap.putAll(keyValueMap);
            querySpec.withFilterExpression(filterExpression).withNameMap(filterNameMap).withValueMap(filterValueMap);
        }
        try {
            if (!GlobalSecondaryIndex.isEmpty()) {
                items = index.query(querySpec);
            } else {
                items = table.query(querySpec);
            }
            iterator = items.iterator();
            while (iterator.hasNext()) {
                // item = iterator.next();
                Item movieItem = iterator.next();
                getitemJsonList.add(movieItem.toJSON());
            }
        } catch (final Exception e) {
            System.err.println("Unable to Query the table:");
            System.err.println(e.getMessage());
            getitemJsonList.add(e.getMessage());
        }

        // System.out.println(getitemJsonList);
        return getitemJsonList;
    }

    // USED
    public List<String> getitem_PartionKey_SortKey(String TableName, String PartKey, String SortKey, String PartkeyVal,
            String SortKeyVal) {

        List<String> getitemJsonList = new ArrayList<>();
        table = dynamoDB.getTable(TableName);
        String result = "";

        // String replyId = forumName + "#" + threadSubject;

        QuerySpec spec = new QuerySpec().withKeyConditionExpression(PartKey + " = :p_id AND " + SortKey + " = :s_id")
                .withValueMap(new ValueMap().withString(":p_id", PartkeyVal).withString(":s_id", SortKeyVal));

        IteratorSupport<Item, QueryOutcome> iterator = table.query(spec).iterator();
        while (iterator.hasNext()) {
            Item movieItem = iterator.next();
            // System.out.println("MAM Asset Info ====================>" +
            // movieItem.toJSONPretty());
            // moviesJsonList.add(movieItem.toJSONPretty());
            getitemJsonList.add(movieItem.toJSON());
        }
        return getitemJsonList;
    }

    // USED
    public List<String> Scan_WochitRendition(String TableName, String AtrName1, String AtrVal1, String AtrName2,
            String AtrVal2) {
        List<String> getitemJsonList = new ArrayList<>();
        ScanSpec scanSpec = null;
        table = dynamoDB.getTable(TableName);
        HashMap<String, String> nameMap = new HashMap<String, String>();
        HashMap<String, Object> valueMap = new HashMap<String, Object>();
        nameMap.put("#atr1", AtrName1);
        nameMap.put("#atr2", AtrName2);
        valueMap.put(":atrv1", AtrVal1);
        valueMap.put(":atrv2", AtrVal2);

        if (AtrVal1.contentEquals("")) {
            scanSpec = new ScanSpec().withFilterExpression("contains(#atr1, :atrv1)").withNameMap(nameMap)
                    .withValueMap(valueMap);
        } else {
            scanSpec = new ScanSpec().withFilterExpression("contains(#atr1, :atrv1) AND contains(#atr2, :atrv2)")
                    .withNameMap(nameMap).withValueMap(valueMap);
        }

        // scanSpec = new ScanSpec().withFilterExpression("contains(#atr1,
        // :atrv1)").withFilterExpression("contains(atr2,
        // :atrv2)").withNameMap(nameMap).withValueMap(valueMap);
        // scanSpec = new ScanSpec().withFilterExpression("contains(#atr1,
        // :atrv1)").withNameMap(nameMap).withValueMap(valueMap);

        ItemCollection<ScanOutcome> items = null;
        Iterator<Item> iter = null;
        Item item = null;

        try {
            items = table.scan(scanSpec);
            // System.out.println("-------Get Max Result Size---------"+
            // items.getMaxResultSize() );
            iter = items.iterator();
            while (iter.hasNext()) {
                Item movieItem = iter.next();
                getitemJsonList.add(movieItem.toString());
                // item = iter.next();
                System.out.println("---------Value of Scan----------" + movieItem.toJSONPretty());
                // System.out.println("------------------While Loop Ends------------");

            }

        } catch (final Exception e) {
            System.err.println("Unable to scan the table:");
            System.err.println(e.getMessage());
            getitemJsonList.add(e.getMessage());
        }

        // System.out.println("--------------Size of Scan---------" +
        // items.getAccumulatedItemCount());
        return getitemJsonList;
    }

    // USED
    public List<String> Scan_DB_WochitRendition(String TableName, String AtrName1, String AtrVal1, String AtrName2,
            String AtrVal2) {
        // System.out.println("---------------1--------------");
        List<String> getitemJsonList = new ArrayList<>();
        ScanSpec scanSpec = null;
        table = dynamoDB.getTable(TableName);
        Map<String, Object> expressionAttributeValues = new HashMap<String, Object>();
        expressionAttributeValues.put(":x", AtrVal1);
        expressionAttributeValues.put(":y", AtrVal2);
        // scanSpec = new ScanSpec().withFilterExpression(AtrName1+" = :x AND
        // "+AtrName2+" = :y").withValueMap(expressionAttributeValues);
        scanSpec = new ScanSpec()
                .withFilterExpression("contains(" + AtrName1 + ", :x) AND contains(" + AtrName2 + ", :y)")
                .withValueMap(expressionAttributeValues);

        ItemCollection<ScanOutcome> items = null;
        Iterator<Item> iter = null;
        Item item = null;

        try {
            items = table.scan(scanSpec);
            // System.out.println("---------------3--------------");
            // System.out.println("-------Get Max Result Size---------"+
            // items.getMaxResultSize() );
            iter = items.iterator();
            while (iter.hasNext()) {
                Item movieItem = iter.next();
                getitemJsonList.add(movieItem.toJSON());
            }
        } catch (final Exception e) {
            System.err.println("Unable to scan the table:");
            System.err.println(e.getMessage());
            getitemJsonList.add(e.getMessage());
        }

        // System.out.println("--------------Size of Scan---------" +
        // items.getAccumulatedItemCount());
        return getitemJsonList;
    }

    // USED
    public List<String> Scan_DB_WochitMapping(String TableName, String AtrName1, String AtrVal1) {
        // System.out.println("---------------1--------------");
        List<String> getitemJsonList = new ArrayList<>();
        ScanSpec scanSpec = null;
        table = dynamoDB.getTable(TableName);
        Map<String, Object> expressionAttributeValues = new HashMap<String, Object>();
        expressionAttributeValues.put(":x", AtrVal1);
        // scanSpec = new ScanSpec().withFilterExpression(AtrName1+" =
        // :x").withValueMap(expressionAttributeValues);
        scanSpec = new ScanSpec().withFilterExpression("contains(" + AtrName1 + ", :x)")
                .withValueMap(expressionAttributeValues);
        ItemCollection<ScanOutcome> items = null;
        Iterator<Item> iter = null;
        Item item = null;

        try {
            items = table.scan(scanSpec);
            // System.out.println("---------------3--------------");
            // System.out.println("-------Get Max Result Size---------"+
            // items.getMaxResultSize() );
            iter = items.iterator();
            while (iter.hasNext()) {
                Item movieItem = iter.next();
                getitemJsonList.add(movieItem.toJSON());

            }

        } catch (final Exception e) {
            System.err.println("Unable to scan the table:");
            System.err.println(e.getMessage());
            getitemJsonList.add(e.getMessage());
        }

        // System.out.println("--------------Size of Scan---------" +
        // items.getAccumulatedItemCount());
        return getitemJsonList;
    }

    // USED
    public List<String> Scan_DB_WochitMapping_Working(String TableName, String ScanAttribute, String ScanValue,
            String ProjectionExp) {
        List<String> getitemJsonList = new ArrayList<>();
        ScanSpec scanSpec = null;
        table = dynamoDB.getTable(TableName);
        Map<String, Object> expressionAttributeValues = new HashMap<String, Object>();
        expressionAttributeValues.put(":x", ScanValue);
        scanSpec = new ScanSpec().withFilterExpression(ScanAttribute + " = :x").withValueMap(expressionAttributeValues);

        ItemCollection<ScanOutcome> items = null;
        Iterator<Item> iter = null;
        Item item = null;

        try {
            items = table.scan(scanSpec);
            // System.out.println("-------Get Max Result Size---------"+
            // items.getMaxResultSize() );
            iter = items.iterator();
            while (iter.hasNext()) {
                Item movieItem = iter.next();
                getitemJsonList.add(movieItem.toString());
                // item = iter.next();
                System.out.println("---------Value of Scan----------" + movieItem.toJSONPretty());
                // System.out.println("------------------While Loop Ends------------");

            }

        } catch (final Exception e) {
            System.err.println("Unable to scan the table:");
            System.err.println(e.getMessage());
            getitemJsonList.add(e.getMessage());
        }

        // System.out.println("--------------Size of Scan---------" +
        // items.getAccumulatedItemCount());
        return getitemJsonList;
    }

    // USED
    public List<String> Scan_GetTableItemCount(String TableName, String AtrName1, String AtrVal1, String Op) {
        List<String> getitemJsonList = new ArrayList<>();
        ScanSpec scanSpec = null;
        table = dynamoDB.getTable(TableName);

        HashMap<String, String> nameMap = new HashMap<String, String>();
        HashMap<String, Object> valueMap = new HashMap<String, Object>();
        nameMap.put("#atr1", AtrName1);
        valueMap.put(":atrv1", AtrVal1);

        Map<String, Object> expressionAttributeValues = new HashMap<String, Object>();
        expressionAttributeValues.put(":x", AtrVal1);
        if (Op.contentEquals("=")) {
            scanSpec = new ScanSpec().withFilterExpression(AtrName1 + " = :x").withValueMap(expressionAttributeValues);
        } else if (Op.contentEquals("containsforcount")) {
            scanSpec = new ScanSpec().withFilterExpression("contains(#atr1, :atrv1)").withNameMap(nameMap)
                    .withValueMap(valueMap);
            // scanSpec = new ScanSpec().withFilterExpression("contains("+AtrName1+",
            // :x)").withValueMap(expressionAttributeValues);
            // .withValueMap(valueMap);
        } else if (Op.contentEquals("contains")) {
            // scanSpec = new ScanSpec().withFilterExpression("contains(#atr1,
            // :atrv1)").withNameMap(nameMap).withValueMap(valueMap);
            scanSpec = new ScanSpec().withFilterExpression("contains(" + AtrName1 + ", :x)")
                    .withValueMap(expressionAttributeValues);
            // .withValueMap(valueMap);
        }

        ItemCollection<ScanOutcome> items = null;
        Iterator<Item> iter = null;
        Item item = null;

        try {
            items = table.scan(scanSpec);
            // System.out.println("-------Get Max Result Size---------"+
            // items.getMaxResultSize() );
            iter = items.iterator();
            while (iter.hasNext()) {
                Item movieItem = iter.next();
                getitemJsonList.add(movieItem.toString());
                // item = iter.next();
                System.out.println(movieItem.toJSONPretty());
                // System.out.println("------------------While Loop Ends------------");

            }
            System.out.println(getitemJsonList);
        } catch (final Exception e) {
            System.err.println("Unable to scan the table:");
            System.err.println(e.getMessage());
            getitemJsonList.add(e.getMessage());
        }

        // System.out.println("--------------Size of Scan---------" +
        // getitemJsonList.size());
        // items.getAccumulatedItemCount());
        return getitemJsonList;

    }

    // **********UNUSED FUNCTIONS ***********/

    // NOT USED
    // public int WaitforDBUpdate(String ScanAtr, String ScanVal) throws
    // InterruptedException
    // {
    // int itemCount =
    // Scan_GetTableItemCount("CA_WOCHIT_RENDITIONS_EU-qa",ScanAtr,ScanVal,"=");
    // int waitTime = 30000;
    // int maxRetries = 1;
    // int retries = 0;
    // while(retries < maxRetries & itemCount <= 0)
    // {
    // System.out.println("---------Intentional Wait for DB Update until item count
    // > 0---------");
    // Thread.sleep(waitTime);
    // retries++;
    // itemCount =
    // Scan_GetTableItemCount("CA_WOCHIT_RENDITIONS_EU-qa",ScanAtr,ScanVal,"=");
    // }
    // return itemCount;
    // }

    // NOT USED
    public List<String> Scan_DB_GetSingleItem(String TableName, String ScanAttribute, String ScanValue,
            String ProjectionExp) {
        ItemCollection<ScanOutcome> items = null;
        List<String> getitemJsonList = new ArrayList<>();
        Map<String, Object> expressionAttributeValues = new HashMap<String, Object>();
        expressionAttributeValues.put(":val", ScanValue);
        table = dynamoDB.getTable(TableName);
        if (ProjectionExp.length() > 0) {
            items = table.scan(ScanAttribute + " = :val", ProjectionExp, null, expressionAttributeValues);
        } else {
            items = table.scan(ScanAttribute + " = :val", null, null, expressionAttributeValues);
        }
        // ItemCollection<ScanOutcome> items = table.scan("renditionFileName =
        // :val","wochitRenditionStatus",null,expressionAttributeValues);
        // ItemCollection<ScanOutcome> items = table.scan(ScanAttribute+" =
        // :val",null,expressionAttributeValues);
        Iterator<Item> iterator = items.iterator();
        while (iterator.hasNext()) {
            Item movieItem = iterator.next();
            getitemJsonList.add(movieItem.toString());
            // getitemJsonList.add(movieItem.toString());
            // System.out.println(iterator.next().toJSONPretty());
        }

        return getitemJsonList;
    }

    // NOT USED
    public void TruncateTable(String TableName, String hashKeyName) {
        table = dynamoDB.getTable(TableName);
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

    // NOT USED
    public void Scan_ValidateItem(String TableName, String AtrName1, String AtrVal1, String ExpectedText) {
        // System.out.println("-------------Inside Scan_ValidateItem----------");
        table = dynamoDB.getTable(TableName);
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
                // System.out.println("-------------Printing Item-----------");
                // System.out.println("-------------Printing Tech metadata Value--------" +
                // item.toString().substring(
                // item.toString().indexOf("technicalMetadata") + 19,
                // item.toString().indexOf("modifiedAt") - 2));
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
                // System.out.println("-------------End of Printing Item-----------");
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

    // **************Backup Functions************ */

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
                // System.out.println("------------------While Loop Ends------------");

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
        // System.out.println("---------Get Query Count---------- " +
        // items.getAccumulatedItemCount());

    }

}