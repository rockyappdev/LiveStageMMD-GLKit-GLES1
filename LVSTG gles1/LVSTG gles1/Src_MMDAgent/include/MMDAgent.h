/* ----------------------------------------------------------------- */
/*           Toolkit for Building Voice Interaction Systems          */
/*           MMDAgent developed by MMDAgent Project Team             */
/*           http://www.mmdagent.jp/                                 */
/* ----------------------------------------------------------------- */
/*                                                                   */
/*  Copyright (c) 2009-2013  Nagoya Institute of Technology          */
/*                           Department of Computer Science          */
/*                                                                   */
/* All rights reserved.                                              */
/*                                                                   */
/* Redistribution and use in source and binary forms, with or        */
/* without modification, are permitted provided that the following   */
/* conditions are met:                                               */
/*                                                                   */
/* - Redistributions of source code must retain the above copyright  */
/*   notice, this list of conditions and the following disclaimer.   */
/* - Redistributions in binary form must reproduce the above         */
/*   copyright notice, this list of conditions and the following     */
/*   disclaimer in the documentation and/or other materials provided */
/*   with the distribution.                                          */
/* - Neither the name of the MMDAgent project team nor the names of  */
/*   its contributors may be used to endorse or promote products     */
/*   derived from this software without specific prior written       */
/*   permission.                                                     */
/*                                                                   */
/* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND            */
/* CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,       */
/* INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF          */
/* MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE          */
/* DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS */
/* BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,          */
/* EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED   */
/* TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,     */
/* DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON */
/* ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,   */
/* OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY    */
/* OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE           */
/* POSSIBILITY OF SUCH DAMAGE.                                       */
/* ----------------------------------------------------------------- */

#ifndef __mmdagent_h__
#define __mmdagent_h__

/* definitions */

#define MMDAGENT_DONTUSESHADOWMAP
#define MMDAGENT_DONTPICKMODEL

#define MMDAGENT_MAXBUFLEN    MMDFILES_MAXBUFLEN
#define MMDAGENT_DIRSEPARATOR MMDFILES_DIRSEPARATOR
#define MMDAGENT_MAXNCOMMAND  10

#ifdef MMDAGENT_OVERWRITEEXEFILE
#define MMDAGENT_EXEFILE(binaryFileName) "%s", MMDAGENT_OVERWRITEEXEFILE
#else
#define MMDAGENT_EXEFILE(binaryFileName) "%s", binaryFileName
#endif /* MMDAGENT_OVERWRITEEXEFILE */

#ifdef MMDAGENT_OVERWRITECONFIGFILE
#define MMDAGENT_CONFIGFILE(configFileName) "%s", MMDAGENT_OVERWRITECONFIGFILE
#else
#define MMDAGENT_CONFIGFILE(configFileName) "%s", configFileName
#endif /* MMDAGENT_OVERWRITECONFIGFILE */

#ifdef MMDAGENT_OVERWRITESYSDATADIR
#define MMDAGENT_SYSDATADIR(binaryDirName) "%s", MMDAGENT_OVERWRITESYSDATADIR
#else
#define MMDAGENT_SYSDATADIR(binaryDirName) "%s%c%s", binaryDirName, MMDAGENT_DIRSEPARATOR, "AppData"
#endif /* MMDAGENT_OVERWRITESYSDATADIR */

#ifdef MMDAGENT_OVERWRITEPLUGINDIR
#define MMDAGENT_PLUGINDIR(binaryDirName) "%s", MMDAGENT_OVERWRITEPLUGINDIR
#else
#define MMDAGENT_PLUGINDIR(binaryDirName) "%s%c%s", binaryDirName, MMDAGENT_DIRSEPARATOR, "Plugins"
#endif /* MMDAGENT_OVERWRITEPLUGINDIR */

