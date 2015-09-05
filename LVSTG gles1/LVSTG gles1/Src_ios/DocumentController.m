//
//  DropboxController.m
//  MMD4U
//
//  Created by Rocky on 2013/03/23.
//  Copyright (c) 2013年 twincle4u. All rights reserved.
//


#import "DocumentController.h"

@interface DocumentController()

-(void)loadListFromCurrentZip;
@end


@implementation DocumentController

@synthesize documentPaths=_documentPaths;
@synthesize documentRoot=_documentRoot;
@synthesize fileManager=_fileManager;
@synthesize zipListRef=_zipListRef;
@synthesize unzipFile=_unzipFile;
@synthesize zipFileName=_zipFileName;
@synthesize listInCurrentZip = _listInCurrentZip;

@synthesize scenarioListDict = _scenarioListDict;
@synthesize scenarioListRef=_scenarioListRef;
@synthesize modelListDict = _modelListDict;
@synthesize modelListRef=_modelListRef;
@synthesize motionListDict = _motionListDict;
@synthesize motionListRef=_motionListRef;
@synthesize scenarioGroupListDict = _scenarioGroupListDict;
@synthesize scenarioGroupListRef=_scenarioGroupListRef;
@synthesize modelGroupListDict=_modelGroupListDict;
@synthesize modelGroupListRef=_modelGroupListRef;
@synthesize motionGroupListDict=_motionGroupListDict;
@synthesize motionGroupListRef=_motionGroupListRef;

static const int CASE_SENSITIVITY = 0;
static const unsigned int BUFFER_SIZE = 8192;
static const unsigned int maxLength = 1024*1024*10;

static NSString *MODELLISTFILENAME = @"__lvstg-model.xml";
static NSString *MOTIONLISTFILENAME = @"__lvstg-motion.xml";
static NSString *SCENARIOLISTFILENAME = @"__lvstg-scenario.xml";
static NSString *SCENARIOGROUPLISTFILENAME = @"__lvstg-scenariogroup.xml";
static NSString *MODELGROUPLISTFILENAME = @"__lvstg-modelgroup.xml";
static NSString *MOTIONGROUPLISTFILENAME = @"__lvstg-motiongroup.xml";


-(id)init
{
    NSLog(@"... DocumentController: init");
    
    self = [super init];
    
    _documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSLog(@"... _documentPaths=[%lu]", (unsigned long)_documentPaths.count);
    _documentRoot = [_documentPaths objectAtIndex:0];
    
    NSLog(@"... _documentRoot=[%@]", _documentRoot);
    
    _fileManager = [NSFileManager defaultManager];
    
    //[self loadZipListFile];
    [self loadModelListFile];
    [self loadMotionListFile];
    [self loadScenarioListFile];
    [self loadScenarioGroupListFile];
    [self loadModelGroupListFile];
    [self loadMotionGroupListFile];

	return self;
}


-(NSString*)root
{
    return _documentRoot;
}

-(NSArray*)listFromRoot
{
    NSArray *contents = [self listFromPath:[self root]];
    
    return contents;
}


-(NSArray*)listFromPath:(NSString*)path
{
    NSLog(@"... listFromPath");
    
    NSLog(@"... path=[%@]", path);
    
    NSError *error;
    NSArray *contents = [_fileManager contentsOfDirectoryAtPath:path error:&error];
    
    return contents;
}

-(BOOL)isFolder:(NSString*)path
{
    BOOL isDir;
    BOOL isExist = [_fileManager fileExistsAtPath:path isDirectory:&isDir];
    
    //NSLog(@"isExist=[%d], isDir=[%d]", (int)isExist, (int)isDir);

    return isExist && isDir;
}

-(BOOL)isFile:(NSString*)path
{
    BOOL isDir;
    BOOL isExist = [_fileManager fileExistsAtPath:path isDirectory:&isDir];
    return isExist && !isDir;
}

-(void)saveScenarioListFile
{
    [self fileWriteDictData:_scenarioListDict fileName:SCENARIOLISTFILENAME];
}

