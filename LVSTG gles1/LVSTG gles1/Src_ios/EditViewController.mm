//
//  MasterViewController.m
//  MMD4U
//
//  Created by Rocky on 2013/03/21.
//  Copyright (c) 2013年 twincle4u. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EditViewController.h"
#import "DocumentController.h"
#import "MMDViewController.h"
#import "EditModelDetailViewController.h"
#import "TextEditViewController.h"


#import "ScenarioData.h"

@interface EditViewController ()

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void) showMediaPicker;

@end


@implementation EditViewController

@synthesize documentController = _documentController;
@synthesize scenarioData = _scenarioData;
@synthesize splitViewController = _splitViewController;
@synthesize navigationController = _navigationController;
@synthesize deviceModel = _deviceModel;
@synthesize editMode = _editMode;
@synthesize paramDict = _paramDict;
@synthesize groupName = _groupName;
@synthesize groupDict = _groupDict;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Edit Scenario Detail", @"Edit Scenario Detail");
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    //self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    //UIBarButtonItem *buttonAdd = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)] autorelease];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        _deviceModel = 5;
    } else {
        _deviceModel = 14;
    }

    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *buttonDel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(removeAddedNewEntryObject:)];
    NSArray *buttons = [NSArray arrayWithObjects:spacer, buttonDel, nil];
    
    [self setToolbarItems:buttons animated:YES];
    
    
}

- (void)playMMD:(id)sender
{
    NSLog(@"... EditViewController: playMMD");
    
    // scenarioInfoDict is already loaded into _scenarioData;
    
    NSLog(@"... EditViewController -> MMDViewController starting");
    
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
    mmdViewController.playList = nil;
    
    self.navigationController.hidesBottomBarWhenPushed = YES;
    mmdViewController.navigationController = self.navigationController;
    [self.navigationController pushViewController:mmdViewController animated:NO];
    
}

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"... EditViewController: viewWillAppear: called");

    if (mmdViewController != nil) {
        //[mmdViewController release];
        mmdViewController = nil;
    }

    NSString *paramFrom = [_paramDict valueForKey:@"paramFrom"];
    
    if ([paramFrom isEqualToString:@"parent"]) {
        _groupName = [_paramDict valueForKey:@"groupName"];
        _groupDict = [_paramDict valueForKey:@"groupDict"];
        [_paramDict setValue:@"" forKey:@"paramFrom"];
        
    } else if ([paramFrom isEqualToString:@"TextEditViewController"]) {

        [_paramDict setValue:@"" forKey:@"paramFrom"];
        
        if ([_paramDict valueForKey:@"indexPath"] != nil) {
            NSIndexPath *indexPath = [_paramDict valueForKey:@"indexPath"];
            NSString *oldTextValue = [_paramDict valueForKey:@"oldTextValue"];
            NSString *newTextValue = [_paramDict valueForKey:@"newTextValue"];
            if (![newTextValue isEqualToString:oldTextValue]) {
                [_scenarioData setValue:newTextValue forScenarioListInexPath: indexPath];
                if (indexPath.section == 0 && indexPath.row == 0) {
                    NSString *key = [_scenarioData getCurrentScenarioKey];
                    // rename key from old to new
                    NSString *newTextValue = [_paramDict valueForKey:@"newTextValue"];
                    NSMutableDictionary *scenarioListDict = [_scenarioData getScenarioListDict];
                    [_scenarioData renameObjectInDictionary:scenarioListDict key:key toName:newTextValue];
                    [_scenarioData saveScenarioListFile];
                    [_scenarioData loadScenarioListFile];
                    [_paramDict setValue:@"EditViewController" forKey:@"paramFrom"];
                    [_paramDict setValue:@"childName" forKey:@"fieldName"];
                    [_paramDict setValue:key forKey:@"key"];
                    // scenario Name has changed
                }
            }
        }
    }
    
    self.navigationController.toolbarHidden = YES;
    
    [self.tableView reloadData];
    [super viewWillAppear:animated];

}

