//
//  DetailViewController.m
//  MMD4U
//
//  Created by Rocky on 2013/03/21.
//  Copyright (c) 2013年 twincle4u. All rights reserved.
//

#include <sys/time.h>

#import <CoreVideo/CVOpenGLESTextureCache.h>
#import <CoreMotion/CoreMotion.h>

#import "MMDViewController.h"
#import "DocumentController.h"
#import "ScenarioData.h"

#import "PVRTVector.h"

/*
#include "btBulletDynamicsCommon.h"
#include "BulletPhysics.h"
#include "PMDTexture.h"
#include "SystemTexture.h"
*/

@interface MMDViewController ()
@end

@implementation MMDViewController

@synthesize scenarioData = _scenarioData;
@synthesize navigationController = _navigationController;
@synthesize deviceModel = _deviceModel;
@synthesize playList = _playList;
@synthesize paramDict = _paramDict;
@synthesize actionView = _actionView;
@synthesize viewSegCtrl = _viewSegCtrl;
@synthesize labelFPS = _labelFPS;
@synthesize labelElapsed = _labelElapsed;
@synthesize infoView = _infoView;

#pragma mark - Managing the detail item

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    NSLog(@"... MMDViewController initWIthNibName called");
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"PMD Model", @"PMD Model");
     
        [self initDeviceMotion];

    }
    
    return self;
}

- (void)initDeviceMotion
{
    // CMMotionManagerを生成
    motionManager = [[CMMotionManager alloc] init];
    
    // CoreMotionに対し、コンパス(方位磁針)較正用のヘッドアップディスプレイを表示するよう指 示
    // (真北を基準とする姿勢が必要な場合)
    //motionManager.showsDeviceMovementDisplay = YES;

}

- (void)startDeviceMotion
{

    // sampling rate
    motionManager.deviceMotionUpdateInterval = 1.0 / 30.0;

    [motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXArbitraryZVertical];

    deviceMotionStarted = true;
    deviceMotionOn = false;
    cariblationDelay = 3.0f;
    cariblateYaw = 0;
    startAttitudeYaw = 9999.0;

    /* 下記の startDeviceMotionUpdatesUsingReferenceFrame で以下の値を指定した場合のみ取得可能
     - CMAttitudeReferenceFrameXArbitraryCorrectedZVertical
     - CMAttitudeReferenceFrameXMagneticNorthZVertical
     - CMAttitudeReferenceFrameXTrueNorthZVertical
     startDeviceMotionUpdatesToQueue や CMAttitudeReferenceFrameXArbitraryZVertical を指定した場合は取得できない
     */
    //[motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXArbitraryZVertical];
    //[motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXArbitraryCorrectedZVertical];
    //[motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXMagneticNorthZVertical];
    
    // 真北を基準とする姿勢
    //[motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXTrueNorthZVertical];
    
    // relativce to start position
    //[motionManager startDeviceMotionUpdates];
    
    //motionManager.gyroUpdateInterval = 1.0 / 60.0;
    //[motionManager startGyroUpdates];
    
    //motionManager.accelerometerUpdateInterval = 1.0 / 60.0;
    //[motionManager startAccelerometerUpdates];
    
    //startAttitudeYaw = (float)motionManager.deviceMotion.attitude.yaw;
    
}

- (void)stopDeviceMotion
{
    //[motionManager stopGyroUpdates];
    //[motionManager stopAccelerometerUpdates];
    [motionManager stopDeviceMotionUpdates];
    motionManager.deviceMotionUpdateInterval = 0.0f;
    deviceMotionStarted = false;
    deviceMotionOn = false;
}

- (void)rewindScene:(id)sender
{
    mmdagent->rewindScene();
    [self startMovie];
}

- (void)pauseScene:(id)sender
{
    UIButton *btn = (UIButton*)sender;
    
    isPause = !isPause;
    mmdagent->procHoldMessage(isPause);
    if (isPause) {
        if (ipodPlayer) {
            [ipodPlayer pause];
        }
        [btn setTitle:@"|>" forState:UIControlStateNormal];
    } else {
        if (ipodPlayer) {
            [ipodPlayer play];
        }
        [btn setTitle:@"|||" forState:UIControlStateNormal];
        
    }
}

- (void)restartScene:(id)sender
{
    mmdagent->restartScene();
    [self startMovie];
}

- (void)repeatScene:(id)sender
{
    UIButton *btn = (UIButton*)sender;
    isRepeat = !isRepeat;

    if (isRepeat) {
        if (bgcRepeatBtnNormal == nil) {
            bgcRepeatBtnNormal = btn.backgroundColor;
        }
        [btn setBackgroundColor:UIColor.brownColor];
    } else {
        [btn setBackgroundColor:bgcRepeatBtnNormal];
    }
}

- (void)deviceMotion:(id)sender
{
    UIButton *btn = (UIButton*)sender;
    isDeviceMotionOn = !isDeviceMotionOn;
    
    if (isDeviceMotionOn) {
        if (bgcDeviceMotionBtnNormal == nil) {
            bgcDeviceMotionBtnNormal = btn.backgroundColor;
        }
        [btn setBackgroundColor:UIColor.brownColor];
    } else {
        [btn setBackgroundColor:bgcDeviceMotionBtnNormal];
    }
}

