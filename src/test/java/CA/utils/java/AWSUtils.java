package AWSUtils;

import com.amazonaws.AmazonServiceException;
import com.amazonaws.regions.Regions;
import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.AmazonS3ClientBuilder;
import com.amazonaws.services.s3.model.S3Object;
import com.amazonaws.services.s3.model.S3ObjectInputStream;
import com.amazonaws.services.s3.model.GetObjectMetadataRequest;
import com.amazonaws.services.s3.model.ObjectMetadata;

import com.amazonaws.services.appsync.AWSAppSync;
import com.amazonaws.services.appsync.AWSAppSyncClientBuilder;
import com.amazonaws.services.appsync.model.GetIntrospectionSchemaRequest;
import com.amazonaws.services.appsync.model.GetIntrospectionSchemaResult;
import com.amazonaws.services.appsync.model.ListGraphqlApisRequest;
import com.amazonaws.services.appsync.model.ListGraphqlApisResult;

import com.amazonaws.services.secretsmanager.AWSSecretsManager;
import com.amazonaws.services.secretsmanager.AWSSecretsManagerClientBuilder;
import com.amazonaws.services.secretsmanager.model.GetSecretValueRequest;
import com.amazonaws.services.secretsmanager.model.GetSecretValueResult;
import com.amazonaws.services.secretsmanager.model.ResourceNotFoundException;
import com.amazonaws.services.secretsmanager.model.InvalidParameterException;
import com.amazonaws.services.secretsmanager.model.InvalidRequestException;
import com.amazonaws.services.secretsmanager.model.DecryptionFailureException;
import com.amazonaws.services.secretsmanager.model.InternalServiceErrorException;

import java.io.File;
import java.io.IOException;
import java.io.FileOutputStream;
import java.io.FileNotFoundException;

import java.nio.CharBuffer;
import java.nio.ByteBuffer;
import java.nio.channels.FileChannel;
import java.nio.charset.StandardCharsets;

import java.util.Date;
import java.util.Base64;
import java.util.Map;
import java.util.concurrent.TimeUnit;
import java.util.HashMap;
import java.util.TimeZone;

import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;

import javax.crypto.spec.SecretKeySpec;
import javax.crypto.Mac;

import java.net.URI;
import java.net.URISyntaxException;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

import java.lang.Long;

import com.fasterxml.jackson.databind.ObjectMapper;

import org.apache.commons.codec.binary.Hex;


public class AWSUtils {

  public String downloadS3Object(String BucketName, String ObjectKey, String S3Region, String TargetDir) {
    String ObjectKeySplit[] = ObjectKey.split("/");
    String SaveFileName = ObjectKeySplit[ObjectKeySplit.length - 1];
    File OutputDir = new File(TargetDir);
    File OutputPath =  new File(OutputDir.getPath() + "/" + SaveFileName);

    System.out.format("Downloading %s from S3 bucket %s to %s\n", ObjectKey, BucketName, OutputPath);
    final AmazonS3 s3 = AmazonS3ClientBuilder.standard().withRegion(S3Region).build();
    var output = "";
    try {
      S3Object o = s3.getObject(BucketName, ObjectKey);
      S3ObjectInputStream s3is = o.getObjectContent();
      
      OutputDir.mkdirs();
      FileOutputStream fos = new FileOutputStream(OutputPath);

      byte[] read_buf = new byte[1024];
      int read_len = 0;
      while ((read_len = s3is.read(read_buf)) > 0) {
          fos.write(read_buf, 0, read_len);
      }
      s3is.close();
      fos.close();
      output = "Download successful.";
    } catch (AmazonServiceException e) {
      System.err.println(e.getErrorMessage());
      output = e.getErrorMessage();
    } catch (FileNotFoundException e) {
      System.err.println(e.getMessage());
      output = e.getMessage();
    } catch (IOException e) {
      System.err.println(e.getMessage());
      output = e.getMessage();
    }
    return output;
  }

  public String downloadAppSyncSchema(String ApiId, String S3Region, String TargetDir) {
    final AWSAppSync AppSync = AWSAppSyncClientBuilder.standard().withRegion(S3Region).build();
    GetIntrospectionSchemaRequest request = new GetIntrospectionSchemaRequest()
                                                .withApiId(ApiId)
                                                .withFormat("SDL");
    ByteBuffer schemaBuffer = AppSync.getIntrospectionSchema(request)
                              .getSchema()
                              .asReadOnlyBuffer();
    String output = "Download SuT successful.";  
    try {
      System.out.format("Downloading AppSync schema for %s to %s\n", ApiId, TargetDir);
      File OutputDir = new File(TargetDir);
      File OutputPath =  new File(OutputDir.getPath() + "/SuT.graphql");
      OutputDir.mkdirs();
      FileChannel fos = new FileOutputStream(OutputPath).getChannel();
      fos.write(schemaBuffer);
      fos.close();
    } catch (FileNotFoundException e) {
      System.err.println(e.getMessage());
      output = e.getMessage();
    } catch (IOException e) {
      System.err.println(e.getMessage());
      output = e.getMessage();
    } catch (AmazonServiceException e) {
      System.err.println(e.getErrorMessage());
      output = e.getErrorMessage();
    }
    return output;
  }

