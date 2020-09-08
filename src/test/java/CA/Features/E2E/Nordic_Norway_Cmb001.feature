Feature:  Nordic_Norway_Cmb001

Background:
    * def Pause = function(pause){ java.lang.Thread.sleep(pause) }
    * def result = call read('classpath:CA/Features/ReUsable/Dynamodb.feature@TruncateTable') {Param_TableName: 'CA_WOCHIT_MAPPING_EU-qa',Param_PrimaryKey: 'ID'}
    * def result = call read('classpath:CA/Features/ReUsable/Dynamodb.feature@TruncateTable') {Param_TableName: 'CA_WOCHIT_RENDITIONS_EU-qa',Param_PrimaryKey: 'ID'}  
    
@PoC
Scenario Outline: <TestCaseID>------Sample POC for Dplay CA Modularized 
    * def Random_String_Generator = function(){ return java.lang.System.currentTimeMillis() }
    * def RandomSeriesTitle = 'Series-' + Random_String_Generator()
    * def RandomCalloutText = 'COT-' + Random_String_Generator()
    * def RandomCTA = 'CTA-' + Random_String_Generator()
    * print '---------------RandomSeriesTitle----------'+RandomSeriesTitle
    * print '---------------RandomCalloutText----------'+RandomCalloutText
    * print '---------------RandomCTA----------'+RandomCTA

    * print '-----------------Validate Update Season Status and Response----------------'
    * def UpdateSeasonquery = read('classpath:CA/Tests/E2ECases/Nordic_Region/Norway/' + <TestCaseID> + '/Input/SeasonRequest.json')
    * replace UpdateSeasonquery.SeriesTitle = RandomSeriesTitle
    * def Season_expectedResponse = read('classpath:CA/Tests/E2ECases/Nordic_Region/Norway/' + <TestCaseID> + '/Output/ExpectedSeasonResponse.json')
    * def result = call read('classpath:CA/Features/ReUsable/UpdateSeason.feature') {SeasonQuery: '#(UpdateSeasonquery)',SeasonExpectedResponse: '#(Season_expectedResponse)',ExpectedSeriesTitle: '#(RandomSeriesTitle)'}

    * print '-----------------Validate Episode Season Status and Response----------------'
    * def UpdateEpisodequery = read('classpath:CA/Tests/E2ECases/Nordic_Region/Norway/' + <TestCaseID> + '/Input/EpisodeRequest.json')
    * replace UpdateEpisodequery.CallOutText = RandomCalloutText
    * replace UpdateEpisodequery.CTA = RandomCTA
    * def Episode_ExpectedResponse = read('classpath:CA/Tests/E2ECases/Nordic_Region/Norway/' + <TestCaseID> + '/Output/ExpectedEpisodeResponse.json')
    * def result = call read('classpath:CA/Features/ReUsable/UpdateEpisode.feature') {EpisodeQuery: '#(UpdateEpisodequery)',EpisodeExpectedResponse: '#(Episode_ExpectedResponse)',ExpectedCalloutText: '#(RandomCalloutText)',ExpectedCTA: '#(RandomCTA)'}

    * print '-----------------Validate Trigger Rendition Status and Response----------------'
    * def Renditionquery = read('classpath:CA/Tests/E2ECases/Nordic_Region/Norway/' + <TestCaseID> + '/Input/RenditionRequest.json')
    * def Rendition_ExpectedResponse = read('classpath:CA/Tests/E2ECases/Nordic_Region/Norway/' + <TestCaseID> + '/Output/ExpectedRenditionResponse.json')
    * def result = call read('classpath:CA/Features/ReUsable/Rendition.feature') {RenditionQuery: '#(Renditionquery)',RenditionExpectedResponse: '#(Rendition_ExpectedResponse)'}

    * print '-----------------Polling for Db Update----------------'
    * def result = call read('classpath:CA/Features/ReUsable/Dynamodb.feature@WaitUntilDBUpdate')


    * print '-----------------Validate Table Counts----------------'
    * def result = call read('classpath:CA/Features/ReUsable/Dynamodb.feature@ItemCountQuery') {Param_TableName: 'CA_MAM_ASSETS_INFO_EU-qa',Param_KeyType: 'Single',Param_Atr1: 'assetId',Param_Atr2: '',Param_Atrvalue1: 'd03eedd4-e345-11ea-9814-0a580a3f06a0',Param_Atrvalue2: '',Param_ExpectedItemCount: <ExpectedMAMAssetInfoCount>}    
    * def result = call read('classpath:CA/Features/ReUsable/Dynamodb.feature@ItemCountScan') {Param_TableName: 'CA_WOCHIT_MAPPING_EU-qa',Param_Atr1: 'mamAssetInfoReferenceId',Param_Atrvalue1: 'd03eedd4-e345-11ea-9814-0a580a3f06a0',Param_ExpectedItemCount: <ExpectedWocRenditionCount>}    
    * def result = call read('classpath:CA/Features/ReUsable/Dynamodb.feature@ItemCountScan') {Param_TableName: 'CA_WOCHIT_RENDITIONS_EU-qa',Param_Atr1: 'createdBy',Param_Atrvalue1: 'step-createWochitRenditions-EU-qa',Param_ExpectedItemCount: <ExpectedWochitMappingCount>}

    * print '-----------------Validate Technical Metadata----------------'
    * def Episode_ExpectedResponse = read('classpath:CA/Tests/E2ECases/Nordic_Region/Norway/' + <TestCaseID> + '/Output/ExpectedTechMetaData.txt')
    * def result = call read('classpath:CA/Features/ReUsable/Dynamodb.feature@@GetItemMAMAssetInfo') {Param_TableName: 'CA_MAM_ASSETS_INFO_EU-qa',Param_PartitionKey: 'assetId', Param_SortKey: 'compositeViewsId',ParamPartionKeyVal: 'd03eedd4-e345-11ea-9814-0a580a3f06a0', ParamSortKeyVal: 'e1706402-934f-11ea-b2e1-0a580a3cb9b9|a86a5f8c-c5ae-11ea-8c30-0a580a3ebc6b',Param_TechMetaData:'#(TechMetaData_expectedResponse)'}
    * def result = call read('classpath:CA/Features/ReUsable/Dynamodb.feature@@GetItemMAMAssetInfo') {Param_TableName: 'CA_MAM_ASSETS_INFO_EU-qa',Param_PartitionKey: 'assetId', Param_SortKey: 'compositeViewsId',ParamPartionKeyVal: 'd03eedd4-e345-11ea-9814-0a580a3f06a0', ParamSortKeyVal: 'adb2fec4-934d-11ea-bcbe-0a580a3c65d4|4cf68d80-890c-11ea-bdcd-0a580a3c35b3',Param_TechMetaData:'#(TechMetaData_expectedResponse)'}
    * def result = call read('classpath:CA/Features/ReUsable/Dynamodb.feature@@GetItemMAMAssetInfo') {Param_TableName: 'CA_MAM_ASSETS_INFO_EU-qa',Param_PartitionKey: 'assetId', Param_SortKey: 'compositeViewsId',ParamPartionKeyVal: 'd03eedd4-e345-11ea-9814-0a580a3f06a0', ParamSortKeyVal: 'becf5274-8908-11ea-8e56-0a580a3c10cd|ec70917e-8909-11ea-95eb-0a580a3f8e05',Param_TechMetaData:'#(TechMetaData_expectedResponse)'}
    * def result = call read('classpath:CA/Features/ReUsable/Dynamodb.feature@@GetItemMAMAssetInfo') {Param_TableName: 'CA_MAM_ASSETS_INFO_EU-qa',Param_PartitionKey: 'assetId', Param_SortKey: 'compositeViewsId',ParamPartionKeyVal: 'd03eedd4-e345-11ea-9814-0a580a3f06a0', ParamSortKeyVal: 'c7197d98-8907-11ea-983a-0a580a3d1fe6|3a32b7ae-8908-11ea-958b-0a580a3c10cd',Param_TechMetaData:'#(TechMetaData_expectedResponse)'}
    * def result = call read('classpath:CA/Features/ReUsable/Dynamodb.feature@@GetItemMAMAssetInfo') {Param_TableName: 'CA_MAM_ASSETS_INFO_EU-qa',Param_PartitionKey: 'assetId', Param_SortKey: 'compositeViewsId',ParamPartionKeyVal: 'd03eedd4-e345-11ea-9814-0a580a3f06a0', ParamSortKeyVal: 'e1706402-934f-11ea-b2e1-0a580a3cb9b9|a86a5f8c-c5ae-11ea-8c30-0a580a3ebc6b',Param_TechMetaData:'#(TechMetaData_expectedResponse)'}

    #* print '-----------------Validate Paload to Wochit , File Name , Rendition Status for 16x9----------------'
    * def Expected_VideoUpdates = read('classpath:CA/Tests/E2ECases/Nordic_Region/Norway/' + <TestCaseID> +'/Output/Expected_VideoUpdates.txt')
    * replace Expected_VideoUpdates.TTBR = RandomSeriesTitle
    * replace Expected_VideoUpdates.CallOutText = RandomCalloutText
    * replace Expected_VideoUpdates.CTA = RandomCTA
    * replace Expected_VideoUpdates.AR = '16x9'
    * def Expected_TimelineItems = read('classpath:CA/Tests/E2ECases/Nordic_Region/Norway/' + <TestCaseID> +'/Output/Expected_TimelineItems.txt')
    * def Expected_Status = read('classpath:CA/Tests/E2ECases/Nordic_Region/Norway/' + <TestCaseID> +'/Output/Expected_Status.txt')
    * def ExpectedItem_AspectRatio_TemplateID = read('classpath:CA/Tests/E2ECases/Nordic_Region/Norway/' + <TestCaseID> +'/Output/Expected16_9_Item_AspectRatio_TemplateID.txt')

    * def result = call read('classpath:CA/Features/ReUsable/Dynamodb.feature@ValidateWochitPayload') {Param_TableName: 'CA_WOCHIT_RENDITIONS_EU-qa',Param_ScanAttr:'aspectRatio',Param_ScanVal:'ASPECT_16_9',Param_Expected_VideoUpdates:'#(Expected_VideoUpdates)',Param_Expected_Item_AspectRatio_TemplateID: '#(Param_Expected_Item_AspectRatio_TemplateID)',Param_Expected_TimelineItems:'#(Expected_TimelineItems)',Param_Expected_Status:'#(Expected_Status)'}
   

   # * print '-----------------Validate Paload to Wochit , File Name , Rendition Status for 4x5----------------'
   # * replace Expected_VideoUpdates.AR = '4x5'
   # * def Param_Expected_Item_AspectRatio_TemplateID = read('classpath:CA/Tests/E2ECases/Nordic_Region/Norway/' + <TestCaseID> +'/Output/Expected4_5_Item_AspectRatio_TemplateID.txt')

    #* def result = call read('classpath:CA/Features/ReUsable/Dynamodb.feature@ValidateWochitPayload') {Param_TableName: 'CA_WOCHIT_RENDITIONS_EU-qa',Param_ScanAttr:'aspectRatio',Param_ScanVal:'ASPECT_4_5',Param_Expected_VideoUpdates:'#(Expected_VideoUpdates)',Param_Expected_Item_AspectRatio_TemplateID: '#(Expected_Item_AspectRatio_TemplateID)',Param_Expected_TimelineItems:'#(Expected_TimelineItems)',Param_Expected_Status:'#(Expected_Status)'}
   
    * print '-------Executed--------'
    Examples:
        | TestCaseID               | ExpectedMAMAssetInfoCount|ExpectedWocRenditionCount|ExpectedWochitMappingCount|
        | 'Nordic_Norway_Cmb001'   |       5                  |  3                      |     3                    |

