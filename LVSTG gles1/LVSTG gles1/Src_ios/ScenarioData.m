//
//  *scenario.m
//  MMD4U
//
//  Created by Rocky on 2013/05/06.
//  Copyright (c) 2013年 twincle4u. All rights reserved.
//

#import "ScenarioData.h"
#import "DocumentController.h"
#import <MediaPlayer/MediaPlayer.h>

@interface ScenarioData()

@end


@implementation ScenarioData

@synthesize documentController = _documentController;
@synthesize scenarioInfoDict= _scenarioInfoDict;
@synthesize scenarioInfoModelList = _scenarioInfoModelList;

@synthesize scenarioInfoIndexPath = _scenarioInfoIndexPath;
@synthesize zipIndexPath = _zipIndexPath;
@synthesize mediaItemCollection = _mediaItemCollection;
@synthesize title = _currentTitle;
@synthesize modelPath = _currentModelPath;
@synthesize modelZipPath = _currentModelZipPath;
@synthesize musicTitle = _currentMusicTitle;
@synthesize motionZipPath = _currentMotionZipPath;
@synthesize motionPath = _currentMotionPath;
@synthesize musicId = _currentMusicId;
@synthesize usePhysics = _usePhysics;
@synthesize positionX = _positionX;
@synthesize positionY = _posttionY;
@synthesize positionZ = _positionZ;
@synthesize lookatDX = _lookatDX;
@synthesize lookatDY = _lookatDY;
@synthesize lookatDZ = _lookatDZ;


-(void)saveScenarioListFile
{
    [_documentController saveScenarioListFile];
}

-(NSInteger)loadScenarioListFile
{
    return [_documentController loadScenarioListFile];
}

-(void)saveModelListFile
{
    [_documentController saveModelListFile];
}

-(NSInteger)loadModelListFile
{
    return [_documentController loadModelListFile];
}

-(void)saveMotionListFile
{
    [_documentController saveMotionListFile];
}

-(NSInteger)loadMotionListFile
{
    return [_documentController loadMotionListFile];
}

-(void)saveScenarioGroupListFile
{
    [_documentController saveScenarioGroupListFile];
}

-(NSInteger)loadScenarioGroupListFile
{
    return [_documentController loadScenarioGroupListFile];
}

-(void)saveModelGroupListFile
{
    [_documentController saveModelGroupListFile];
}

-(NSInteger)loadModelGroupListFile
{
    return [_documentController loadModelGroupListFile];
}

-(void)saveMotionGroupListFile
{
    [_documentController saveMotionGroupListFile];
}

-(NSInteger)loadMotionGroupListFile
{
    return [_documentController loadMotionGroupListFile];
}

-(void)loadZipListFile
{
    [_documentController loadZipListFile];
}

-(void)loadListOfModelAndMotionFromZipListDict
{
    [_documentController loadListOfModelAndMotionFromZipListDict];
}

-(void)loadCurrentScenarioInfoDict: (NSMutableDictionary*) aScenarioInfoDict
{
    NSLog(@"... ScenarioData: loadCurrentScenarioInfoDict");
    NSLog(@"... aScenarioInfoDict [%ld]", (long)[aScenarioInfoDict count]);
    _scenarioInfoDict = aScenarioInfoDict;
    _scenarioInfoModelList = _scenarioInfoDict[@"modelList"];
}

-(NSInteger)getCurrentScenarioInfoModelCount
{
    NSInteger count = 0;
    if (_scenarioInfoModelList != nil) {
        count = [_scenarioInfoModelList count];
    }

    return count;
}

-(NSMutableDictionary*)getCurrentScenarioInfoModelByOrder:(NSInteger)idx
{
    if (_scenarioInfoModelList != nil && [_scenarioInfoModelList count] > idx) {
        return _scenarioInfoModelList[idx];
    }

    return nil;
}

-(NSString*)getTargetNameForDictionary:(NSMutableDictionary*)listDict name:(NSString*)name device:(NSString*)device
{
    NSLog(@"... ScenarioData: getTargetNameForDictionary name=[%@] device[%@]", name, device);
    
    // if the name existed, add a suffix number to the name
    NSString *baseName = nil;
    NSString *targetName = nil;
    NSString *key = nil;

    int n;
    if ([name hasSuffix:@")"]) {
        NSMutableArray *arr = [[name componentsSeparatedByString:@"("] mutableCopy];
        if ([arr count] > 0) {
            NSString *str = arr[[arr count]-1];
            [arr removeObjectAtIndex:[arr count]-1];
            baseName = [arr componentsJoinedByString:@"("];
            targetName = baseName;
            str = [str substringToIndex:[str length]-1];
            n = (int)[str integerValue];
            if (n == 0) {
                n = 1;
            }
        } else {
            targetName = name;
            baseName = [NSString stringWithFormat:@"%@ ", name];
            n = 0;
        }
        
    } else {
        targetName = name;
        baseName = [NSString stringWithFormat:@"%@ ", name];
        n = 0;
    }
    
    do {
        if (n > 0) {
            targetName = [NSString stringWithFormat:@"%@(%d)",baseName, n];
        }
        n++;
        if (device != nil) {
            key = [NSString stringWithFormat:@"%@:%@",device,targetName];
        } else {
            key = targetName;
        }
        NSString *val = [listDict valueForKey:key];
        NSLog(@"... check key=[%@] val=[%@]", key, val);
    } while ([listDict valueForKey:key]);
    
    NSLog(@"... targetName=[%@], key=[%@]", targetName, key);
    
    return targetName;
}