- (void)viewDidDisappear:(BOOL)animated
{
    NSLog(@"xxx EditViewController:viewDidDisappear");

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
    NSInteger n = [_scenarioData numberOfSectionsInScenarioList];
    NSLog(@"... numberOfSectionsInTableView=[%ld]", (long)n);
    return n;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger n = [_scenarioData numberOfRowsInSectionOfScenarioList: section];
    NSLog(@"... numberOfRowsInSection[%ld]=row[%ld]", (long)section, (long)n);
    if (section == 1) {
        // add the [Add Model] row
        n++;
    }
    return n;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *str = [_scenarioData titleForSectionInScenarioList: section];
    return str;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";

    bool addDisclosure = YES;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.textLabel.numberOfLines = 0;
        if (indexPath.section == 1) {
            if (indexPath.row == 8) {
                addDisclosure = NO;
            }
        }
        
        if (addDisclosure) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }

    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    
    NSString *title;
    NSString *value;
    
    if (section == 0) {
        title = [_scenarioData titleForRowInScenarioInfoIndexPath: indexPath];
        if (row >= 3 && row <= 9) {
            NSNumber *num = [_scenarioData valueForScenarioInfoIndexPath: indexPath];
            value = [NSString stringWithFormat:@"%01.3f", [num floatValue]];
        } else {
            value = [_scenarioData valueForScenarioInfoIndexPath: indexPath];
        }
        //cell.textLabel.numberOfLines = 0;
        cell.textLabel.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
        //cell.detailTextLabel.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
    } else {
        // section == 1
        NSInteger numRows = [_scenarioData numberOfRowsInSectionOfScenarioList: section];
        if (row >= numRows) {
            title = @"Add Model";
            value = @"Please tap to add a new model entry";
        } else {
            title = [_scenarioData titleForRowInScenarioInfoIndexPath: indexPath];
            value = [_scenarioData valueForScenarioInfoIndexPath: indexPath];
        }
        
        //cell.textLabel.numberOfLines = 0;
        cell.detailTextLabel.numberOfLines = 2;
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
        if (indexPath.section == 1) {
            // delete a model
            // remove object from datasource
            [_scenarioData removeModelFromScenarioInfoModelListAtRow:indexPath.row];
            // remove object from tableview
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"... EditViewController:tableView didSelectRowAtIndexPath section[%ld] row[%ld]", (long)indexPath.section, (long)indexPath.row);
    
    _scenarioData.scenarioInfoIndexPath = indexPath;
    NSString *value;
    
    TextEditViewController *textEditViewController;
    EditModelDetailViewController *editModelDetailViewController;

    if (indexPath.section == 0) {
        if (indexPath.row == 2) {
            [self showMediaPicker];
            
        } else if (indexPath.row <= 11) {
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                textEditViewController = [[TextEditViewController alloc] initWithNibName:@"TextEditViewController_iPhone" bundle:nil];
            } else {
                textEditViewController = [[TextEditViewController alloc] initWithNibName:@"TextEditViewController_iPad" bundle:nil];
            }
            
            value = [_scenarioData titleForRowInScenarioInfoIndexPath: indexPath];
            if (indexPath.row == 10) {
                NSNumber *nx = [_scenarioData valueForScenarioInfoIndexPath: indexPath];
                NSInteger n = [nx integerValue];
                switch (n) {
                    case 0:
                        value = @"0";
                        break;
                    default:
                        value = @"1";
                        break;
                }
            } else if (indexPath.row >= 3 && indexPath.row <= 9) {
                NSNumber *num = [_scenarioData valueForScenarioInfoIndexPath: indexPath];
                value = [NSString stringWithFormat:@"%01.3f", [num floatValue]];
            } else {
                value = [_scenarioData valueForScenarioInfoIndexPath: indexPath];
            }

            [_paramDict setValue:indexPath forKey:@"indexPath"];
            [_paramDict setValue:[_scenarioData titleForRowInScenarioInfoIndexPath: indexPath] forKey:@"name"];
            [_paramDict setValue:value forKey:@"oldTextValue"];
            [_paramDict setValue:@"parent" forKey:@"paramFrom"];
            NSLog(@"... paramDict[%ld]", (long)[_paramDict count]);

            textEditViewController.paramDict = _paramDict;
            textEditViewController.scenarioData = _scenarioData;
            textEditViewController.navigationController = self.navigationController;
            
            [self.navigationController pushViewController:textEditViewController animated:YES];

        }
    } else if (indexPath.section >= 1) {
        NSInteger numRows = [_scenarioData numberOfRowsInSectionOfScenarioList: indexPath.section];
        if (indexPath.row >= numRows) {
            // Add a new row
            [_scenarioData addNewModelToScenarioInfoModelList];
            [self.tableView reloadData];
        } else {
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                editModelDetailViewController = [[EditModelDetailViewController alloc] initWithNibName:@"TableViewController_iPhone" bundle:nil];
            } else {
                editModelDetailViewController = [[EditModelDetailViewController alloc] initWithNibName:@"TableViewController_iPad" bundle:nil];
            }

            [_paramDict setValue:indexPath forKey:@"indexPath"];
            [_paramDict setValue:@"parent" forKey:@"paramFrom"];

            editModelDetailViewController.paramDict = _paramDict;
            editModelDetailViewController.scenarioData = _scenarioData;
            editModelDetailViewController.navigationController = self.navigationController;
            editModelDetailViewController.editViewController = self;
            
            [self.navigationController pushViewController:editModelDetailViewController animated:YES];
        }

    }
}

