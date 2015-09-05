//
//  DetailViewController.m
//  app-master-detail
//
//  Created by Rocky on 2013/03/22.
//  Copyright (c) 2013年 twincle4u. All rights reserved.
//

#import "StartViewController.h"
#import "MainViewController.h"
#import "DocumentController.h"
#import "ScenarioData.h"

@implementation StartViewController

@synthesize mainViewController = _mainViewController;
@synthesize documentController = _documentController;

#pragma mark - Managing the detail item

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"PlayMMD", @"PlayMMD");
    }
    return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return NO;
}

- (BOOL)shouldAutorotate
{
    return NO;
    
}

- (void)start:(id)sender
{
    NSLog(@"... StartViewController::start");
	
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        _mainViewController = [[MainViewController alloc] initWithNibName:@"MainViewController_iPhone" bundle:nil];
    } else {
        _mainViewController = [[MainViewController alloc] initWithNibName:@"MainViewController_iPad" bundle:nil];
    }

    _documentController = [[DocumentController alloc] init];

    ScenarioData *scenarioData = [[ScenarioData alloc] init];
    scenarioData.documentController = _documentController;
    
    _mainViewController.scenarioData = scenarioData;

    NSMutableArray *initialControllers = [NSMutableArray arrayWithObject:_mainViewController];

	UINavigationController *nav = [[UINavigationController alloc] init];
	nav.viewControllers = initialControllers;
	self.view.window.rootViewController = nav;
    
    _mainViewController.navigationController = nav;
    
    [self.view.window makeKeyAndVisible];
}

// call back from AppDelegagte
- (void)applicationWillResignActive
{
    [_mainViewController applicationWillResignActive];
}

- (void)applicationDidEnterBackground
{
    [_mainViewController applicationDidEnterBackground];
}

- (void)applicationWillEnterForeground
{
    [_mainViewController applicationWillEnterForeground];
}

- (void)applicationDidBecomeActive
{
    [_mainViewController applicationDidBecomeActive];
}

- (void)applicationWillTerminate
{
    [_mainViewController applicationWillTerminate];
}


@end
