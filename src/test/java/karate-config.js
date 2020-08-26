function() {  
  var targetEnv = karate.properties['karate.targetEnv'];
  var authType = karate.properties['karate.authType'];
  var envData = read('classpath:env_data.json');
  var envConfig = envData[targetEnv];
  
  var AWSUtilsClass = Java.type('AWSUtils.AWSUtils');
  var AWSUtils = new AWSUtilsClass();

  var smSecretKeys = AWSUtils.getSecrets(envConfig.Common.SecretsManager.secretName, envConfig.Common.SecretsManager.region);
  
  var config = {
    targetEnv: targetEnv,
    authType: authType,
    CIMBLbaseUrl: envConfig.CIMBL.baseUrl,
    CIMBLAPIKey: eval('smSecretKeys.cimblApiKey' + targetEnv),
    CIMBLIAMAccessKeyId: smSecretKeys.IAMAccessKeyId,
    CIMBLIAMSecretKey: smSecretKeys.IAMSecretKey,
    CIMBLImgS3Bucket: envConfig.CIMBL.imgS3Bucket,
    CIMBLSMCRespS3Bucket: envConfig.CIMBL.smcRespS3Bucket,
    CIMBLS3BucketRegion: envConfig.CIMBL.imgS3BucketRegion,
    CIMBLApiId: envConfig.CIMBL.apiId,
    CIMBLApiRegion: envConfig.CIMBL.apiRegion,
    CIMBLQaBucket: envConfig.CIMBL.qaBucket,
    CIMBLQaBucketRegion: envConfig.CIMBL.qaBucketRegion,
    SMCAPIKey: eval('smSecretKeys.allsvenskanAuthToken' + targetEnv),
    SMCbaseUrl: envConfig.SMC.baseUrl
  };

  karate.log(config);

  return config;
}