#define MMDAGENT_COMMAND_MODELADD         "MODEL_ADD"
#define MMDAGENT_COMMAND_MODELCHANGE      "MODEL_CHANGE"
#define MMDAGENT_COMMAND_MODELDELETE      "MODEL_DELETE"
#define MMDAGENT_COMMAND_MOTIONADD        "MOTION_ADD"
#define MMDAGENT_COMMAND_MOTIONCHANGE     "MOTION_CHANGE"
#define MMDAGENT_COMMAND_MOTIONACCELERATE "MOTION_ACCELERATE"
#define MMDAGENT_COMMAND_MOTIONDELETE     "MOTION_DELETE"
#define MMDAGENT_COMMAND_MOVESTART        "MOVE_START"
#define MMDAGENT_COMMAND_MOVESTOP         "MOVE_STOP"
#define MMDAGENT_COMMAND_TURNSTART        "TURN_START"
#define MMDAGENT_COMMAND_TURNSTOP         "TURN_STOP"
#define MMDAGENT_COMMAND_ROTATESTART      "ROTATE_START"
#define MMDAGENT_COMMAND_ROTATESTOP       "ROTATE_STOP"
#define MMDAGENT_COMMAND_STAGE            "STAGE"
#define MMDAGENT_COMMAND_LIGHTCOLOR       "LIGHTCOLOR"
#define MMDAGENT_COMMAND_LIGHTDIRECTION   "LIGHTDIRECTION"
#define MMDAGENT_COMMAND_LIPSYNCSTART     "LIPSYNC_START"
#define MMDAGENT_COMMAND_LIPSYNCSTOP      "LIPSYNC_STOP"
#define MMDAGENT_COMMAND_CAMERA           "CAMERA"
#define MMDAGENT_COMMAND_PLUGINENABLE     "PLUGIN_ENABLE"
#define MMDAGENT_COMMAND_PLUGINDISABLE    "PLUGIN_DISABLE"

#define MMDAGENT_EVENT_MODELADD         "MODEL_EVENT_ADD"
#define MMDAGENT_EVENT_MODELCHANGE      "MODEL_EVENT_CHANGE"
#define MMDAGENT_EVENT_MODELDELETE      "MODEL_EVENT_DELETE"
#define MMDAGENT_EVENT_MOTIONADD        "MOTION_EVENT_ADD"
#define MMDAGENT_EVENT_MOTIONCHANGE     "MOTION_EVENT_CHANGE"
#define MMDAGENT_EVENT_MOTIONACCELERATE "MOTION_EVENT_ACCELERATE"
#define MMDAGENT_EVENT_MOTIONDELETE     "MOTION_EVENT_DELETE"
#define MMDAGENT_EVENT_MOVESTART        "MOVE_EVENT_START"
#define MMDAGENT_EVENT_MOVESTOP         "MOVE_EVENT_STOP"
#define MMDAGENT_EVENT_TURNSTART        "TURN_EVENT_START"
#define MMDAGENT_EVENT_TURNSTOP         "TURN_EVENT_STOP"
#define MMDAGENT_EVENT_ROTATESTART      "ROTATE_EVENT_START"
#define MMDAGENT_EVENT_ROTATESTOP       "ROTATE_EVENT_STOP"
#define MMDAGENT_EVENT_LIPSYNCSTART     "LIPSYNC_EVENT_START"
#define MMDAGENT_EVENT_LIPSYNCSTOP      "LIPSYNC_EVENT_STOP"
#define MMDAGENT_EVENT_PLUGINENABLE     "PLUGIN_EVENT_ENABLE"
#define MMDAGENT_EVENT_PLUGINDISABLE    "PLUGIN_EVENT_DISABLE"
#define MMDAGENT_EVENT_DRAGANDDROP      "DRAGANDDROP"
#define MMDAGENT_EVENT_KEY              "KEY"

/* headers */

#include "MMDFiles.h"

//#include "GL/glfw.h"
#include <OpenGLES/ES1/gl.h>
#include <OpenGLES/ES1/glext.h>
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>


class MMDAgent;

#include "MMDAgent_utils.h"

#include "TextRenderer.h"
#include "LogText.h"
#include "LipSync.h"
#include "PMDObject.h"

#include "Option.h"
#include "ScreenWindow.h"
#include "Message.h"
#include "TileTexture.h"
#include "Stage.h"
#include "Render.h"
#include "Timer.h"
//#include "Plugin.h"
#include "MotionStocker.h"

#include "PVRTVector.h"

//#pragma pack(push,4)

const int32_t NUM_SHADERS = 8;

enum SHADER_INDEX {
	SHADER_MODEL = 0,
	SHADER_SHADOW = 1,
	SHADER_EDGE = 2,
	SHADER_ZPLOT = 3,
};

