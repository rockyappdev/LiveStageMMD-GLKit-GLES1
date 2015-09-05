//
//  MasterViewController.m
//  MMD4U
//
//  Created by Rocky on 2013/03/21.
//  Copyright (c) 2013年 twincle4u. All rights reserved.
//

#import "ScenarioGroupViewController.h"
#import "ScenarioListViewController.h"
#import "TextEditViewController.h"

#import "MMDViewController.h"
#import "EditViewController.h"

#import "ScenarioData.h"

@interface ScenarioGroupViewController ()

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)addNewGroup:(id)sender;

@end


@implementation ScenarioGroupViewController

@synthesize editViewController = _editViewController;
@synthesize navigationController = _navigationController;
@synthesize scenarioData = _scenarioData;
@synthesize splitViewController = _splitViewController;
@synthesize deviceModel = _deviceModel;
@synthesize viewMode = _viewMode;
@synthesize parentGroupDict = _parentGroupDict;
@synthesize groupDict = _groupDict;
@synthesize groupList = _groupList;
@synthesize groupName = _groupName;
@synthesize groupLevel = _groupLevel;
@synthesize paramDict = _paramDict;
@synthesize selectedIndexPathList = _selectedIndexPathList;
@synthesize scenarioListViewControllerAll = _scenarioListViewControllerAll;
@synthesize scenarioListViewControllerGrp = _scenarioListViewControllerGrp;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

    _selectedIndexPathList = [NSMutableArray array];

    return self;
}

- (void)setGroupDict:(NSMutableDictionary*)aGroupDict name:(NSString *)name
{
    NSLog(@"... ScenarioGroupViewController: setGroupDict");
    _groupName = name;
    _groupDict = aGroupDict;
    
    NSMutableDictionary *listDict = [_groupDict valueForKey:@"listDict"];
    
     _groupList = [[listDict allKeys] sortedArrayUsingComparator:^(id obj1, id obj2) {
        return [(NSString*)obj1 compare:(NSString*)obj2];
    }];

    NSLog(@"... setGroupDict: name[%@], _groupList[%ld]", name, (unsigned long)[_groupList count]);
    
}

