Feature: Hooks
@BeforeAll
Scenario: Before All
* print '----------Before All-----------'
* def BeforeAll =
    """
    function()
    {
        var TrTable = Java.type('CA.utils.java.GenericUtils');
        var Trt = new TrTable();
        return Trt.BeforeAll();
    }
    """
* def temp = call BeforeAll
