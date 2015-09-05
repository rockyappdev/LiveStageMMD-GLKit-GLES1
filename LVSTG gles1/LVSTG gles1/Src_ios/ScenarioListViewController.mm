//
//  MasterViewController.m
//  MMD4U
//
//  Created by Rocky on 2013/03/21.
//  Copyright (c) 2013年 twincle4u. All rights reserved.
//

#import "ScenarioListViewController.h"

#import "DocumentController.h"
#import "MMDViewController.h"
#import "EditViewController.h"

#import "ScenarioData.h"

@interface ScenarioListViewController ()

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)playMMD:(id)sender;
- (void)showScenarioDetail:(UIButton*)button;

@end


@implementation ScenarioListViewController

@synthesize documentController = _documentController;
@synthesize navigationController = _navigationController;
@synthesize scenarioData = _scenarioData;
@synthesize splitViewController = _splitViewController;
@synthesize deviceModel = _deviceModel;
@synthesize viewMode = _viewMode;
@synthesize selectedCellIndexPath = _selectedCellIndexPath;
@synthesize selectedCell = _selectedCell;
@synthesize groupDict = _groupDict;
@synthesize groupName = _groupName;
@synthesize selectedIndexPathList = _selectedIndexPathList;
@synthesize paramDict = _paramDict;

/* viewMode:
 * 0: PlayList - add selected to play
 * 1: Edit     - edit show detail
 * 2: AddGroup - add selected to group
 */


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

    _selectedIndexPathList = [NSMutableArray array];
    
    return self;
}

- (void)viewDidLoad
{
    NSLog(@"... ScenarioListViewController:viewDidLoad called");
    
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        _deviceModel = 5;
    } else {
        _deviceModel = 14;
    }
    
        if (_viewMode == 1) {
            // Edit mode
            // only one item select at a time
            [self setEditing:NO];
            
            //self.tableView.allowsMultipleSelectionDuringEditing = NO;
            self.tableView.allowsMultipleSelection = NO;
            
            // Top Navigation bar
            //self.navigationItem.rightBarButtonItem = [self editButtonItem];
            
            UIBarButtonItem *buttonAddNewScenario = [[UIBarButtonItem alloc] initWithTitle:@"AddNew"
                                                                                     style:UIBarButtonItemStylePlain
                                                                                    target:self
                                                                                    action:@selector(insertNewObject:)];
            /*
             UIBarButtonItem *buttonEditList = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
             target:self
             action:@selector(editMode:)];
             */
            //NSArray *topButtons = [NSArray arrayWithObjects:buttonEditList, buttonAddNewScenario, nil];
            NSArray *topButtons = [NSArray arrayWithObjects:buttonAddNewScenario, nil];
            [self.navigationItem setRightBarButtonItems:topButtons animated:YES];
            
            
            // Bottom Menu bar
            UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
            UIBarButtonItem *buttonPlay = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(playMMD:)];
            UIBarButtonItem *buttonTrush = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteObject:)];
            UIBarButtonItem *buttonCopy = [[UIBarButtonItem alloc] initWithTitle:@"Copy" style:UIBarButtonItemStylePlain target:self action:@selector(copyObject:)];
            UIBarButtonItem *buttonDetail = [[UIBarButtonItem alloc] initWithTitle:@"Detail" style:UIBarButtonItemStylePlain target:self action:@selector(showScenarioDetail:)];
            NSArray *bottomButtons = [NSArray arrayWithObjects:spacer, buttonPlay, spacer, buttonDetail, spacer, buttonCopy, spacer, buttonTrush, spacer, nil];
            [self setToolbarItems:bottomButtons animated:YES];
            
        } else {
            // Not Edit mode
            // show multiple check circle on the left
            [self setEditing:NO];
            
            // Top Navigation bar
            UIBarButtonItem *buttonCancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelOperation:)];
            self.navigationItem.rightBarButtonItem = buttonCancel;
            NSArray *topButtons = [NSArray arrayWithObjects:buttonCancel, nil];
            [self.navigationItem setRightBarButtonItems:topButtons animated:YES];
            
        }
        
}