- (void)viewDidLoad
{
    NSLog(@"... ScenarioGroupViewController: viewDidLoad called");

    NSLog(@"... paramDict count[%ld]", (unsigned long)[_paramDict count]);

    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    if (_selectedIndexPathList == nil) {
        _selectedIndexPathList = [NSMutableArray array];
    }

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        _deviceModel = 5;
    } else {
        _deviceModel = 14;
    }
    
        if (_viewMode != 1) {
            // Not Edit mode
            //[self setEditing:YES];
            self.navigationController.toolbarHidden = YES;

        }
        
        if (_viewMode == 1) {
            // Edit mode
            
            self.tableView.allowsMultipleSelection = NO;
            
            // Top Navigation bar
            //self.navigationItem.rightBarButtonItem = [self editButtonItem];
            
            UIBarButtonItem *buttonAddScenario = [[UIBarButtonItem alloc] initWithTitle:@"AddScenario"
                                                                                  style:UIBarButtonItemStylePlain
                                                                                 target:self
                                                                                 action:@selector(addScenarioToGroup:)];
            UIBarButtonItem *buttonAddGroup = [[UIBarButtonItem alloc] initWithTitle:@"AddGroup"
                                                                               style:UIBarButtonItemStylePlain
                                                                              target:self
                                                                              action:@selector(addNewGroup:)];
            NSArray *topButtons = [NSArray arrayWithObjects:buttonAddGroup, buttonAddScenario, nil];
            [self.navigationItem setRightBarButtonItems:topButtons animated:YES];
            
            
            // Bottom Menu bar
            UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
            UIBarButtonItem *buttonPlay = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(playMMD:)];
            UIBarButtonItem *buttonTrush = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteObject:)];
            UIBarButtonItem *buttonDetail = [[UIBarButtonItem alloc] initWithTitle:@"Detail" style:UIBarButtonItemStylePlain target:self action:@selector(showScenarioDetail:)];
            NSArray *bottomButtons = [NSArray arrayWithObjects:spacer, buttonPlay, spacer, buttonDetail, spacer, buttonTrush, spacer, nil];
            [self setToolbarItems:bottomButtons animated:YES];
            
        }

}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    NSIndexPath *indexPath;
    NSInteger numRow = [_groupList count];

    if (editing) {
        // Editing mode
        indexPath = [NSIndexPath indexPathForRow:numRow inSection:0];
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
        /*
        indexPath = [NSIndexPath indexPathForRow:numRow inSection:0];
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
        */
        
    } else {
        // end of editing mode
        indexPath = [NSIndexPath indexPathForRow:numRow inSection:0];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
    }

    [super setEditing:editing animated:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"... ScenarioGroupViewController: viewWillAppear");
    
    if (mmdViewController != nil) {
        //[mmdViewController release];
        mmdViewController = nil;
    }

    NSLog(@"... paramDict count[%ld]", (unsigned long)[_paramDict count]);

    if (_paramDict != nil) {
        NSString *paramFrom = [_paramDict valueForKey:@"paramFrom"];
        NSLog(@"... paramDict from [%@]", paramFrom);
        if ([paramFrom isEqualToString:@"parent"]) {
            _groupDict = [_paramDict valueForKey:@"groupDict"];
            _groupName = [_paramDict valueForKey:@"groupName"];
            _parentGroupDict = [_paramDict valueForKey:@"parentGroupDict"];
            
        } else if ([paramFrom isEqualToString:@"TextEditViewController"]) {
            NSString *fieldName = [_paramDict valueForKey:@"fieldName"];
            if ([fieldName isEqualToString:@"groupName"]) {
                NSString *oldName = [_paramDict valueForKey:@"oldTextValue"];
                NSString *newName = [_paramDict valueForKey:@"newTextValue"];
                if (![newName isEqualToString:oldName]) {
                    NSString *oldPath = [_groupDict valueForKey:@"path"];
                    NSString *targetName = [_scenarioData getTargetNameForDictionary:_parentGroupDict name:newName device:nil];
                    [_scenarioData renameObjectInDictionary:_parentGroupDict key:oldName toName:newName];
                    NSString *newPath = [_groupDict valueForKey:@"path"];
                    NSMutableDictionary *pathDict = [[_scenarioData getScenarioGroupListDict] valueForKey:@"pathDict"];
                    [pathDict setValue:_groupDict forKeyPath:newPath];
                    [pathDict removeObjectForKey:oldPath];
                    
                    [_scenarioData saveScenarioGroupListFile];
                    // do not reload groupList, will be broke the reference
                    _groupName = targetName;
                }
            }
        } else if ([paramFrom isEqualToString:@"EditViewController"]) {
            NSString *fieldName = [_paramDict valueForKey:@"fieldName"];
            if ([fieldName isEqualToString:@"childName"]) {
                NSString *key = [_paramDict valueForKey:@"key"];
                NSString *oldName = [_paramDict valueForKey:@"oldTextValue"];
                NSString *newName = [_paramDict valueForKey:@"newTextValue"];
                if (![newName isEqualToString:oldName]) {
                    NSLog(@"... Amend scenario name");
                    NSLog(@"... name from=[%@] to=[%@]", oldName, newName);
                    // rename in groupDict
                    [_scenarioData renameObjectInDictionary:_groupDict key:key toName:newName];
                    [_scenarioData saveScenarioGroupListFile];
                    // do not reload groupList, will be broke the reference
                }
            }
        } else if ([paramFrom isEqualToString:@"MMDViewController"]) {
            NSString *action = [_paramDict valueForKey:@"action"];
            if ([action isEqualToString:@"nextScenario"]) {
                [_paramDict setObject:@"" forKey:@"paramFrom"];
                [_paramDict setValue:@"" forKey:@"action"];
                if (playListIdx < [playList count]) {
                    // return from MMDViewController
                    // continue play next selected item
                    [self playScenarioNext];
                }
            }
        }
    } else {
        
        if (_parentGroupDict == nil) {
            _groupName = @"Top";
        }
        
    }

    [_paramDict setValue:@"" forKey:@"paramFrom"];

    // reload groupDict to groupList for any changes
    [self setGroupDict:_groupDict name:_groupName];
    
    if (_viewMode == 0) {
        self.title = [NSString stringWithFormat:@"Play Scenario Group: %@", _groupName];
    } else  if (_viewMode == 1) {
        self.title = [NSString stringWithFormat:@"Edit Scenario Group:%@", _groupName];
    }
    
    if (0) {
        NSLog(@"... selectedIndexPathList count[%lu]", (unsigned long)[_selectedIndexPathList count]);
        if (_selectedIndexPathList != nil) {
            for (NSIndexPath *indexPath in _selectedIndexPathList) {
                UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                cell.selected = YES;
                //cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
        }
    }
    
    if (_viewMode == 1) {
        // Edit mode
        self.navigationController.toolbarHidden = NO;
    } else {
        self.navigationController.toolbarHidden = YES;
    }
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.0];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    _navigationController.navigationBar.alpha = 1.0;
    _navigationController.toolbar.alpha = 1.0;
    [UIView commitAnimations];

    
    [self.tableView reloadData];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender
{
    NSLog(@"... ScenarioGroupViewController:insertNewObject called");
    
}

