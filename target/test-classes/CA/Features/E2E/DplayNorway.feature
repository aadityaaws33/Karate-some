Feature:  Dplay Norway CA

 
@DPLAY
Scenario: Sample POC for Dplay CA 
#------------Season Request-------------------
* url 'https://app.iconik.io/API/metadata/v1/collections/b78432bc-e03f-11ea-a22d-0a580a3c35aa/views/4cf68d80-890c-11ea-bdcd-0a580a3c35b3/'
* header Auth-Token = 'eyJhbGciOiJIUzI1NiIsImlhdCI6MTU4NjA5NjczOCwiZXhwIjoxOTAxNTU2NzM4fQ.eyJpZCI6IjUyNGFjZTU2LTc3NDktMTFlYS04ZmI4LTBhNTgwYTNjMTBmOSJ9.ixPYfczc55WD0Qzzg4-CcL_ILm89HtXxGBHuZZh0U7U'
* header App-ID = '511aba46-7749-11ea-b4d1-0a580a3ebcc5'
    When request
      """
      {
      "metadata_values": {
      "no-dplay-SeriesTitle": {
          "field_values": [
              {
                  "value": "CA\nQA Automation\nTitle_0004 \n"
              }
          ]
      },
      "no-dplay-Logo": {
          "field_values": [
              {
                  "value": "3"
              }
          ]
      },
      "no-dplay-ColouredBox": {
          "field_values": [
              {
                  "value": "Putty"
              }
          ]
      },
      "no-dplay-Scribble16x9": {
          "field_values": [
              {
                  "value": "2"
              }
          ]
      },
      "no-dplay-Scribble1x1": {
          "field_values": [
              {
                  "value": "2"
              }
          ]
      },
      "no-dplay-Scribble4x5": {
          "field_values": [
              {
                  "value": "2"
              }
          ]
      },
      "no-dplay-Scribble9x16": {
          "field_values": [
              {
                  "value": "2"
              }
          ]
      }
      }
      }
      """
    And method put
    * print '----------Response------------->'+response
    Then status 200
    And match response == 
    """
    {
    "date_created": null,
    "date_modified": null,
    "metadata_values": {
      "__separator__": {
          "date_created": null,
          "field_values": []
      },
      "no-dplay-ColouredBox": {
          "date_created": '#notnull',
          "field_values": [
              {
                  "value": "Putty"
              }
          ]
      },
      "no-dplay-Logo": {
          "date_created": '#notnull',
          "field_values": [
              {
                  "value": "3"
              }
          ]
      },
      "no-dplay-Scribble16x9": {
          "date_created": '#notnull',
          "field_values": [
              {
                  "value": "2"
              }
          ]
      },
      "no-dplay-Scribble1x1": {
          "date_created": '#notnull',
          "field_values": [
              {
                  "value": "2"
              }
          ]
      },
      "no-dplay-Scribble4x5": {
          "date_created": '#notnull',
          "field_values": [
              {
                  "value": "2"
              }
          ]
      },
      "no-dplay-Scribble9x16": {
          "date_created": '#notnull',
          "field_values": [
              {
                  "value": "2"
              }
          ]
      },
      "no-dplay-SeriesTitle": {
          "date_created": '#notnull',
          "field_values": [
              {
                  "value": "CA\nQA Automation\nTitle_0004 \n"
              }
          ]
      }
    },
    "object_id": "b78432bc-e03f-11ea-a22d-0a580a3c35aa",
    "object_type": "collections",
    "version_id": "b78432bc-e03f-11ea-a22d-0a580a3c35aa"
    }
    """
    #------------Episode Request-------------------
  * url 'https://app.iconik.io/API/metadata/v1/assets/d03eedd4-e345-11ea-9814-0a580a3f06a0/views/6be501e6-890b-11ea-958b-0a580a3c10cd/'
  * header Auth-Token = 'eyJhbGciOiJIUzI1NiIsImlhdCI6MTU4NjA5NjczOCwiZXhwIjoxOTAxNTU2NzM4fQ.eyJpZCI6IjUyNGFjZTU2LTc3NDktMTFlYS04ZmI4LTBhNTgwYTNjMTBmOSJ9.ixPYfczc55WD0Qzzg4-CcL_ILm89HtXxGBHuZZh0U7U'
  * header App-ID = '511aba46-7749-11ea-b4d1-0a580a3ebcc5'
  When request
  """
    {
      "metadata_values": {
          "no-dplay-OutputAspectRatio": {
              "field_values": [
                  {
                      "label": "1x1",
                      "value": "1x1"
                  },
                  {
                      "label": "16x9",
                      "value": "16x9"
                  },
                  {
                      "label": "4x5",
                      "value": "4x5"
                  }
              ]
          },
          "no-dplay-TagIn": {
              "field_values": [
                  {
                      "value": "2"
                  }
              ]
          },
          "no-dplay-CalloutText-multi": {
              "field_values": [
                  {
                      "score": 1,
                      "value": "QA Callout Text 27_8_0004"
                  }
              ]
          },
          "no-dplay-CtaText-multi": {
              "field_values": [
                  {
                      "score": 1,
                      "value": "QA CTA Text 27_8_0004"
                  }
              ]
          }
      }
    }
  """
  And method put
  * print '----------Response------------->'+response
    Then status 200
    And match response == 
    """
    {
    "date_created": null,
    "date_modified": null,
    "metadata_values": {
        "__separator__": {
            "date_created": null,
            "field_values": []
        },
        "no-dplay-CalloutList-multi": {
            "date_created": null,
            "field_values": []
        },
        "no-dplay-CalloutText-multi": {
            "date_created": '#notnull',
            "field_values": [
                {
                    "score": 1,
                    "value": "QA Callout Text 27_8_0004"
                }
            ]
        },
        "no-dplay-CtaList-multi": {
            "date_created": null,
            "field_values": []
        },
        "no-dplay-CtaText-multi": {
            "date_created": '#notnull',
            "field_values": [
                {
                    "score": 1,
                    "value": "QA CTA Text 27_8_0004"
                }
            ]
        },
        "no-dplay-OutputAspectRatio": {
            "date_created": '#notnull',
            "field_values": [
                {
                    "label": "1x1",
                    "value": "1x1"
                },
                {
                    "label": "16x9",
                    "value": "16x9"
                },
                {
                    "label": "4x5",
                    "value": "4x5"
                }
            ]
        },
        "no-dplay-TagIn": {
            "date_created": '#notnull',
            "field_values": [
                {
                    "value": "2"
                }
            ]
        },
        "no-dplay-isNoTagRequired": {
            "date_created": null,
            "field_values": []
        }
    },
    "object_id": "d03eedd4-e345-11ea-9814-0a580a3f06a0",
    "object_type": "assets",
    "version_id": "d03f2eca-e345-11ea-9814-0a580a3f06a0"
    }
    """
    #---------------API Gateway---------------------
  * url 'https://qa.creatives.dplayautomation.com/caadapter/media/inbound'
  * header Auth-Token = 'eyJhbGciOiJIUzI1NiIsImlhdCI6MTU4NjA5NjczOCwiZXhwIjoxOTAxNTU2NzM4fQ.eyJpZCI6IjUyNGFjZTU2LTc3NDktMTFlYS04ZmI4LTBhNTgwYTNjMTBmOSJ9.ixPYfczc55WD0Qzzg4-CcL_ILm89HtXxGBHuZZh0U7U'
  * header App-ID = '511aba46-7749-11ea-b4d1-0a580a3ebcc5'
  When request
  """
    {
      "user_id": "db01ddf8-1d57-11ea-9366-0a580a3f8f79",
      "system_domain_id": "da4c0aaa-1d57-11ea-93d8-0a580a3cb9a8",
      "context": "ASSET",
      "action_id": "fd02ac0a-99fa-11ea-8151-0a580a3ee649",
      "asset_ids": [
        "d03eedd4-e345-11ea-9814-0a580a3f06a0"
      ],
      "collection_ids": [],
      "saved_search_ids": [],
      "metadata_view_id": null,
      "metadata_values": null,
      "date_created": "2020-08-21T00:40:34.377229",
      "auth_token": "eyJhbGciOiJIUzI1NiIsImlhdCI6MTU5Nzk3MDQzNCwiZXhwIjoxNTk4MDEzNjM0fQ.eyJpZCI6ImVjOTE5MWYyLWUzNDYtMTFlYS1iYzczLTBhNTgwYTNkMWYxYiJ9.QGeookJH-domsFAyO4BKKLbiVQyIqsV_-E4GOdvlIaM"
    }
  """
  And method post
  And match response ==
  """
  {
    "statusCode": 200,
    "apiError": {
        "message": null,
        "errors": null
    },
    "mamAssetInfo": [
        {
            "createdAt": '#notnull',
            "modifiedAt": '#notnull',
            "createdBy": "ca-iconik-inbound-api-EU-qa",
            "modifiedBy": "ca-iconik-inbound-api-EU-qa",
            "assetId": "d03eedd4-e345-11ea-9814-0a580a3f06a0",
            "compositeViewsId": "adb2fec4-934d-11ea-bcbe-0a580a3c65d4|4cf68d80-890c-11ea-bdcd-0a580a3c35b3",
            "assetTitle": "DAQ CA Test_1.mp4",
            "assetMetadata": {
                "id": "adb2fec4-934d-11ea-bcbe-0a580a3c65d4",
                "name": "Dplay w/o Endboard - Asset Metadata (Norway)",
                "objectId": "d03eedd4-e345-11ea-9814-0a580a3f06a0",
                "objectName": "DAQ CA Test_1.mp4",
                "objectType": "assets",
                "objectFilePath": "DAQ CA Test_1.mp4",
                "data": {
                    "no-dplaywoeb-TagIn": "",
                    "no-dplaywoeb-isNoTagRequired": "",
                    "no-dplaywoeb-OutputAspectRatio": "",
                    "no-dplaywoeb-CtaList-multi": "",
                    "no-dplaywoeb-CtaText-multi": ""
                }
            },
            "episodeMetadata": {
                "id": null,
                "name": null,
                "objectId": "ba077850-e03f-11ea-8124-0a580a3c8ca8",
                "objectName": "QA Episode 1",
                "objectType": "collections",
                "objectFilePath": null,
                "data": null
            },
            "seasonMetadata": {
                "id": "4cf68d80-890c-11ea-bdcd-0a580a3c35b3",
                "name": "Dplay Season Metadata (Norway)",
                "objectId": "b78432bc-e03f-11ea-a22d-0a580a3c35aa",
                "objectName": "QA Season",
                "objectType": "collections",
                "objectFilePath": null,
                "data": {
                    "no-dplay-Scribble16x9": "2",
                    "no-dplay-Scribble1x1": "2",
                    "no-dplay-SeriesTitle": "CA\nQA Automation\nTitle_0004 \n",
                    "no-dplay-Logo": "3",
                    "no-dplay-Scribble4x5": "2",
                    "no-dplay-Scribble9x16": "2",
                    "no-dplay-ColouredBox": "Putty"
                }
            },
            "seriesMetadata": {
                "id": null,
                "name": null,
                "objectId": "afe338aa-e03f-11ea-874c-0a580a3c2cd7",
                "objectName": "QA Series",
                "objectType": "collections",
                "objectFilePath": null,
                "data": null
            },
            "technicalMetadata": {
                "id": "488545e4-8398-11ea-87ea-0a580a3c35ce",
                "name": "Asset Metadata",
                "objectId": "d03eedd4-e345-11ea-9814-0a580a3f06a0",
                "objectName": "DAQ CA Test_1.mp4",
                "objectType": "assets",
                "objectFilePath": null,
                "data": {
                    "Format": "MPEG-4|AVC|AAC",
                    "Approved": "",
                    "Duration": "30000",
                    "Height": "1080",
                    "Width": "1920",
                    "Tags": "",
                    "FileSize": "34674856"
                }
            },
            "renditionMetadata": null,
            "keyArts": null,
            "country": "NORWAY",
            "assetType": "VIDEO",
            "onlyNoTagRequired": false
        },
        {
            "createdAt": '#notnull',
            "modifiedAt": '#notnull',
            "createdBy": "ca-iconik-inbound-api-EU-qa",
            "modifiedBy": "ca-iconik-inbound-api-EU-qa",
            "assetId": "d03eedd4-e345-11ea-9814-0a580a3f06a0",
            "compositeViewsId": "6be501e6-890b-11ea-958b-0a580a3c10cd|4cf68d80-890c-11ea-bdcd-0a580a3c35b3",
            "assetTitle": "DAQ CA Test_1.mp4",
            "assetMetadata": {
                "id": "6be501e6-890b-11ea-958b-0a580a3c10cd",
                "name": "Dplay Asset Metadata (Norway)",
                "objectId": "d03eedd4-e345-11ea-9814-0a580a3f06a0",
                "objectName": "DAQ CA Test_1.mp4",
                "objectType": "assets",
                "objectFilePath": "DAQ CA Test_1.mp4",
                "data": {
                    "no-dplay-CalloutText-multi": "QA Callout Text 27_8_0004",
                    "no-dplay-CalloutList-multi": "",
                    "no-dplay-CtaList-multi": "",
                    "no-dplay-TagIn": "2",
                    "no-dplay-isNoTagRequired": "",
                    "no-dplay-OutputAspectRatio": "1x1|16x9|4x5",
                    "no-dplay-CtaText-multi": "QA CTA Text 27_8_0004"
                }
            },
            "episodeMetadata": {
                "id": null,
                "name": null,
                "objectId": "ba077850-e03f-11ea-8124-0a580a3c8ca8",
                "objectName": "QA Episode 1",
                "objectType": "collections",
                "objectFilePath": null,
                "data": null
            },
            "seasonMetadata": {
                "id": "4cf68d80-890c-11ea-bdcd-0a580a3c35b3",
                "name": "Dplay Season Metadata (Norway)",
                "objectId": "b78432bc-e03f-11ea-a22d-0a580a3c35aa",
                "objectName": "QA Season",
                "objectType": "collections",
                "objectFilePath": null,
                "data": {
                    "no-dplay-Scribble16x9": "2",
                    "no-dplay-Scribble1x1": "2",
                    "no-dplay-SeriesTitle": "CA\nQA Automation\nTitle_0004 \n",
                    "no-dplay-Logo": "3",
                    "no-dplay-Scribble4x5": "2",
                    "no-dplay-Scribble9x16": "2",
                    "no-dplay-ColouredBox": "Putty"
                }
            },
            "seriesMetadata": {
                "id": null,
                "name": null,
                "objectId": "afe338aa-e03f-11ea-874c-0a580a3c2cd7",
                "objectName": "QA Series",
                "objectType": "collections",
                "objectFilePath": null,
                "data": null
            },
            "technicalMetadata": {
                "id": "488545e4-8398-11ea-87ea-0a580a3c35ce",
                "name": "Asset Metadata",
                "objectId": "d03eedd4-e345-11ea-9814-0a580a3f06a0",
                "objectName": "DAQ CA Test_1.mp4",
                "objectType": "assets",
                "objectFilePath": null,
                "data": {
                    "Format": "MPEG-4|AVC|AAC",
                    "Approved": "",
                    "Duration": "30000",
                    "Height": "1080",
                    "Width": "1920",
                    "Tags": "",
                    "FileSize": "34674856"
                }
            },
            "renditionMetadata": null,
            "keyArts": null,
            "country": "NORWAY",
            "assetType": "VIDEO",
            "onlyNoTagRequired": false
        },
        {
            "createdAt": '#notnull',
            "modifiedAt": '#notnull',
            "createdBy": "ca-iconik-inbound-api-EU-qa",
            "modifiedBy": "ca-iconik-inbound-api-EU-qa",
            "assetId": "d03eedd4-e345-11ea-9814-0a580a3f06a0",
            "compositeViewsId": "e1706402-934f-11ea-b2e1-0a580a3cb9b9|a86a5f8c-c5ae-11ea-8c30-0a580a3ebc6b",
            "assetTitle": "DAQ CA Test_1.mp4",
            "assetMetadata": {
                "id": "e1706402-934f-11ea-b2e1-0a580a3cb9b9",
                "name": "Dplay Endboard Only - Asset Metadata (Norway)",
                "objectId": "d03eedd4-e345-11ea-9814-0a580a3f06a0",
                "objectName": "DAQ CA Test_1.mp4",
                "objectType": "assets",
                "objectFilePath": "DAQ CA Test_1.mp4",
                "data": {
                    "no-dplayebo-isNoTagRequired": "",
                    "no-dplayebo-CalloutText-multi": "",
                    "no-dplayebo-CalloutList-multi": "",
                    "no-dplayebo-CtaList-multi": "",
                    "no-dplayebo-OutputAspectRatio": "",
                    "no-dplayebo-CtaText-multi": ""
                }
            },
            "episodeMetadata": {
                "id": null,
                "name": null,
                "objectId": "ba077850-e03f-11ea-8124-0a580a3c8ca8",
                "objectName": "QA Episode 1",
                "objectType": "collections",
                "objectFilePath": null,
                "data": null
            },
            "seasonMetadata": {
                "id": "a86a5f8c-c5ae-11ea-8c30-0a580a3ebc6b",
                "name": "Dplay Endboard Only - Season Metadata (Norway)",
                "objectId": "b78432bc-e03f-11ea-a22d-0a580a3c35aa",
                "objectName": "QA Season",
                "objectType": "collections",
                "objectFilePath": null,
                "data": {
                    "no-dplay-SeriesTitle": "CA\nQA Automation\nTitle_0004 \n",
                    "no-dplayebo-Scribble4x5": "",
                    "no-dplayebo-ColouredBox": "",
                    "no-dplayebo-Scribble9x16": "",
                    "no-dplayebo-Scribble16x9": "",
                    "no-dplayebo-Scribble1x1": "",
                    "no-dplayebo-Logo": ""
                }
            },
            "seriesMetadata": {
                "id": null,
                "name": null,
                "objectId": "afe338aa-e03f-11ea-874c-0a580a3c2cd7",
                "objectName": "QA Series",
                "objectType": "collections",
                "objectFilePath": null,
                "data": null
            },
            "technicalMetadata": {
                "id": "488545e4-8398-11ea-87ea-0a580a3c35ce",
                "name": "Asset Metadata",
                "objectId": "d03eedd4-e345-11ea-9814-0a580a3f06a0",
                "objectName": "DAQ CA Test_1.mp4",
                "objectType": "assets",
                "objectFilePath": null,
                "data": {
                    "Format": "MPEG-4|AVC|AAC",
                    "Approved": "",
                    "Duration": "30000",
                    "Height": "1080",
                    "Width": "1920",
                    "Tags": "",
                    "FileSize": "34674856"
                }
            },
            "renditionMetadata": null,
            "keyArts": null,
            "country": "NORWAY",
            "assetType": "VIDEO",
            "onlyNoTagRequired": false
        }
    ]
}
  """