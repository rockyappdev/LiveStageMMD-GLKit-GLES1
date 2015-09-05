//
//  DropboxController.h
//  MMD4U
//
//  Created by Rocky on 2013/03/23.
//  Copyright (c) 2013年 twincle4u. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "unzip.h"


@interface DocumentController : NSObject {
    NSArray *documentPaths;
    NSString *documentRoot;
    NSFileManager *fileManager;
    NSString *zipFileName;
    unzFile unzipFile;
    NSArray *zipListRef;

    NSMutableDictionary *scenarioListDict;
    NSArray *scenarioListRef;
    NSMutableDictionary *modelListDict;
    NSArray *modelListRef;
    NSMutableDictionary *motionListDict;
    NSArray *motionListRef;
    NSMutableDictionary *scenarioGroupListDict;
    NSArray *scenarioGroupListRef;
    NSMutableDictionary *modelGroupListDict;
    NSArray *modelGroupListRef;
    NSMutableDictionary *motionGroupListDict;
    NSArray *motionGroupListRef;
    
    NSMutableArray *listInCurrentZip;
    
}

@property (nonatomic,retain) NSArray *documentPaths;
@property (nonatomic,retain) NSString *documentRoot;
@property (nonatomic,retain) NSFileManager *fileManager;
@property (nonatomic,retain) NSString *zipFileName;
@property (nonatomic,assign) unzFile unzipFile;
@property (nonatomic,retain) NSArray *zipListRef;

@property (nonatomic,retain) NSMutableDictionary *scenarioListDict;
@property (nonatomic,retain) NSArray *scenarioListRef;
@property (nonatomic,retain) NSMutableDictionary *modelListDict;
@property (nonatomic,retain) NSArray *modelListRef;
@property (nonatomic,retain) NSMutableDictionary *motionListDict;
@property (nonatomic,retain) NSArray *motionListRef;
@property (nonatomic,retain) NSMutableDictionary *scenarioGroupListDict;
@property (nonatomic,retain) NSArray *scenarioGroupListRef;
@property (nonatomic,retain) NSMutableDictionary *modelGroupListDict;
@property (nonatomic,retain) NSArray *modelGroupListRef;
@property (nonatomic,retain) NSMutableDictionary *motionGroupListDict;
@property (nonatomic,retain) NSArray *motionGroupListRef;

@property (nonatomic,retain) NSMutableArray *listInCurrentZip;


-(NSString*)root;
-(NSArray*)listFromRoot;
-(NSArray*)listFromPath:(NSString*)path;
-(NSData*)fileRead:(NSString*)path;

-(void)saveScenarioListFile;
-(NSInteger)loadScenarioListFile;
-(void)saveModelListFile;
-(NSInteger)loadModelListFile;
-(void)saveMotionListFile;
-(NSInteger)loadMotionListFile;
-(void)saveScenarioGroupListFile;
-(NSInteger)loadScenarioGroupListFile;
-(void)saveModelGroupListFile;
-(NSInteger)loadModelGroupListFile;
-(void)saveMotionGroupListFile;
-(NSInteger)loadMotionGroupListFile;

-(BOOL)fileWriteDictData:(NSDictionary*)dict fileName:(NSString*)fn;
-(NSMutableDictionary*)dictionaryWithContentsOfFile:(NSString*)fn;
-(BOOL)fileWriteArrayData:(NSArray*)array fileName:(NSString*)fn;
-(NSMutableArray*)arrayWithContentsOfFile:(NSString*)fn;

-(void)fileClose;
-(long long)fileSizeForPath:(NSString*)path;
-(BOOL)isFolder:(NSString*)path;
-(BOOL)isFile:(NSString*)path;

-(BOOL)openZipFile:(NSString*)zipFile;
-(void)closeZipFile;
-(NSData*)readZipContentFile:(NSString*)path;
-(NSString*)getZipPathOfModelPath:(NSString*)modelPath;
-(NSString*)getZipPathOfMotionPath:(NSString*)motionPath;

-(void)loadZipListFile;
-(void)loadListOfModelAndMotionFromZipListDict;

-(NSMutableDictionary*)getScenarioListDict;
-(NSArray*)getScenarioList;
-(NSMutableDictionary*)getModelListDict;
-(NSArray*)getModelList;
-(NSMutableDictionary*)getMotionListDict;
-(NSArray*)getMotionList;
-(NSMutableDictionary*)getScenarioGroupListDict;
-(NSArray*)getScenarioGroupList;
-(NSMutableDictionary*)getModelGroupListDict;
-(NSArray*)getModelGroupList;
-(NSMutableDictionary*)getMotionGroupListDict;
-(NSArray*)getMotionGroupList;

@end