-(void)scenarioListDictConversion
{
    NSLog(@"... DocumentController: scenarioListDictConversion");

    NSMutableDictionary *listDict = [_scenarioListDict valueForKey:@"listDict"];
    
    // convert to new structure
    if (listDict == nil) {
        listDict = [NSMutableDictionary dictionary];
        // moved scenarioDict into the listDict
        for (NSString *key in [_scenarioListDict allKeys]) {
            NSMutableDictionary *aDict = [_scenarioListDict valueForKey:key];
            [listDict setValue:aDict forKey:key];
            [_scenarioListDict removeObjectForKey:key];

        }
        [_scenarioListDict setValue:listDict forKey:@"listDict"];

    }
    
    int n = 0;
    for (NSString *key in [listDict allKeys]) {
        NSLog(@"... listDict[%d]=key[%@]", n, key);
        n++;
        
        NSMutableDictionary *scenarioDict = [listDict valueForKey:key];
        // conver key from old to new
        
        NSString *device = [scenarioDict valueForKey:@"device"];
        NSString *name = [scenarioDict valueForKey:@"name"];
        if (device == nil) {
            device = @"all";
            [scenarioDict setObject:device forKey:@"device"];
        }

        NSString *newKey = [NSString stringWithFormat:@"%@:%@",device,name];
        [scenarioDict setValue:newKey forKey:@"key"];
        [listDict setValue:scenarioDict forKey:newKey];

        if (![key isEqualToString:newKey]) {
            // remove old key from parent
            [listDict removeObjectForKey:key];
        }
        
        //[scenarioDict removeObjectForKey:@"musicTitle"];
        //[scenarioDict removeObjectForKey:@"musicId"];

        // add new attribute and default value

        if ([scenarioDict valueForKey:@"kind"] == nil) {
            [scenarioDict setObject:@"scenario" forKey:@"kind"];
        }
        if ([scenarioDict valueForKey:@"useAntialias"] == nil) {
            [scenarioDict setObject:@"0" forKey:@"useAntialias"];
        }
        if ([scenarioDict valueForKey:@"physicsFact"] == nil) {
            [scenarioDict setObject:@"0" forKey:@"physicsFact"];
        }
        if ([scenarioDict valueForKey:@"motionOffset"] == nil) {
            [scenarioDict setObject:@"0.0000" forKey:@"motionOffset"];
        }
        if ([scenarioDict valueForKey:@"lightcolorR"] == nil) {
            [scenarioDict setObject:@"0.6000" forKey:@"lightcolorR"];
            [scenarioDict setObject:@"0.6000" forKey:@"lightcolorB"];
            [scenarioDict setObject:@"0.6000" forKey:@"lightcolorG"];
            
        }
        
        // remove deprecated attributes
        
        if ([scenarioDict valueForKey:@"useHakosuko"] != nil) {
            [scenarioDict removeObjectForKey:@"useHakoSuko"];
        }
        
        // modelList
        if (1) {
            NSMutableArray *modelList = scenarioDict[@"modelList"];
            for (NSMutableDictionary *modelDict in modelList) {
                if ([modelDict valueForKey:@"textureLib"] == nil) {
                    [modelDict setObject:@"0" forKey:@"textureLib"];
                }
                if ([modelDict valueForKey:@"useSubSphereTexture"] != nil) {
                    [modelDict removeObjectForKey:@"useSubSphereTexture"];
                }

                if ([modelDict valueForKey:@"motionRepeat"] == nil) {
                    [modelDict setObject:@"0" forKey:@"motionRepeat"];
                }
                if ([modelDict valueForKey:@"kind"] == nil) {
                    [modelDict removeObjectForKey:@"kind"];
                }
            }
        }
    }

}

-(NSInteger)loadScenarioListFile
{
    NSLog(@"... DocumentController:loadScenarioListFile");

    _scenarioListDict = [self dictionaryWithContentsOfFile:SCENARIOLISTFILENAME];

    // no file existed or error in the file
    if (_scenarioListDict == nil) {
        _scenarioListDict = [NSMutableDictionary dictionary];
    }

    // should call listDictConversion between load dictionary file and creation of listRef
    [self scenarioListDictConversion];
    
    _scenarioListRef = [[[_scenarioListDict valueForKey:@"listDict"] allKeys]
                         sortedArrayUsingComparator:^(id obj1, id obj2) {
        return [(NSString*)obj1 compare:(NSString*)obj2];
    }];
    
    NSLog(@"... _scenarioListRef = [%lu]", (unsigned long)[_scenarioListRef count]);

    return [_scenarioListRef count];
}

