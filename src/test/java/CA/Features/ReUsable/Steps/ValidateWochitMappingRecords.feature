Feature: Wochit Mapping Record Validation

Background:
    * def thisTCMetadata = karate.read(thisOutputReadPath + '/TCMetadata.json')

Scenario: Wochit Mapping Record Validation
    * def ExpectedRenditionFileNames = thisTCMetadata.Expected.WochitRenditionFileNames
    * karate.log(ExpectedRenditionFileNames)
    * def FormExpectedWochitMappingRecordsParams =
        """
            {
                ExpectedRenditionFileNames: #(ExpectedRenditionFileNames), 
                InputMetadata: #(thisTCMetadata.InputMetadata), 
                IconikConfig: #(thisTCMetadata.IconikConfig), 
                Config: #(thisTCMetadata.Config), 
                IconikMetadata: #(thisTCMetadata.IconikMetadata)
            }
        """
    * def ExpectedWochitMappingRecords = karate.call(ReUsableFeaturesPath + '/StepDefs/WochitMapping.feature@FormExpectedWochitMappingRecords', FormExpectedWochitMappingRecordsParams).result
    * karate.log(ExpectedWochitMappingRecords)
    * def ValidateWochitMappingRecordsParams =
        """
            {
                ExpectedWochitMappingRecords: #(ExpectedWochitMappingRecords),
                Config: #(thisTCMetadata.Config), 
                IconikMetadata: #(thisTCMetadata.IconikMetadata),
                ExpectedDate: #(thisTCMetadata.Expected.Date), 
                TCName: #(thisTCMetadata.TCName)
            }
        """
    * def validationResult = karate.call(ReUsableFeaturesPath + '/StepDefs/WochitMapping.feature@ValidateWochitMappingRecords', ValidateWochitMappingRecordsParams).result
    * validationResult.pass == true? karate.log('[PASSED] Wochit Mapping Records Validation - ' + thisTCMetadata.TCName) : karate.fail('[FAILED] Wochit Mapping Records Validation - ' + thisTCMetadata.TCName + ': ' + karate.pretty(validationResult))