-(void)renameObjectInDictionary:(NSMutableDictionary*)parentDict key:(NSString*)key toName:(NSString*)toName
{
    NSLog(@"... ScenarioData: renameObjectInDictionary");
    NSString *newKey = nil;
    
    if (parentDict != nil) {
        NSMutableDictionary *listDict = [parentDict valueForKey:@"listDict"];
        NSMutableDictionary *dictInfo = [listDict valueForKey:key];

        if (key != nil && toName != nil) {
            NSString *device = [dictInfo valueForKey:@"device"];
            NSString *newName = [self getTargetNameForDictionary:parentDict name:toName device:device];
            if (device != nil) {
                // non group object
                newKey = [NSString stringWithFormat:@"%@:%@",device,newName];
            } else{
                // group object
                newKey = newName;
                NSString *path = [dictInfo valueForKey:@"parentPath"];
                if (path != nil) {
                    path = [NSString stringWithFormat:@"%@/%@",path,newName];
                    [dictInfo setValue:path forKeyPath:@"path"];
                }
            }
            NSLog(@"... add new key=[%@] to obj and parent",newKey);
            [dictInfo setValue:newKey forKey:@"key"];
            [dictInfo setValue:newName forKey:@"name"];
            [listDict setValue:dictInfo forKey:newKey];

            if (key != newKey) {
                NSLog(@"... removed old key=[%@] from parent",key);
                [listDict removeObjectForKey:key];
            }
            
            NSLog(@"... renamed toName [%@] device=[%@] newKey=[%@] oldKey=[%@]", newName, device, newKey, key);
        } else {
            NSLog(@"... fromName and toName are same or nil");
        }
    } else {
        NSLog(@"... dict is nil, no action");
        
    }

    // should caller save the dictionary to a file
}

-(void)addNewGroupToDictionary:(NSMutableDictionary*)groupDict rootDict:(NSMutableDictionary *)rootDict
{
    NSMutableDictionary *newGroup = [NSMutableDictionary dictionary];
    NSString *name = @" no name";
    [newGroup setValue:name forKey:@"key"];
    [newGroup setValue:@"group" forKey:@"kind"];

    NSString *parentPath = [groupDict valueForKey:@"path"];
    NSMutableDictionary *listDict = [NSMutableDictionary dictionary];
    [newGroup setValue:listDict forKey:@"listDict"];
    
    NSString *newName = [self getTargetNameForDictionary:groupDict name:name device:nil];
    NSString *newPath = [NSString stringWithFormat:@"%@/%@", parentPath, newName];
    [newGroup setValue:newPath forKeyPath:@"path"];
    
    NSMutableDictionary *pathDict = [rootDict valueForKeyPath:@"pathDict"];
    [pathDict setValue:newGroup forKeyPath:newPath];
    
    NSLog(@"... added new object[%@] key=[%@] to groupDict", newGroup, newName);

    [[groupDict valueForKey:@"listDict"] setValue:newGroup forKey:newName];
    
}

-(void)addNewGroupToScenarioGroupDict:(NSMutableDictionary*)groupDict
{
    NSMutableDictionary *rootDict = [_documentController getScenarioGroupListDict];
    [self addNewGroupToDictionary:groupDict rootDict:rootDict];
}

-(void)addNewGroupToModelGroupDict:(NSMutableDictionary*)groupDict
{
    NSMutableDictionary *rootDict = [_documentController getModelGroupListDict];
    [self addNewGroupToDictionary:groupDict rootDict:rootDict];
    
}

-(void)addNewGroupToMotionGroupDict:(NSMutableDictionary*)groupDict
{
    NSMutableDictionary *rootDict = [_documentController getMotionGroupListDict];
    [self addNewGroupToDictionary:groupDict rootDict:rootDict];
    
}