-(void)saveModelListFile
{
    [self fileWriteDictData:_modelListDict fileName:MODELLISTFILENAME];
}

-(void)modelListDictConversion
{
    NSLog(@"... DocumentController: modelListDictConversion");
    
    NSMutableDictionary *listDict = [_modelListDict valueForKey:@"listDict"];
    
    // convert to new structure
    if (listDict == nil) {
        listDict = [NSMutableDictionary dictionary];
        // moved scenarioDict into the listDict
        for (NSString *key in [_modelListDict allKeys]) {
            NSMutableDictionary *aDict = [_modelListDict valueForKey:key];
            // added to the listDict
            [listDict setValue:aDict forKey:key];
            // remove from top structure modelListDict
            [_modelListDict removeObjectForKey:key];
            
        }
        [_modelListDict setValue:listDict forKey:@"listDict"];
        
    }
    
}

-(NSInteger)loadModelListFile
{
    NSLog(@"... DocumentController:loadModelListFile");
    _modelListDict = [self dictionaryWithContentsOfFile:MODELLISTFILENAME];
    
    // no file existed or error in the file
    if (_modelListDict == nil) {
        _modelListDict = [NSMutableDictionary dictionary];
    }
    
    // should call listDictConversion between load dictionary file and creation of listRef
    [self modelListDictConversion];
    
    _modelListRef = [[[_modelListDict valueForKey:@"listDict"] allKeys]
                      sortedArrayUsingComparator:^(id obj1, id obj2) {
        return [(NSString*)obj1 compare:(NSString*)obj2];
    }];
    
    NSLog(@"... _modelListRef = [%lu]", (unsigned long)[_modelListRef count]);
    
    return [_modelListRef count];
}

-(void)saveMotionListFile
{
    [self fileWriteDictData:_motionListDict fileName:MOTIONLISTFILENAME];
}

-(void)motionListDictConversion
{
    NSLog(@"... DocumentController: motionListDictConversion");
    
    NSMutableDictionary *listDict = [_motionListDict valueForKey:@"listDict"];
    
    // convert to new structure
    if (listDict == nil) {
        listDict = [NSMutableDictionary dictionary];
        // moved scenarioDict into the listDict
        for (NSString *key in [_motionListDict allKeys]) {
            NSMutableDictionary *aDict = [_motionListDict valueForKey:key];
            // added to the listDict
            [listDict setValue:aDict forKey:key];
            // removed from top structure
            [_motionListDict removeObjectForKey:key];
            
        }
        [_motionListDict setValue:listDict forKey:@"listDict"];
        
    }
    
}

-(NSInteger)loadMotionListFile
{
    NSLog(@"... ScenarioData: loadMotionListFile");
    _motionListDict = [self dictionaryWithContentsOfFile:MOTIONLISTFILENAME];
    
    // no file existed or error in the file
    if (_motionListDict == nil) {
        _motionListDict = [NSMutableDictionary dictionary];
    }
    
    // should call listDictConversion between load dictionary file and creation of listRef
    [self motionListDictConversion];
    
    _motionListRef = [[[_motionListDict valueForKey:@"listDict"] allKeys]
                       sortedArrayUsingComparator:^(id obj1, id obj2) {
        return [(NSString*)obj1 compare:(NSString*)obj2];
    }];
    
    NSLog(@"... _motionListRef = [%lu]", (unsigned long)[_motionListRef count]);
    
    return [_motionListRef count];
}

-(void)makePathDictForGroupDict:(NSMutableDictionary*)groupDict inRootDict:(NSMutableDictionary*)rootDict
{
    //NSLog(@"... makePathDictForGroupDict");
    
    NSString *pathDict = [rootDict valueForKey:@"pathDict"];
    NSString *parentPath = [groupDict valueForKey:@"parentPath"];
    NSString *name = [groupDict valueForKey:@"key"];
    NSString *path = [NSString stringWithFormat:@"%@/%@", parentPath, name];
    [groupDict setValue:path forKey:@"path"];
    [pathDict setValue:groupDict forKey:path];

    NSMutableDictionary *listDict = [groupDict valueForKey:@"listDict"];

    for (NSMutableDictionary *aDict in [listDict allValues]) {
        NSString *kind = [aDict valueForKey:@"kind"];
        if ([kind isEqualToString:@"group"]) {
            [aDict setValue:path forKeyPath:@"parentPath"];
            [self makePathDictForGroupDict:aDict inRootDict:rootDict];
        }
    }

}

