//
//  MasterViewController.m
//  MMD4U
//
//  Created by Rocky on 2013/03/21.
//  Copyright (c) 2013年 twincle4u. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EditModelDetailViewController.h"
#import "DocumentController.h"
#import "ModelGroupViewController.h"
#import "ModelViewController.h"
#import "MotionGroupViewController.h"
#import "MotionViewController.h"
#import "TextEditViewController.h"


#import "ScenarioData.h"

@interface EditModelDetailViewController ()

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end


@implementation EditModelDetailViewController

@synthesize documentController = _documentController;
@synthesize scenarioData = _scenarioData;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize splitViewController = _splitViewController;
@synthesize navigationController = _navigationController;
@synthesize editViewController = _editViewController;
@synthesize deviceModel = _deviceModel;
@synthesize paramDict = _paramDict;
@synthesize editMode = _editMode;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"EditModel", @"EditModel");
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    //self.navigationItem.leftBarButtonItem = self.editButtonItem;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        _deviceModel = 5;
    } else {
        _deviceModel = 14;
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"... EditModelDetailViewController:viewWillAppear: called");

    NSLog(@"... paramDict count[%ld]", (long)[_paramDict count]);
    
    NSString *paramFrom = [_paramDict valueForKey:@"paramFrom"];
    if ([paramFrom isEqualToString:@"TextEditViewController"]) {
        if ([_paramDict valueForKey:@"indexPath"] != nil) {
            NSIndexPath *indexPath = [_paramDict valueForKey:@"indexPath"];
            NSString *oldTextValue = [_paramDict valueForKey:@"oldTextValue"];
            NSString *newTextValue = [_paramDict valueForKey:@"newTextValue"];
            if (![oldTextValue isEqualToString:newTextValue]) {
                [_scenarioData setValue:newTextValue forModelDetailInexPath:indexPath];
            }
        }
    }

    [_paramDict setValue:@"" forKey:@"paramFrom"];

    self.navigationController.toolbarHidden = YES;

    [self.tableView reloadData];
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    NSLog(@"xxx EditModelDetailViewController:viewDidDisappear");

    [super viewDidDisappear:animated];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger n = [_scenarioData numberOfSectionsInModelDetail];
    NSLog(@"... numberOfSectionsInTableView=[%ld]", (long)n);
    return n;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger n = [_scenarioData numberOfRowsInSectionOfModelDetail: section];
    NSLog(@"... numberOfRowsInSection[%ld]=[%ld]", (long)section, (long)n);
    return n;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *str = [_scenarioData titleForSectionInModelDetail: section];
    return str;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    BOOL disclosure = YES;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.textLabel.numberOfLines = 0;
        
        if (disclosure) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }

    }

    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = [indexPath section];
    //NSInteger row = [indexPath row];
    
    NSString *title;
    NSString *value;
    NSNumber *num;
    
    if (section == 0) {
        title = [_scenarioData titleForRowInModelDetailIndexPath: indexPath];
        num = [_scenarioData valueForModelDetailIndexPath: indexPath];
        value = [NSString stringWithFormat:@"%d", [num intValue]];
        //cell.textLabel.numberOfLines = 0;
        cell.textLabel.font = [UIFont systemFontOfSize:[UIFont buttonFontSize]];
        //cell.detailTextLabel.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else if (section >= 1 && section <= 2) {
        title = [_scenarioData titleForRowInModelDetailIndexPath: indexPath];
        value = [_scenarioData valueForModelDetailIndexPath: indexPath];
        //cell.textLabel.numberOfLines = 0;
        cell.textLabel.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
        //cell.detailTextLabel.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
    } else if (section >= 3 && section <= 5) {
        title = [_scenarioData titleForRowInModelDetailIndexPath: indexPath];
        num = [_scenarioData valueForModelDetailIndexPath: indexPath];
        value = [NSString stringWithFormat:@"%d", [num intValue]];
        //cell.textLabel.numberOfLines = 0;
        cell.textLabel.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
        //cell.detailTextLabel.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
    } else if (section >= 6 && section <= 7) {
        title = [_scenarioData titleForRowInModelDetailIndexPath: indexPath];
        num = [_scenarioData valueForModelDetailIndexPath: indexPath];
        value = [NSString stringWithFormat:@"%3.4f", [num floatValue]];
        //cell.textLabel.numberOfLines = 0;
        cell.textLabel.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
        //cell.detailTextLabel.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
        
    }
    
    //cell.textLabel.numberOfLines = 0;
    cell.textLabel.text = title;
    cell.detailTextLabel.text = value;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return [_scenarioData canEditRowAtScenarioInfoIndexPath:indexPath];
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
    NSLog(@"... EditModelDetailViewController: didSelectRowAtIndexPath");
    
    NSString *title;
    NSString *value;
    NSNumber *num;
    
    TextEditViewController *textEditViewController;
    ModelGroupViewController *modelGroupViewController;
    MotionGroupViewController *motionGroupViewController;
    
    if (indexPath.section == 0) {
        if (indexPath.row < 3) {
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                textEditViewController = [[TextEditViewController alloc] initWithNibName:@"TextEditViewController_iPhone" bundle:nil];
            } else {
                textEditViewController = [[TextEditViewController alloc] initWithNibName:@"TextEditViewController_iPad" bundle:nil];
            }

            title = [_scenarioData titleForRowInModelDetailIndexPath: indexPath];
            num = [_scenarioData valueForModelDetailIndexPath: indexPath];
            value = [NSString stringWithFormat:@"%d", [num intValue]];

            [_paramDict setValue:indexPath forKey:@"indexPath"];
            [_paramDict setValue:[_scenarioData titleForRowInModelDetailIndexPath: indexPath] forKey:@"title"];
            [_paramDict setValue:value forKey:@"oldTextValue"];
            [_paramDict setValue:@"parent" forKey:@"paramFrom"];
            textEditViewController.paramDict = _paramDict;
            textEditViewController.scenarioData = _scenarioData;
            textEditViewController.mode = 1;
            textEditViewController.navigationController = _navigationController;

            [self.navigationController pushViewController:textEditViewController animated:YES];
            
        }
    } else if (indexPath.section == 1) {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            modelGroupViewController = [[ModelGroupViewController alloc] initWithNibName:@"TableViewController_iPhone" bundle:nil];
        } else {
            modelGroupViewController = [[ModelGroupViewController alloc] initWithNibName:@"TableViewController_iPad" bundle:nil];
        }

        //NSString *path = [_scenarioData valueForModelDetailIndexPath: indexPath];
        //[_paramDict setValue:path forKey:@"oldTextValue"];

        [_paramDict setValue:@"parent" forKey:@"paramFrom"];
        [_paramDict setValue:[_scenarioData getModelGroupListDict] forKey:@"groupDict"];
        [_paramDict setValue:@"Top" forKey:@"groupName"];
        modelGroupViewController.paramDict = _paramDict;
        modelGroupViewController.viewMode = 0;
        modelGroupViewController.scenarioData = _scenarioData;
        modelGroupViewController.navigationController = _navigationController;
        modelGroupViewController.editModelDetailViewController = self;
        
        /*
         if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
         [self.navigationController pushViewController:_modelViewController animated:YES];
         }
         */
        [self.navigationController pushViewController:modelGroupViewController animated:YES];
    
    } else if (indexPath.section == 2) {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            motionGroupViewController = [[MotionGroupViewController alloc] initWithNibName:@"TableViewController_iPhone" bundle:nil];
        } else {
            motionGroupViewController = [[MotionGroupViewController alloc] initWithNibName:@"TableViewController_iPad" bundle:nil];
        }
        
        [_paramDict setValue:@"parent" forKey:@"paramFrom"];
        [_paramDict setValue:[_scenarioData getMotionGroupListDict] forKey:@"groupDict"];
        [_paramDict setValue:@"Top" forKey:@"groupName"];
        motionGroupViewController.paramDict = _paramDict;
        motionGroupViewController.viewMode = 0;
        motionGroupViewController.scenarioData = _scenarioData;
        motionGroupViewController.navigationController = _navigationController;
        motionGroupViewController.editModelDetailViewController = self;
        
        /*
         if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
         [self.navigationController pushViewController:_motionViewController animated:YES];
         }
         */
        [self.navigationController pushViewController:motionGroupViewController animated:YES];
        
    } else if (indexPath.section >= 3) {

        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            textEditViewController = [[TextEditViewController alloc] initWithNibName:@"TextEditViewController_iPhone" bundle:nil];
        } else {
            textEditViewController = [[TextEditViewController alloc] initWithNibName:@"TextEditViewController_iPad" bundle:nil];
        }

        num = [_scenarioData valueForModelDetailIndexPath: indexPath];

        if (indexPath.section >= 3 && indexPath.section <= 5) {
            value = [NSString stringWithFormat:@"%d", [num intValue]];
        } else {
            value = [NSString stringWithFormat:@"%3.4f", [num floatValue]];
        }
        
        [_paramDict setValue:indexPath forKey:@"indexPath"];
        [_paramDict setValue:[_scenarioData titleForRowInModelDetailIndexPath: indexPath] forKey:@"title"];
        [_paramDict setValue:value forKey:@"oldTextValue"];
        [_paramDict setValue:@"parent" forKey:@"paramFrom"];
        
        NSLog(@"... paramDict count[%ld]", (unsigned long)[_paramDict count]);

        textEditViewController.paramDict = _paramDict;
        textEditViewController.scenarioData = _scenarioData;
        textEditViewController.mode = 1;
        textEditViewController.navigationController = _navigationController;
        
        [self.navigationController pushViewController:textEditViewController animated:YES];
    }
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
