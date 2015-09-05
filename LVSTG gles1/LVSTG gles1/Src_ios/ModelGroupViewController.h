//
//  MasterViewController.h
//  MMD4U
//
//  Created by Rocky on 2013/03/21.
//  Copyright (c) 2013年 twincle4u. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ScenarioData;
@class EditModelDetailViewController;
@class ModelViewController;

@interface ModelGroupViewController : UITableViewController {
    EditModelDetailViewController *editModelDetailViewController;
    ModelViewController *modelViewControllerAll;
    ModelViewController *modelViewControllerGrp;
    ScenarioData *scenarioData;
    UINavigationController *navigationController;
    UISplitViewController *splitViewController;
    NSInteger viewMode;
    NSInteger deviceModel;
    NSMutableDictionary *parentGroupDict;
    NSMutableDictionary *groupDict;
    NSArray *groupList;
    NSString *groupName;
    NSInteger groupLevel;
    NSMutableDictionary *paramDict;
    NSMutableArray *selectedIndexPathList;

}

@property (nonatomic,retain) EditModelDetailViewController *editModelDetailViewController;
@property (nonatomic,retain) ModelViewController *modelViewControllerAll;
@property (nonatomic,retain) ModelViewController *modelViewControllerGrp;

// file
@property (nonatomic, retain) ScenarioData *scenarioData;
@property (nonatomic,assign) NSInteger deviceModel;
@property (nonatomic,assign) NSInteger viewMode;
@property (nonatomic,retain) NSMutableDictionary *parentGroupDict;
@property (nonatomic,retain) NSMutableDictionary *groupDict;
@property (nonatomic,retain) NSArray *groupList;
@property (nonatomic,retain) NSString *groupName;
@property (nonatomic,assign) NSInteger groupLevel;
@property (nonatomic,retain) NSMutableDictionary *paramDict;
@property (nonatomic,retain) NSMutableArray *selectedIndexPathList;

// Navibar Controller
@property (nonatomic,retain) UINavigationController *navigationController;
@property (nonatomic,retain) UISplitViewController *splitViewController;

- (void)setGroupDict:(NSMutableDictionary*)groupDict name:(NSString*)name;

// calll back from AppDelegate
- (void)applicationWillResignActive;
- (void)applicationDidEnterBackground;
- (void)applicationWillEnterForeground;
- (void)applicationDidBecomeActive;
- (void)applicationWillTerminate;

@end