-(void)conversionForGroupListDict:(NSMutableDictionary*)groupListDict
{
    NSLog(@"... DocumentController: conversionForGroupListDict");
    
    NSString *pathDict = [groupListDict valueForKey:@"pathDict"];
    if (pathDict == nil) {
        [groupListDict setValue:@"" forKey:@"parentPath"];
        [groupListDict setValue:@"Top" forKey:@"key"];
        [groupListDict setValue:@"group" forKey:@"kind"];
        [self makePathDictForGroupDict:groupListDict inRootDict:groupListDict];
    }
    
    NSMutableDictionary *listDict = [groupListDict valueForKey:@"listDict"];
    
    // convert to new structure
    
}

-(void)saveScenarioGroupListFile
{
    [self fileWriteDictData:_scenarioGroupListDict fileName:SCENARIOGROUPLISTFILENAME];
}

-(NSInteger)loadScenarioGroupListFile
{
    NSLog(@"... ScenarioData: loadScenarioGroupListFile");
    _scenarioGroupListDict = [self dictionaryWithContentsOfFile:SCENARIOGROUPLISTFILENAME];
    
    // no file existed or error in the file
    if (_scenarioGroupListDict == nil) {
        _scenarioGroupListDict = [NSMutableDictionary dictionary];
        NSMutableDictionary *listDict = [NSMutableDictionary dictionary];
        [_scenarioGroupListDict setValue:listDict forKey:@"listDict"];
    }
    
    // should call listDictConversion between load dictionary file and creation of listRef
    [self conversionForGroupListDict:_scenarioGroupListDict];
    
    _scenarioGroupListRef = [[[_scenarioGroupListDict valueForKey:@"listDict"] allKeys]
                              sortedArrayUsingComparator:^(id obj1, id obj2) {
        return [(NSString*)obj1 compare:(NSString*)obj2];
    }];
    
    NSLog(@"... _groupListRef = [%lu]", (unsigned long)[_scenarioGroupListRef count]);
    
    return [_scenarioGroupListRef count];
}

-(void)saveModelGroupListFile
{
    [self fileWriteDictData:_modelGroupListDict fileName:MODELGROUPLISTFILENAME];
}

-(NSInteger)loadModelGroupListFile
{
    NSLog(@"... ScenarioData: loadModelGroupListFile");
    _modelGroupListDict = [self dictionaryWithContentsOfFile:MODELGROUPLISTFILENAME];
    
    // no file existed or error in the file
    if (_modelGroupListDict == nil) {
        _modelGroupListDict = [NSMutableDictionary dictionary];
        NSMutableDictionary *listDict = [NSMutableDictionary dictionary];
        [_modelGroupListDict setValue:listDict forKey:@"listDict"];

    }
    
    // should call listDictConversion between load dictionary file and creation of listRef
    [self conversionForGroupListDict:_modelGroupListDict];
    
    _modelGroupListRef = [[_modelGroupListDict allKeys] sortedArrayUsingComparator:^(id obj1, id obj2) {
        return [(NSString*)obj1 compare:(NSString*)obj2];
    }];
    
    NSLog(@"... _groupListRef = [%lu]", (unsigned long)[_modelGroupListRef count]);
    
    return [_modelGroupListRef count];
}

-(void)saveMotionGroupListFile
{
    [self fileWriteDictData:_motionGroupListDict fileName:MOTIONGROUPLISTFILENAME];
}