- (void)loadScenarioData
{
    // Update the user interface for the detail item.

    NSLog(@"... MMDViewController: loadScenarioData");
    
    if (_scenarioData != nil) {
        
        NSDictionary *musicDict = [_scenarioData.scenarioInfoDict valueForKey:@"musicDict"];
        // MPMediaItemPropertyTitle
        // MPMediaItemPropertyArtist
        // MPMediaItemPropertyAlbumTitle
        // MPMediaItemPropertyAlbumArtist
        // MPMediaItemPropertyGenre
        // MPMediaItemPropertyComposer
        // MPMediaItemPropertyPlaybackDuration (double)
        
        if (musicDict != nil) {
            MPMediaItemCollection *collection = nil;
            MPMediaPropertyPredicate *predicate;
            NSString *pval;
            NSNumber *musicDurationTarget = [musicDict valueForKey:@"MPMediaItemPropertyPlaybackDuration"];
            // predicate = [MPMediaPropertyPredicate predicateWithValue:musicId forProperty:MPMediaItemPropertyPersistentID comparisonType:MPMediaPredicateComparisonEqualTo];
            
            MPMediaQuery *query = [[MPMediaQuery alloc] init];
            pval = [musicDict valueForKey:@"MPMediaItemPropertyTitle"];
            if (pval != nil) {
                predicate = [MPMediaPropertyPredicate predicateWithValue:pval forProperty:MPMediaItemPropertyTitle];
                [query addFilterPredicate:predicate];
            }
            pval = [musicDict valueForKey:@"MPMediaItemPropertyArtist"];
            if (pval != nil) {
                predicate = [MPMediaPropertyPredicate predicateWithValue:pval forProperty:MPMediaItemPropertyArtist];
                [query addFilterPredicate:predicate];
            }
            pval = [musicDict valueForKey:@"MPMediaItemPropertyAlbumTitle"];
            if (pval != nil) {
                predicate = [MPMediaPropertyPredicate predicateWithValue:pval forProperty:MPMediaItemPropertyAlbumTitle];
                [query addFilterPredicate:predicate];
            }
            pval = [musicDict valueForKey:@"MPMediaItemPropertyAlbumArtist"];
            if (pval != nil) {
                predicate = [MPMediaPropertyPredicate predicateWithValue:pval forProperty:MPMediaItemPropertyAlbumArtist];
                [query addFilterPredicate:predicate];
            }
            pval = [musicDict valueForKey:@"MPMediaItemPropertyGenre"];
            if (pval != nil) {
                predicate = [MPMediaPropertyPredicate predicateWithValue:pval forProperty:MPMediaItemPropertyGenre];
                [query addFilterPredicate:predicate];
            }
            pval = [musicDict valueForKey:@"MPMediaItemPropertyComposer"];
            if (pval != nil) {
                predicate = [MPMediaPropertyPredicate predicateWithValue:pval forProperty:MPMediaItemPropertyComposer];
                [query addFilterPredicate:predicate];
            }
            
            NSArray *items = query.items;
            if (items.count == 1) {
                collection = [MPMediaItemCollection collectionWithItems:items];
            } else if (items.count > 1) {
                NSArray *xitems = nil;
                for (MPMediaItem *musicItem in items) {
                    NSNumber *musicDuration = [musicItem valueForProperty:MPMediaItemPropertyPlaybackDuration];
                    if (musicDuration == musicDurationTarget) {
                        xitems = [NSArray arrayWithObject:musicItem];
                        break;
                    }
                }
                if (xitems == nil) {
                    xitems = [NSArray arrayWithObject:items[0]];
                }
                collection = [MPMediaItemCollection collectionWithItems:xitems];
            } else {
                NSLog(@"*** MMDViewcontroller::configView Warning: cound not find the music for musicTitle=[%@]",
                      [musicDict valueForKey:@"MPMediaItemPropertyTitle"]);
            }
            
            if (collection != nil) {
                mediaItemCollection = collection;
            }
            
        } else {
            NSLog(@"*** MMDViewcontroller::configView Warning: no music data source.");
        }

        NSNumber *num;
        float fval;
        int physicsFact;
        int physicsFps;

        num = [_scenarioData.scenarioInfoDict valueForKey:@"motionOffset"];
        fval = [num floatValue];
        motionOffset = fval;

        num = [_scenarioData.scenarioInfoDict valueForKey:@"bgcolorR"];
        fval = [num floatValue];
        bgcolorR = fval;
        num = [_scenarioData.scenarioInfoDict valueForKey:@"bgcolorG"];
        fval = [num floatValue];
        bgcolorG =fval;
        num = [_scenarioData.scenarioInfoDict valueForKey:@"bgcolorB"];
        fval = [num floatValue];
        bgcolorB = fval;
        
        // set lightColor
        num = [_scenarioData.scenarioInfoDict valueForKey:@"lightcolorR"];
        fval = [num floatValue];
        lightcolorR = fval;
        num = [_scenarioData.scenarioInfoDict valueForKey:@"lightcolorG"];
        fval = [num floatValue];
        lightcolorG =fval;
        num = [_scenarioData.scenarioInfoDict valueForKey:@"lightcolorB"];
        fval = [num floatValue];
        lightcolorB = fval;
        mmdagent->changeLightColor(lightcolorR,lightcolorG,lightcolorB);
        
        num = [_scenarioData.scenarioInfoDict valueForKey:@"physicsFact"];
        physicsFact = (int) [num integerValue];
        if (physicsFact == 0) {
            physicsFact = 2; // 60 is default
        }
        physicsFps = physicsFact * 30;
        mmdagent->setPhysicsFps(physicsFps);

        // add Models and Mortions
        int modelCount = (int) [_scenarioData getCurrentScenarioInfoModelCount];
        for (int n=0; n<modelCount; n++) {
            NSLog(@"xxx MMDViewcontroller::configView configureView adding model[%d]", n);

            NSDictionary *scenarioModelDict = [_scenarioData getCurrentScenarioInfoModelByOrder:n];
            
            NSLog(@"xxx scenarioModel.modelPath[%@]", [scenarioModelDict valueForKey:@"modelPath"]);
            NSLog(@"xxx scenarioModel.modelInZip[%@]", [scenarioModelDict valueForKey:@"modelInZip"]);
            NSLog(@"xxx scenarioModel.motionPath[%@]", [scenarioModelDict valueForKey:@"motionPath"]);
            NSLog(@"xxx scenarioModel.motionInZip[%@]", [scenarioModelDict valueForKey:@"motionInZip"]);
            
            NSString *text = [NSString stringWithFormat:@"loading %02d:[%@]", n, [[scenarioModelDict valueForKey:@"modelPath"] lastPathComponent]];
            self.title = text;
            
            int ival;
            float rotX, rotY, rotZ;
            float posX, posY, posZ;
            int usePhysics = 0;
            bool once = false;
            int textureLib = 0;
            
            if (scenarioModelDict != nil) {
                _scenarioData.modelPath = [scenarioModelDict valueForKey:@"modelPath"];
                _scenarioData.modelZipPath = [scenarioModelDict valueForKey:@"modelInZip"];
                _scenarioData.motionPath = [scenarioModelDict valueForKey:@"motionPath"];
                _scenarioData.motionZipPath = [scenarioModelDict valueForKey:@"motionInZip"];
                NSString *drawOrder = [NSString stringWithFormat:@"model%03d", n];
                NSString *modelName = [_scenarioData.modelPath lastPathComponent];
                NSString *motionName = [_scenarioData.motionPath lastPathComponent];
                num = [scenarioModelDict valueForKey:@"motionRepeat"];
                ival = (int) [num integerValue];
                if (ival == 0) {
                    once = true;
                } else {
                    once = false; // repeat motion
                }
                num = [scenarioModelDict valueForKey:@"physicsMode"];
                usePhysics = (int) [num integerValue];
                num = [scenarioModelDict valueForKey:@"textureLib"];
                textureLib = (int) [num integerValue];
                num = [scenarioModelDict valueForKey:@"positionX"];
                posX = [num floatValue];
                num = [scenarioModelDict valueForKey:@"positionY"];
                posY = [num floatValue];
                num = [scenarioModelDict valueForKey:@"positionZ"];
                posZ = [num floatValue];
                num = [scenarioModelDict valueForKey:@"rotationX"];
                rotX = [num floatValue];
                num = [scenarioModelDict valueForKey:@"rotationY"];
                rotY = [num floatValue];
                num = [scenarioModelDict valueForKey:@"rotationZ"];
                rotZ = [num floatValue];
                char szDrawOrder[128];
                char szModelName[1024];
                char szMotionName[1024];
                [drawOrder getCString:szDrawOrder maxLength:sizeof(szDrawOrder) encoding:NSUTF8StringEncoding];
                [modelName getCString:szModelName maxLength:sizeof(szModelName) encoding:NSUTF8StringEncoding];
                [motionName getCString:szMotionName maxLength:sizeof(szMotionName) encoding:NSUTF8StringEncoding];

                btVector3 offsetPos = btVector3(posX, posY, posZ);
                btQuaternion offsetRot = btQuaternion(MMDFILES_RAD(rotY), MMDFILES_RAD(rotX), MMDFILES_RAD(rotZ));
                
                NSLog(@"xxx szDrawOrder = [%s]", szDrawOrder);
                NSLog(@"xxxxxxxxxxx MMDViewController::configureView usePhysics = [%d]", usePhysics);
                
                if (_scenarioData.modelPath != nil && _scenarioData.modelPath.length > 0)
                {
                    if (mmdagent->addModel(szDrawOrder,
                                           _scenarioData,
                                           &offsetPos,
                                           &offsetRot,
                                           false,
                                           NULL,
                                           NULL,
                                           usePhysics,
                                           textureLib))
                    {
                        if (_scenarioData.motionPath != nil && _scenarioData.motionPath.length > 0) {
                            mmdagent->addMotion(szDrawOrder,
                                                szDrawOrder,
                                                _scenarioData,
                                                YES,
                                                YES,
                                                once,
                                                YES,
                                                50.0);
                        }
                    }
                }
            }
            
        }

        if (mediaItemCollection != nil) {
            ipodPlayer = [MPMusicPlayerController applicationMusicPlayer];
            [ipodPlayer setQueueWithItemCollection:mediaItemCollection];
        } else {
            ipodPlayer = nil;
        }

        mmdagent->updateScene();
        mmdagent->procHoldMessage(true); // hold until motion and music in sync

        NSLog(@"... loadScenarioData done");
        self.title = [NSString stringWithFormat:@"%@", [_scenarioData.scenarioInfoDict valueForKey:@"name"]];

    }
}