// Configures and displays the media item picker.
- (void) showMediaPicker
{
    
	MPMediaPickerController *picker =
    [[MPMediaPickerController alloc] initWithMediaTypes: MPMediaTypeAnyAudio];
	
	picker.delegate	= self;
	picker.allowsPickingMultipleItems	= NO;
	picker.prompt = NSLocalizedString (@"AddSongsPrompt", @"Prompt to user to choose some songs to play");
	
	[[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleDefault animated:YES];
    
    [self presentViewController:picker animated:YES completion:nil];
}

// Responds to the user tapping Done after choosing music.
- (void) mediaPicker: (MPMediaPickerController *) mediaPicker didPickMediaItems: (MPMediaItemCollection *) mediaItemCollection
{
    
    [self dismissViewControllerAnimated:YES completion:nil];
	[self updatePlayerQueueWithMediaCollection: mediaItemCollection];
    
	[[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleLightContent animated:YES];
}

// Responds to the user tapping done having chosen no music.
- (void) mediaPickerDidCancel: (MPMediaPickerController *) mediaPicker {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
	[[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleLightContent animated:YES];
}


- (void) updatePlayerQueueWithMediaCollection: (MPMediaItemCollection *) mediaItemCollection {
    
	// Configure the music player, but only if the user chose at least one song to play
    NSMutableDictionary *musicDict = [NSMutableDictionary dictionary];
	if (mediaItemCollection) {
        MPMediaItem *item = [mediaItemCollection.items objectAtIndex:0];
        // MPMediaItemPropertyTitle
        // MPMediaItemPropertyArtist
        // MPMediaItemPropertyAlbumTitle
        // MPMediaItemPropertyAlbumArtist
        // MPMediaItemPropertyGenre
        // MPMediaItemPropertyComposer
        // MPMediaItemPropertyPlaybackDuration (double)
        [musicDict setValue:[item valueForProperty:MPMediaItemPropertyTitle] forKey:@"MPMediaItemPropertyTitle"];
        [musicDict setValue:[item valueForProperty:MPMediaItemPropertyArtist] forKey:@"MPMediaItemPropertyArtist"];
        [musicDict setValue:[item valueForProperty:MPMediaItemPropertyAlbumTitle] forKey:@"MPMediaItemPropertyAlbumTitle"];
        [musicDict setValue:[item valueForProperty:MPMediaItemPropertyAlbumArtist] forKey:@"MPMediaItemPropertyAlbumArtist"];
        [musicDict setValue:[item valueForProperty:MPMediaItemPropertyGenre] forKey:@"MPMediaItemPropertyGenre"];
        [musicDict setValue:[item valueForProperty:MPMediaItemPropertyComposer] forKey:@"MPMediaItemPropertyComposer"];
        [musicDict setValue:[item valueForProperty:MPMediaItemPropertyPlaybackDuration] forKey:@"MPMediaItemPropertyPlaybackDuration"]; // NSNumber
	}
    [_scenarioData setMusicForScenarioInfoIndexPath:musicDict];
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
