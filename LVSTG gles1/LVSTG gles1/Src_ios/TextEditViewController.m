//
//  DetailViewController.m
//  app-master-detail
//
//  Created by Rocky on 2013/03/22.
//  Copyright (c) 2013年 twincle4u. All rights reserved.
//

#import "TextEditViewController.h"
#import "ScenarioData.h"


@implementation TextEditViewController

@synthesize textView = _textView;
@synthesize navigationController = _navigationController;
@synthesize scenarioData = _scenarioData;
@synthesize mode = _mode;
@synthesize deviceModel = _deviceModel;
@synthesize paramDict = _paramDict;


#pragma mark - Managing the detail item

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (void)viewDidLoad
{
    NSLog(@"... TextEditorViewController: viewDidLoad");
	// Do any additional setup after loading the view, typically from a nib.

    UIBarButtonItem *buttonCancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelOperation:)];
    self.navigationItem.rightBarButtonItem = buttonCancel;

    NSLog(@"... _paramDict[%ld]", (long)[_paramDict count]);
    
    NSString *title = [_paramDict valueForKey:@"title"];
    
    self.title = title;

    [super viewDidLoad];

}

- (void)viewWillAppear:(BOOL)animated {
    
    NSLog(@"... TextEditorViewController: viewWillAppear");
    
    NSString *paramFrom = [_paramDict valueForKey:@"paramFrom"];
    if ([paramFrom isEqualToString:@"parent"]) {
        NSString *oldTextValue = [_paramDict valueForKey:@"oldTextValue"];
        [self setText:oldTextValue];
    }

    [_paramDict setValue:@"" forKey:@"paramFrom"];

    self.navigationController.toolbarHidden = YES;
    
    [_textView reloadInputViews];
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [_textView selectAll:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"... TextEditorViewController: viewWillDisappear");

    [self saveText:nil];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    NSLog(@"... TextEditorViewController: viewDidDisappear");

    [super viewDidDisappear:animated];
    _mode = 0;
}

- (void)cancelOperation:(id)sender
{
    NSLog(@"... TextEditorViewController: cancelOperation");
    
    // reload original value
    NSString *oldTextValue = [_paramDict valueForKey:@"oldTextValue"];
    [_textView setText:oldTextValue];
    
    [_navigationController popViewControllerAnimated:YES];
    
}

- (void)saveText:(id)sender
{
    NSLog(@"... TextEditorViewController: saveText");

    NSString *text = _textView.text;
    
    NSLog(@"... saveText [%@]", text);

    [_paramDict setValue:text forKey:@"newTextValue"];

    // will update the groupName
    [_paramDict setValue:@"TextEditViewController" forKey:@"paramFrom"];

}

- (void)setText:(NSString *)newText
{
    NSLog(@"... TextEditorViewController: setText");
    NSLog(@"... setText[%@]",newText);
    
    [_textView setText:newText];
    [_textView reloadInputViews];

    [self reloadInputViews];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
