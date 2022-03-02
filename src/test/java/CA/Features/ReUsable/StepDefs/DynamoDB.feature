Feature: DynamoDB-related ReUsable/Methods functions.

Background:
  * def Pause = function(pause){ java.lang.Thread.sleep(pause) }
  * def initializeDynamoDBObject = 
    """
      function(thisAWSregion) {
        var dynamoDBUtilsClass = Java.type('com.automation.ca.backend.DynamoDBUtils');
        return new dynamoDBUtilsClass(thisAWSregion)
      }
    """
  * def dynamoDB = call initializeDynamoDBObject AWSRegion
  * configure afterScenario =
    """
      function() {
        dynamoDB.shutdown();
      }
    """

@FilterQueryResults
# Filter Results generated from @GetItemsViaQuery
# Parameters:
# {
#   Param_QueryResults: <Results from @GetItemsViaQuery>,
#   Param_FilterNestedInfoList: [
#     {
#       attributeName: <attribute to filter>,
#       attributeValue: <attribute value to filter>,
#       attributeComparator: <[contains | = ]>
#     }        
#   ]
# }
Scenario: Filter Results generated from Querying DynamoDB
  * def filterResults =
    """
      function()
      {
        for(var index in Param_FilterNestedInfoList) {
          var queryResults = [];
          var attributeName = Param_FilterNestedInfoList[index].attributeName;
          var attributeValue = Param_FilterNestedInfoList[index].attributeValue;
          var attributeComparator = Param_FilterNestedInfoList[index].attributeComparator;

          if(attributeName.contains('.')) {
            var infoFilter = attributeName.split('.').pop();
            attributeName = attributeName.replace('.' + infoFilter, '');
            var thisPath = "$." + attributeName + "[?(@." + infoFilter + " contains '" + attributeValue + "')]";
            karate.log(thisPath);
            for(var i in Param_QueryResults) {
              var filteredValue = karate.jsonPath(Param_QueryResults[i], thisPath);
              if(filteredValue.length > 0) {
                queryResults.push(Param_QueryResults[i]);
              }
            }
          } else {
            for(var i in Param_QueryResults) {
              karate.log(Param_QueryResults[i][attributeName]);
              if(!Param_QueryResults[i][attributeName]) {
                // karate.log(karate.pretty(Param_QueryResults[i]));
                karate.log(Param_QueryResults[i]);
                karate.fail('Empty key-value pair! Key: ' + attributeName + ' has value: ' + Param_QueryResults[i][attributeName]);
              }
              if(Param_QueryResults[i][attributeName].contains(attributeValue)) {
                queryResults.push(Param_QueryResults[i]);
              }
            }
          }
          Param_QueryResults = queryResults;    
          if(queryResults.length < 1)  {
            // karate.log('No results found for ' + karate.pretty(Param_FilterNestedInfoList));
            break;
          }      
        }

        return queryResults;
      }
    """
  * def result = call filterResults
  # * print result

@GetItemsViaQuery
# Get DynamoDB Item(s) via Query
# Parameters:
# {
#   Param_TableName: <Tablename>,
#   Param_QueryAttributeList: [
#       {
#           attributeName: <attribute to filter>,
#           attributeValue: <attribute value to filter>,
#           attributeComparator: <['contains' | '=']>,
#           attributeType: <'key' | 'filter'>
#       }
#   ],
#   Param_GlobalSecondaryIndex: <Table GSI>,
#   AWSRegion: <AWS Region: 'Nordics' | 'APAC'>,
#   Retries: <number of retries>,
#   RetryDuration: <time between retries in milliseconds>
# }
Scenario: Get DynamoDB Item(s) via Query
  * def getItemsQuery =
    """
    function()
    {
      var HashMap = Java.type('java.util.HashMap');
      var Param_QueryAttributeListJava = [];
      for(var index in Param_QueryAttributeList){
        // Convert J04 Object into Java HashMap
        var Param_QueryAttributeItemHashMapJava = new HashMap();
        Param_QueryAttributeItemHashMapJava.putAll(Param_QueryAttributeList[index]);
        // Append converted Java HashMap to Java List
        Param_QueryAttributeListJava.push(
          Param_QueryAttributeItemHashMapJava
        );
      }

      var queryResp = dynamoDB.Query_GetItems(
        Param_TableName,
        Param_QueryAttributeListJava,
        Param_GlobalSecondaryIndex
      );

      if(queryResp.length < 1)  {
        // karate.log('No results found for ' + karate.pretty(Param_QueryAttributeList));
        return queryResp;
      }

      return JSON.parse(queryResp);
    }
    """
  * def result = call getItemsQuery
  # * print result