-(void)saveChildDict:(NSMutableDictionary*)childDict withName:(NSString*)name IntoParentDict:(NSMutableDictionary*)parentDict
{
    NSLog(@"... ScenarioData: saveChildDict");
    
    // if the name existed, add a suffix number to the name
    NSString *device = [childDict valueForKey:@"device"];
    NSString *targetName = [self getTargetNameForDictionary:parentDict name:name device:device];
 
    [childDict setObject:targetName forKey:@"name"];
    NSString *key = targetName;
    if (device != nil) {
        key = [NSString stringWithFormat:@"%@:%@",device,targetName];
    }
    NSLog(@"... add new key=[%@] to obj and parent",key);
    [childDict setValue:key forKey:@"key"];
    
    [parentDict setValue:childDict forKey:key];
    
    NSLog(@"... ScenarioData: saveChildDict name[%@] to targetName[%@] key=[%@]", name, targetName, key);
    
    // please save the parnetDict into a file
}

-(void)copyScenarioFromScenarioList:(NSString*)key
{
    NSLog(@"... ScenarioData: copyScenarioFromScenarioList");

    NSMutableDictionary *scenarioListDict = [_documentController getScenarioListDict];
    NSMutableDictionary *listDict = [scenarioListDict valueForKey:@"listDict"];
    
    NSMutableDictionary *newScenarioDict = [[listDict valueForKey:key] mutableCopy];
    NSString *newName = [newScenarioDict valueForKey:@"name"];

    [self saveChildDict:newScenarioDict withName:newName IntoParentDict:listDict];
    newName = [newScenarioDict valueForKey:@"key"];
    
    NSLog(@"... ScenarioData: copyScenarioFromScenarioList copy[%@] to [%@]", key, newName);

    // save into a file
    [_documentController saveScenarioListFile];
    // refresh order of scenarioList
    [_documentController loadScenarioListFile];
}

-(void)addNewScenarioToScenarioList
{
    NSString *name = @" no name";
    
    NSMutableDictionary *scenarioDict = [NSMutableDictionary dictionary];
    [scenarioDict setObject:@"all" forKey:@"device"];
    [scenarioDict setObject:@"" forKey:@"musicTitle"];
    [scenarioDict setObject:@"0.0000" forKey:@"motionOffset"];
    [scenarioDict setObject:@"scenario" forKey:@"kind"];
    [scenarioDict setObject:@"0.6000" forKey:@"bgcolorR"];
    [scenarioDict setObject:@"0.5000" forKey:@"bgcolorB"];
    [scenarioDict setObject:@"0.5000" forKey:@"bgcolorG"];
    [scenarioDict setObject:@"0.6000" forKey:@"lightcolorR"];
    [scenarioDict setObject:@"0.6000" forKey:@"lightcolorB"];
    [scenarioDict setObject:@"0.6000" forKey:@"lightcolorG"];
    [scenarioDict setObject:@"0" forKey:@"useAntialias"];
    [scenarioDict setObject:@"0" forKey:@"physicsFact"];
    [scenarioDict setObject:@"" forKey:@"note"];

    NSMutableDictionary *scenarioListDict = [_documentController getScenarioListDict];
    NSMutableDictionary *listDict = [scenarioListDict valueForKey:@"listDict"];
    [self saveChildDict:scenarioDict withName:name IntoParentDict:listDict];

    // save into a file
    [_documentController saveScenarioListFile];
    // refresh order of scenarioList
    [_documentController loadScenarioListFile];
}

-(void)addNewModelToScenarioInfoModelList
{
    if (_scenarioInfoModelList == nil) {
        _scenarioInfoModelList = [NSMutableArray array];
        [_scenarioInfoDict setObject:_scenarioInfoModelList forKey:@"modelList"];
    }
    
    NSInteger count = [_scenarioInfoModelList count];
    NSMutableDictionary *modelDict = [NSMutableDictionary dictionary];
    
    NSString *sval = [NSString stringWithFormat:@"%ld", (long)count];
    [modelDict setObject:sval forKey:@"drawOrder"];

    [modelDict setObject:@"0.0000" forKey:@"colorAlpha"];
    [modelDict setObject:@"" forKey:@"modelPath"];
    [modelDict setObject:@"" forKey:@"modelInZip"];
    [modelDict setObject:@"" forKey:@"motionPath"];
    [modelDict setObject:@"" forKey:@"motionInZip"];
    [modelDict setObject:@"0" forKey:@"motionRepeat"];
    [modelDict setObject:@"2" forKey:@"physicsMode"];
    [modelDict setObject:@"1" forKey:@"useSubSphereTexture"];
    [modelDict setObject:@"0.00" forKey:@"positionX"];
    [modelDict setObject:@"0.00" forKey:@"positionY"];
    [modelDict setObject:@"0.00" forKey:@"positionZ"];
    [modelDict setObject:@"0.00" forKey:@"rotationX"];
    [modelDict setObject:@"0.00" forKey:@"rotationY"];
    [modelDict setObject:@"0.00" forKey:@"rotationZ"];

    [_scenarioInfoModelList addObject:modelDict];
    
    // save into a file
    [_documentController saveScenarioListFile];
}