-(NSInteger)loadMotionGroupListFile
{
    NSLog(@"... ScenarioData: loadMotionGroupListFile");
    _motionGroupListDict = [self dictionaryWithContentsOfFile:MOTIONGROUPLISTFILENAME];
    
    // no file existed or error in the file
    if (_motionGroupListDict == nil) {
        _motionGroupListDict = [NSMutableDictionary dictionary];
        NSMutableDictionary *listDict = [NSMutableDictionary dictionary];
        [_motionGroupListDict setValue:listDict forKey:@"listDict"];
    }
    
    // should call listDictConversion between load dictionary file and creation of listRef
    [self conversionForGroupListDict:_motionGroupListDict];
    
    _motionGroupListRef = [[_motionGroupListDict allKeys] sortedArrayUsingComparator:^(id obj1, id obj2) {
        return [(NSString*)obj1 compare:(NSString*)obj2];
    }];
    
    NSLog(@"... _groupListRef = [%lu]", (unsigned long)[_motionGroupListRef count]);
    
    return [_motionGroupListRef count];
}

-(BOOL)fileWriteDictData:(NSDictionary*)dict fileName:(NSString*)fn
{
    BOOL ret = true;

    NSLog(@"... DocumentController:: fileWriteDictData=[%@]", fn);
    if (fn) {
        NSString *path = [_documentRoot stringByAppendingPathComponent:fn];
        NSLog(@"... dict writeToFile=[%@]", path);
        if (![dict writeToFile:path atomically:YES]) {
            NSLog(@"*** Error: failed, dict fileWriteDictData=[%@]", path);
            ret = false;
        }
    }
    
    return ret;
}

-(BOOL)fileWriteArrayData:(NSArray*)array fileName:(NSString*)fn
{
    BOOL ret = true;
    
    NSLog(@"... DocumentController:: fileWriteArraData=[%@]", fn);
    if (fn) {
        NSString *path = [_documentRoot stringByAppendingPathComponent:fn];
        NSLog(@"... array writeToFile=[%@]", path);
        if (![array writeToFile:path atomically:YES]) {
            NSLog(@"*** Error: failed, array writeToFile=[%@]", path);
            ret = false;
        }
    }
    
    return ret;
}

-(NSMutableDictionary*)dictionaryWithContentsOfFile:(NSString*)fn
{
    NSMutableDictionary *dict = nil;
    
    NSLog(@"... DocumentController:: dictionaryWithContentsOfFile=[%@]", fn);
    if (fn) {
        NSString *path = [_documentRoot stringByAppendingPathComponent:fn];
        NSLog(@"... dict dictionaryWithContentsOfFile=[%@]", path);
        
        dict = [NSMutableDictionary dictionaryWithContentsOfFile:path];
        if (dict == nil) {
            NSLog(@"*** Error: failed, dictionaryWithContentsOfFile=[%@]", path);
            
        }
    }
    
    return dict;
}

-(NSMutableArray*)arrayWithContentsOfFile:(NSString*)fn
{
    NSMutableArray *array = nil;
    
    NSLog(@"... DocumentController:: arrayWithContentsOfFile=[%@]", fn);
    if (fn) {
        NSString *path = [_documentRoot stringByAppendingPathComponent:fn];
        NSLog(@"... dict arrayWithContentsOfFile=[%@]", path);
        
        array = [NSMutableArray arrayWithContentsOfFile:path];
        if (array == nil) {
            NSLog(@"*** Error: failed, arrayWithContentsOfFile=[%@]", path);
            
        }
    }
    
    return array;
}

