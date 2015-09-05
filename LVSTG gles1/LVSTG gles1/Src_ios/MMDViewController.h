//
//  DetailViewController.h
//  MMD4U
//
//  Created by Rocky on 2013/03/21.
//  Copyright (c) 2013年 twincle4u. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "MMDAgent.h"

@class ScenarioData;
@class CMMotionManager;

// C++ classes

@interface MMDViewController : GLKViewController <AVCaptureVideoDataOutputSampleBufferDelegate>
{
    UINavigationController *navigationController;
    ScenarioData *scenarioData;
    BOOL fullScreen;
    EAGLContext *context;
    GLKView *glkview;
	AVAudioPlayer *player;
    MPMusicPlayerController *ipodPlayer;
    MPMediaItemCollection *mediaItemCollection;
    NSMutableDictionary *paramDict;

    NSInteger deviceModel;
    NSArray *playList;
    NSInteger playListIdx;
    NSArray *buttonsForResume;
    NSArray *buttonsForPause;
    NSArray *buttonsForReply;

    
    NSInteger animationFrameInterval;
    bool timerStopRequest;
    bool motionFinished;
    bool musicFinished;
    bool sceneFinished;
    
    float timerInterval;
    double startTime;
    double lastUpdatedTime;
	double elapsedTime;
    double endElapsed;
    double motionOffset;
    double sceneHoldAtEnd;
    double hideMenuDelay;
    bool  motionStarted;
    bool  musicStarted;
    int   animationState;
	float anglex;
	float angley;
    float anglez;
    float rotateDx;
    float rotateDy;
    float rotateDz;
    float tranX;
    float tranY;
    float tranZ;
    float bgcolorR;
    float bgcolorG;
    float bgcolorB;
    float bgcolorA;
    float lightcolorR;
    float lightcolorG;
    float lightcolorB;

    // camera params
    float cam_fov;
    float cam_near;
	float cam_z;
	
    bool bRotate;

    // touch handling
    NSInteger touchCount;
	CGPoint startPoints[4];
	CGPoint endPoints[4];
    double startTouchTime;
    double endTouchTime;

    // The pixel dimensions of the CAEAGLLayer
    GLint backingWidth;
    GLint backingHeight;
    
    MMDAgent *mmdagent;
    bool landscapeView;

    CMMotionManager *motionManager;
    bool deviceMotionStarted;
    bool deviceMotionOn;
    double cariblationDelay;
    double startAttitudeYaw;
    int cariblateYaw;
    NSInteger useAntialias;

    UIView *infoView;
    UILabel *labelFPS;
    UILabel *labelElapsed;
    UIView *actionView;
    UISegmentedControl *viewSegCtrl;
    bool isPause;
    bool isRepeat;
    bool isDeviceMotionOn;
    float fps;
    bool singleTapYes;
    UIColor *bgcRepeatBtnNormal;
    UIColor *bgcDeviceMotionBtnNormal;
    
}

// Navibar Controller
@property (nonatomic,retain) UINavigationController *navigationController;
@property (nonatomic,retain) ScenarioData *scenarioData;

@property (nonatomic,assign) NSInteger deviceModel;
@property (nonatomic,retain) NSArray *playList;
@property (nonatomic,retain) NSMutableDictionary *paramDict;

@property (nonatomic,retain) IBOutlet UIView *infoView;
@property (nonatomic,retain) IBOutlet UILabel *labelFPS;
@property (nonatomic,retain) IBOutlet UILabel *labelElapsed;
@property (nonatomic,retain) IBOutlet UIView *actionView;
@property (nonatomic,retain) IBOutlet UISegmentedControl *viewSegCtrl;

- (void) deleteContext;

- (void) startMovie;
- (void) stopMovie;
- (IBAction)rewindScene:(id)sender;
- (IBAction)pauseScene:(id)sender;
- (IBAction)repeatScene:(id)sender;
- (IBAction)deviceMotion:(id)sender;
- (MMDAgent*) getMMDAgent;
- (MMDAgent*) newMMDAgent;

// calll back from AppDelegate
- (void)applicationWillResignActive;
- (void)applicationDidEnterBackground;
- (void)applicationWillEnterForeground;
- (void)applicationDidBecomeActive;
- (void)applicationWillTerminate;

@end