struct SHADER_PARAMS
{
	GLuint _program;
	GLuint _uiLight0;
	GLuint _uiMaterialDiffuse;
	GLuint _uiMaterialAmbient;
	GLuint _uiMaterialSpecular;
	
	GLuint _uiMatrixPalette;
	GLuint _uiMatrixP;
    
	GLuint _uiSkinWeight;
};

struct renderer_vertex
{
	float pos[3];
	float normal_vec[3];
	float uv[2];
	uint8_t bone[4];
};

struct skinanimation_vertex
{
	float pos[3];
};


/* MMDAgent: MMDAgent class */
class MMDAgent
{
private:
   bool m_enable;

   char *m_configFileName; /* config file name */
   char *m_configDirName;  /* directory name of config file */
   char *m_appDirName;     /* directory name of application data */

   Option *m_option;        /* user options */
   ScreenWindow *m_screen;  /* screen window */
   Message *m_message;      /* message queue */
   BulletPhysics *m_bullet; /* Bullet Physics */
   //Plugin *m_plugin;        /* plugins */
   Stage *m_stage;          /* stage */
   SystemTexture *m_systex; /* system texture */
   LipSync *m_lipSync;      /* system default lipsync */
   Render *m_render;        /* render */
   Timer *m_timer;          /* timer */
   TextRenderer *m_text;    /* text render */
   LogText *m_logger;       /* logger */

    int m_numModel;          /* number of models */
    PMDObject *m_models;      /* models */
    int *m_renderOrder;      /* model rendering order */
    MotionStocker *m_motion; /* motions */

   CameraController m_camera; /* camera controller */
   bool m_cameraControlled;   /* true when camera is controlled by motion */

   bool m_keyCtrl;           /* true if Ctrl-key is on */
   bool m_keyShift;          /* true if Shift-key is on */
   int m_selectedModel;      /* model ID selected by mouse */
   int m_highLightingModel;
   bool m_doubleClicked;     /* true if double clicked */
   int m_mousePosX;
   int m_mousePosY;
   bool m_leftButtonPressed;
   double m_restFrame;

   bool m_enablePhysicsSimulation; /* true if physics simulation is on */
   bool m_dispLog;                 /* true if log window is shown */
   bool m_dispBulletBodyFlag;      /* true if bullet body is shown */
   bool m_dispModelDebug;          /* true if model debugger is on */
   bool m_holdMotion;              /* true if holding motion */
    float m_fps;                // frame per second
    
public:

    // GLSL management
    // The pixel dimensions of the CAEAGLLayer
    // The OpenGL names for the framebuffer and renderbuffer used to render to this view

    SHADER_PARAMS& shader(int idx);
    void setMatProjection(PVRTMat4& mat4);
    void setMatView(PVRTMat4& mat4);
    void setDepthBuffer(GLuint buffer);
    void setDefaultFrameBuffer(GLuint buffer);
    void setColorRenderBuffer(GLuint buffer);
    PVRTMat4& getMatProjection();
    PVRTMat4& getMatView();
    GLuint getDepthBuffer();
    GLuint getDefaultFramebuffer();
    GLuint getColorRenderbuffer();
    void setBackingWidth(GLint width);
    void setBackingHeight(GLint height);
    GLint getBackingWidth();
    GLint getBackingHeight();

    float getDistance( void );
    void setDistance( float dist );
    void addDistance( float delta );
    void rotateView(float x, float y, float z);
    void translate(float x, float y, float z);
    void setAngleXNoUpdate(float x);
    void setAngleYNoUpdate(float y);
    void setAngleZNoUpdate(float z);
    float getAngleX();
    float getAngleY();
    float getAngleZ();
    void setPhysicsFps(int fps);
    int getPhysicsFps();
    void jump(float height, float back, float duration);

    int getJumpState();
    
   /* getNewModelId: return new model ID */
   int getNewModelId();

   /* removeRelatedModels: delete a model */
   void removeRelatedModels(int modelId);

   /* updateLight: update light */
   void updateLight();

   /* setHighLight: set high-light of selected model */
   void setHighLight(int modelId);

   /* updateScene: update the whole scene */
   bool updateScene();

   /* renderScene: render the whole scene */
   bool renderScene();
    
    void rewindScene();

