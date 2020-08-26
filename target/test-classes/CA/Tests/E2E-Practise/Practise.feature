Feature:  Practise

@Practise1
Scenario: PractiseNew
* def GetTableCount =
    """
    function()
    {
        var DataStorage = Java.type('MiscUtils.MiscUtils');
        var dS = new DataStorage();
        return dS.Add(1,2);
    }
    """
* def temp = GetTableCount()
* print 'Count in Matching Engine Result Table----------------->', temp
* assert temp == '3'

@Practise2
Scenario: PractiseNew
* def GetTableCount =
    """
    function()
    {
        var DataStorage = Java.type('MiscUtils.MiscUtils');
        var dS = new DataStorage();
        return DataStorage.Add(1,2);
    }
    """
* def temp = call GetTableCount
* print 'Count in Matching Engine Result Table----------------->', temp
* assert temp == '3'

@Practise3
Scenario: PractiseNew
* def GetTableCount = Java.type('MiscUtils.MiscUtils')
* def temp =  GetTableCount.Add(1,2)
* print 'Count in Matching Engine Result Table----------------->', temp
* assert temp == '3'