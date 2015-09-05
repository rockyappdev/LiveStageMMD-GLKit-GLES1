//
//  MasterViewController.h
//  MMD4U
//
//  Created by Rocky on 2013/03/21.
//  Copyright (c) 2013年 twincle4u. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MMDViewController.h"
#import "EditViewController.h"

@class ScenarioData;
@class ScenarioListViewController;

@interface ScenarioGroupViewController : UITableViewController {
    EditViewController *editViewController;
    ScenarioData *scenarioData;
    UINavigationController *navigationController;
    UISplitViewController *splitViewController;
    ScenarioListViewController *scenarioListViewControllerAll;
    ScenarioListViewController *scenarioListViewControllerGrp;
    MMDViewController *mmdViewController;
    
    NSInteger viewMode;
    NSInteger deviceModel;
    NSMutableDictionary *parentGroupDict;
    NSMutableDictionary *groupDict;
    NSArray *groupList;
    NSString *groupName;
    NSInteger groupLevel;
    NSMutableDictionary *paramDict;
    NSMutableArray *selectedIndexPathList;
    NSMutableArray *playList;
    NSInteger playListIdx;

}

@property (nonatomic,retain) EditViewController *editViewController;
@property (nonatomic,retain) ScenarioListViewController *scenarioListViewControllerAll;
@property (nonatomic,retain) ScenarioListViewController *scenarioListViewControllerGrp;

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
