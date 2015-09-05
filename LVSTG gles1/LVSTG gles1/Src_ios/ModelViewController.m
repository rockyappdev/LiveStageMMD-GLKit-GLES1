//
//  MasterViewController.m
//  MMD4U
//
//  Created by Rocky on 2013/03/21.
//  Copyright (c) 2013年 twincle4u. All rights reserved.
//

#import "ModelViewController.h"
#import "EditModelDetailViewController.h"

#import "ScenarioData.h"


@interface ModelViewController ()


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end


@implementation ModelViewController

@synthesize scenarioData = _scenarioData;
@synthesize editModelDetailViewController = _editModelDetailViewController;
@synthesize splitViewController = _splitViewController;
@synthesize navigationController = _navigationController;
@synthesize deviceModel = _deviceModel;
@synthesize viewMode = _viewMode;
@synthesize selectedCellIndexPath = _selectedCellIndexPath;
@synthesize selectedCell = _selectedCell;
@synthesize groupDict = _groupDict;
@synthesize groupName = _groupName;
@synthesize selectedIndexPathList = _selectedIndexPathList;
@synthesize paramDict = _paramDict;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"ModelList", @"ModelList");
    }
    
    _selectedIndexPathList = [NSMutableArray array];
    
    return self;
}

- (void)viewDidLoad
{
    NSLog(@"... ModelViewController viewDidLoad called");

    [super viewDidLoad];

	// Do any additional setup after loading the view, typically from a nib.
    //self.navigationItem.leftBarButtonItem = self.editButtonItem;
        
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        _deviceModel = 5;
    } else {
        _deviceModel = 14;
    }

    // Top Navigation bar
    UIBarButtonItem *buttonCancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelOperation:)];
    self.navigationItem.rightBarButtonItem = buttonCancel;
    NSArray *topButtons = [NSArray arrayWithObjects:buttonCancel, nil];
    [self.navigationItem setRightBarButtonItems:topButtons animated:YES];

}

- (void)viewWillDisappear:(BOOL)animated
{
    if (_viewMode == 2 && _groupDict != nil) {
        // add to group
        NSMutableDictionary *listDict = [_groupDict valueForKey:@"listDict"];
        NSMutableDictionary *listDictOfModelList = [[_scenarioData getModelListDict] valueForKey:@"listDict"];

        NSArray *selectedArr = [self.tableView indexPathsForSelectedRows];
        for (NSIndexPath *indexPath in selectedArr) {
            NSString *key = [_scenarioData getModelList][indexPath.row];
            NSMutableDictionary *detailInfo = [listDictOfModelList valueForKey:key];
            [listDict setValue:detailInfo forKey:key];
            NSLog(@"... added model[%@] to group[%@]", key, _groupName);
        }
        [_scenarioData saveModelGroupListFile];
        
        NSLog(@"... groupName=[%@] groupDict[listDict]=[%ld]", _groupName, (long)[listDict count]);

    }
}

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"... ModelViewContorller: viewWillAppear");
    
    NSString *paramFrom = [_paramDict valueForKey:@"paramFrom"];
    if ([paramFrom isEqualToString:@"parent"]) {
        [_paramDict setValue:@"" forKey:@"paramFrom"];
        _groupDict = [_paramDict valueForKey:@"groupDict"];
        _groupName = [_paramDict valueForKey:@"groupName"];
    }
    [_paramDict setValue:@"" forKey:@"paramFrom"];
    
    if (_viewMode == 0) {
        self.title = @"Model Selection in All List";
    } else  if (_viewMode == 1) {
        self.title = [NSString stringWithFormat:@"Edit Model in Group: %@", _groupName];
    } else  if (_viewMode == 2) {
        self.title = [NSString stringWithFormat:@"Add Model to Group: %@", _groupName];
    } else {
        self.title = @"Model List";
    }

    self.navigationController.toolbarHidden = YES;

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


#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[_scenarioData getModelList] count];
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
    
    key = [_scenarioData getModelList][indexPath.row];
    dictInfo = [[_scenarioData getModelListDict] valueForKey:key];
    
    key = [NSString stringWithFormat:@"%@/\n%@",[key stringByDeletingLastPathComponent], [key lastPathComponent] ];
    cell.textLabel.text = key;
    
    if (_deviceModel > 10) {
        cell.textLabel.font = [UIFont systemFontOfSize:12.0];
    } else {
        cell.textLabel.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"... ModelViewController:tableView didSelectRowAtIndexPath called");
    
    NSString *path = [_scenarioData getModelList][indexPath.row];
    NSString *name = [path lastPathComponent];
    NSString *zipPath = [_scenarioData getZipPathOfModelPath:path];
    
    if (_viewMode != 2) {
        // not adding to group
        [_scenarioData setModelForScenarioInfoIndexPath:name path:path zipPath:zipPath];
        // skip GroupViewController and back to EditDetailViewController
        [_navigationController popToViewController:_editModelDetailViewController animated:YES];
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
            // delete zipFile
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