-(void)removeModelFromScenarioInfoModelListAtRow:(NSInteger)row
{
    if (_scenarioInfoModelList == nil) {
        // nothing to do
        return;
    }
    
    NSInteger count = [_scenarioInfoModelList count];
    if (row < count) {
        [_scenarioInfoModelList removeObjectAtIndex:row];
    }
    // save into a file
    [_documentController saveScenarioListFile];
}

-(NSString*)getCurrentScenarioKey
{
    return [_scenarioInfoDict valueForKey:@"key"];
}

-(NSString*)getCurrentScenarioName
{
    return [_scenarioInfoDict valueForKey:@"name"];
}

-(NSString*)getCurrentModelPath
{
    return _currentModelPath;
}

-(NSString*)getCurrentMotionPath
{
    return _currentMotionPath;
}

-(NSString*)getZipPathOfModelPath:(NSString*)modelPathx
{
    return [_documentController getZipPathOfModelPath:modelPathx];
}

-(NSString*)getZipPathOfMotionPath:(NSString*)motionPathx
{
    return [_documentController getZipPathOfMotionPath:motionPathx];
}

-(BOOL)openZipFile:(NSString*)zipFile
{
    return [_documentController openZipFile:zipFile];
}

-(void)closeZipFile
{
    [_documentController closeZipFile];
}

-(NSData*)readZipContentFile:(NSString*)filename
{
    if (filename == nil) {
        NSLog(@"*** Error: ScenarioData::readZipContentFile filename is [nil]");
    }
    NSData *pdata = [_documentController readZipContentFile:filename];
    
    return pdata;
}

-(BOOL)openCurrentModelZipPath
{
    return [self openZipFile: _currentModelZipPath];
}

-(BOOL)openCurrentMotionZipPath
{
    return [self openZipFile:_currentMotionZipPath];
}

-(NSData*)readZipCurrentModelPath
{
    if (_currentModelPath == nil) {
        NSLog(@"*** ScenarioData::readZipCurrentModelPath _currentModelPath is [nil]");
    }
    return [self readZipContentFile:_currentModelPath];
}

-(NSData*)readZipCurrentMotionPath
{
    return [self readZipContentFile:_currentMotionPath];
}

-(NSMutableDictionary*)getScenarioListDict
{
    return [_documentController getScenarioListDict];
}

-(NSArray*)getScenarioList
{
    return [_documentController getScenarioList];
}

-(NSMutableDictionary*)getModelListDict
{
    return [_documentController getModelListDict];
}

-(NSArray*)getModelList
{
    NSLog(@"... ScenarioData getModelList");
    
    return [_documentController getModelList];
}

-(NSMutableDictionary*)getMotionListDict
{
    return [_documentController getMotionListDict];
}

-(NSArray*)getMotionList
{
    return [_documentController getMotionList];
}

-(NSMutableDictionary*)getScenarioGroupListDict
{
    return [_documentController getScenarioGroupListDict];
}

-(NSArray*)getScenarioGroupList
{
    return [_documentController getScenarioGroupList];
}

-(NSMutableDictionary*)getModelGroupListDict
{
    return [_documentController getModelGroupListDict];
}

-(NSArray*)getModelGroupList
{
    return [_documentController getModelGroupList];
}

-(NSMutableDictionary*)getMotionGroupListDict
{
    return [_documentController getMotionGroupListDict];
}

-(NSArray*)getMotionGroupList
{
    return [_documentController getMotionGroupList];
}

-(NSInteger)numberOfSectionsInScenarioList
{
    /*
     * 0: General
     *    .0 title
     *    .1 group
     *    .2 music
     *    .3 motionOffset
     *    .4 bgcolorR
     *    .5 bgcolorB
     *    .6 bgcolorG
     *    .7 lightcolorR
     *    .8 lightcolorG
     *    .9 lightcolorB
     *    .10 useAntiAliase
     *    .11 physicsFact
     *    .12 note
     *    .13 timeStamp (read-only)
     * 1: Model
     *    .0 Model
     *       Line:0 drawOrder
     *       Line:1 model
     *       Line:2 motion
     *    .1 Model
     *       Line:0 drawOrder
     *       Line:1 model
     *       Line:2 motion
     *    .2 Model
     *       Line:0 drawOrder
     *       Line:1 model
     *       Line:2 motion
     */
    
    return 2;
}

-(NSInteger)numberOfRowsInSectionOfScenarioList:(NSInteger)section
{
    NSInteger numRows = 1;
    
    if (section == 0) {
        // General
        // Not show item Note, not used at this moment
        numRows = 12;
    } else if (section == 1) {
        numRows = 0; // first one to be [Add button]
        if (_scenarioInfoModelList != nil) {
            numRows += [_scenarioInfoModelList  count];
        }
    }
    
    return numRows;
}

