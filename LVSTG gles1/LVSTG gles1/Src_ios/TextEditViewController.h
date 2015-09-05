//
//  DetailViewController.h
//  app-master-detail
//
//  Created by Rocky on 2013/03/22.
//  Copyright (c) 2013年 twincle4u. All rights reserved.
//

#import <UIKit/UIKit.h>


@class ScenarioData;


@interface TextEditViewController : UIViewController <UISplitViewControllerDelegate> {
    UITextView *textView;
    UINavigationController *navigationController;
    ScenarioData *scenarioData;
    NSInteger   mode;
    NSInteger deviceModel;
    NSMutableDictionary *paramDict;
}



@property (nonatomic,retain) IBOutlet UITextView *textView;

// Navibar Controller
@property (strong, nonatomic) UINavigationController *navigationController;
@property (nonatomic,retain) NSMutableDictionary *paramDict;

@property (nonatomic,retain) ScenarioData *scenarioData;
@property (nonatomic,assign) NSInteger mode;
@property (nonatomic,assign) NSInteger deviceModel;


- (void)setText:(NSString*) newText;

- (void)saveText:(id)sender;

// calll back from AppDelegate
- (void)applicationWillResignActive;
- (void)applicationDidEnterBackground;
- (void)applicationWillEnterForeground;
- (void)applicationDidBecomeActive;
- (void)applicationWillTerminate;

@end
