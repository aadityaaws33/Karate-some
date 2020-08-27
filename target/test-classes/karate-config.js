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
    authType: authType
  };
  karate.log(config);
  return config;
}