- (void)removeAddedNewEntryObject
{
    NSLog(@"... ScenarioGroupViewController: removeNewObject called");
    
}

- (void)addNewGroup:(id)sender
{
    NSLog(@"... ScenarioGroupViewController: addNewGropu called");
    
    [_scenarioData addNewGroupToScenarioGroupDict:_groupDict];
    [_scenarioData saveScenarioGroupListFile];
    // do not reload groupList, will be broke the reference

    [self setGroupDict:_groupDict name:_groupName];

    [self.tableView reloadData];
}

- (void)deleteObject:(id)sender
{
    NSLog(@"... ScenarioGroupViewController: deleteObject");
    
    NSArray *selectedArr = [self.tableView indexPathsForSelectedRows];
    if ([selectedArr count] > 0) {
        // delete scenario items
        NSMutableDictionary *listDict = [_groupDict valueForKey:@"listDict"];
        
        for (NSIndexPath *indexPath in selectedArr) {
            NSString *key = _groupList[indexPath.row];
            if ([listDict valueForKey:key]) {
                [listDict removeObjectForKey:key];
                NSLog(@"... removed scenario[%@] from group[%@]", key, _groupName);
            }
        }
        
        [_scenarioData saveScenarioGroupListFile];
        
        [self setGroupDict:_groupDict name:_groupName];
        
        [self.tableView reloadData];
        
    } else {
        // delete current group
        
        // show alert and get confirmation
        UIAlertView *alert = [[UIAlertView alloc] init];
        alert.delegate = self;
        alert.title = @"Delete this group";
        alert.message = @"Would you like to delete this group?";
        [alert addButtonWithTitle:@"No"];
        [alert addButtonWithTitle:@"Yes"];
        alert.cancelButtonIndex = 0;
        [alert show];

    }
    
}

- (void) alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex) {
        if ([alertView.title isEqualToString:@"Delete this group"]) {
            if (_parentGroupDict == nil) {
                [[_parentGroupDict valueForKey:@"listDict"] removeAllObjects];
            }
            
            [[_parentGroupDict valueForKey:@"listDict"] removeObjectForKey:_groupName];
            
            NSLog(@"... removed group[%@]", _groupName);
            
            [_scenarioData saveScenarioGroupListFile];
            
            [_navigationController popViewControllerAnimated:YES];
            
        }
    }
    
}


- (void)addScenarioToGroup:(id)sender
{
    NSLog(@"... ScenarioGroupViewController: addNewScenarioToGroup called");
    
    // Play List for All Scenario
    if (_scenarioListViewControllerGrp == nil) {
        if (_deviceModel < 10) {
            _scenarioListViewControllerGrp = [[ScenarioListViewController alloc] initWithNibName:@"TableViewController_iPhone" bundle:nil];
        } else {
            _scenarioListViewControllerGrp = [[ScenarioListViewController alloc] initWithNibName:@"TableViewController_iPad" bundle:nil];
        }
    }

    [_paramDict setValue:_groupName forKey:@"groupName"];
    [_paramDict setValue:_groupDict forKey:@"groupDict"];
    [_paramDict setValue:@"parent" forKey:@"paramFrom"];
    
    _scenarioListViewControllerGrp.paramDict = _paramDict;
    _scenarioListViewControllerGrp.viewMode = 2;
    _scenarioListViewControllerGrp.scenarioData = _scenarioData;
    _scenarioListViewControllerGrp.navigationController = self.navigationController;
    
    NSLog(@"... ScenarioGroupViewController -> ScenarioListViewController");
    
    [self.navigationController pushViewController:_scenarioListViewControllerGrp animated:YES];
    
}

