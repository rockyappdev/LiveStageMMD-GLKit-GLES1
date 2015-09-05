//
//  *scenario.h
//  MMD4U
//
//  Created by Rocky on 2013/05/06.
//  Copyright (c) 2013年 twincle4u. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Foundation/NSEnumerator.h>

@class DocumentController;
@class MPMediaItemCollection;

@interface ScenarioData : NSObject {
    DocumentController *documentController;
    NSMutableDictionary *scenarioInfoDict;
    NSMutableArray *scenarioInfoModelList;
    
    // table entry
    NSIndexPath *scenarioInfoIndexPath;
    NSIndexPath *zipIndexPath;
    MPMediaItemCollection *mediaItemCollection;
    //NSDictionary *scenarioModelDict;
    
    // current object
    NSString  *titile;
    NSString  *modelPath;
    NSString  *modelZipPath;
    NSString  *motionPath;
    NSString  *motionZipPath;
    NSString  *musicTitle;
    NSNumber  *musicId;
    int       usePhysics;
    float     positionX;
    float     positionY;
    float     positionZ;
    float     lookatDX;
    float     lookatDY;
    float     lookatDZ;
    
}

// file access api
@property (nonatomic,strong) DocumentController *documentController;
@property (nonatomic,retain) NSMutableDictionary *scenarioInfoDict;
@property (nonatomic,retain) NSMutableArray *scenarioInfoModelList;

// table entry
@property (nonatomic,retain) NSIndexPath *scenarioInfoIndexPath;
@property (nonatomic,retain) NSIndexPath *zipIndexPath;
@property (nonatomic,retain) MPMediaItemCollection *mediaItemCollection;

// current object
@property (nonatomic,retain) NSString *title;
@property (nonatomic,retain) NSString *modelPath;
@property (nonatomic,retain) NSString *modelZipPath;
@property (nonatomic,retain) NSString *motionPath;
@property (nonatomic,retain) NSString *motionZipPath;
@property (nonatomic,retain) NSString *musicTitle;
@property (nonatomic,retain) NSNumber *musicId;
@property (nonatomic,assign) int      usePhysics;
@property (nonatomic,assign) float    positionX;
@property (nonatomic,assign) float    positionY;
@property (nonatomic,assign) float    positionZ;
@property (nonatomic,assign) float    lookatDX;
@property (nonatomic,assign) float    lookatDY;
@property (nonatomic,assign) float    lookatDZ;

-(NSInteger)numberOfSectionsInScenarioList;
-(NSInteger)numberOfRowsInSectionOfScenarioList:(NSInteger)section;
-(NSString*)titleForSectionInScenarioList:(NSInteger)section;
-(NSString*)titleForRowInScenarioInfoIndexPath:(NSIndexPath*)indexPath;
-(id)valueForScenarioInfoIndexPath:(NSIndexPath*)indexPath;

-(NSInteger)numberOfSectionsInModelDetail;
-(NSInteger)numberOfRowsInSectionOfModelDetail:(NSInteger)section;
-(NSString*)titleForSectionInModelDetail:(NSInteger)section;
-(NSString*)titleForRowInModelDetailIndexPath:(NSIndexPath*)indexPath;
-(id)valueForModelDetailIndexPath:(NSIndexPath*)indexPath;
-(id)valueForModelDetailSection:(NSInteger)section row:(NSInteger)row;

-(BOOL)canEditRowAtScenarioInfoIndexPath:(NSIndexPath *)indexPath;
-(void)setMusicForScenarioInfoIndexPath:(NSDictionary*)musicDict;
-(void)setModelForScenarioInfoIndexPath:(NSString*)name path:(NSString*)path zipPath:(NSString*)zipPath;
-(void)setMotionForScenarioInfoIndexPath:(NSString*)name path:(NSString*)path zipPath:(NSString*)zipPath;
-(void)setValue:(NSString*)value forScenarioListInexPath:(NSIndexPath*)indexPath;
-(void)setValue:(NSString*)value forModelDetailInexPath:(NSIndexPath *)indexPath;

-(BOOL)openZipFile:(NSString*)zipFile;
-(void)closeZipFile;

//-(NSString*)lastZipFile;

-(BOOL)openCurrentModelZipPath;
-(BOOL)openCurrentMotionZipPath;
-(NSData*)readZipContentFile:(NSString*)filename;
-(NSData*)readZipCurrentModelPath;
-(NSData*)readZipCurrentMotionPath;


-(void)loadZipListFile;
-(void)loadListOfModelAndMotionFromZipListDict;
-(void)loadCurrentScenarioInfoDict:(NSMutableDictionary*)scenarioInfoDict;

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

-(void)addNewGroupToDictionary:(NSMutableDictionary*)groupDict rootDict:(NSMutableDictionary*)rootDict;
-(void)addNewGroupToScenarioGroupDict:(NSMutableDictionary*)groupDict;
-(void)addNewGroupToModelGroupDict:(NSMutableDictionary*)groupDict;
-(void)addNewGroupToMotionGroupDict:(NSMutableDictionary*)groupDict;

-(NSString*)getZipPathOfModelPath:(NSString*)modelPath;
-(NSString*)getZipPathOfMotionPath:(NSString*)motionPath;
-(NSString*)getCurrentModelPath;
-(NSString*)getCurrentMotionPath;
-(NSString*)getCurrentScenarioName;
-(NSString*)getCurrentScenarioKey;
-(NSMutableDictionary*)getCurrentScenarioInfoModelByOrder:(NSInteger)idx;
-(NSInteger)getCurrentScenarioInfoModelCount;
-(void)addNewModelToScenarioInfoModelList;

-(void)addNewScenarioToScenarioList;
-(void)deleteScenarioFromScenarioList:(NSString*)name;
-(void)copyScenarioFromScenarioList:(NSString*)name;
-(void)saveChildDict:(NSMutableDictionary*)childDict withName:(NSString*)name IntoParentDict:(NSMutableDictionary*)parentDict;
-(NSString*)getTargetNameForDictionary:(NSMutableDictionary*)listDict name:(NSString*)name device:(NSString*)device;
-(void)renameObjectInDictionary:(NSMutableDictionary*)dict key:(NSString*)key toName:(NSString*)toName;
-(void)removeModelFromScenarioInfoModelListAtRow:(NSInteger)row;

@end
