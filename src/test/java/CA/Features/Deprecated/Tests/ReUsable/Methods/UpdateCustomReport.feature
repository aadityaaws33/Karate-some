Feature: Update Custom Report
@UpdateReport
Scenario: UpdateReport
* def UpdateReport =
    """
    function()
    {
        var UpRep = Java.type('CA.utils.java.GenericUtils');
        var UR = new UpRep();
        return UR.UpdateReport(ParamID,ParamCell);
    }
    """
* def temp = call UpdateReport