- (double)getTime
{
    struct timeval tv;
	double now;
	gettimeofday( &tv, NULL );
	now = tv.tv_usec;
	now /= 1000000;
	now += tv.tv_sec;
	
	return now;
}

- (void)viewDidLoad
{
    NSLog(@"... MMDViewController viewDidLoad called");
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    //self.navigationController.toolbarHidden = YES;
    
    NSNumber *num;

    num = [_scenarioData.scenarioInfoDict valueForKey:@"useAntialias"];
    useAntialias = (int) [num integerValue];

    [_viewSegCtrl setSelectedSegmentIndex:0];
    
    context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
    
    if (!context) {
        NSLog(@"Failed to create ES context");
    }
    
    NSLog(@"... EAGLContext setCurrentContext:context");
    [EAGLContext setCurrentContext:context];
    
    glkview = (GLKView *)self.view;

    NSLog(@"... glkview.context set context");
    glkview.context = context;
    
    // Configure renderbuffers created by the view
    glkview.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    glkview.drawableDepthFormat = GLKViewDrawableDepthFormat16;
    //glkview.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    glkview.drawableStencilFormat = GLKViewDrawableStencilFormat8;
    
    // Enable multisampling
    if (useAntialias > 0) {
        glkview.drawableMultisample = GLKViewDrawableMultisample4X;
        NSLog(@"... GLKViewDrawableMultisample4X");
    } else {
        glkview.drawableMultisample = GLKViewDrawableMultisampleNone;
        NSLog(@"... GLKViewDrawableMultisampleNone");
        
    }
    
    self.preferredFramesPerSecond = 30;
    
    glkview.contentScaleFactor = [UIScreen mainScreen].scale;
    
    [glkview bindDrawable];

    backingHeight = (GLint) glkview.drawableHeight;
    backingWidth = (GLint) glkview.drawableWidth;
    
    if (backingWidth > backingHeight) {
        landscapeView = YES;
    } else {
        landscapeView = NO;
    }

    mmdagent->setBackingWidth(backingWidth);
    mmdagent->setBackingHeight(backingHeight);
    
    NSLog(@"... MMDViewController: viewDidLoad width=%d, height=%d", backingWidth, backingHeight);
    
    [self setupGL];
    
    timerInterval = 1.0/30.0;
    
    animationState = 0;
    
    anglex = 0.0;
    angley = 0.0;
    anglez = 0.0;
    
    isPause = false;
    isRepeat = false;
    isDeviceMotionOn = false;
    sceneHoldAtEnd = 5.0;
    bgcRepeatBtnNormal = nil;
    bgcDeviceMotionBtnNormal = nil;

}