- (void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"... ScenarioListViewController: viewWillDisappear");
    if (_viewMode == 2 && _groupDict != nil) {
        // add to group
        NSMutableDictionary *listDict = [_groupDict valueForKey:@"listDict"];
        NSMutableDictionary *listDictOfScenarioList = [[_scenarioData getScenarioListDict] valueForKey:@"listDict"];
        
        NSArray *selectedArr = [self.tableView indexPathsForSelectedRows];
        for (NSIndexPath *indexPath in selectedArr) {
            NSString *key = [_scenarioData getScenarioList][indexPath.row];
            NSMutableDictionary *sceanrioInfo = [listDictOfScenarioList valueForKey:key];
            [listDict setValue:sceanrioInfo forKey:key];
            NSLog(@"... added scenario[%@] to group[%@]", key, _groupName);
        }
        [_scenarioData saveScenarioGroupListFile];
        // do not reload groupList, will be broke the reference
        
        NSLog(@"... groupName=[%@] groupDict[listDict]=[%ld]", _groupName, (long)[listDict count]);
    }
}

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"... ScenarioListViewContorller: viewWillAppear");
    
    if (mmdViewController != nil) {
        //[mmdViewController release];
        mmdViewController = nil;
    }
    
    NSString *paramFrom = [_paramDict valueForKey:@"paramFrom"];
    if ([paramFrom isEqualToString:@"parent"]) {
        [_paramDict setValue:@"" forKey:@"paramFrom"];
        _groupDict = [_paramDict valueForKey:@"groupDict"];
        _groupName = [_paramDict valueForKey:@"groupName"];
    } else if ([paramFrom isEqualToString:@"EditViewController"]) {
        [_paramDict setValue:@"" forKey:@"paramFrom"];
        // work done at EditViewController
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
   
    if (_viewMode == 0) {
        self.title = @"Scenario List";
    } else  if (_viewMode == 1) {
        self.title = [NSString stringWithFormat:@"Edit Scenario"];
    } else  if (_viewMode == 2) {
        self.title = [NSString stringWithFormat:@"Add Scenario"];
    } else {
        self.title = @"Scenario List";
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)cancelOperation:(id)sender
{
    NSLog(@"... TextEditorViewController: cancelOperation");
    
    _viewMode = 9; // disabling adding selected items
    [_paramDict setValue:@"parent" forKey:@"paramFrom"];
    
    [_navigationController popViewControllerAnimated:YES];
    
}

- (void)insertNewObject:(id)sender
{
    NSLog(@"... ScenarioListViewController: insertNewObject called");
    
    [_scenarioData addNewScenarioToScenarioList];
    [self.tableView reloadData];
}

- (void)deleteObject:(id)sender
{
    NSLog(@"... ScenarioListViewController: deleteObject called");
    
    NSArray *selectedList = [self.tableView indexPathsForSelectedRows];
    
    NSMutableDictionary *listDict = [[_scenarioData getScenarioListDict] valueForKey:@"listDict"];
    for (NSIndexPath *indexPath in selectedList) {
        NSString *key = [_scenarioData getScenarioList][indexPath.row];
        if ([listDict valueForKey:key]) {
            [listDict removeObjectForKey:key];
            NSLog(@"... removed scenario=[%@] from scenarioListDict", key);
        }
    }

    [_scenarioData saveScenarioListFile];
    [_scenarioData loadScenarioListFile];
    
    [self.tableView reloadData];
}

- (void)copyObject:(id)sender
{
    NSLog(@"... ScenarioListViewController: copyObject called");
    
    NSArray *selectedList = [self.tableView indexPathsForSelectedRows];
    
    for (NSIndexPath *indexPath in selectedList) {
        NSString *key = [_scenarioData getScenarioList][indexPath.row];
        [_scenarioData copyScenarioFromScenarioList:key];
    }
    
    [self.tableView reloadData];
}

- (void)showScenarioDetail:(UIButton*)button
{
    NSMutableDictionary *scenarioDict;
    NSString *key;
    NSInteger row = button.tag;
    NSArray *selectedList = [self.tableView indexPathsForSelectedRows];
    
    if (row == 0 && selectedList.count > 0) {
        NSIndexPath *indexPath = selectedList[0];
        row = indexPath.row;
    }
    
    key = [_scenarioData getScenarioList][row];
    
    //NSLog(@"... row = [%ld], name = [%@]", (long)row, name);
    
    scenarioDict = [[[_scenarioData getScenarioListDict] valueForKey:@"listDict"] valueForKey:key];
    
    [_scenarioData loadCurrentScenarioInfoDict: scenarioDict];

    EditViewController *editViewController;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        editViewController = [[EditViewController alloc] initWithNibName:@"EditViewController_iPhone" bundle:nil];
    } else {
        editViewController = [[EditViewController alloc] initWithNibName:@"EditViewController_iPad" bundle:nil];
    }
    
    [_paramDict setValue:scenarioDict forKey:@"scenarioInfoDict"];
    [_paramDict setValue:@"parent" forKey:@"paramFrom"];
    
    editViewController.paramDict = _paramDict;
    editViewController.scenarioData = _scenarioData;
    editViewController.navigationController = self.navigationController;
    
    NSLog(@"... ScenarioListViewController -> EditViewController starting");
    [self.navigationController pushViewController:editViewController animated:YES];
   
}

