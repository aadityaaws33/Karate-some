function() {  

  try {
    karate.read('classpath:target/test-classes/Results.json')
  } catch (err) {
    karate.write([],'test-classes/Results.json');
  }
  
  var config = {
    // Auth_Token, App_ID are common for all iconik stuff
    Auth_Token: 'eyJhbGciOiJIUzI1NiIsImlhdCI6MTU4NjA5NjczOCwiZXhwIjoxOTAxNTU2NzM4fQ.eyJpZCI6IjUyNGFjZTU2LTc3NDktMTFlYS04ZmI4LTBhNTgwYTNjMTBmOSJ9.ixPYfczc55WD0Qzzg4-CcL_ILm89HtXxGBHuZZh0U7U',
    App_ID: '511aba46-7749-11ea-b4d1-0a580a3ebcc5',
    // Iconik_UserId: 'db01ddf8-1d57-11ea-9366-0a580a3f8f79',
    Iconik_UserId: 'custom-qa-user-id',
    Iconik_CustomActionListURL: 'https://app.iconik.io/API/assets/v1/custom_actions/',
    // UpdateSeasonURL and UpdateEpisodeURL is unique for each country
    // NORWAY
    AssetIDNorway: 'd03eedd4-e345-11ea-9814-0a580a3f06a0',
    UpdateSeasonURLNorway: 'https://app.iconik.io/API/metadata/v1/collections/b78432bc-e03f-11ea-a22d-0a580a3c35aa/views/4cf68d80-890c-11ea-bdcd-0a580a3c35b3/',
    UpdateEpisodeURLNorway: 'https://app.iconik.io/API/metadata/v1/assets/d03eedd4-e345-11ea-9814-0a580a3f06a0/views/6be501e6-890b-11ea-958b-0a580a3c10cd/',
    TriggerRenditionURLNorway: 'https://qa.creatives.dplayautomation.com/caadapter/creative/trigger',
    Iconik_CollectionIDNorway: 'b78432bc-e03f-11ea-a22d-0a580a3c35aa',
    Iconik_CustomActionNorway: 'EU-Trigger Rendition QA',
    // NETHERLANDS
    AssetIDNetherlands: '90fedfd0-f7e5-11ea-9ff7-0a580a3fed90',
    UpdateSeasonURLNetherlands: 'https://app.iconik.io/API/metadata/v1/collections/53823be8-f7e5-11ea-97b5-0a580a3c0c6b/views/1f708f46-e771-11ea-b4dd-0a580a3c8cb3/',
    UpdateEpisodeURLNetherlands: 'https://app.iconik.io/API/metadata/v1/assets/90fedfd0-f7e5-11ea-9ff7-0a580a3fed90/views/83a5bfc2-e771-11ea-afed-0a580a3c2c48/',
    TriggerRenditionURLNetherlands: 'https://qa.creatives.dplayautomation.com/caadapter/creative/trigger',
    Iconik_CollectionIDNetherlands: '53823be8-f7e5-11ea-97b5-0a580a3c0c6b',
    Iconik_CustomActionNetherlands: 'EU-Trigger Rendition QA',
    // JAPAN
    AssetIDJapan: 'e122a862-12b5-11eb-ad03-0a580a3c653c',
    // Unused: UpdateSeason and UpdateEpisode
    // UpdateSeasonURLJapan: 'https://app.iconik.io/API/metadata/v1/collections/53823be8-f7e5-11ea-97b5-0a580a3c0c6b/views/1f708f46-e771-11ea-b4dd-0a580a3c8cb3/',
    // UpdateEpisodeURLJapan: 'https://app.iconik.io/API/metadata/v1/assets/90fedfd0-f7e5-11ea-9ff7-0a580a3fed90/views/83a5bfc2-e771-11ea-afed-0a580a3c2c48/',
    TriggerRenditionURLJapan: 'https://qa.apac.creatives.dplayautomation.com/caadapter/creative/trigger',
    Iconik_CollectionIDJapan: '97d99e12-f8b2-11ea-97e3-0a580a3ee6da',
    Iconik_CustomActionJapan: 'APAC-Trigger Rendition  QA'
  };
  
  karate.log(config);
  return config;
}