- (void)showScenarioDetail:(UIButton*)button
{
    NSLog(@"... ScenarioGroupViewController: showScenarioDetail");

    NSMutableDictionary *scenarioDict;
    NSString *key;
    NSInteger row = button.tag;
    NSArray *selectedList = [self.tableView indexPathsForSelectedRows];
    
    if (row == 0 && selectedList.count > 0) {
        NSIndexPath *indexPath = selectedList[0];
        row = indexPath.row;
    }
    
    key = _groupList[row];
    
    //NSLog(@"... row = [%ld], name = [%@]", (long)row, name);

    scenarioDict = [[[_scenarioData getScenarioListDict] valueForKey:@"listDict"] valueForKey:key];
    
    [_scenarioData loadCurrentScenarioInfoDict: scenarioDict];
    
    if (!_editViewController) {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            _editViewController = [[EditViewController alloc] initWithNibName:@"EditViewController_iPhone" bundle:nil];
        } else {
            _editViewController = [[EditViewController alloc] initWithNibName:@"EditViewController_iPad" bundle:nil];
        }
    }
    
    [_paramDict setValue:_groupName forKey:@"groupName"];
    [_paramDict setValue:_groupDict forKey:@"groupDict"];
    [_paramDict setValue:scenarioDict forKey:@"scenarioInfoDict"];
    [_paramDict setValue:@"parent" forKey:@"paramFrom"];

    _editViewController.paramDict = _paramDict;
    _editViewController.scenarioData = _scenarioData;
    _editViewController.navigationController = self.navigationController;
    
    
    NSLog(@"... ScenarioGroupViewController -> EditViewController starting");
    [self.navigationController pushViewController:_editViewController animated:YES];
    
}

- (void)playMMD:(id)sender
{
    NSLog(@"... ScenarioGroupViewController: playMMD");
    
    NSArray *selectedList = [self.tableView indexPathsForSelectedRows];

    if (playList == nil) {
        playList = [NSMutableArray array];
    }
    
    [playList removeAllObjects];

    for (NSIndexPath *indexPath in selectedList) {
        NSString *key = _groupList[indexPath.row];
        [playList addObject:key];
    }

    playListIdx = 0;
    
    [self playScenarioNext];

}