- (void)viewDidUnload
{
    NSLog(@"... MMDViewController viewDidUnload called");
    
    [super viewDidUnload];
    
    [self stopDeviceMotion];
    
    mmdagent->clear();
    delete mmdagent;
    mmdagent = NULL;

    [self tearDownGL];
    
    if ([EAGLContext currentContext] == context) {
        [EAGLContext setCurrentContext:nil];
    }
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [_paramDict setValue:@"" forKey:@"paramFrom"];
    [_paramDict setValue:@"" forKey:@"action"];
    
    if (backingWidth > backingHeight) {
        landscapeView = YES;
    } else {
        landscapeView = NO;
    }
    
    fullScreen = NO;
    

    //[self.navigationController setNavigationBarHidden:NO];
    
    //[UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackOpaque;
    //self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    //self.navigationController.navigationBar.viewForBaselineLayout.backgroundColor = UIColor.clearColor;
    //[self.navigationController.navigationBar setBackgroundColor:UIColor.purpleColor];
    //self.navigationController.navigationBar.translucent = YES;
    
    //self.navigationController.toolbar.barStyle = UIBarStyleBlack;
    //self.navigationController.toolbar.translucent = YES;
    //[self.navigationController.toolbar setOpaque:YES];
    
    [self.navigationController setToolbarHidden:YES];
    
    [self becomeFirstResponder];
 
}

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"... MMDViewController viewDidAppear called");
    
    [super viewDidAppear:animated];
    
    [self loadScenarioData];

    [glkview display];
    [self startMovie];
    
    [self hideMenuBarsYesNo:NO duration:0.0f];
    hideMenuDelay = 7.0f; // 7.0 secs

    if (backingWidth > backingHeight) {
        landscapeView = YES;
    } else {
        landscapeView = NO;
    }

}

- (void)viewDidDisappear:(BOOL)animated
{
    NSLog(@"... MMDViewController viewDidDisappear called");
    
    [super viewDidDisappear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"... MMDViewController viewWillDisappear called");
    
    [super viewWillDisappear:animated];
    [self stopDeviceMotion];
    [self stopMovie];
}