-(NSString*)titleForSectionInScenarioList:(NSInteger)section
{
    NSString *str = nil;
        
    if (section == 0) {
        str = @"General";
    } else if (section == 1) {
        str = @"Models";
    }
    
    //NSLog(@"... titleForSection:%d =[%@]", section, str);
    return str;
}


-(NSString*)titleForRowInScenarioInfoIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    NSString *str = nil;

    //NSLog(@"... ScenarioData:titleForRowInScenarioInfoIndexPath section[%d], row[%d]", section, row);
    
    if (section == 0) {
        switch (row) {
            case 0:
                str = @"Name";
                break;
            case 1:
                str = @"Device";
                break;
            case 2:
                str = @"Music";
                break;
            case 3:
                str = @"Motion start offset in secs";
                break;
            case 4:
                str = @"Background ColorR";
                break;
            case 5:
                str = @"Background ColorG";
                break;
            case 6:
                str = @"Background ColorB";
                break;
            case 7:
                str = @"Light ColorR";
                break;
            case 8:
                str = @"Light ColorG";
                break;
            case 9:
                str = @"Light ColorB";
                break;
            case 10:
                str = @"Quality: 0=Motion 1=Picture";
                break;
            case 11:
                str = @"PhysicsFact: 0=60fps 1=30fps 2=60fps 3=90fps 4=120fps";
                break;
            case 12:
                str = @"Note";
                break;
        }
    } else if (section == 1) {
        /*
         *    .0 drawOrder
         *    .1 model
         *    .2 motion
         *    .3 pHysicsMode
         *    .4 PosX, PosY, PosZ
         *    .5 AngleX, AngleY, AngleZ
         */
        if (row < [_scenarioInfoModelList count]) {
            str = [NSString stringWithFormat:@"Model %03ld", (long)row+1];
        }
    }
    
    //NSLog(@"... titleForSection:%d row:%d =[%@]", section, row, str);
    return str;
}

-(id)valueForScenarioInfoIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    
    NSLog(@"... ScenarioData:valueForRowInScenarioInfoIndexPath section[%ld], row[%ld]", (long)section, (long)row);

    if (section == 0) {
        NSDictionary *musicDict = [_scenarioInfoDict valueForKey:@"musicDict"];
        NSString *musicTitle;
        NSNumber *musicDuration;
        // MPMediaItemPropertyTitle
        // MPMediaItemPropertyArtist
        // MPMediaItemPropertyAlbumTitle
        // MPMediaItemPropertyAlbumArtist
        // MPMediaItemPropertyGenre
        // MPMediaItemPropertyComposer
        // MPMediaItemPropertyPlaybackDuration (double)
        
        switch (row) {
            case 0:
                return [_scenarioInfoDict valueForKey:@"name"];
                break;
            case 1:
                return [_scenarioInfoDict valueForKey:@"device"];
                break;
            case 2:
                musicTitle = [musicDict valueForKey:@"MPMediaItemPropertyTitle"];
                musicDuration = [musicDict valueForKey:@"MPMediaItemPropertyPlaybackDuration"];
                if (musicTitle == nil) {
                    musicTitle = [NSString stringWithFormat:@""];
                } else {
                    musicTitle = [NSString stringWithFormat:@"%@ (%@)", musicTitle, [musicDuration stringValue]];
                }
                return musicTitle;
                break;
            case 3:
                return [_scenarioInfoDict valueForKey:@"motionOffset"];
                break;
            case 4:
                return [_scenarioInfoDict valueForKey:@"bgcolorR"];
                break;
            case 5:
                return [_scenarioInfoDict valueForKey:@"bgcolorG"];
                break;
            case 6:
                return [_scenarioInfoDict valueForKey:@"bgcolorB"];
                break;
            case 7:
                return [_scenarioInfoDict valueForKey:@"lightcolorR"];
                break;
            case 8:
                return [_scenarioInfoDict valueForKey:@"lightcolorG"];
                break;
            case 9:
                return [_scenarioInfoDict valueForKey:@"lightcolorB"];
                break;
            case 10:
                return [_scenarioInfoDict valueForKey:@"useAntialias"];
                break;
            case 11:
                return [_scenarioInfoDict valueForKey:@"physicsFact"];
                break;
            case 12:
                return [_scenarioInfoDict valueForKey:@"note"];
                break;
        }
    } else if (section == 1) {

        NSString *str;
        NSString *modelName = @"please select a model";
        NSString *motionName = @"please select a motion";
        
        if (row < [_scenarioInfoModelList  count]) {
            NSMutableDictionary *scenarioModel = _scenarioInfoModelList[row];
            modelName = [[scenarioModel valueForKey:@"modelPath"] lastPathComponent];
            motionName = [[scenarioModel valueForKey:@"motionPath"] lastPathComponent];
            if (modelName == nil || [modelName length] == 0) {
                modelName = @"plese select a model";
            } else {
                modelName = [NSString stringWithFormat:@"model:%@", modelName];
            }
            if (motionName == nil || [motionName length] == 0) {
                motionName = @"pleae select motion";
            } else {
                motionName = [NSString stringWithFormat:@"motion:%@", motionName];
            }
        }
        str = [NSString stringWithFormat:@"%@\n%@", modelName, motionName];

        return str;
    }
    
    //NSLog(@"... valueForSection:%d row:%d =[%@]", section, row, str);
    return nil;
    
}

