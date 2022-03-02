@parallel=off
Feature: Test Setup

Scenario: Setup - Global Generic Variables & Methods
    # ---- Functions ----
    * def Pause = function(pause){ karate.log('Pausing for ' + pause + 'ms.'); java.lang.Thread.sleep(pause) }
    * Pause(WaitTime)
    * def updateThisTCMetadata =
        """
            function(TCMetadata) {
                karate.log('Updating TCMetadata File');
                karate.write(karate.pretty(TCMetadata), OutputWritePath + '/TCMetadata.json');
                Pause(1000);
            }
        """
    * def modifyInputMetadataWithRandomString =
        """
            function(InputMetadata) {
                var additionalString = ' ' + RandomString;
                if(InputMetadata.CustomTitle) {
                    InputMetadata.CustomTitle += additionalString;
                }
                if(InputMetadata.PromotionalLine) {
                    InputMetadata.PromotionalLine += additionalString;
                }
                if(InputMetadata.SomeCTA) {
                    InputMetadata.SomeCTA += additionalString;
                }
                if(InputMetadata.CustomStrapOutroCTA) {
                    InputMetadata.CustomStrapOutroCTA += additionalString;
                }
                if(InputMetadata.LegalText) {
                    InputMetadata.LegalText += additionalString;
                }

                return InputMetadata
            }
        """
    * def getAdditionalIconikMetadata =
        """
            function(IconikConfig, IconikMetadata) {
                var iconikAuthToken = IconikConfig.IconikAuthenticationData.AuthToken;
                var iconikAppID = IconikConfig.IconikAuthenticationData.AppID;

                var GetCustomActionDataParams = {
                    URL: IconikConfig.URL.CustomActionsAPI,
                    IconikAuthToken: iconikAuthToken,
                    IconikAppID: iconikAppID,
                    CustomActionTitle: IconikMetadata.IconikCustomActionTitle[TargetEnv]
                } 
                var customActionData = karate.call(ReUsableFeaturesPath + '/StepDefs/Iconik.feature@GetCustomActionData', GetCustomActionDataParams).result
                if(customActionData.pass == false) {
                    karate.fail('[FAILED] Setup - Get Custom Action Data: ' + karate.pretty(customActionData.message))
                    karate.abort();
                }

                // CUSTOM ACTION DATA
                IconikMetadata.IconikCustomActionID = customActionData.response.id;
                IconikMetadata.IconikCustomActionMetadataView = customActionData.response.metadata_view;
                IconikMetadata.IconikCustomActionHTTPMethod = customActionData.response.type;
                IconikMetadata.IconikCustomActionContext = customActionData.response.context;
                IconikMetadata.IconikCustomActionURL = customActionData.response.url;

                for(var i in IconikMetadata) {
                    if(IconikMetadata[i] == null) {
                        karate.fail('[FAILED] Setup - Get Custom Action Data: NULL value in IconikMetadata - ' + karate.pretty(IconikMetadata));
                        karate.abort();
                    }
                }
                karate.log('[PASSED] Setup - Get Custom Action Data');

                // ASSET DATA
                var SearchForAssetDataParams = {
                    URL: IconikConfig.URL.SearchAPI,
                    IconikAuthToken: iconikAuthToken,
                    IconikAppID: iconikAppID,
                    IconikMetadata: IconikMetadata
                }
                var searchForAssetData = karate.call(ReUsableFeaturesPath + '/StepDefs/Iconik.feature@SearchForAssetData', SearchForAssetDataParams).result
                if(searchForAssetData.pass == false) {
                    karate.fail('[FAILED] Setup - Search for Asset Data: ' + karate.pretty(searchForAssetData.message));
                    karate.abort();
                }
                karate.log('[PASSED] Setup - Search for Asset Data');

                // APPEND DATA TO TCMETADATA
                IconikMetadata.IconikAssetId = searchForAssetData.response.id;

                return IconikMetadata;
            }
        """
    * def getDBAspectRatios =
        """
            function(InputMetadata) {
                var aspectRatios = InputMetadata.IconikAspectRatios.split('|')
                for(var i in aspectRatios) {
                    aspectRatios[i] = 'ASPECT_' + aspectRatios[i].replace('x', '_');
                }
                InputMetadata.DBAspectRatios = aspectRatios.join('|');

                return InputMetadata
            }
        """
    # ---- Paths ----
    * def ReUsableFeaturesPath = 'classpath:CA/Features/ReUsable'
    * def ResourcesPath = 'classpath:CA/Resources'
    * def OutputReadPath = 'classpath:CA/Output/' + TCMetadata.TCName
    * def OutputWritePath = 'test-classes/CA/Output/' + TCMetadata.TCName
    * def ResultsReadPath = 'OutputReadPath' + '/Results'
    * def ResultsWritePath = OutputWritePath + '/Results'
    # ---- Testing Variables ----
    * def RandomString = GenerateRandomString == true?karate.callSingle(ReUsableFeaturesPath + '/StepDefs/RandomGenerator.feature@GenerateRandomString').result:RandomString
    * def ExpectedDate = GenerateRandomString == true?karate.callSingle(ReUsableFeaturesPath + '/StepDefs/Date.feature@GetDateWithOffset', { offset: 0 }).result:ExpectedDate
    # ---- Config Variables----
    * def ThisConfig = 
        """
            {
                AWSRegion: #(EnvConfig.Common.AWSRegion),
                DynamoDBConfig: #(EnvConfig.Common.DynamoDB),
                IconikConfig: #(EnvConfig.Common.Iconik)
            }
        """
    * TCMetadata.Config = ThisConfig   
    * TCMetadata.InputMetadata = modifyInputMetadataWithRandomString(TCMetadata.InputMetadata, RandomString)
    * TCMetadata.InputMetadata = getDBAspectRatios(TCMetadata.InputMetadata)
    * TCMetadata.Config.IconikConfig.IconikAuthenticationData = karate.callSingle(ReUsableFeaturesPath + '/StepDefs/Iconik.feature@GetAppTokenData', { IconikConfig: TCMetadata.Config.IconikConfig }).result;
    * TCMetadata.IconikMetadata = getAdditionalIconikMetadata(TCMetadata.Config.IconikConfig, TCMetadata.IconikMetadata)
    * TCMetadata.Expected = { Date: ExpectedDate, RandomString: RandomString }
    * updateThisTCMetadata(TCMetadata);
    
    