- (void)didReceiveMemoryWarning
{
    NSLog(@"... MMDViewController didReceiveMemoryWarning called");
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [self exitViewController];
}

// New Autorotation support.
- (BOOL)shouldAutorotate
{
    BOOL ans = YES;
    
    NSLog(@"... MMDViewController shouldAutorotate called");

    if (mmdagent->getJumpState() > 0) {
        ans = NO;
        NSLog(@"... MMDViewController shouldAutorotate NO!!!");
    }
    
    return ans;
}


// Notifies when rotation begins, reaches halfway point and ends.
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    
    NSLog(@"... didRotateFromInterfaceOrientation: width=%d, height=%d", backingWidth, backingHeight);

    //[glkview bindDrawable];

    //[EAGLContext setCurrentContext:context];
    
    glkview.contentScaleFactor = [UIScreen mainScreen].scale;
    
    backingHeight = (GLint) glkview.drawableHeight;
    backingWidth = (GLint) glkview.drawableWidth;
    
    mmdagent->setBackingWidth(backingWidth);
    mmdagent->setBackingHeight(backingHeight);
    
    if (backingWidth > backingHeight) {
        landscapeView = YES;
    } else {
        landscapeView = NO;
    }
    
    if (mmdagent) {
        mmdagent->procWindowSizeMessage(mmdagent->getBackingWidth(), mmdagent->getBackingHeight());
    }
    
    [self hideMenuBarsYesNo:fullScreen duration:0.0f];
    
}


- (void)setupGL
{
    [EAGLContext setCurrentContext:context];
    
    // Initialize MMDAgent
    [self newMMDAgent];
    
    //[self loadShaders];
    //mmdagent->setUseGLSL(1);
    
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:context];
    
}

