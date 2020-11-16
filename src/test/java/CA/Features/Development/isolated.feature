# @isolated
Feature: Isolated

Background:
#   * def AWSregion = "APAC"
#   * def initializeDynamoDBObject = 
#     """
#       function(thisAWSregion) {
#         var dynamoDBUtilsClass = Java.type('CA.utils.java.DynamoDBUtils');
#         return new dynamoDBUtilsClass(thisAWSregion)
#       }
#     """
#   * def dynamoDB = callonce initializeDynamoDBObject AWSregion
#   * def query =
#     """
#       function() {
#         var HashMap = Java.type('java.util.HashMap');
#         var partitionKeyInfo = new HashMap();
#         var sortKeyInfo = new HashMap();
#         var filters = new HashMap();

#         patitionKeyInfo.putAll(
#           ''
#         )



#         filters.putAll({
#           'filterKey1': 'filterKeyValue',
#           'filterAlias1': 'filterAlias1Value',
#           'filterAlias2': 'filterAlias2Value'
#         });
#         var queryResp = dynamoDB.queryTableViaIndex(
#           'thisTable',
#           // 'thisIndex',
#           'thisPartitionKeyName',
#           'thisPartitionKeyValue',
#           'thisPartitionAlias',
#           'thisSortKeyName',
#           'thisSortKeyValue',
#           'thisSortKeyAlias',
#           filters
#         );
#         karate.log(queryResp);
#       }
#     """
# Scenario:
#   * call query