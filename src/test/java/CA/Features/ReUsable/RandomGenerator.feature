Feature: Random Generator

Background:
    * def Random_String_Generator = function(){ return java.lang.System.currentTimeMillis() }

@SeriesTitle
Scenario: Random generator Series
    * def RandomSeriesTitle = 'Series-' + Random_String_Generator()
    #* print '-------------RandomSeriesTitle in feature file----------'+RandomSeriesTitle
@CallOutText  
Scenario: Random generator CallOut Text
    * def RandomCalloutText = 'COT-' + Random_String_Generator()
    #* print '-------------RandomCalloutText in feature file----------'+RandomCalloutText
@CTA
Scenario: Random generator CTA
    * def RandomCTA = 'CTA-' + Random_String_Generator()
    #* print '-------------RandomCTA in feature file----------'+RandomCTA

@DateNow
Scenario: DateTimeGeneration
#* print '-------------------Dynamo DB Feature and Item Count-------------'
* def ItemCount =
    """
    function()
    {
        var ItemCount = Java.type('CA.utils.java.DynamoDBUtils');
        var ItCnt = new ItemCount();
        return ItCnt.CreateDate();
    }
    """
* def Datenow = call ItemCount
* print '----------------Date in FeatureFile------------'+Datenow