-(void)loadListOfModelAndMotionFromZipListDict
{
    NSLog(@"... loadListOfModelAndMotionFromZipListDict");
    
    /*
    if (_modelListRef.count > 0) {
        return; // load Zip file list once
    }
     */
    
    // listDict are initialized at load data from the file
    
    NSMutableDictionary *listDictOfModel = [_modelListDict valueForKey:@"listDict"];
    [listDictOfModel removeAllObjects];
    
    NSMutableDictionary *listDictOfMotion = [_motionListDict valueForKey:@"listDict"];
    [listDictOfMotion removeAllObjects];
    
    for (NSString *zipPath in _zipListRef) {
        //NSLog(@"... zipPath is [%@", zipPath);
        
        [self openZipFile:zipPath];
        for (NSString *file in _listInCurrentZip) {
            NSMutableDictionary *detailDict = [NSMutableDictionary dictionary];
            NSMutableDictionary *txtListDict = [NSMutableDictionary dictionary];
            [detailDict setValue:zipPath forKey:@"zipPath"];
            [detailDict setValue:txtListDict forKey:@"txtListDict"];
            
            //NSLog(@"... file = [%@]", file);
            if (file.length > 8) {
                if ([[file substringToIndex:8] compare:@"__MACOSX"] == NSOrderedSame ) {
                    continue;
                }
            }
            if ([file.pathExtension isEqualToString:@"pmd"] || [file.pathExtension isEqualToString:@"pmxxx"]) {
                [listDictOfModel setValue:detailDict forKey:file];
                //NSLog(@"... modelList: zipPath=[%@] file=[%@]", zipPath, file);
            } else if ([file.pathExtension isEqualToString:@"vmd"]) {
                [listDictOfMotion setValue:detailDict forKey:file];
            } else if ([file.pathExtension isEqualToString:@"txt"] || [file.pathExtension isEqualToString:@"TXT"]) {
                [txtListDict setValue:zipPath forKey:file];
            }
        }
        
        [self closeZipFile];
    }
    
    //NSLog(@"... get _modelListRef from _modelListDict");
    _modelListRef = [[listDictOfModel allKeys] sortedArrayUsingComparator:^(id obj1, id obj2) {
        return [(NSString*)obj1 compare:(NSString*)obj2];
    }];

    _motionListRef = [[listDictOfMotion allKeys] sortedArrayUsingComparator:^(id obj1, id obj2) {
        return [(NSString*)obj1 compare:(NSString*)obj2];
    }];

    NSLog(@"... _modelListRef[%lu]", (unsigned long)_modelListRef.count);
    NSLog(@"... _motionListRef[%lu]", (unsigned long)_motionListRef.count);
    
    [self saveModelListFile];
    [self saveMotionListFile];
}

-(NSMutableDictionary*)getScenarioListDict
{
    return _scenarioListDict;
}

-(NSArray*)getScenarioList
{
    //NSLog(@"... DocumentController getScenarioList");
    unsigned long n = [_scenarioListRef count];
    //NSLog(@"... count=[%lu]", n);
    return _scenarioListRef;
}

-(NSMutableDictionary*)getModelListDict
{
    return _modelListDict;
}

-(NSArray*)getModelList
{
    NSLog(@"... DocumentController getModelList");
    return _modelListRef;
}

-(NSMutableDictionary*)getMotionListDict
{
    return _motionListDict;
}

-(NSArray*)getMotionList
{
    return _motionListRef;
}

-(NSMutableDictionary*)getScenarioGroupListDict
{
    return _scenarioGroupListDict;
}

-(NSArray*)getScenarioGroupList
{
    return _scenarioGroupListRef;
}

-(NSMutableDictionary*)getModelGroupListDict
{
    return _modelGroupListDict;
}

-(NSArray*)getModelGroupList
{
    return _modelGroupListRef;
}

-(NSMutableDictionary*)getMotionGroupListDict
{
    return _motionGroupListDict;
}

-(NSArray*)getMotionGroupList
{
    return _motionGroupListRef;
}

-(NSString*)getZipPathOfModelPath:(NSString*)modelPath
{
    NSString *path = [[[_modelListDict valueForKey:@"listDict"] valueForKey:modelPath] valueForKey:@"zipPath"];
    //NSLog(@"... getZipPathOfModelPathL model[%@] num[%@] path[%@]", modelPath, num, path);
    return path;
}

-(NSString*)getZipPathOfMotionPath:(NSString*)motionPath
{
    NSString *path = [[[_motionListDict valueForKey:@"listDict"] valueForKey:motionPath] valueForKey:@"zipPath"];
    return path;
    
}

