Feature:  Download file from URL

Background:
  * def downloadFile = 
    """
      function(dlInfo) {
        var MiscUtilsClass = Java.type('MiscUtils.MiscUtils');
        var MiscUtils = new MiscUtilsClass();
        var resp = MiscUtils.getFileFromURL(dlInfo.targetUrl, dlInfo.downloadPath);
        if(!resp.contains('success')) {
          karate.abort();
        }
        return resp;
      }
    """

Scenario:
  * def downloadFileResult = call downloadFile URLObjectInfo
  * print downloadFileResult