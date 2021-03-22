function() {  

  try {
    karate.read('classpath:target/test-classes/Results.json')
  } catch (err) {
    karate.write([],'test-classes/Results.json');
  }
  var targetEnv = karate.properties['karate.targetEnv'];
  var targetTag = karate.properties['karate.options'].split('@')[1];
  var envData = read('classpath:env.json');
  var envConfig = envData[targetEnv];
  
  // var secretsData = null;
  // try {
  //   var AWSUtilsClass = Java.type('AWSUtils.AWSUtils');
  //   var AWSUtils = new AWSUtilsClass();
  //   secretsData = AWSUtils.getSecrets(envConfig.Common.SecretsManager.secretName, envConfig.Common.SecretsManager.region);
  // } catch (err) {
  //   karate.log('Problem encountered while fetching data from Secrets Manager');
  //   karate.log(err);
  //   karate.abort();
  // }
  
  var secretsData = {
    "Iconik-AdminEmailqa": "rohan_mundkur@discovery.com",
    "Iconik-AdminPasswordqa": "*aeWV56gmrEPMi",
    "Iconik-AdminEmailpreprod": "iconik-prod-admin@discovery.com",
    "Iconik-AdminPasswordpreprod": "4z9nxyy9vpf0hw8l",
    "Iconik-AdminEmailprod": "iconik-prod-admin@discovery.com",
    "Iconik-AdminPasswordprod": "4z9nxyy9vpf0hw8l"
  };

  var config = {
    TargetEnv: targetEnv,
    TargetTag: targetTag,
    EnvData: envData[targetEnv],
    SecretsData: secretsData
  };
  
  karate.log(config);
  return config;
}


