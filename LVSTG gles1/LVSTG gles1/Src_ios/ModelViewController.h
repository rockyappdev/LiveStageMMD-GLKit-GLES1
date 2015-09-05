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

@interface ModelViewController : UITableViewController {
    ScenarioData *scenarioData;
    EditModelDetailViewController *editModelDetailViewController;
    UINavigationController *navigationController;
    UISplitViewController *splitViewController;
    NSInteger deviceModel;
    NSInteger viewMode;
    NSIndexPath *selectedCellIndexPath;
    UITableViewCell *selectedCell;
    NSMutableDictionary *groupDict;
    NSString *groupName;
    NSMutableArray *selectedIndexPathList;
    NSMutableDictionary *paramDict;
}

// Navibar Controller
@property (nonatomic,retain) UINavigationController *navigationController;
@property (nonatomic,retain) UISplitViewController *splitViewController;

// file
@property (nonatomic,retain) ScenarioData *scenarioData;
@property (nonatomic,retain) EditModelDetailViewController *editModelDetailViewController;

@property (nonatomic,assign) NSInteger deviceModel;
@property (nonatomic,assign) NSInteger viewMode;
@property (nonatomic,retain) NSIndexPath *selectedCellIndexPath;
@property (nonatomic,retain) UITableViewCell *selectedCell;
@property (nonatomic,retain) NSMutableDictionary *groupDict;
@property (nonatomic,retain) NSString *groupName;
@property (nonatomic,retain) NSMutableArray *selectedIndexPathList;
@property (nonatomic,retain) NSMutableDictionary *paramDict;


// calll back from AppDelegate
- (void)applicationWillResignActive;
- (void)applicationDidEnterBackground;
- (void)applicationWillEnterForeground;
- (void)applicationDidBecomeActive;
- (void)applicationWillTerminate;

@end
