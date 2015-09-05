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
@class MotionViewController;

@interface MotionGroupViewController : UITableViewController {
    EditModelDetailViewController *editModelDetailViewController;
    MotionViewController *motionViewControllerAll;
    MotionViewController *motionViewControllerGrp;
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
@property (nonatomic,retain) MotionViewController *motionViewControllerAll;
@property (nonatomic,retain) MotionViewController *motionViewControllerGrp;

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