-(void)setValue:(id)value forScenarioListInexPath:(NSIndexPath *)indexPath
{
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    NSString *key = nil;
    NSString *sval;
    
    if (section == 0) {
        switch (row) {
            case 0:
                key = @"name";
                _currentTitle = value;
                [_scenarioInfoDict setValue:value forKey:key];
                break;
            case 1:
                key = @"device"; // NSString
                [_scenarioInfoDict setValue:value forKey:key];
                break;
            case 2:
                // deal by the function
                break;
            case 3:
                key = @"motionOffset"; // NSNumber int
                sval = [NSString stringWithFormat:@"%1.4f",[value floatValue]];
                [_scenarioInfoDict setValue:sval forKey:key];
                break;
            case 4:
                key = @"bgcolorR"; // NSNumber float
                sval = [NSString stringWithFormat:@"%1.4f",[value floatValue]];
                [_scenarioInfoDict setValue:sval forKey:key];
                break;
            case 5:
                key = @"bgcolorG"; // NSNumber float
                sval = [NSString stringWithFormat:@"%1.4f",[value floatValue]];
                [_scenarioInfoDict setValue:sval forKey:key];
                break;
            case 6:
                key = @"bgcolorB"; // NSNumber float
                sval = [NSString stringWithFormat:@"%1.4f",[value floatValue]];
                [_scenarioInfoDict setValue:sval forKey:key];
                break;
            case 7:
                key = @"lightcolorR"; // NSNumber int
                sval = [NSString stringWithFormat:@"%1.4f",[value floatValue]];
                [_scenarioInfoDict setValue:sval forKey:key];
                break;
            case 8:
                key = @"lightcolorG"; // NSNumber int
                sval = [NSString stringWithFormat:@"%1.4f",[value floatValue]];
                [_scenarioInfoDict setValue:sval forKey:key];
                break;
            case 9:
                key = @"lightcolorB"; // NSNumber int
                sval = [NSString stringWithFormat:@"%1.4f",[value floatValue]];
                [_scenarioInfoDict setValue:sval forKey:key];
                break;
            case 10:
                key = @"useAntialias"; // NSNumber int
                sval = [NSString stringWithFormat:@"%ld",(long)[value integerValue]];
                [_scenarioInfoDict setValue:sval forKey:key];
                break;
            case 11:
                key = @"physicsFact"; // NSNumber int
                sval = [NSString stringWithFormat:@"%ld",(long)[value integerValue]];
                [_scenarioInfoDict setValue:sval forKey:key];
                break;
            case 12:
                key = @"note"; // NSString
                [_scenarioInfoDict setValue:value forKey:key];
                break;
            case 13:
                key = @"timeStamp"; // date
                [_scenarioInfoDict setValue:value forKey:key];
                break;
        }
    }
    
    [_documentController saveScenarioListFile];
}

- (BOOL)canEditRowAtScenarioInfoIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    
    
    BOOL rval = NO;
    
    if (section == 0) {
        switch (row) {
            case 0:
                rval = YES;
                break;
            case 1:
                rval = YES;
                break;
            case 2:
                rval = YES;
                break;
            case 3:
                rval = YES;
                break;
            case 4:
                rval = YES;
                break;
            case 5:
                rval = YES;
                break;
            case 6:
                rval = YES;
                break;
            case 7:
                rval = YES;
                break;
            case 8:
                rval = YES;
                break;
            case 9:
                rval = YES;
                break;
            case 10:
                rval = YES;
                break;
            case 11:
                rval = YES;
                break;
            case 12:
                rval = YES;
                break;
            case 13:
                rval = NO;
                break;
        }
    } else if (section == 1) {
        rval = YES;
    }
    
    return rval;
}

-(NSInteger)numberOfSectionsInModelDetail
{
    /* 0. DrawOrder int
     * 1. Model
     *    .0 name
     *    .1 path
     * 2. Motion
     *    .0 name
     *    .1 path
     * 3. Motion Repeat
     * 4. PhysicsMode
     * 5. Pos
     *   .0 x
     *   .1 y
     *   .2 z
     * 6. Angle
     *   .0 x
     *   .1 y
     *   .2 z
     */
    
    return 8;
}