- (void)playScenarioNext
{
    
    NSLog(@"... ScenarioGroupView: playScenarioNext");
    
    if (playListIdx < [playList count]) {
        
        NSString *key = playList[playListIdx];
        NSMutableDictionary *scenarioDict = [[[_scenarioData getScenarioListDict] valueForKey:@"listDict"] valueForKey:key];

        [_scenarioData loadCurrentScenarioInfoDict:scenarioDict];
        
        playListIdx++;
        
        NSLog(@"... ScenarioGroupViewController -> MMDViewController starting");
        
        if (mmdViewController == nil) {
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                mmdViewController = [[MMDViewController alloc] initWithNibName:@"MMDViewController_iPhone" bundle:nil];
            } else {
                mmdViewController = [[MMDViewController alloc] initWithNibName:@"MMDViewController_iPad" bundle:nil];
            }
        }
        
        [_paramDict setValue:@"" forKey:@"paramFrom"];

        mmdViewController.paramDict = _paramDict;
        mmdViewController.scenarioData = _scenarioData;
        mmdViewController.playList = playList;
        
        self.navigationController.hidesBottomBarWhenPushed = NO;
        mmdViewController.navigationController = self.navigationController;
        [self.navigationController pushViewController:mmdViewController animated:NO];
        
    }
    
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    int n = 1;

    if (_viewMode == 1) {
        // Edit mode
        n = 2;
    }

    return n;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title;
    if (_viewMode == 1) {
        if (section == 0) {
            title = @"Name";
        } else {
            title = @"(Edit mode to add new group and scenario)";
        }
    } else {
        title = @"Name";
    }
    
    return title;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger n;
    
    if (_viewMode == 1 && section == 0) {
            n = 1;
    } else {
        n = [_groupList count];
        
    }
    
    return n;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.numberOfLines = 0;
        /*
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
         */
        //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSString *title;
    
    NSLog(@"... tableView configureCell= viewMode[%ld] section[%ld], row[%ld]", (long)_viewMode, (long)indexPath.section, (long)indexPath.row);
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    //cell.textLabel.numberOfLines = 0;
    if (_viewMode == 1 && indexPath.section == 0) {
        title = _groupName;
    } else {
        NSString *key = _groupList[indexPath.row];
        NSLog(@"... key=[%@]", key);
        
        NSMutableDictionary *dictInfo = [[_groupDict valueForKey:@"listDict"] valueForKey:key];
        NSString *kind = [dictInfo valueForKey:@"kind"];
        if ([kind isEqualToString:@"group"]) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else {
            UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoDark];
            [infoButton addTarget:self action:@selector(showScenarioDetail:) forControlEvents:UIControlEventTouchUpInside];
            infoButton.tag = indexPath.row;
            cell.accessoryView = infoButton;
        }
        title = key;
        
    }
    
    cell.textLabel.text = title;
    
    if (_deviceModel > 10) {
        cell.textLabel.font = [UIFont systemFontOfSize:16.0];
    } else {
        cell.textLabel.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
    }
    
    NSLog(@"... tableView configureCell finished");
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL ret = YES;
    // Return NO if you do not want the specified item to be editable.
    if (_viewMode == 1 && indexPath.section == 0) {
        ret = NO;
    } else {
        NSString *key = _groupList[indexPath.row];
        NSMutableDictionary *dictInfo = [_groupDict valueForKey:key];
        NSString *kind = [dictInfo valueForKey:@"kind"];
        if ([kind isEqualToString:@"group"]) {
            ret = NO;
        }
        
    }

    return ret;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        ;
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"... ScenarioGroupViewController:tableView didSelectRowAtIndexPath called");
    NSLog(@"... _paramDict[%lu]", (unsigned long)[_paramDict count]);
    
    if (_viewMode == 1 && indexPath.section == 0) {
        // Amend Group name
        if ([_groupName isEqualToString:@"Top"]) {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            cell.selected = NO;
            cell.accessoryType = UITableViewCellAccessoryNone;
        } else {
            TextEditViewController *textEditViewController;
            
            if (_deviceModel < 10) {
                textEditViewController = [[TextEditViewController alloc] initWithNibName:@"TextEditViewController_iPhone" bundle:nil];
            } else {
                textEditViewController = [[TextEditViewController alloc] initWithNibName:@"TextEditViewController_iPad" bundle:nil];
            }

            [_paramDict setValue:@"groupName" forKey:@"fieldName"];
            [_paramDict setValue:_groupName forKey:@"oldTextValue"];
            [_paramDict setValue:@"parent" forKey:@"paramFrom"];
            
            NSLog(@"... _paramDict[%ld]", (unsigned long)[_paramDict count]);
            
            textEditViewController.paramDict = _paramDict;
            textEditViewController.navigationController = _navigationController;
            
            [self.navigationController pushViewController:textEditViewController animated:YES];
        }

    } else {
        // Group List
        
        ScenarioGroupViewController *scenarioGroupViewController;
        
        if (_deviceModel < 10) {
            scenarioGroupViewController = [[ScenarioGroupViewController alloc] initWithNibName:@"TableViewController_iPhone" bundle:nil];
        } else {
            scenarioGroupViewController = [[ScenarioGroupViewController alloc] initWithNibName:@"TableViewController_iPad" bundle:nil];
        }
        
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        
        NSString *key = _groupList[indexPath.row];
        NSMutableDictionary *dictInfo = [[_groupDict valueForKey:@"listDict"] valueForKey:key];
        NSString *kind = [dictInfo valueForKey:@"kind"];
        if ([kind isEqualToString:@"group"]) {
            // Group Dict
            
            [_paramDict setValue:dictInfo forKey:@"groupDict"];
            [_paramDict setValue:key forKey:@"groupName"];
            [_paramDict setValue:_groupDict forKey:@"parentGroupDict"];
            [_paramDict setValue:@"parent" forKey:@"paramFrom"];
            
            NSLog(@"... _paramDict[%lu]", (unsigned long)[_paramDict count]);
            
            scenarioGroupViewController.paramDict = _paramDict;
            scenarioGroupViewController.scenarioData = _scenarioData;
            scenarioGroupViewController.navigationController = self.navigationController;
            scenarioGroupViewController.groupLevel = _groupLevel+1;
            scenarioGroupViewController.viewMode = self.viewMode;
            
            NSLog(@"... ScenarioGroupViewController -> ScenarioGroupViewController");
            
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selected = NO;
            
            [self.navigationController pushViewController:scenarioGroupViewController animated:YES];
        } else {
            // Scenario Item
            if (_viewMode != 1) {
                // Not edit mode
                [self playMMD:nil];
            }
            // _viewMode=1 edit mode
            // no action, just select one item
        }
        
    }

}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //[_selectedIndexPathList removeObject:indexPath];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
}

// call back from AppDelegagte
- (void)applicationWillResignActive
{
    [_editViewController applicationWillResignActive];
}

- (void)applicationDidEnterBackground
{
    [_editViewController applicationDidEnterBackground];
}

- (void)applicationWillEnterForeground
{
    [_editViewController applicationWillEnterForeground];
}

- (void)applicationDidBecomeActive
{
    [_editViewController applicationDidBecomeActive];
}

- (void)applicationWillTerminate
{
    [_editViewController applicationWillTerminate];
}


@end