-(void)loadZipListFile
{
    NSLog(@"... loadZipListFile");

    NSLog(@"... _documentRoot=[%@]", _documentRoot);
        
    NSString *parentPath = _documentRoot;

    NSMutableArray *arr = [NSMutableArray array];
    
    NSArray *contents = [self listFromPath:parentPath];
    for (NSString *path in contents) {
        if ([path compare:@".DS_Store"] == 0) {
            continue;
        }
        NSString *fullPath = [parentPath stringByAppendingPathComponent:path];
        //NSLog(@"... 1:path is [%@]", fullPath);
        
        if ([self isFolder:fullPath]) {
            //NSLog(@"... 1:path is folder");
            NSString *parentPath = fullPath;
            
            NSArray *contents = [self listFromPath:parentPath];
            for (NSString *path in contents) {
                if ([path compare:@".DS_Store"] == 0) {
                    continue;
                }
                NSString *fullPath = [parentPath stringByAppendingPathComponent:path];
                //NSLog(@"... 2:path is [%@]", fullPath);
                NSString *parentPath = fullPath;
                
                if ([self isFolder:fullPath]) {
                    //NSLog(@"... 2:path is folder");
                    
                    NSArray *contents = [self listFromPath:parentPath];
                    for (NSString *path in contents) {
                        if ([path compare:@".DS_Store"] == 0) {
                            continue;
                        }
                        NSString *fullPath = [parentPath stringByAppendingPathComponent:path];
                        NSString *parentPath = fullPath;
                        if ([self isFolder:fullPath]) {
                            NSArray *contents = [self listFromPath:parentPath];
                            for (NSString *path in contents) {
                                if ([path compare:@".DS_Store"] == 0) {
                                    continue;
                                }
                                NSString *fullPath = [parentPath stringByAppendingPathComponent:path];
                                if ([self isFile:fullPath]) {
                                    //NSLog(@"... 4:path is [%@]", fullPath);
                                    if( [path.pathExtension isEqualToString:@"zip"]) {
                                        [arr addObject:path];
                                    }
                                }
                            }
                        } else {
                            //NSLog(@"... 3:path file is [%@]", fullPath);
                            if( [path.pathExtension isEqualToString:@"zip"]) {
                                [arr addObject:path];
                            }
                        }
                    }
                } else {
                    //NSLog(@"... 2:path file is [%@]", fullPath);
                    if( [path.pathExtension isEqualToString:@"zip"]) {
                        [arr addObject:path];
                    }
                }
            }
        } else {
            //NSLog(@"... 1:path file is [%@]", fullPath);
            if( [path.pathExtension isEqualToString:@"zip"]) {
                [arr addObject:path];
            }
        }
    }
    
    _zipListRef = [arr sortedArrayUsingComparator: ^(id obj1, id obj2) {
        return [(NSString*)obj1 compare:(NSString*)obj2];
    }];
    
    NSLog(@"... _zipListRef[%lu]", (unsigned long)_zipListRef.count);
}

-(NSData*)fileRead:(NSString*)path
{
    //NSLog(@"... DocumentController fileRead");
    NSData *data = NULL;
    if (path) {
        //NSLog(@"... _filesystem fileRead:[%@]", path);
        data = [_fileManager contentsAtPath:path];
    }

    return data;
}

-(void)fileClose
{
}

-(long long)fileSizeForPath:(NSString*)path
{
    long long size = 0;
    NSError *error;

    size = [[_fileManager attributesOfItemAtPath:path error:&error] fileSize];

    return size;
}

-(BOOL)openZipFile:(NSString*) zipFile
{
    //NSLog(@"... openZipFile: [%@", zipFile);
    
    [self closeZipFile];
    
    if (_documentRoot == nil) {
        _documentRoot = [self root];
    }

    NSString *path = [_documentRoot stringByAppendingPathComponent:zipFile];
    _unzipFile = unzOpen(path.UTF8String);

    if (_unzipFile == NULL) {
        NSLog(@"*** Error: could not unzOpen(%s)", path.UTF8String);
    }
    [self loadListFromCurrentZip];
    return _unzipFile != NULL;
}

-(void)closeZipFile
{
    if (_unzipFile != NULL) {
        unzClose(_unzipFile);
    }
	_unzipFile = NULL;
}