-(NSInteger)numberOfRowsInSectionOfModelDetail:(NSInteger)section
{
    NSInteger numRows = 1;

    if (section == 0) {
        numRows = 1;
    } else if (section == 1) {
        numRows = 2;
    } else if (section == 2) {
        numRows = 2;
    } else if (section == 3) {
        numRows = 1;
    } else if (section == 4) {
        numRows = 1;
    } else if (section == 5) {
        numRows = 1;
    } else if (section == 6) {
        numRows = 3;
    } else if (section == 7) {
        numRows = 3;
    }
    
    return numRows;
}

-(NSString*)titleForSectionInModelDetail:(NSInteger)section
{
    NSString *str = nil;

    switch (section) {
        case 0:
            str = @"DrawOrder";
            break;
        case 1:
            str = @"Model";
            break;
        case 2:
            str = @"Motion";
            break;
        case 3:
            str = @"Repeat Motion";
            break;
        case 4:
            str = @"UsePhysics";
            break;
        case 5:
            str = @"TextureLib";
            break;
        case 6:
            str = @"Position";
            break;
        case 7:
            str = @"Rotate";
            break;
            
        default:
            break;
    }

    //NSLog(@"... titleForSection:%d =[%@]", section, str);
    return str;
}


-(NSString*)titleForRowInModelDetailIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    NSString *str = nil;
    
    if (section == 1) {
        switch (row) {
            case 0:
                str = @"Model Name";
                break;
            case 1:
                str = @"Model Path";
                break;
        }
    } else if (section == 2) {
            switch (row) {
                case 0:
                    str = @"Motion Name";
                    break;
                case 1:
                    str = @"Motion Path";
                    break;
            }
    } else if (section == 3) {
        str = @"0:none 1:repeat";
    } else if (section == 4) {
        str = @"2:gloabl 1:local 0:no";
    } else if (section == 5) {
        str = @"0:custom 1:apple";
    } else if (section == 6) {
        switch (row) {
            case 0:
                str = @"Lef-Right";
                break;
            case 1:
                str = @"Front-Back";
                break;
            case 2:
                str = @"Up-Down";
                break;
        }
        
    } else if (section == 7) {
        switch (row) {
            case 0:
                str = @"Left-Right";
                break;
            case 1:
                str = @"Front-Back";
                break;
            case 2:
                str = @"Up-Down";
                break;
        }
        
    }
    
    //NSLog(@"... titleForSection:%d row:%d =[%@]", section, row, str);
    return str;
}

-(id)valueForModelDetailIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    return [self valueForModelDetailSection:section row:row];
}

-(id)valueForModelDetailSection:(NSInteger)section row:(NSInteger)row
{

    NSInteger scenarioInfoIndexPathRow = [_scenarioInfoIndexPath row];
    NSMutableDictionary *scenarioModel = _scenarioInfoModelList[scenarioInfoIndexPathRow];
    
    NSString *sval;
    
    if (section == 0) {
        return [scenarioModel valueForKey:@"drawOrder"];
    } else if (section == 1) {
        if (row == 0) {
            sval = [[scenarioModel valueForKey:@"modelPath"] lastPathComponent];
            if ([sval length] == 0) {
                sval = @"<none>";
            }
            return sval;
        } else {
            return [scenarioModel valueForKey:@"modelPath"];
        }
    } else if (section == 2) {
        if (row == 0) {
            return [[scenarioModel valueForKey:@"motionPath"] lastPathComponent];
        } else {
            return [scenarioModel valueForKey:@"motionPath"];
        }
    } else if (section == 3) {
        return [scenarioModel valueForKey:@"motionRepeat"];
    } else if (section == 4) {
        return [scenarioModel valueForKey:@"physicsMode"];
    } else if (section == 5) {
        return [scenarioModel valueForKey:@"textureLib"];
    } else if (section == 6) {
        if (row == 0) {
            return [scenarioModel valueForKey:@"positionX"];
        } else if (row == 1) {
            return [scenarioModel valueForKey:@"positionZ"];
        } else if (row == 2) {
            return [scenarioModel valueForKey:@"positionY"];
        }
    } else if (section == 7) {
        if (row == 0) {
            return [scenarioModel valueForKey:@"rotationY"];
        } else if (row == 1) {
            return [scenarioModel valueForKey:@"rotationX"];
        } else if (row == 2) {
            return [scenarioModel valueForKey:@"rotationZ"];
        }
    }

    //NSLog(@"... valueForSection:%d row:%d =[%@]", section, row, str);
    return nil;
    
}