    void restartScene();

   /* addModel: add model */
    /*******
    bool addModel(const char *modelAlias, const char *fileName,
                btVector3 *pos, btQuaternion *rot,
                bool useCartoonRendering,
                const char *baseModelAlias,
                const char *baseBoneName);

   // changeModel: change model
   bool changeModel(const char *modelAlias, const char *fileName);
    ******/
    
    bool addModel(const char *modelAlias, ScenarioData *_scenarioData,
                  btVector3 *pos, btQuaternion *rot,
                  bool useCartoonRendering,
                  const char *baseModelAlias,
                  const char *baseBoneName,
                  int usePhysics,
                  int textureLib);
    
    /* changeModel: change model */
    bool changeModel(const char *modelAlias, ScenarioData *_scenarioData);
    

   /* deleteModel: delete model */
   bool deleteModel(const char *modelAlias);

   /* addMotion: add motion */
    /*********
     bool addMotion(const char *modelAlias, const char *motionAlias,
                  const char *fileName, bool full,
                  bool once, bool enableSmooth,
                  bool enableRePos, float priority);

     // changeMotion: change motion
    bool changeMotion(const char *modelAlias, const char *motionAlias, const char *fileName);
     ***********/

    bool addMotion(const char *modelAlias, const char *motionAlias,
                   ScenarioData *_scenarioData, bool full, bool once,
                   bool enableSmooth, bool enableRePos, float priority);

    bool changeMotion(const char *modelAlias, const char *motionAlias, ScenarioData *_scenarioData);

   /* accelerateMotion: accelerate motion */
   bool accelerateMotion(const char *modelAlias, const char *motionAlias, float speed, float durationTime, float targetTime);

   /* deleteMotion: delete motion */
   bool deleteMotion(const char *modelAlias, const char *motionAlias);

   /* startMove: start moving */
   bool startMove(const char *modelAlias, btVector3 *pos, bool local, float speed);

   /* stopMove: stop moving */
   bool stopMove(const char *modelAlias);

   /* startTurn: start turn */
   bool startTurn(const char *modelAlias, btVector3 *pos, bool local, float speed);

   /* stopTurn: stop turn */
   bool stopTurn(const char *modelAlias);

   /* startRotation: start rotation */
   bool startRotation(const char *modelAlias, btQuaternion *rot, bool local, float spped);

   /* stopRotation: stop rotation */
   bool stopRotation(const char *modelAlias);

   /* setFloor: set floor image */
   bool setFloor(char *fileName);

   /* setBackground: set background image */
   bool setBackground(char *fileName);

   /* setStage: set stage */
   bool setStage(ScenarioData *_scenarioData);

   /* changeCamera: change camera setting */
    /*********
     bool changeCamera(const char *pos, const char *rot, const char *distance, const char *fovy, const char *time);
     **********/
    
    bool changeCamera(const char *pos, const char *rot, const char *distance=NULL,
                      const char *fovy=NULL, const char *time=NULL, ScenarioData *_scenarioData=NULL);

   /* changeLightColor: change light color */
   bool changeLightColor(float r, float g, float b);

   /* changeLightDirection: change light direction */
   bool changeLightDirection(float x, float y, float z);

   /* startLipSync: start lip sync */
   bool startLipSync(const char *modelAlias, const char *seq);

   /* stopLipSync: stop lip sync */
   bool stopLipSync(const char *modelAlias);

   /* procReceivedMessage: process received message */
   void procReceivedMessage(const char *type, const char *value);

   /* procReceivedLogString: process received log string */
   void procReceivedLogString(const char *log);

   /* initialize: initialize MMDAgent */
   void initialize();

   /* clear: free MMDAgent */
   void clear();

   /* MMDAgent: constructor */
   MMDAgent();

   /* ~MMDAgent: destructor */
   ~MMDAgent();

   /* setup: initialize and setup MMDAgent */
    //bool setup(int argc, char **argv, const char *title);
    bool setup( int screenWidth, int screenHeight );

    // return option pointer
    Option *getOption( void );

   /* updateAndRender: update and render the whole scene */
   bool updateAndRender(int mode=0); // mode: 0=all, 1=update, 2=render

    // get frame per second
    float getFPS();
    
   /* drawString: draw string */
   void drawString(const char *str);