- (void)deleteContext
{
    
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)update
{

    //NSLog(@"... MMDViewController: update");
    
    double timeNow = [self getTime];
    
    if (startTime == 0.0f) {
        NSLog(@"... motionOffset=[%f]", motionOffset);
        
        startTime = lastUpdatedTime = timeNow;
        elapsedTime = 0.0f;

        if (motionOffset < 0.0f) {
            mmdagent->procHoldMessage(false); // off hold motion
            motionStarted = true;

        } else {
            [ipodPlayer play]; // start music
            musicStarted = true;
        }
    }
    
    if (!isPause) {
        elapsedTime += timeNow - lastUpdatedTime;

        if (!motionStarted) {
            // delay music start time
            if (elapsedTime >= motionOffset) {
                mmdagent->procHoldMessage(false); // off hold motion
                motionStarted = true;
            }
        }
        if (!musicStarted) {
            // delay motion start time
            if (elapsedTime >= -motionOffset) {
                [ipodPlayer play]; // start music
                musicStarted = true;
            }
        }

        if (hideMenuDelay > 0.0f) {
                if (elapsedTime > hideMenuDelay) {
                    [self hideMenuBarsYesNo:YES duration:1.0f];
                }
        }
        
    }

    lastUpdatedTime = timeNow;

    // Draw
    if (isDeviceMotionOn) {
        if (!deviceMotionOn && !deviceMotionStarted) {
            [self startDeviceMotion];
        }
    } else {
        if (deviceMotionOn || deviceMotionStarted) {
            [self stopDeviceMotion];
        }
    }

    if (!deviceMotionOn) {
        if (deviceMotionStarted) {
            if (cariblationDelay > 0.0f) {
                cariblationDelay -= timeNow;
            } else {
                deviceMotionOn = true;
            }
        }
    }
    
    if (deviceMotionOn) {
        CMDeviceMotion *deviceMotion = motionManager.deviceMotion;
        
        float frontback;
        float y;
        
        frontback = (float)deviceMotion.gravity.z;
        frontback += (float)deviceMotion.userAcceleration.z;
        frontback *= 90.0f;
        mmdagent->setAngleXNoUpdate(-frontback);

        float sideUpDown;
        sideUpDown = (float)deviceMotion.gravity.y;
        sideUpDown += (float)deviceMotion.userAcceleration.y;
        sideUpDown *= 80.f;

        if (landscapeView) {
            if (sideUpDown > 60.0f) {
                //NSLog(@"... sideUpDown=[%f]", sideUpDown);
                sideUpDown -= 60.0;
                if  (sideUpDown > 1.0f) { sideUpDown = 1.0f; }
                mmdagent->addDistance(sideUpDown);
            } else if (sideUpDown < -60.0f) {
                //NSLog(@"... sideUpDown=[%f]", sideUpDown);
                sideUpDown += 60.0f;
                if  (sideUpDown < -1.0f) { sideUpDown = -1.0f; }
                mmdagent->addDistance(sideUpDown);
            } else {
                mmdagent->setAngleZNoUpdate(-sideUpDown);
                
            }

            y = (float)deviceMotion.attitude.yaw;
            if (cariblateYaw == 0) {
                startAttitudeYaw = y;
                cariblateYaw = 1;
            } else {
                y -= startAttitudeYaw;
                y = y * 180.0 / M_PI;
                mmdagent->setAngleYNoUpdate(-y);
            }

            mmdagent->rotateView(0, 0, 0);

            //NSLog(@"... update: deviceMotion frontback=[%f] y=[%f] startAttitudeYaw=[%f]", frontback, y, startAttitudeYaw);
        
        } else {
            mmdagent->setAngleZNoUpdate(0);
            
        }

    }
    
    if (tranX != 0.0 || tranY != 0.0 || tranZ != 0.0) {
        //NSLog(@"... update: tranX=[%f] tranY=[%f] tranZ=[%f]", tranX, tranY, tranZ);
        mmdagent->translate(tranX, tranY, tranZ);
        tranX = tranY = tranZ = 0.0;
    }
    
    if (anglex != 0.0 || angley != 0.0 || anglez != 0.0) {
        //NSLog(@"... update: anglex=[%f] angley=[%f] anglez=[%f]", anglex, angley, anglez);
        mmdagent->rotateView(anglex, angley, anglez);
        anglex = angley = anglez = 0.0;
        
    } else if (!isDeviceMotionOn && (rotateDx != 0.0 || rotateDy != 0.0 || rotateDz != 0.0)) {
        //NSLog(@"... update: rotateDx=[%f] rotateDy=[%f] rotateDz=[%f]", rotateDx, rotateDy, rotateDz);
        mmdagent->rotateView(rotateDx, rotateDy, rotateDz);
        
    }
    
    if (animationState > 0) {
        
        anglex = anglex - rotateDx;
        angley = angley - rotateDy;
        anglez = anglez - rotateDz;
        
    }

    // update models and no render
    motionFinished = !mmdagent->updateAndRender(1);
    
    if (motionFinished) {
        if (endElapsed == 0.0f) {
            NSLog(@"... motion finished.");
            endElapsed = elapsedTime;
        }

        if (!sceneFinished) {
            if (elapsedTime > (endElapsed + sceneHoldAtEnd)) {
                NSLog(@"... elapseTime=[%f] endElapse+sceneHoldAtEnd=[%f]", elapsedTime, endElapsed + sceneHoldAtEnd);
                NSLog(@"... scene finished.");
                sceneFinished = true;
            }
        }
        
    }

    if (sceneFinished) {
        if (isRepeat) {
            NSLog(@"... repeat.");
            [self restartScene:nil];
        } else {
            NSLog(@"... scene end.");
            [self exitViewController];
            
        }
    }
    
    fps = mmdagent->getFPS();

    // iOS8 bug that slow down OpenGLES draw performance
    //_labelFPS.text = [NSString stringWithFormat:@"%3.3f", fps];
    //_labelElapsed.text = [NSString stringWithFormat:@"%4.2f", elapsedTime];
    
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    
    //glBindFramebuffer(GL_FRAMEBUFFER, mmdagent->getDefaultFramebuffer());
    
    //NSLog(@"... MMDViewController: glkView drawScreen glViewPport()");
    
    GLint screenWidth = (GLint) glkview.drawableWidth;
    GLint screenHeight = (GLint) glkview.drawableHeight;
    
    glViewport(0, 0, screenWidth, screenHeight);
    
    glClearColor(bgcolorR, bgcolorG, bgcolorB, bgcolorA); // R, G, B, A
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    // シーンの射影行列を設定
    glMatrixMode(GL_PROJECTION);
    
    //const GLfloat width = near * tanf(M_PI * 60.0f / 180.0f / 2.0f);
    const GLfloat near  = 0.2f, far = 100000.0f; //1000.0f;
    const float tanf_c = M_PI_2 / 3.f;
    const GLfloat width = near * tanf(tanf_c);
    const GLfloat aspect = rect.size.width / rect.size.height;
    
    glLoadIdentity();
    glFrustumf(-width, width, -width / aspect, width / aspect, near, far);
    
    // 球体の変換行列を設定
    glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
    glPushMatrix();
	
	//glTranslatef(0.0, -10.0, -self.distance);
    
	glScalef(1.0, 1.0, -1.0);
	//glRotatef(self.anglex, 0.0, 1.0, 0.0);
	//glRotatef(self.angley, 1.0f, 0.0f, 0.0f);
    
	glColor4f(1.0,1.0,1.0,1.0);
    
    mmdagent->updateAndRender(2);  // render only
    
    glPopMatrix();
    
}

#pragma mark - Touch handling methods

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    
    if (motion == UIEventSubtypeMotionShake)
        
    {
        
        // User was shaking the device. Post a notification named "shake."
        
        NSLog(@"... deviceShaked!!!");
        
        mmdagent->jump(800.0f, 0.0f, 10.0f);
        
    }
    
}

- (void) touchesBegan:(NSSet*) touches withEvent:( UIEvent*) event
{
	touchCount = 0;
    singleTapYes = NO;
}

