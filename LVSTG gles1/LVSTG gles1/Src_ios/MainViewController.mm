//
//  MasterViewController.m
//  MMD4U
//
//  Created by Rocky on 2013/03/21.
//  Copyright (c) 2013年 twincle4u. All rights reserved.
//

#import "MainViewController.h"
#import "ScenarioGroupViewController.h"
#import "ScenarioListViewController.h"
#import "ModelGroupViewController.h"
#import "ModelViewController.h"
#import "MotionGroupViewController.h"
#import "MotionViewController.h"

#import "ScenarioData.h"


@interface MainViewController ()

//@property (nonatomic,retain) ModelZipViewController *modelZipViewController;

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end


@implementation MainViewController

@synthesize navigationController = _navigationController;

@synthesize scenarioData = _scenarioData;
@synthesize scenarioGroupViewController = _scenarioGroupViewController;
@synthesize modelGroupViewController = _modelGroupViewController;
@synthesize motionGroupViewController = _motionGroupViewController;
@synthesize deviceModel = _deviceModel;
@synthesize paramDict = _paramDict;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Poke MMD pmd", @"Poke MMD pmd");
    }

    return self;
}

- (void)viewDidLoad
{
    NSLog(@"... ScenarioGroupViewController:viewDidLoad called");

    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        _deviceModel = 5;
    } else {
        _deviceModel = 14;
    }

    /*
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;
     */
}

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"... MainViewController viewWillAppear: animated called");
    
    self.navigationController.toolbarHidden = YES;
    
    [super viewWillAppear:animated];

    //[self.tableView reloadData];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"... MainViewController viewWillAppear: animated called");
    [super viewDidAppear:animated];
    
    NSInteger n = [[_scenarioData getModelList] count];

    if (n == 0) {
        [_scenarioData loadZipListFile];  // force reload all zip files
        [_scenarioData loadListOfModelAndMotionFromZipListDict];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger n = 0;
    
    if (section == 0) {
        n = 2;
    } else if (section == 1) {
        n = 1;
    } else if (section == 2) {
        n = 3;
    } else if (section == 3) {
        n = 1;
    } else if (section == 4) {
        n = 1;
    }

    return n;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = @"";
    
    if (section == 0) {
        title = @"Play List";
    } else if (section == 1) {
        title = @"Data Maintenace";
    } else if (section == 2) {
        title = @"Group Maintenace";
    } else if (section == 3) {
        title = @"File Maintenance";
    } else if (section == 4) {
        title = @"Help";
    }
    
    return title;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSString *text;
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            text = @"Play list by group";
        } else if (indexPath.row == 1) {
            text = @"Play list for all scenarios";
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            text = @"Scenario List";
        }
    } else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            text = @"Scenario Group";
        } else if (indexPath.row == 1) {
            text = @"Model and Stage Group";
        } else if (indexPath.row == 2) {
            text = @"Motion Group";
        }
    } else if (indexPath.section == 3) {
        text = @"Reload all zip files";
    } else if (indexPath.section == 4) {
        text = @"To Be Added ...";
    }
    
    cell.textLabel.text = text;
    
    if (_deviceModel > 10) {
        cell.textLabel.font = [UIFont systemFontOfSize:18.0];
    } else {
        cell.textLabel.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
    }
    
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
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{

}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

