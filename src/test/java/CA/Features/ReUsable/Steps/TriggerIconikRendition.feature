Feature: Trigger Iconik Rendition

Scenario: Trigger Iconik Rendition
    # Build Iconik Rendition Request
    * Pause(1000)
    * def thisTCMetadata = karate.read(thisOutputReadPath + '/TCMetadata.json')
    * def IconikRenditionRequest = karate.call(ReUsableFeaturesPath + '/StepDefs/Iconik.feature@BuildIconikRenditionRequest', { IconikMetadata: thisTCMetadata.IconikMetadata }).result
    * karate.write(karate.pretty(IconikRenditionRequest), OutputWritePath + '/IconikRenditionRequest.json')
    * def TriggerRenditionParams = 
        """
            {
                URL: #(thisTCMetadata.IconikMetadata.IconikCustomActionURL),
                Query: #(IconikRenditionRequest),
                IconikAuthToken: #(thisTCMetadata.Config.IconikConfig.IconikAuthenticationData.AuthToken),
                IconikAppID: #(thisTCMetadata.Config.IconikConfig.IconikAuthenticationData.AppID)
            }
        """
    * def triggerRenditionResponse = karate.call(ReUsableFeaturesPath + '/StepDefs/Iconik.feature@TriggerRendition', TriggerRenditionParams).result
    * triggerRenditionResponse.pass == true? karate.log('[PASSED] Trigger Rendition - ' + thisTCMetadata.TCName) : karate.fail('[FAILED] Trigger Rendition - ' + thisTCMetadata.TCName + ': ' + karate.pretty(triggerRenditionResponse.message))