function() {  

  try {
    karate.read('classpath:target/test-classes/Results.json')
  } catch (err) {
    karate.write([],'test-classes/Results.json');
  }
  var targetEnv = karate.properties['karate.targetEnv'];

  var targetTag = karate.properties['karate.options'].split('@')[1];
  if(targetTag != 'E2E' && targetTag != 'Regression') {
    if(targetTag.contains('E2E')) {
      targetTag = 'E2E'
    } else {
      targetTag = 'Regression';
    }
  }

  var envData = read('classpath:env.json');
  var envConfig = envData[targetEnv];
  
  var secretsData = null;
  try {
    var AWSUtilsClass = Java.type('AWSUtils.AWSUtils');
    var AWSUtils = new AWSUtilsClass();
    secretsData = AWSUtils.getSecrets(envConfig.Common.SecretsManager.secretName, envConfig.Common.SecretsManager.region);
  } catch (err) {
    karate.log('Problem encountered while fetching data from Secrets Manager');
    karate.log(err);
    karate.abort();
  }

  var config = {
    TargetEnv: targetEnv,
    TargetTag: targetTag,
    EnvData: envData[targetEnv],
    SecretsData: secretsData
  };
  
  karate.log(config);
  return config;
}


