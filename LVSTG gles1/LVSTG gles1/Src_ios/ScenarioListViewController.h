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

@class DocumentController;
@class ScenarioData;

@interface ScenarioListViewController : UITableViewController {
    DocumentController *documentController;
    ScenarioData *scenarioData;
    UINavigationController *navigationController;
    UISplitViewController *splitViewController;
    MMDViewController *mmdViewController;
    
    NSInteger deviceModel;
    NSInteger viewMode;
    NSIndexPath *selectedCellIndexPath;
    UITableViewCell *selectedCell;
    NSMutableDictionary *groupDict;
    NSString *groupName;
    NSMutableArray *selectedIndexPathList;
    NSMutableDictionary *paramDict;
    NSMutableArray *playList;
    NSInteger playListIdx;

}

// file
@property (nonatomic,retain) DocumentController *documentController;
@property (nonatomic,retain) ScenarioData *scenarioData;
@property (nonatomic,assign) NSInteger deviceModel;
@property (nonatomic,assign) NSInteger viewMode;
@property (nonatomic,retain) NSIndexPath *selectedCellIndexPath;
@property (nonatomic,retain) UITableViewCell *selectedCell;
@property (nonatomic,retain) NSMutableDictionary *groupDict;
@property (nonatomic,retain) NSString *groupName;
@property (nonatomic,retain) NSMutableArray *selectedIndexPathList;
@property (nonatomic,retain) NSMutableDictionary *paramDict;

// Navibar Controller
@property (nonatomic,retain) UINavigationController *navigationController;
@property (nonatomic,retain) UISplitViewController *splitViewController;

- (void)insertNewObject:(id)sender;

// calll back from AppDelegate
- (void)applicationWillResignActive;
- (void)applicationDidEnterBackground;
- (void)applicationWillEnterForeground;
- (void)applicationDidBecomeActive;
- (void)applicationWillTerminate;

@end