- (void) alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex) {
        if ([alertView.title isEqualToString:@"Reload all zip files"]) {
            [_scenarioData loadZipListFile];  // force reload all zip files
            [_scenarioData loadListOfModelAndMotionFromZipListDict];
            
        }
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"... MainViewController: didSelectRowAtIndexPath");

    if (_paramDict == nil) {
        _paramDict = [NSMutableDictionary dictionary];
    }

    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            if (_deviceModel < 10) {
                _scenarioGroupViewController = [[ScenarioGroupViewController alloc] initWithNibName:@"TableViewController_iPhone" bundle:nil];
            } else {
                _scenarioGroupViewController = [[ScenarioGroupViewController alloc] initWithNibName:@"TableViewController_iPad" bundle:nil];
            }
            
            [_paramDict setValue:@"parent" forKey:@"paramFrom"];
            [_paramDict setValue:[_scenarioData getScenarioGroupListDict] forKey:@"groupDict"];
            [_paramDict setValue:@"Top" forKey:@"groupName"];
            
            NSLog(@"... paramDict count[%ld]", [_paramDict count]);
            
            _scenarioGroupViewController.paramDict = _paramDict;
            _scenarioGroupViewController.scenarioData = _scenarioData;
            _scenarioGroupViewController.navigationController = self.navigationController;
            _scenarioGroupViewController.groupLevel = 0;
            _scenarioGroupViewController.viewMode = 0; // Play mode
            _scenarioGroupViewController.parentGroupDict = nil;
            
            /*
             //NSMutableArray *initialControllers = [NSMutableArray arrayWithObject:self.settingsController];
             NSMutableArray *initialControllers = [NSMutableArray arrayWithObject:_ScenarioGroupViewController];
             
             UINavigationController *nav = [[UINavigationController alloc] init];
             nav.viewControllers = initialControllers;
             self.view.window.rootViewController = nav;
             
             _scenarioGroupViewController.navigationController = self.navigationController;
             
             
             //[self.view.window makeKeyAndVisible];
             */
            
            NSLog(@"... MainViewController -> ScenarioGroupViewController");
            
            [self.navigationController pushViewController:_scenarioGroupViewController animated:YES];
            
        } else {
            // Play List for All Scenario
            ScenarioListViewController *scenarioListViewController;
            if (_deviceModel < 10) {
                scenarioListViewController = [[ScenarioListViewController alloc] initWithNibName:@"TableViewController_iPhone" bundle:nil];
            } else {
                scenarioListViewController = [[ScenarioListViewController alloc] initWithNibName:@"TableViewController_iPad" bundle:nil];
            }
            
            [_paramDict setValue:@"parent" forKey:@"paramFrom"];
            [_paramDict setValue:[_scenarioData getScenarioGroupListDict] forKey:@"groupDict"];
            [_paramDict setValue:@"Top" forKey:@"groupName"];
            scenarioListViewController.paramDict = _paramDict;
            scenarioListViewController.scenarioData = _scenarioData;
            scenarioListViewController.navigationController = self.navigationController;
            scenarioListViewController.viewMode = 0; // Play mode

            
            NSLog(@"... MainViewController -> ScenarioListViewController");
            
            [self.navigationController pushViewController:scenarioListViewController animated:YES];
            
        }
        
    } else if (indexPath.section == 1) {
        // Data maintenance
        if (indexPath.row == 0) {
            // Scenario List
            ScenarioListViewController *scenarioListViewController;
            if (_deviceModel < 10) {
                scenarioListViewController = [[ScenarioListViewController alloc] initWithNibName:@"TableViewController_iPhone" bundle:nil];
            } else {
                scenarioListViewController = [[ScenarioListViewController alloc] initWithNibName:@"TableViewController_iPad" bundle:nil];
            }
            
            [_paramDict setValue:@"parent" forKey:@"paramFrom"];
            [_paramDict setValue:[_scenarioData getScenarioGroupListDict] forKey:@"groupDict"];
            [_paramDict setValue:@"Top" forKey:@"groupName"];
            scenarioListViewController.paramDict = _paramDict;
            scenarioListViewController.scenarioData = _scenarioData;
            scenarioListViewController.navigationController = self.navigationController;
            scenarioListViewController.viewMode = 1; // Edit mode
            
            NSLog(@"... MainViewController -> ScenarioListViewController");
            
            [self.navigationController pushViewController:scenarioListViewController animated:YES];
            
        }
        
    } else if (indexPath.section == 2) {
        // group maintenance
        if (indexPath.row == 0) {
            // Scenario Group
            if (_deviceModel < 10) {
                _scenarioGroupViewController = [[ScenarioGroupViewController alloc] initWithNibName:@"TableViewController_iPhone" bundle:nil];
            } else {
                _scenarioGroupViewController = [[ScenarioGroupViewController alloc] initWithNibName:@"TableViewController_iPad" bundle:nil];
            }
            
            [_paramDict setValue:@"parent" forKey:@"paramFrom"];
            [_paramDict setValue:[_scenarioData getScenarioGroupListDict] forKey:@"groupDict"];
            [_paramDict setValue:@"Top" forKey:@"groupName"];
            _scenarioGroupViewController.paramDict = _paramDict;
            _scenarioGroupViewController.scenarioData = _scenarioData;
            _scenarioGroupViewController.navigationController = self.navigationController;
            _scenarioGroupViewController.groupLevel = 0;
            _scenarioGroupViewController.viewMode = 1; // Edit mode
            
            /*
             //NSMutableArray *initialControllers = [NSMutableArray arrayWithObject:self.settingsController];
             NSMutableArray *initialControllers = [NSMutableArray arrayWithObject:_ScenarioGroupViewController];
             
             UINavigationController *nav = [[UINavigationController alloc] init];
             nav.viewControllers = initialControllers;
             self.view.window.rootViewController = nav;
             
             _scenarioGroupViewController.navigationController = self.navigationController;
             
             
             //[self.view.window makeKeyAndVisible];
             */
            
            NSLog(@"... MainViewController -> ScenarioGroupViewController");
            
            [self.navigationController pushViewController:_scenarioGroupViewController animated:YES];
            
        } else if (indexPath.row == 1) {
            // Model Group
            if (_deviceModel < 10) {
                _modelGroupViewController = [[ModelGroupViewController alloc] initWithNibName:@"TableViewController_iPhone" bundle:nil];
            } else {
                _modelGroupViewController = [[ModelGroupViewController alloc] initWithNibName:@"TableViewController_iPad" bundle:nil];
            }
            
            [_paramDict setValue:@"parent" forKey:@"paramFrom"];
            [_paramDict setValue:[_scenarioData getModelGroupListDict] forKey:@"groupDict"];
            [_paramDict setValue:@"Top" forKey:@"groupName"];
            _modelGroupViewController.paramDict = _paramDict;
            _modelGroupViewController.scenarioData = _scenarioData;
            _modelGroupViewController.navigationController = self.navigationController;
            _modelGroupViewController.groupLevel = 0;
            [_modelGroupViewController setGroupDict:[_scenarioData getModelGroupListDict] name:@"Top"];
            _modelGroupViewController.viewMode = 1; // Edit mode
            
            NSLog(@"... MainViewController -> ModelGroupViewController");
            
            [self.navigationController pushViewController:_modelGroupViewController animated:YES];
            
        } else if (indexPath.row == 2) {
            // Motion Group
            if (_deviceModel < 10) {
                _motionGroupViewController = [[MotionGroupViewController alloc] initWithNibName:@"TableViewController_iPhone" bundle:nil];
            } else {
                _motionGroupViewController = [[MotionGroupViewController alloc] initWithNibName:@"TableViewController_iPad" bundle:nil];
            }
            
            [_paramDict setValue:@"parent" forKey:@"paramFrom"];
            [_paramDict setValue:[_scenarioData getMotionGroupListDict] forKey:@"groupDict"];
            [_paramDict setValue:@"Top" forKey:@"groupName"];
            _motionGroupViewController.paramDict = _paramDict;
            _motionGroupViewController.scenarioData = _scenarioData;
            _motionGroupViewController.navigationController = self.navigationController;
            _motionGroupViewController.groupLevel = 0;
            [_motionGroupViewController setGroupDict:[_scenarioData getMotionGroupListDict] name:@"Top"];
            _motionGroupViewController.viewMode = 1; // Edit mode
            
            NSLog(@"... MainViewController -> MotionGroupViewController");
            
            [self.navigationController pushViewController:_motionGroupViewController animated:YES];
            
        }
        
    } else if (indexPath.section == 3) {
        // File maintenance
        UIAlertView *alert = [[UIAlertView alloc] init];
        alert.delegate = self;
        alert.title = @"Reload all zip files";
        alert.message = @"Would you like to reload all zip files?";
        [alert addButtonWithTitle:@"No"];
        [alert addButtonWithTitle:@"Yes"];
        alert.cancelButtonIndex = 0;
        [alert show];

    } else {
        // Help document
    }
}

// call back from AppDelegagte
- (void)applicationWillResignActive
{
    [_scenarioGroupViewController applicationWillResignActive];
}

- (void)applicationDidEnterBackground
{
    [_scenarioGroupViewController applicationDidEnterBackground];
}

- (void)applicationWillEnterForeground
{
    [_scenarioGroupViewController applicationWillEnterForeground];
}

- (void)applicationDidBecomeActive
{
    [_scenarioGroupViewController applicationDidBecomeActive];
}

- (void)applicationWillTerminate
{
    [_scenarioGroupViewController applicationWillTerminate];
}


@end
