Feature: Sets necessary HTTP headers dependending on the authentication method
         <IAM or API Key>
Background:
  * def setHeaders = 
    """
      function(thisQuery) {
        if (authType == 'IAM') {
          var AWSUtilsClass = Java.type('AWSUtils.AWSUtils');
          var AWSUtils = new AWSUtilsClass();

          var method = 'POST';
          var serviceName = 'appsync';
          var host = CIMBLbaseUrl.split('\/')[2];
          var regionName = 'eu-west-1';
          var endpoint = CIMBLbaseUrl;
          var contentType = 'application/json; charset=UTF-8';

          var request = "{\"query\":" + "\"" + AWSUtils.stringify(thisQuery) + "\"" + "}";
          var contentLength = request.length();

          var accessKey = CIMBLIAMAccessKeyId;
          var secretKey = CIMBLIAMSecretKey;

          var xAmzDate = AWSUtils.getCurrentDateTime('yyyyMMdd' + '\'T\'' + 'HHmmss' + '\'Z\'');
          var dateStamp = AWSUtils.getCurrentDateTime('yyyyMMdd');

          // TASK 1: CREATE A canonical REQUEST
          var canonicalURI = '/graphql'
          var canonicalQueryString = '';

          var canonicalHeaders = 'content-length:' + contentLength + '\n'
                                  + 'content-type:' + contentType + '\n'
                                  + 'host:' + host + '\n'
                                  + 'x-amz-date:' + xAmzDate + '\n';

          var signedHeaders = 'content-length;content-type;host;x-amz-date'

          var payloadHashedHex = AWSUtils.convertByteToHexString(
                                  AWSUtils.hashSHA256(request)
                                );

          karate.log('payloadHashedHex: ' + payloadHashedHex);


          var canonicalRequest = method + '\n'
                                  + canonicalURI + '\n'
                                  + canonicalQueryString + '\n'
                                  + canonicalHeaders + '\n'
                                  + signedHeaders + '\n'
                                  + payloadHashedHex;

          karate.log('canonical REQUEST: ' + canonicalRequest);

          // TASK 2: CREATE THE STRING TO SIGN

          var algorithm = 'AWS4-HMAC-SHA256';

          var credentialScope  = dateStamp + '/'
                                 + regionName + '/'
                                 + serviceName + '/'
                                 + 'aws4_request';
          
          var canonicalRequestStringified = AWSUtils.stringify(canonicalRequest);
          karate.log('canonicalRequestStringified: ' + canonicalRequestStringified);
          var canonicalRequestHashedHex = AWSUtils.convertByteToHexString(
                                                  AWSUtils.hashSHA256(
                                                    canonicalRequest
                                                  )
                                                );
          karate.log('canonicalRequestHashedHex: ' + canonicalRequestHashedHex);

          var stringToSign =  algorithm + '\n'
                              + xAmzDate + '\n'
                              + credentialScope + '\n'
                              + canonicalRequestHashedHex;
          
          var stringToSignStringified = AWSUtils.stringify(stringToSign);

          karate.log('stringToSignStringified: ' + stringToSignStringified);

          // TASK 3: CALCULATE THE SIGNATURE
          var signingKey = AWSUtils.getSignatureKey(
            secretKey,
            dateStamp,
            regionName,
            serviceName
          );
          
          var signature = AWSUtils.convertByteToHexString(
                            AWSUtils.HmacSHA256(stringToSign, signingKey)
                          );
          
          karate.log('SIGNATURE: ' + signature);
                   
          // TASK 4: ADD SIGJNING INFO TO THE RQEUEST
          var authHeader = algorithm + ' ' 
                           + 'Credential=' + accessKey + '/' + credentialScope + ', '
                           + 'SignedHeaders=' + signedHeaders + ', '
                           + 'Signature=' + signature;
          
          var thisHeader = {
            'Content-Type': contentType,
            'X-Amz-Date': xAmzDate,
            'Authorization': authHeader,
          }

          karate.log(thisHeader);

          return thisHeader;

        } else {
          return validCimblHeader;
        }
      }
    """

Scenario: Set headers
  * def output = call setHeaders query

# @utilSanity
# Scenario: Check setHeader.feature Sanity IAM
#   * url CIMBLbaseUrl
#   * def authType = 'IAM'
#   * def query = '{getLeagues{id}}'
#   * request
#     """
#       {
#         query: #(query)
#       }
#     """
#   * configure headers = call setHeaders query
#   * method post
#   * status 200

# @utilSanity
# Scenario: Check setHeader.feature Sanity apiKey
#   * url CIMBLbaseUrl
#   * def validCimblHeader = read('classpath:CIMBL/Auth/' + authType + '.json')
#   * def authType = 'apiKey'
#   * def query = '{getLeagues{id}}'
#   * request
#     """
#       {
#         query: #(query)
#       }
#     """
#   * configure headers = call setHeaders query
#   * method post
#   * status 200