@ValidateItemViaQuery
# Get DynamoDB Item(s) via Query and Validate against Expected Result
# Parameters:
# {
#   Param_TableName: <Tablename>,
#   Param_QueryAttributeList: [
#       {
#           attributeName: <attribute to filter>,
#           attributeValue: <attribute value to filter>,
#           attributeComparator: <['contains' | '=']>,
#           attributeType: <'key' | 'filter'>
#       }
#   ],
#   Param_GlobalSecondaryIndex: <Table GSI>,
#   Param_ExpectedResponse: <Expected JSON>,
#   AWSRegion: <AWS Region: 'Nordic' | 'APAC'>,
#   Retries: <number of retries>,
#   RetryDuration: <time between retries in milliseconds>,
#   WriteToFile: <true | false>,
#   ShortCircuit: {
#        Key: <The trailing keys from the root e.g. promoAssetStatus>,
#        Value: <Expected value to short circuit>
#   }
# }
Scenario: Validate DynamoDB Item via Query
  #* print '-------------------Dynamo DB Feature and Item Count-------------'
  * def getItemsQuery =
    """
    function()
    {
      var HashMap = Java.type('java.util.HashMap');
      var Param_QueryAttributeListJava = [];
      for(var index in Param_QueryAttributeList){
        // Convert J04 Object into Java HashMap
        var Param_QueryAttributeItemHashMapJava = new HashMap();
        Param_QueryAttributeItemHashMapJava.putAll(Param_QueryAttributeList[index]);
        // Append converted Java HashMap to Java List
        Param_QueryAttributeListJava.push(
          Param_QueryAttributeItemHashMapJava
        );
      }


      var queryResp = dynamoDB.Query_GetItems(
        Param_TableName,
        Param_QueryAttributeListJava,
        Param_GlobalSecondaryIndex
      );

      if(queryResp.length < 1)  {
        karate.log('[' + TCName + '] No results found for ' + Param_TableName + ' - ' + karate.pretty(Param_QueryAttributeList));
        //karate.log('No results found for ' + Param_QueryAttributeList);
        return queryResp;
      }

      // dynamoDB.shutdown();
      
      return JSON.parse(queryResp);

    }
    """
  * def getMatchResult = 
    """
      function(queryResult) {
        var finalResult = {
          message: [],
          pass: false,
          path: null
        }

        if(queryResult.length < 1) {
          finalResult.message.push('No records found.');
        }
        else {
          var temp = queryResult;
          for(var i in queryResult) {
            testVar = queryResult[i];
            var thisRes = karate.match('testVar contains deep Param_ExpectedResponse');
            if(!thisRes.pass) {
              finalResult.message = finalResult.message.concat(thisRes.message);
              karate.log(finalResult);
            } else {
              finalResult.message = [];
              finalResult = thisRes;
              break;
            }
          }
        }
        return finalResult;
      }
    """
  * def getFinalResult =
    """
      function() {
        var matchResult = {};
        for(var i = 0; i < Retries; i++) {
          queryResult = getItemsQuery();
          //karate.log(karate.pretty(queryResult));
          
          matchResult = getMatchResult(queryResult);

          if(WriteToFile == true) {
            karate.write(karate.pretty(queryResult), WritePath);
          }
          if(matchResult.pass) {
            matchResult.response = queryResult;
            break;
          }
          else {
            karate.log('ShortCircuit: ' + ShortCircuit);
            if(ShortCircuit != null) {
              if(eval('queryResult.' + ShortCircuit.Key) == ShortCircuit.Value) {
                matchResult.message.push('comments: ' + queryResult.comments);
                karate.log('[FAILED] Short circuit condition met! ' + karate.pretty(matchResult));
                return matchResult;
              }
            } 
          
            karate.log('Try #' + (i+1) + ' of ' + Retries + ': Failed. Sleeping for ' + RetryDuration + ' ms. - ' + karate.pretty(matchResult));
            Pause(RetryDuration);
          }
        }

        // if(!matchResult.pass) {
        //   karate.fail(karate.pretty(matchResult));
        // }
        return matchResult;
      }
    """
  * def finalResult = getFinalResult()
  * def result =
    """
      {
        "response": #(finalResult.response),
        "message": #(finalResult.message),
        "pass": #(finalResult.pass),
        "path": #(finalResult.path)
      }
    """

@DeleteDBRecords
# Delete items from DynamoDB Table
# Parameters:
# {
#     Param_TableName: <Tablename>,
#     Param_DeleteItemAttributeList: [
#       {
#           attributeName: <attribute to filter>,
#           attributeValue: <attribute value to filter>,
#           attributeComparator: <['contains' | '=']>,
#           attributeType: <'key' | 'filter'>
#       }
#     ],
#     Retries: <# of retries>,
#     RetryDuration: <time between retries in milliseconds>,
#     AWSRegion: <AWS Region: 'Nordic' | 'APAC'>
# }
Scenario: Delete items from DynamoDB Table
  * def deleteItems =
    """
    function()
    {
      var result = {
        message: [],
        pass: true
      }
      var HashMap = Java.type('java.util.HashMap');
      var Param_DeleteItemAttributeListJava = [];
      for(var index in Param_DeleteItemAttributeList){
        // Convert J04 Object into Java HashMap
        var Param_DeleteItemAttributeHashMapJava = new HashMap();
        Param_DeleteItemAttributeHashMapJava.putAll(Param_DeleteItemAttributeList[index]);
        // Append converted Java HashMap to Java List
        Param_DeleteItemAttributeListJava.push(
          Param_DeleteItemAttributeHashMapJava
        );
      }

      var deleteResp = dynamoDB.Delete_Items(
        Param_TableName,
        Param_DeleteItemAttributeListJava
      );

      result.message = deleteResp;
      if(!deleteResp.contains('Success')) {           
        karate.log('Failed to delete ' + karate.pretty(Param_DeleteItemAttributeList));
        result.pass = false;
      }

      return result     
    }
    """
  * def result = deleteItems()