-(void)loadListFromCurrentZip
{
    
    /*
     enum {
     NSASCIIStringEncoding = 1,
     NSNEXTSTEPStringEncoding = 2,
     NSJapaneseEUCStringEncoding = 3,
     NSUTF8StringEncoding = 4,
     NSISOLatin1StringEncoding = 5,
     NSSymbolStringEncoding = 6,
     NSNonLossyASCIIStringEncoding = 7,
     NSShiftJISStringEncoding = 8,
     NSISOLatin2StringEncoding = 9,
     NSUnicodeStringEncoding = 10,
     NSWindowsCP1251StringEncoding = 11,
     NSWindowsCP1252StringEncoding = 12,
     NSWindowsCP1253StringEncoding = 13,
     NSWindowsCP1254StringEncoding = 14,
     NSWindowsCP1250StringEncoding = 15,
     NSISO2022JPStringEncoding = 21,
     NSMacOSRomanStringEncoding = 30,
     NSUTF16StringEncoding = NSUnicodeStringEncoding,
     NSUTF16BigEndianStringEncoding = 0x90000100,
     NSUTF16LittleEndianStringEncoding = 0x94000100,
     NSUTF32StringEncoding = 0x8c000100,
     NSUTF32BigEndianStringEncoding = 0x98000100,
     NSUTF32LittleEndianStringEncoding = 0x9c000100,
     NSProprietaryStringEncoding = 65536
     };
     */
    
    //NSLog(@"... loadListFromCurrentZip");
    
    _listInCurrentZip = [NSMutableArray array];
    
    if (_unzipFile == NULL) {
        NSLog(@"... _unzipFile is NULL");
        return;
    }
	if (unzGoToFirstFile(_unzipFile) != UNZ_OK) {
        NSLog(@"... error in unzGoToFirstFile");
		return;
	}

	while (YES) {
		unz_file_info64 fileInfo;
		char fileName[PATH_MAX];
		if (unzGetCurrentFileInfo64(_unzipFile, &fileInfo, fileName, PATH_MAX, NULL, 0, NULL, 0) != UNZ_OK) {
            NSLog(@"... error in unzGetCurrentFileInfo64");
			return;
		}
        
        //NSLog(@"... found file in zip [%s]", fileName);
		NSString *str;

        str = [NSString stringWithCString:fileName encoding:NSUTF8StringEncoding];

        if (str == nil) {
            str = [NSString stringWithCString:fileName encoding:NSShiftJISStringEncoding];
        }
        
        //NSLog(@"... add str[%@] into _zipFileLlist[%d]", str, _listInZip.count);

		[_listInCurrentZip addObject:str];
        
		int error = unzGoToNextFile(_unzipFile);
		if (error == UNZ_END_OF_LIST_OF_FILE) {
			break;
		}
		if (error != UNZ_OK) {
			return;
		}
	}

    //NSLog(@"... end _zipFileLlist[%d]", _listInZip.count);
}

-(NSData*)readZipContentFile:(NSString*)path
{
    char cstrpath[PATH_MAX];
    
    //[filename getCString:path maxLength:PATH_MAX encoding:NSShiftJISStringEncoding];
    //[path getCString:cstrpath maxLength:PATH_MAX encoding:NSShiftJISStringEncoding];
    [path getCString:cstrpath maxLength:PATH_MAX encoding:NSUTF8StringEncoding];
    //[path getCharacters:cstrpath];

	if (unzLocateFile(_unzipFile, cstrpath, CASE_SENSITIVITY) != UNZ_OK) {
        [path getCString:cstrpath maxLength:PATH_MAX encoding:NSShiftJISStringEncoding];
        if (unzLocateFile(_unzipFile, cstrpath, CASE_SENSITIVITY) != UNZ_OK) {
            return nil;
        }
	}
    
	if (unzOpenCurrentFile(_unzipFile) != UNZ_OK) {
        NSLog(@"*** Error: unzOpenCurrentFile");
		return nil;
	}
    
	NSMutableData *data = [NSMutableData data];
	NSUInteger length = 0;
	void *buffer = (void *)malloc(BUFFER_SIZE);
	while (YES) {
		unsigned int size = (unsigned int) (length + BUFFER_SIZE <= maxLength ? BUFFER_SIZE : maxLength - length);
		int readLength = unzReadCurrentFile(_unzipFile, buffer, size);
		if (readLength > 0) {
			[data appendBytes:buffer length:readLength];
			length += readLength;
		}
		if (readLength == 0) {
			break;
		}
	};
	free(buffer);
    
	unzCloseCurrentFile(_unzipFile);
    
    return data;
}


@end