- (void)playMMD:(id)sender
{
    NSLog(@"... ScenarioListViewController:playMMD");
    
    NSArray *selectedList = [self.tableView indexPathsForSelectedRows];
    
    if (playList == nil) {
        playList = [NSMutableArray array];
    }

    [playList removeAllObjects];
    
    for (NSIndexPath *indexPath in selectedList) {
        NSString *key = [_scenarioData getScenarioList][indexPath.row];
        [playList addObject:key];
    }

    playListIdx = 0;
    [self playScenarioNext];
    
}

- (void)playScenarioNext
{
    
    NSLog(@"... ScenarioListViewController: playScenarioNext");
    
    if (playListIdx < [playList count]) {
        
        NSString *key = playList[playListIdx];
        
        NSMutableDictionary *scenarioDict = [[[_scenarioData getScenarioListDict] valueForKey:@"listDict"] valueForKey:key];
        
        [_scenarioData loadCurrentScenarioInfoDict:scenarioDict];
        
        playListIdx++;
        
        NSLog(@"... ScenarioListViewController -> MMDViewController starting");
        
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
        
        self.navigationController.hidesBottomBarWhenPushed = YES;
        mmdViewController.navigationController = self.navigationController;
        [self.navigationController pushViewController:mmdViewController animated:NO];
        
    }
    
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    int n = 1;
    return n;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger n = [[_scenarioData getScenarioList] count];

    NSLog(@"... tableView numberOfRowsInSection=[%ld]", (long)n);
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
        //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    cell.tag = indexPath.row;

    [self configureCell:cell atIndexPath:indexPath];

    if (0) {
        if (_selectedIndexPathList != nil) {
            if ([_selectedIndexPathList containsObject:indexPath]) {
                cell.selected = YES;
                //cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
        }
    }
    
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *dictInfo;
    NSString *key;
    
    key = [_scenarioData getScenarioList][indexPath.row];
    dictInfo = [[_scenarioData getScenarioListDict] valueForKey:key];

    cell.textLabel.text = key;
    
    if (_deviceModel > 10) {
        cell.textLabel.font = [UIFont systemFontOfSize:18.0];
    } else {
        cell.textLabel.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
    }
    
    if (viewMode != 2) {
        // not adding to group
        UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoDark];
        [infoButton addTarget:self action:@selector(showScenarioDetail:) forControlEvents:UIControlEventTouchUpInside];
        infoButton.tag = indexPath.row;
        cell.accessoryView = infoButton;
    }
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"... ScenarioListViewController:tableView didSelectRowAtIndexPath called");
    
    if (_viewMode == 0) {
        [self playMMD:nil];
    }
    
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{

    //[_selectedIndexPathList removeObject:indexPath];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
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

// call back from AppDelegagte
- (void)applicationWillResignActive
{
}

- (void)applicationDidEnterBackground
{
}

- (void)applicationWillEnterForeground
{
}

- (void)applicationDidBecomeActive
{
}

- (void)applicationWillTerminate
{
}


@end
