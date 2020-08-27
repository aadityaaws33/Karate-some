Feature:  Dplay
Background:
  Given url 'https://app.iconik.io/API/metadata/v1/collections/b78432bc-e03f-11ea-a22d-0a580a3c35aa/views/4cf68d80-890c-11ea-bdcd-0a580a3c35b3/'
  And header Auth-Token = 'eyJhbGciOiJIUzI1NiIsImlhdCI6MTU4NjA5NjczOCwiZXhwIjoxOTAxNTU2NzM4fQ.eyJpZCI6IjUyNGFjZTU2LTc3NDktMTFlYS04ZmI4LTBhNTgwYTNjMTBmOSJ9.ixPYfczc55WD0Qzzg4-CcL_ILm89HtXxGBHuZZh0U7U'
  And header App-ID = '511aba46-7749-11ea-b4d1-0a580a3ebcc5'

@dplay
Scenario: Create New IOI with Dynamic Status Query Parameter

    When request
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
        "date_created": "2020-08-27T03:34:05.249000+00:00",
        "field_values": [
        {
        "value": "Putty"
        }
        ]
        },
        "no-dplay-Logo": {
        "date_created": "2020-08-27T03:34:05.249000+00:00",
        "field_values": [
        {
        "value": "3"
        }
        ]
        },
        "no-dplay-Scribble16x9": {
        "date_created": "2020-08-27T03:34:05.249000+00:00",
        "field_values": [
        {
        "value": "2"
        }
        ]
        },
        "no-dplay-Scribble1x1": {
        "date_created": "2020-08-27T03:34:05.249000+00:00",
        "field_values": [
        {
        "value": "2"
        }
        ]
        },
        "no-dplay-Scribble4x5": {
        "date_created": "2020-08-27T03:34:05.249000+00:00",
        "field_values": [
        {
        "value": "2"
        }
        ]
        },
        "no-dplay-Scribble9x16": {
        "date_created": "2020-08-27T03:34:05.250000+00:00",
        "field_values": [
        {
        "value": "2"
        }
        ]
        },
        "no-dplay-SeriesTitle": {
        "date_created": "2020-08-27T03:34:05.249000+00:00",
        "field_values": [
        {
        "value": "CA\nQA Automation\nTitle_0002 \n"
        }
        ]
        }
        },
        "object_id": "b78432bc-e03f-11ea-a22d-0a580a3c35aa",
        "object_type": "collections",
        "version_id": "b78432bc-e03f-11ea-a22d-0a580a3c35aa"
      }
      """
    And method put
    #And def IOIID = get[0] response..buyInterestId
    * print '----------Response------------->'+response