- (void) touchesMoved:(NSSet *) touches withEvent: (UIEvent *) event
{
	int i;
    CGFloat diffx, diffy;
    
	if( touchCount == 0){
		touchCount = [[touches allObjects] count];
		for (i = 0; i < touchCount; i++) {
			CGPoint pt = [[[touches allObjects] objectAtIndex:i] locationInView:self.view];
			startPoints[i] = pt;
            startTouchTime =  [self getTime];
		}
	} else if([[touches allObjects] count] == 2 && touchCount < 2){
		touchCount = [[touches allObjects] count];
		for (i = 0; i < touchCount; i++) {
			CGPoint pt = [[[touches allObjects] objectAtIndex:i] locationInView:self.view];
			startPoints[i] = pt;
		}
 	}else {
		if(!(touchCount == 2 && [[touches allObjects] count] < 2)){
            endTouchTime = [self getTime];
			for (i = 0; i < [[touches allObjects] count]; i++) {
				CGPoint pt = [[[touches allObjects] objectAtIndex:i] locationInView:self.view];
				endPoints[i] = pt;
			}
			
			if(touchCount==1){
				diffx = endPoints[0].x - startPoints[0].x;
				diffy = endPoints[0].y - startPoints[0].y;
                
				if( diffx*diffx > diffy*diffy){
                    if ([_viewSegCtrl selectedSegmentIndex] == 0) {
                        if (endTouchTime - startTouchTime <= 0.3 && abs(diffx) > 30) {
                            diffx += (diffx < 0 ? 30 : -30);
                            rotateDy += -diffx * 0.005; //0.025;
                        } else {
                            angley = 0.2*diffx;
                            
                            rotateDx = rotateDy = rotateDz = 0.0;
                        }
                    } else {
                        int iyangle = abs(mmdagent->getAngleY()) / 45;
                        //NSLog(@"... mmdagent yangle=[%d]", iyangle);
                        if (iyangle >= 1 && iyangle <= 2) {
                            tranZ = -0.1*diffx;
                        } else if (iyangle >= 5 && iyangle <= 6) {
                            tranZ = -0.1*diffx;
                        } else if (iyangle >=3 && iyangle <= 4) {
                            tranX = 0.1*diffx;
                        } else {
                            tranX = -0.1*diffx;
                        }
                        
                        rotateDx = rotateDy = rotateDz = 0.0;
                    }
                    
				}else {

                    if ([_viewSegCtrl selectedSegmentIndex] == 0) {
                        if (endTouchTime - startTouchTime <= 0.3 && abs(diffy) > 40) {
                            diffy += (diffy < 0 ? 40 : -40);
                            rotateDx += -diffy * 0.005; // 0.015;
                        } else {
                            anglex = 0.2*diffy;
                            
                            rotateDx = rotateDy = rotateDz = 0.0;
                        }
                    } else {
                        //tranY = 0.2*diffy;
                        int ixangle = abs(mmdagent->getAngleX()) / 45;
                        //NSLog(@"... mmdagent xangle=[%f", xangle);
                        if (ixangle >= 1 && ixangle <= 2) {
                            tranZ = -0.1*diffy;
                        } else if (ixangle >= 5 && ixangle <= 6) {
                            tranZ = -0.1*diffy;
                        } else if (ixangle >=3 && ixangle <= 4) {
                            tranY = -0.1*diffy;
                        } else {
                            tranY = 0.1*diffy;
                        }
                        
                        rotateDx = rotateDy = rotateDz = 0.0;
                    }
                    
				}
				
			}else {
				float dist = ( sqrt(pow((startPoints[0].x - startPoints[1].x),2)+
                                    pow((startPoints[0].y - startPoints[1].y),2))
                              -
                              sqrt(pow((endPoints[0].x - endPoints[1].x),2)+
                                   pow((endPoints[0].y -endPoints[1].y),2))
                              )*0.1;
                
                if (dist > 0.1 || dist < -0.1) {
                    // zoom in-out
                    mmdagent->addDistance(dist);
                } else {
                    // drag side way
                    diffx = endPoints[0].x - startPoints[0].x;
                    diffy = endPoints[0].y - startPoints[0].y;
                    
                    if( diffx*diffx > diffy*diffy){
                        
                        int iyangle = abs(mmdagent->getAngleY()) / 45;
                        //NSLog(@"... mmdagent yangle=[%d]", iyangle);
                        if (iyangle >= 1 && iyangle <= 2) {
                            tranZ = -0.1*diffx;
                        } else if (iyangle >= 5 && iyangle <= 6) {
                            tranZ = -0.1*diffx;
                        } else if (iyangle >=3 && iyangle <= 4) {
                            tranX = 0.1*diffx;
                        } else {
                            tranX = -0.1*diffx;
                        }

                    } else {
                        //tranY = 0.2*diffy;
                        int ixangle = abs(mmdagent->getAngleX()) / 45;
                        //NSLog(@"... mmdagent xangle=[%f", xangle);
                        if (ixangle >= 1 && ixangle <= 2) {
                            tranZ = -0.1*diffy;
                        } else if (ixangle >= 5 && ixangle <= 6) {
                            tranZ = -0.1*diffy;
                        } else if (ixangle >=3 && ixangle <= 4) {
                            tranY = -0.1*diffy;
                        } else {
                            tranY = 0.1*diffy;
                        }
                        
                    }

                    rotateDx = rotateDy = rotateDz = 0.0;

                }
        
			}
    
			startPoints[0] = endPoints[0];
			startPoints[1] = endPoints[1];
			
		}
	}
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    int i;
    
    if (endTouchTime == 0.0) {
        endTouchTime = [self getTime];
    }
    
    NSLog(@"touchCount %ld", (long)touchCount);
    for (i = 0; i < touchCount; i++) {
        NSLog(@"startPos x,y=%@", NSStringFromCGPoint(startPoints[i]));
    }
    for (i = 0; i < touchCount; i++) {
        NSLog(@"endPos x,y=%@", NSStringFromCGPoint(endPoints[i]));
    }
    
    for (i = 0; i < touchCount; i++) {
        NSLog(@"startPos x,y=%@", NSStringFromCGPoint(startPoints[i]));
    }
    for (i = 0; i < touchCount; i++) {
        NSLog(@"endPos x,y=%@", NSStringFromCGPoint(endPoints[i]));
    }
    
    NSInteger tapCount = [[touches anyObject] tapCount];
    
    if (tapCount < 2) {
        singleTapYes = YES;
        [self performSelector:@selector(singleTap) withObject:nil afterDelay:0.3f];
    } else {
        [self performSelector:@selector(doubleTap)];
    }
    
}