-(void)setValue:(NSString*)value forModelDetailInexPath:(NSIndexPath *)indexPath
{
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    NSString *sval;
    NSString *key;
    
    NSLog(@"... ScenarioData: setvalue: forModelDetailIndexPath");
    NSLog(@"... indexPath.section[%ld] row[%ld]", (long)indexPath.section, (long)indexPath.row);
    
    NSInteger scenarioInfoIndexPathRow = [_scenarioInfoIndexPath row];
    NSMutableDictionary *scenarioModel = _scenarioInfoModelList[scenarioInfoIndexPathRow];
    
    if (section == 0) {
        key = @"drawOrder";
        sval = [NSString stringWithFormat:@"%ld", (long)[value integerValue]];
        [scenarioModel setValue:sval forKey:key];
    } else if (section == 3) {
        key = @"motionRepeat";
        sval = [NSString stringWithFormat:@"%ld", (long)[value integerValue]];
        [scenarioModel setValue:sval forKey:key];
    } else if (section == 4) {
        key = @"physicsMode";
        sval = [NSString stringWithFormat:@"%ld", (long)[value integerValue]];
        [scenarioModel setValue:sval forKey:key];
    } else if (section == 5) {
        key = @"textureLib";
        sval = [NSString stringWithFormat:@"%ld", (long)[value integerValue]];
        [scenarioModel setValue:sval forKey:key];
    } else if (section == 6) {
        if (row == 0) {
            key = @"positionX"; // NSNumber float
            sval = [NSString stringWithFormat:@"%3.4f", [value floatValue]];
            [scenarioModel setValue:sval forKey:key];
        } else if (row == 1) {
            key = @"positionZ"; // NSNumber float
            sval = [NSString stringWithFormat:@"%3.4f", [value floatValue]];
            [scenarioModel setValue:sval forKey:key];
        } else if (row == 2) {
            key = @"positionY"; // NSNumber float
            sval = [NSString stringWithFormat:@"%3.4f", [value floatValue]];
            [scenarioModel setValue:sval forKey:key];
        }
    } else if (section == 7) {
        if (row == 0) {
            key = @"rotationY"; // NSNumber float
            sval = [NSString stringWithFormat:@"%3.4f", [value floatValue]];
            [scenarioModel setValue:sval forKey:key];
        } else if (row == 1) {
            key = @"rotationX"; // NSNumber float
            sval = [NSString stringWithFormat:@"%3.4f", [value floatValue]];
            [scenarioModel setValue:sval forKey:key];
        } else if (row == 2) {
            key = @"rotationZ"; // NSNumber float
            sval = [NSString stringWithFormat:@"%3.4f", [value floatValue]];
            [scenarioModel setValue:sval forKey:key];
        }
    }

    [_documentController saveScenarioListFile];
}


-(void)setMusicForScenarioInfoIndexPath:(NSDictionary*)musicDict
{

    [_scenarioInfoDict setValue:musicDict forKey:@"musicDict"];
    [_documentController saveScenarioListFile];
}

-(void)setModelForScenarioInfoIndexPath:(id)name path:(NSString*)path zipPath:(NSString*)zipPath
{
    NSInteger scenarioInfoIndexPathSection = [_scenarioInfoIndexPath section];
    NSInteger scenarioInfoIndexPathRow = [_scenarioInfoIndexPath row];
    
    NSLog(@"... setModelForScenarioInfoIndexPath: section[%ld] path[%@], zipPath[%@]", (long)scenarioInfoIndexPathSection, path, zipPath);

    if (scenarioInfoIndexPathSection >= 1) {
        NSMutableDictionary *scenarioModel = _scenarioInfoModelList[scenarioInfoIndexPathRow];

        if (path == nil) {
            path = @"";
        }
        if (zipPath == nil) {
            zipPath = @"";
        }
        [scenarioModel setObject:path forKey:@"modelPath"];
        [scenarioModel setObject:zipPath forKey:@"modelInZip"];
        
    }
    [_documentController saveScenarioListFile];
}

-(void)setMotionForScenarioInfoIndexPath:(id)name path:(NSString*)path zipPath:(NSString*)zipPath
{
    NSInteger scenarioInfoIndexPathSection = [_scenarioInfoIndexPath section];
    NSInteger scenarioInfoIndexPathRow = [_scenarioInfoIndexPath row];
    
    NSLog(@"... setMotionForScenarioInfoIndexPath: section[%ld] path[%@], zipPath[%@]", (long)scenarioInfoIndexPathSection, path, zipPath);

    if (scenarioInfoIndexPathSection >= 1) {
        NSMutableDictionary *scenarioModel = _scenarioInfoModelList[scenarioInfoIndexPathRow];
        
        if (path == nil) {
            path = @"";
        }
        if (zipPath == nil) {
            zipPath = @"";
        }

        [scenarioModel setObject:path forKey:@"motionPath"];
        [scenarioModel setObject:zipPath forKey:@"motionInZip"];
        
    }

    [_documentController saveScenarioListFile];
}


@end
