function() {  

  // Global configurations
  karate.configure('connectTimeout', 10000);
  karate.configure('retry', { count:4, interval:2000});
  // karate.configure('report', { showLog: true, showAllSteps: false});
  
  // Environment configurations
  var targetEnv = karate.properties['karate.targetEnv'];
  var testUser = java.lang.System.getenv('TestUser');
  
  var AdminEmail = java.lang.System.getenv('IconikAdminEmail'); 
  var AdminPassword = java.lang.System.getenv('IconikAdminPassword'); 

  if(!AdminEmail || !AdminPassword) {
    karate.fail('[FAILED] No AdminEmail/AdminPassword acquired! Please check your environment variables!');
  }

  var targetTag = karate.properties['karate.options'].split('@')[1];

  var configDir = 'classpath:CA/Config/' + targetEnv;

  var CommonData = read(configDir + '/' + 'Common.json');
  
  CommonData.Iconik.AdminEmail = AdminEmail;
  CommonData.Iconik.AdminPassword = AdminPassword;
  CommonData.Iconik.TestUser = testUser;
  
  var envConfig = {
    Common: CommonData
  };
 

  // Consolidation of configurations
  var config = {
    TargetEnv: targetEnv,
    TargetTag: targetTag,
    EnvConfig: envConfig,
  };

  // karate.log(config);
  return config;
}