- (void)singleTap
{
    if (!singleTapYes) { return; }
    
    if (touchCount == 0) {
        rotateDx = rotateDy = rotateDz = 0.0;
    }

}

- (void)doubleTap
{
    // switch FullScreen, hide top and bottom menu bars
    if (fullScreen) {
        [self hideMenuBarsYesNo:NO duration:0.0f];
    } else {
        [self hideMenuBarsYesNo:YES duration:1.0f];
    }
    
}

- (void)hideMenuBarsYesNo:(BOOL)yesNo duration:(float)duration
{
    // hide or show top and bottom menu bars
    fullScreen = yesNo;
    
    if (yesNo) {
        hideMenuDelay = 0.0f;
    }

    //[self.navigationController.navigationBar setOpaque:NO];
    //UIViewController *vc = [self childViewControllerForStatusBarStyle];
    //UIViewController *vc = [self childViewControllerForStatusBarHidden];

    [self.navigationController.navigationBar setBackgroundColor:UIColor.clearColor];
    //[self.navigationController.view setBackgroundColor:UIColor.clearColor];
    //[self.navigationController.toolbar setBackgroundColor:UIColor.clearColor];
    //[self.navigationController.toolbar setOpaque:YES];
    //[self.navigationController.toolbar setBackgroundColor:UIColor.clearColor];

    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:duration];
    [[UIApplication sharedApplication] setStatusBarHidden:yesNo withAnimation:UIStatusBarAnimationFade];
    _navigationController.navigationBar.alpha = yesNo ? 0.0f : 0.65f;
    //_navigationController.toolbar.alpha = yesNo ? 0.0f : 0.2f;
    _actionView.alpha = yesNo ? 0.0f : 1.0f;
    //_infoView.alpha = yesNo ? 0.0f : 1.0f;
    _infoView.alpha = YES ? 0.0f : 1.0f;
    
    [UIView commitAnimations];

}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

#pragma mark - OpenGL ES 2 shader compilation


- (MMDAgent*) newMMDAgent
{
    if (mmdagent) {
        mmdagent->clear();
        delete mmdagent;
    }
    
#pragma pack(push,4)
    mmdagent = new MMDAgent();
#pragma pack(pop)
    
    
    // use Physics bullet with in local Model
    if (!mmdagent->setup(mmdagent->getBackingWidth(), mmdagent->getBackingHeight())) {
        // MMDAgent setup failed
        mmdagent = NULL;
    }
    
    return mmdagent;
}

- (MMDAgent*) getMMDAgent
{
    return mmdagent;
}


//
// movie start off
//
- (void) startMovie
{
    NSLog(@"... startMovie");
    
    NSLog(@"... ipodPlayer play");
    ipodPlayer.currentPlaybackTime = 0.0;
    
    startTime = 0.0f;
    endElapsed = 0.0f;
    animationState = 1;
    motionFinished = false;
    musicFinished = false;
    sceneFinished = false;
    timerStopRequest = false;
    motionStarted = false;
    musicStarted = false;
   
}

//
// movie stop
//
- (void) stopMovie
{
    
    NSLog(@"... stopMovie");
    
    if (ipodPlayer) {
        [ipodPlayer stop];
    }

    animationState = 9;
    
}

//
// exit ViewController
//
- (void) exitViewController
{
    
    NSLog(@"... exitViewController");
    
    [_paramDict setValue:@"MMDViewController" forKey:@"paramFrom"];
    [_paramDict setValue:@"nextScenario" forKey:@"action"];
    
    [_navigationController popViewControllerAnimated:YES];
    
}



- (void)dealloc
{
    // Tear down GL
	
    if (mmdagent != nil) {
        mmdagent->clear();
        delete mmdagent;
        mmdagent = NULL;
    }
    
    // Tear down context
    if ([EAGLContext currentContext] == context)
        [EAGLContext setCurrentContext:nil];
    
    //[context release];
    context = nil;
    
    //[super dealloc];
}


// call back from AppDelegagte
- (void)applicationWillResignActive
{
    [self stopMovie];
}

- (void)applicationDidEnterBackground
{
    [self stopMovie];
}

- (void)applicationWillEnterForeground
{
}

- (void)applicationDidBecomeActive
{
}

- (void)applicationWillTerminate
{
    [self stopMovie];
}

@end