   /* resetAdjustmentTimer: reset adjustment timer */
   void resetAdjustmentTimer();

   /* sendMessage: send message to global message queue */
   void sendMessage(const char *type, const char *format, ...);

   /* sendLogString: send log string */
   void sendLogString(const char *format, ...);

   /* findModelAlias: find a model with the specified alias */
   int findModelAlias(const char *alias);

   /* getMoelList: get model list */
   PMDObject *getModelList();

   /* getNumModel: get number of models */
   short getNumModel();

   /* getMousePosition:: get mouse position */
   void getMousePosition(int *x, int *y);

   /* getScreenPointPosition: convert screen position to object position */
   void getScreenPointPosition(btVector3 *dst, btVector3 *src);

   /* MMDAgent::getWindowSize: get window size */
   void getWindowSize(int *w, int *h);

   /* getConfigFileName: get config file name for plugin */
   char *getConfigFileName();

   /* getConfigDirName: get directory of config file for plugin */
   char *getConfigDirName();

   /* getAppDirName: get application directory name for plugin */
   char *getAppDirName();

   /* procWindowDestroyMessage: process window destroy message */
   void procWindowDestroyMessage();

   /* procMouseLeftButtonDoubleClickMessage: process mouse left button double click message */
   void procMouseLeftButtonDoubleClickMessage(int x, int y);

   /* procMouseLeftButtonDownMessage: process mouse left button down message */
   void procMouseLeftButtonDownMessage(int x, int y, bool withCtrl, bool withShift);

   /* procMouseLeftButtonUpMessage: process mouse left button up message */
   void procMouseLeftButtonUpMessage();

   /* procMouseWheel: process mouse wheel message */
   void procMouseWheelMessage(bool zoomup, bool withCtrl, bool withShift);

   /* procMousePosMessage: process mouse position message */
   void procMousePosMessage(int x, int y, bool withCtrl, bool withShift);

   /* procMouseRightButtonDownMessage: process mouse right button down message */
   void procMouseRightButtonDownMessage();

   /* procFullScreenMessage: process full screen message */
   void procFullScreenMessage();

   /* procInfoStringMessage: process information string message */
   void procInfoStringMessage();

   /* procVSyncMessage: process vsync message */
   void procVSyncMessage();

   /* procShadowMappingMessage: process shadow mapping message */
   void procShadowMappingMessage();

   /* procShadowMappingOrderMessage: process shadow mapping order message */
   void procShadowMappingOrderMessage();

   /* procDisplayRigidBodyMessage: process display rigid body message */
   void procDisplayRigidBodyMessage();

   /* procDisplayWireMessage: process display wire message */
   void procDisplayWireMessage();

   /* procDisplayBoneMessage: process display bone message */
   void procDisplayBoneMessage();

   /* procCartoonEdgeMessage: process cartoon edge message */
   void procCartoonEdgeMessage(bool plus);

   /* procTimeAdjustMessage: process time adjust message */
   void procTimeAdjustMessage(bool plus);

   /* procHorizontalRotateMessage: process horizontal rotate message */
   void procHorizontalRotateMessage(bool right);

   /* procVerticalRotateMessage: process vertical rotate message */
   void procVerticalRotateMessage(bool up);

   /* procHorizontalMoveMessage: process horizontal move message */
   void procHorizontalMoveMessage(bool right);

   /* procVerticalMoveMessage: process vertical move message */
   void procVerticalMoveMessage(bool up);

   /* procDeleteModelMessage: process delete model message */
   void procDeleteModelMessage();

   /* procPhysicsMessage: process physics message */
   void procPhysicsMessage(bool enable);

   /* procDisplayLogMessage: process display log message */
   void procDisplayLogMessage();

   /* procHoldMessage: process hold message */
   void procHoldMessage(bool hold);

   /* procWindowSizeMessage: process window size message */
   void procWindowSizeMessage(int x, int y);

   /* procKeyMessage: process key message */
   void procKeyMessage(char c);

   /* procScrollLogMessage: process log scroll message */
   void procScrollLogMessage(bool up);

   /* procDropFileMessage: process file drops message */
   void procDropFileMessage(ScenarioData *_scenarioData, int x, int y);
};

//#pragma pack(pop)

#endif /* __mmdagent_h__ */
