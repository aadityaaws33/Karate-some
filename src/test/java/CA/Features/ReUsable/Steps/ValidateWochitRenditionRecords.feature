Feature: Validate Wochit Renditon Records

Background:
    * def thisTCMetadata = karate.read(thisOutputReadPath + '/TCMetadata.json')

@ValidateWochitRenditionRecords
Scenario: Validate Wochit Rendition Records
    # GET ALL POSSIBLE OUTCOMES
    * def ExpectedRenditionFileNames = karate.call(ReUsableFeaturesPath + '/StepDefs/RenditionFilenames.feature@GetAllRenditionFilenames', {InputMetadata: thisTCMetadata.InputMetadata, IconikMetadata: thisTCMetadata.IconikMetadata, Duration: Duration}).result
    * karate.log(ExpectedRenditionFileNames)
    * def FormExpectedWochitRenditionRecordsParams =
        """
            {
                ExpectedRenditionFileNames: #(ExpectedRenditionFileNames),
                InputMetadata: #(thisTCMetadata.InputMetadata),
                Config: #(thisTCMetadata.Config),
                IconikMetadata: #(thisTCMetadata.IconikMetadata)
            }
        """
    * def ExpectedWochitRenditionRecords = karate.call(ReUsableFeaturesPath + '/StepDefs/WochitRendition.feature@FormExpectedWochitRenditionRecords', FormExpectedWochitRenditionRecordsParams).result
    * def ValidateWochitRenditionRecordsParams =
        """
            {
                ExpectedWochitRenditionRecords: #(ExpectedWochitRenditionRecords),
                Config: #(thisTCMetadata.Config),
                ExpectedDate: #(thisTCMetadata.Expected.Date)
            }
        """
    * def validationResult = karate.call(ReUsableFeaturesPath + '/StepDefs/WochitRendition.feature@ValidateWochitRenditionRecords', ValidateWochitRenditionRecordsParams).result
    * validationResult.pass == true? karate.log('[PASSED] Wochit Rendition Records Validation - ' + thisTCMetadata.TCName) : karate.fail('[FAILED] Wochit Rendition Results - ' + thisTCMetadata.TCName + ': ' + karate.pretty(validationResult))



