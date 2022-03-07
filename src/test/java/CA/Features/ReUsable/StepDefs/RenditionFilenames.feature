Feature: Rendition Filenames

@GetAllRenditionFilenames
Scenario: Get All Rendition Filenames
    * def splitAttributeEntries =
        """
            function(entry) {
                if(!entry) {
                    return []
                }
                var entrySplit = entry.split('|');
                return entrySplit
            }
        """
    * def combineToRenditionFileName =
        """
            function(entries, renditionFileNames, separator) {
                if(!separator) {
                    var separator = 'name';
                }
                var newRenditionFileNames = [];
                for(var i in entries) {
                    for(var j in renditionFileNames) {
                        if(separator == 'name') {
                            var separatorSymbol = '-';
                            newRenditionFileNames.push(renditionFileNames[j].replace('/', '') + separatorSymbol + entries[i]);
                        } else if(separator == 'bar') {
                            var separatorSymbol = '|';
                            newRenditionFileNames.push(renditionFileNames[j].replace('/', '') + separatorSymbol + entries[i]);
                        } else if(separator == 'name+bar') {
                            newRenditionFileNames.push(renditionFileNames[j].replace('/', '') + '-' + entries[i] + '|' + entries[i]);
                        }
                    }
                }
                
                return newRenditionFileNames
            }
        """
    * def getAllRenditionFileNames =
        """
            function(InputMetadata, IconikMetadata) {
                var renditionFileNames = [];

                var assetName = IconikMetadata.IconikSourceAssetName;
                var IconikAspectRatios = splitAttributeEntries(InputMetadata.DBAspectRatios);
                var titleCardTypes = splitAttributeEntries(InputMetadata.TitleCardTypes);
                var ctas = splitAttributeEntries(InputMetadata.SomeCTA);
                ctas.push(InputMetadata.CustomStrapOutroCTA.replace('/', ''));
                for(var i in IconikAspectRatios) {
                    renditionFileNames.push(assetName + '-' + IconikAspectRatios[i]);
                }

                renditionFileNames = combineToRenditionFileName(titleCardTypes, renditionFileNames);
                renditionFileNames = combineToRenditionFileName(ctas, renditionFileNames);

                // -------------- not part of renditionFileName but needs to be counted ---------------------
                var strapTypes = splitAttributeEntries(InputMetadata.StrapTypes);
                // FILTER OUT NO STRAP
                var straps = [];
                var hasNoStrap = false;
                for(var i in strapTypes) {
                    karate.log(strapTypes[i]);
                    if(strapTypes[i] == 'No Strap') {
                        hasNoStrap = true;
                    } else {
                        straps.push(strapTypes[i]);
                    }
                }
                
                if(hasNoStrap && straps.length > 0 && Duration <= 10) {
                    karate.fail('CONFIGURATION ERROR: VIDEOS WITH LESS THAN 10s DURATION CAN ONLY HAVE NO STRAP!');
                }
                
                // ALL STRAPS THAT ARE NOT 'No Strap'
                var renditionFileNamesStraps = [];

                if(InputMetadata.Partner != 'NONE') {
                    renditionFileNamesStraps = combineToRenditionFileName([InputMetadata.Partner], renditionFileNames)
                }
                karate.log('Straps: ' + karate.pretty(straps));
                renditionFileNamesStraps = combineToRenditionFileName(straps, renditionFileNamesStraps, 'bar');

                // 'No Strap'
                var renditionFileNamesNoStraps = [];
                if(hasNoStrap) {
                    renditionFileNamesNoStraps = combineToRenditionFileName(['No Strap'], renditionFileNames);
                    if(InputMetadata.Partner != 'NONE') {
                        renditionFileNamesNoStraps = combineToRenditionFileName([InputMetadata.Partner], renditionFileNames);
                    }
                    renditionFileNamesNoStraps = combineToRenditionFileName(['No Strap'], renditionFileNames, 'bar');
                }
  
                renditionFileNames = renditionFileNamesNoStraps.concat(renditionFileNamesStraps);
                
                if('ColourSchemes' in InputMetadata) {
                    var colourSchemes = splitAttributeEntries(InputMetadata.ColourSchemes);
                    renditionFileNames = combineToRenditionFileName(colourSchemes, renditionFileNames, 'bar');
                }

                return renditionFileNames
            }
        """
    * def result = getAllRenditionFileNames(InputMetadata, IconikMetadata)