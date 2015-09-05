//
//  MasterViewController.h
//  MMD4U
//
//  Created by Rocky on 2013/03/21.
//  Copyright (c) 2013年 twincle4u. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>
#import <UIKit/UIKit.h>

#import <CoreData/CoreData.h>


@class DocumentController;
@class MMDViewController;
@class ScenarioData;

@interface EditViewController : UITableViewController <MPMediaPickerControllerDelegate> {
    ScenarioData *scenarioData;
    DocumentController *documentController;
    UINavigationController *navigationController;
    MMDViewController *mmdViewController;

    bool editMode;
    NSInteger deviceModel;
    NSMutableDictionary *paramDict;
    NSString *groupName;
    NSMutableDictionary *groupDict;

}


@property (nonatomic,retain) ScenarioData *scenarioData;
@property (nonatomic,assign) NSInteger deviceModel;
@property (nonatomic,retain) DocumentController *documentController;

// Navibar Controller
@property (nonatomic,retain) UINavigationController *navigationController;
@property (nonatomic,retain) UISplitViewController *splitViewController;
@property (nonatomic,assign) bool editMode;
@property (nonatomic,retain) NSMutableDictionary *paramDict;
@property (nonatomic,retain) NSString *groupName;
@property (nonatomic,retain) NSMutableDictionary *groupDict;

// calll back from AppDelegate
-(void)applicationWillResignActive;
-(void)applicationDidEnterBackground;
-(void)applicationWillEnterForeground;
-(void)applicationDidBecomeActive;
-(void)applicationWillTerminate;

@end