  public ObjectMetadata getS3ObjectMetadata(String BucketName, String ObjectKey, String S3Region) {
    final AmazonS3 s3 = AmazonS3ClientBuilder.standard().withRegion(S3Region).build();
    ObjectMetadata metadata = s3.getObjectMetadata(BucketName, ObjectKey);
    return metadata;
  }

  public Date getS3ObjectLastModified(String BucketName, String ObjectKey, String Region) {
    ObjectMetadata metadata = getS3ObjectMetadata(BucketName, ObjectKey, Region);
    Date date = metadata.getLastModified();
    return date;
  }

  public Long getTimeNow() {
    Date dateNow = new Date();
    return dateNow.getTime();
  }

  public Long getTimeDiff(Long startDateTime, Long endDateTime, String diffFormat) {
    Long timeDiff = startDateTime - endDateTime;
    Long diff = 0L;
    if (diffFormat.toLowerCase().contains("minute")) {
      diff = TimeUnit.MILLISECONDS.toMinutes(timeDiff);
    } else if (diffFormat.toLowerCase().contains("second")) {
      diff = TimeUnit.MILLISECONDS.toSeconds(timeDiff);
    }
    return diff;
  }


  public Map<String,String> getSecrets(String secretName, String region) {
    AWSSecretsManager client  = AWSSecretsManagerClientBuilder.standard()
                                    .withRegion(region)
                                    .build();
   
    String secret = null;
    String decodedBinarySecret = null;
    
    GetSecretValueRequest getSecretValueRequest = new GetSecretValueRequest()
                    .withSecretId(secretName);
    GetSecretValueResult getSecretValueResult = null;

    try {
        getSecretValueResult = client.getSecretValue(getSecretValueRequest);
    } catch (DecryptionFailureException e) {
        throw e;
    } catch (InternalServiceErrorException e) {
        throw e;
    } catch (InvalidParameterException e) {
        throw e;
    } catch (InvalidRequestException e) {
        throw e;
    } catch (ResourceNotFoundException e) {
        throw e;
    }

    if (getSecretValueResult.getSecretString() != null) {
        secret = getSecretValueResult.getSecretString();
    }
    else {
        decodedBinarySecret = new String(Base64.getDecoder().decode(getSecretValueResult.getSecretBinary()).array());
    }

    Map<String, String> output = convertJSONStringToMap(secret);
    return output;  
  }

  public Map<String, String> convertJSONStringToMap(String jsonString) {
    ObjectMapper mapper = new ObjectMapper();
    Map<String, String> output = null;
    try {

      output = mapper.readValue(jsonString, Map.class);

    } catch (IOException e) {
        e.printStackTrace();
    }
    return output;
  }

  public byte[] HmacSHA256(String data, byte[] key) throws Exception {
    String algorithm="HmacSHA256";
    Mac mac = Mac.getInstance(algorithm);
    mac.init(new SecretKeySpec(key, algorithm));
    return mac.doFinal(data.getBytes("UTF-8"));
  }

  public byte[] getSignatureKey(String key, String dateStamp, String regionName, String serviceName) throws Exception {
    byte[] kSecret = ("AWS4" + key).getBytes("UTF-8");
    byte[] kDate = HmacSHA256(dateStamp, kSecret);
    byte[] kRegion = HmacSHA256(regionName, kDate);
    byte[] kService = HmacSHA256(serviceName, kRegion);
    byte[] kSigning = HmacSHA256("aws4_request", kService);
    return kSigning;
  }

  public String convertByteToHexString(byte[] byteData) {
    char[] result = Hex.encodeHex(byteData);
    return new String(result);
  }


  public byte[] hashSHA256(String data) {
    MessageDigest digest = null;
    try {
      digest = MessageDigest.getInstance("SHA-256");
    } catch (NoSuchAlgorithmException e) {
      System.err.println(e.getMessage());
    }
    byte[] encodedHash = digest.digest(data.getBytes(StandardCharsets.UTF_8));
    return encodedHash;
  }

  public String getCurrentDateTime(String format) {
    SimpleDateFormat sdfDate = new SimpleDateFormat(format);
    sdfDate.setTimeZone(TimeZone.getTimeZone("UTC"));
    Date now = new Date();
    String strDate = sdfDate.format(now);
    return strDate;
  }

  public String stringify(String data) {
    data = data.replaceAll("\r", "\\\\r");
    data = data.replaceAll("\n", "\\\\n");
    data = data.replaceAll("\t", "\\\\t");
    data = data.replaceAll("\"", "\\\\\"");
    return data;
  }

}