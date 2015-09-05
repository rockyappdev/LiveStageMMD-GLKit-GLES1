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

/* headers */

#import "ScenarioData.h"

#include <stdarg.h>
#include <locale.h>
#include "MMDAgent.h"


GLuint g_depthBuffer = 0;
GLuint g_defaultFramebuffer = 0;
GLuint g_colorRenderbuffer = 0;
PVRTMat4 g_matView;
PVRTMat4 g_matProjection;
GLint g_backingWidth;
GLint g_backingHeight;
SHADER_PARAMS g_shaders[ NUM_SHADERS ];

SHADER_PARAMS& MMDAgent::shader(int idx)
{
    return g_shaders[idx];
}

void MMDAgent::setBackingWidth(GLint width)
{
    g_backingWidth = width;
}

void MMDAgent::setBackingHeight(GLint height)
{
    g_backingHeight = height;
}

GLint MMDAgent::getBackingWidth()
{
    return g_backingWidth;
}

GLint MMDAgent::getBackingHeight()
{
    return g_backingHeight;
}

void MMDAgent::setDepthBuffer(GLuint buffer)
{
    g_depthBuffer = buffer;
}

void MMDAgent::setDefaultFrameBuffer(GLuint buffer)
{
    g_defaultFramebuffer = buffer;
}

void MMDAgent::setColorRenderBuffer(GLuint buffer)
{
    g_colorRenderbuffer = buffer;
}

GLuint MMDAgent::getDepthBuffer()
{
    return g_depthBuffer;
}

GLuint MMDAgent::getDefaultFramebuffer()
{
    return g_defaultFramebuffer;
}

GLuint MMDAgent::getColorRenderbuffer()
{
    return g_colorRenderbuffer;
}

void MMDAgent::setMatProjection(PVRTMat4& mat4)
{
    g_matProjection = mat4;
}

void MMDAgent::setMatView(PVRTMat4& mat4)
{
    g_matView = mat4;
}

PVRTMat4& MMDAgent::getMatProjection()
{
    return g_matProjection;
}

PVRTMat4& MMDAgent::getMatView()
{
    return g_matView;
}

/* MMDAgent::getNewModelId: return new model ID */
int MMDAgent::getNewModelId()
{
   int i;

   for (i = 0; i < m_numModel; i++)
      if (m_models[i].isEnable() == false)
         return i; /* re-use it */

   if (m_numModel >= m_option->getMaxNumModel())
      return -1; /* no more room */

   i = m_numModel;
   m_numModel++;

    m_models[i].setEnableFlag(false); /* model is not loaded yet */
    m_models[i].setMMDAgent(this);

    return i;
}

/* MMDAgent::removeRelatedModels: delete a model */
void MMDAgent::removeRelatedModels(int modelId)
{
   int i;
   MotionPlayer *motionPlayer;

   /* remove assigned accessories */
   for (i = 0; i < m_numModel; i++)
      if (m_models[i].isEnable() == true && m_models[i].getAssignedModel() == &m_models[modelId])
         removeRelatedModels(i);

   /* remove motion */
   for (motionPlayer = m_models[modelId].getMotionManager()->getMotionPlayerList(); motionPlayer; motionPlayer = motionPlayer->next) {
      /* send message */
      if (MMDAgent_strequal(motionPlayer->name, LIPSYNC_MOTIONNAME))
         sendMessage(MMDAGENT_EVENT_LIPSYNCSTOP, "%s", m_models[modelId].getAlias());
      else {
         sendMessage(MMDAGENT_EVENT_MOTIONDELETE, "%s|%s", m_models[modelId].getAlias(), motionPlayer->name);
      }
      /* unload from motion stocker */
      m_motion->unload(motionPlayer->vmd);
   }

   /* remove model */
   sendMessage(MMDAGENT_EVENT_MODELDELETE, "%s", m_models[modelId].getAlias());
   m_models[modelId].release();
}

/* MMDAgent::updateLight: update light */
void MMDAgent::updateLight()
{
   int i;
   float *f;
   btVector3 l;

   /* udpate OpenGL light */
   m_render->updateLight(m_option->getUseMMDLikeCartoon(), m_option->getUseCartoonRendering(), m_option->getLightIntensity(), m_option->getLightDirection(), m_option->getLightColor());
   /* update shadow matrix */
   f = m_option->getLightDirection();
   m_stage->updateShadowMatrix(f);
   /* update vector for cartoon */
   l = btVector3(btScalar(f[0]), btScalar(f[1]), btScalar(f[2]));
   for (i = 0; i < m_numModel; i++)
      if (m_models[i].isEnable() == true)
         m_models[i].setLightForToon(&l);
}

/* MMDAgent::setHighLight: set high-light of selected model */
void MMDAgent::setHighLight(int modelId)
{
   float color[4];

   if (m_highLightingModel == modelId) return;

   if (m_highLightingModel != -1) {
      /* reset current highlighted model */
      color[0] = PMDMODEL_EDGECOLORR;
      color[1] = PMDMODEL_EDGECOLORG;
      color[2] = PMDMODEL_EDGECOLORB;
      color[3] = PMDMODEL_EDGECOLORA;
      m_models[m_highLightingModel].getPMDModel()->setEdgeColor(color);
      /* disable force edge flag */
      m_models[m_highLightingModel].getPMDModel()->setForceEdgeFlag(false);
   }
   if (modelId != -1) {
      /* set highlight to the specified model */
      m_models[modelId].getPMDModel()->setEdgeColor(m_option->getCartoonEdgeSelectedColor());
      /* enable force edge flag */
      m_models[modelId].getPMDModel()->setForceEdgeFlag(true);
   }

   m_highLightingModel = modelId;
}

/* MMDAgent::addModel: add model */
bool MMDAgent::addModel(const char *modelAlias, ScenarioData *_scenarioData,
                        btVector3 *pos, btQuaternion *rot,
                        bool useCartoonRendering,
                        const char *baseModelAlias,
                        const char *baseBoneName,
                        int usePhysics,
                        int textureLib)
{
    NSLog(@"... MMDAgent::addModel entered");
    
    char *fileName;
   int i;
   int id;
   int baseID;
   char *name;
   btVector3 offsetPos(btScalar(0.0f), btScalar(0.0f), btScalar(0.0f));
   btQuaternion offsetRot(btScalar(0.0f), btScalar(0.0f), btScalar(0.0f), btScalar(1.0f));
   bool forcedPosition = false;
   PMDBone *assignBone = NULL;
   PMDObject *assignObject = NULL;
   //float *l = m_option->getLightDirection();
   //btVector3 light = btVector3(btScalar(l[0]), btScalar(l[1]), btScalar(l[2]));

    ScenarioData *scenarioData = _scenarioData;
    fileName = (char*) [[scenarioData getCurrentModelPath] cStringUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"xxx MMDAgent::addModel _scenarioData = [%lx]", (unsigned long) _scenarioData);
    
    if (scenarioData == nil) {
        NSLog(@"*** MMDAgent::addModel scenarioData is [nil]");
    }
    
    
   /* set */
   if (pos)
      offsetPos = (*pos);
   if (rot)
      offsetRot = (*rot);
   if (pos || rot)
      forcedPosition = true;
   if (baseModelAlias) {
      baseID = findModelAlias(baseModelAlias);
      if (baseID < 0) {
         m_logger->log("Error: addModel: %s is not found.", baseModelAlias);
         return false;
      }
      if (baseBoneName) {
         assignBone = m_models[baseID].getPMDModel()->getBone(baseBoneName);
      } else {
         assignBone = m_models[baseID].getPMDModel()->getCenterBone();
      }
      if (assignBone == NULL) {
         if (baseBoneName)
            m_logger->log("Error: addModel: %s is not exist on %s.", baseBoneName, baseModelAlias);
         else
            m_logger->log("Error: addModel: %s don't have center bone.", baseModelAlias);
         return false;
      }
      assignObject = &m_models[baseID];
   }

   /* ID */
   id = getNewModelId();
   if (id == -1) {
      m_logger->log("Error: addModel: number of models exceed the limit.");
      return false;
   }

   /* determine name */
   if (MMDAgent_strlen(modelAlias) > 0) {
      /* check the same alias */
      name = MMDAgent_strdup(modelAlias);
      if (findModelAlias(name) >= 0) {
         m_logger->log("Error: addModel: model alias \"%s\" is already used.", name);
         free(name);
         return false;
      }
   } else {
      /* if model alias is not specified, unused digit is used */
      for(i = 0;; i++) {
         name = MMDAgent_intdup(i);
         if (findModelAlias(name) >= 0)
            free(name);
         else
            break;
      }
   }

   /* add model */
    if (!m_models[id].load(_scenarioData, name, &offsetPos, &offsetRot, forcedPosition,
                          assignBone, assignObject, m_bullet, m_systex, m_lipSync,
                          usePhysics, useCartoonRendering, textureLib,
                           m_option))
    {
        m_logger->log("Error: addModel: %s cannot be loaded.", fileName);
        m_models[id].release();
        free(name);
        return false;
    }

   /* initialize motion manager */
   m_models[id].resetMotionManager();

   /* update for initial positions and skins */
   m_models[id].updateRootBone();
   m_models[id].updateMotion(0.0);
   m_models[id].updateSkin();

   /* send message */
   sendMessage(MMDAGENT_EVENT_MODELADD, "%s", name);
   free(name);
   
    return true;
}

/* MMDAgent::changeModel: change model */
bool MMDAgent::changeModel(const char *modelAlias, ScenarioData *_scenarioData)
{
    char *fileName;
   int i;
   int id;
   MotionPlayer *motionPlayer;
   double currentFrame;
   double previousFrame;
   //float *l = m_option->getLightDirection();
   //btVector3 light = btVector3(btScalar(l[0]), btScalar(l[1]), btScalar(l[2]));

    ScenarioData *scenarioData = _scenarioData;
    fileName = (char*) [[scenarioData getCurrentMotionPath] cStringUsingEncoding:NSUTF8StringEncoding];
    

   /* ID */
   id = findModelAlias(modelAlias);
   if (id < 0) {
      m_logger->log("Error: changeModel: %s is not found.", modelAlias);
      return false;
   }

   /* load model */
    if (!m_models[id].load(_scenarioData, modelAlias, NULL, NULL, false, NULL, NULL,
                          m_bullet, m_systex, m_lipSync, true,
                          m_models[id].useCartoonRendering(),
                           m_models[id].getTextureLib(),
                           m_option))
   {
      m_logger->log("Error: changeModel: %s cannot be loaded.", fileName);
      return false;
   }

   /* update motion manager */
   if (m_models[id].getMotionManager()) {
      for (motionPlayer = m_models[id].getMotionManager()->getMotionPlayerList(); motionPlayer; motionPlayer = motionPlayer->next) {
         if (motionPlayer->active) {
            currentFrame = motionPlayer->mc.getCurrentFrame();
            previousFrame = motionPlayer->mc.getPreviousFrame();
            motionPlayer->mc.setup(m_models[id].getPMDModel(), motionPlayer->vmd);
            motionPlayer->mc.setCurrentFrame(currentFrame);
            motionPlayer->mc.setPreviousFrame(previousFrame);
         }
      }
   }

   /* update for initial positions and skins */
   m_models[id].updateRootBone();
   m_models[id].updateMotion(0.0);
   m_models[id].updateSkin();

   /* delete accessories immediately */
   for (i = 0; i < m_numModel; i++)
      if (m_models[i].isEnable() && m_models[i].getAssignedModel() == &(m_models[id]))
         removeRelatedModels(i);

   /* send message */
   sendMessage(MMDAGENT_EVENT_MODELCHANGE, "%s", modelAlias);
   return true;
}

/* MMDAgent::deleteModel: delete model */
bool MMDAgent::deleteModel(const char *modelAlias)
{
   int i;
   int id;

   /* ID */
   id = findModelAlias(modelAlias);
   if (id < 0) {
      /* wrong alias */
      m_logger->log("Error: deleteModel: %s is not found.", modelAlias);
      return false;
   }

   /* delete accessories  */
   for (i = 0; i < m_numModel; i++)
      if (m_models[i].isEnable() && m_models[i].getAssignedModel() == &(m_models[id]))
         deleteModel(m_models[i].getAlias());

   /* set frame from now to disappear */
   m_models[id].startDisappear();

   /* don't send message yet */
   return true;
}

/* MMDAgent::addMotion: add motion */
bool MMDAgent::addMotion(const char *modelAlias, const char *motionAlias,
                         ScenarioData *_scenarioData, bool full, bool once,
                        bool enableSmooth, bool enableRePos, float priority)
{
    char *fileName;
   int i;
   bool find;
   int id;
   VMD *vmd;
   MotionPlayer *motionPlayer;
   char *name;

    NSLog(@"... MMDAgent::addMotion entered");
    
    ScenarioData *scenarioData = _scenarioData;
    fileName = (char*) [[scenarioData getCurrentMotionPath] cStringUsingEncoding:NSUTF8StringEncoding];
    
    if (scenarioData == nil) {
        NSLog(@"*** scenarioData is [nil]");
    }
    
   /* motion file */
   vmd = m_motion->loadFromFile(scenarioData);
   if (vmd == NULL) {
      m_logger->log("Error: addMotion: %s cannot be loaded.", fileName);
      return false;
   }

   /* ID */
   id = findModelAlias(modelAlias);
   if (id < 0) {
      m_logger->log("Error: addMotion: %s is not found.", modelAlias);
      return false;
   }

   /* alias */
   if (MMDAgent_strlen(motionAlias) > 0) {
      /* check the same alias */
      name = MMDAgent_strdup(motionAlias);
      for (motionPlayer = m_models[id].getMotionManager()->getMotionPlayerList(); motionPlayer; motionPlayer = motionPlayer->next) {
         if (motionPlayer->active && MMDAgent_strequal(motionPlayer->name, name)) {
            m_logger->log("Error: addMotion: motion alias \"%s\" is already used.", name);
            free(name);
            return false;
         }
      }
   } else {
      /* if motion alias is not specified, unused digit is used */
      for(i = 0;; i++) {
         find = false;
         name = MMDAgent_intdup(i);
         for (motionPlayer = m_models[id].getMotionManager()->getMotionPlayerList(); motionPlayer; motionPlayer = motionPlayer->next) {
            if (motionPlayer->active && MMDAgent_strequal(motionPlayer->name, name)) {
               find = true;
               break;
            }
         }
         if(find == false)
            break;
         free(name);
      }
   }

   /* when smoothing is disabled, skip next physics simulation for warping at beginning of motion */
   if (enableSmooth == false)
      m_models[id].skipNextSimulation();

   /* start motion */
   if (m_models[id].startMotion(vmd, name, full, once, enableSmooth, enableRePos, priority) == false) {
      free(name);
      return false;
   }

   sendMessage(MMDAGENT_EVENT_MOTIONADD, "%s|%s", modelAlias, name);
   free(name);
   return true;
}

/* MMDAgent::changeMotion: change motion */
bool MMDAgent::changeMotion(const char *modelAlias, const char *motionAlias, ScenarioData *_scenarioData)
{
    char *fileName;
   int id;
   VMD *vmd, *old = NULL;
   MotionPlayer *motionPlayer;

    ScenarioData *scenarioData = _scenarioData;
    fileName = (char*) [[scenarioData getCurrentMotionPath] cStringUsingEncoding:NSUTF8StringEncoding];

   /* ID */
   id = findModelAlias(modelAlias);
   if (id < 0) {
      m_logger->log("Error: changeMotion: %s is not found.", modelAlias);
      return false;
   }

   /* check */
   if (!motionAlias) {
      m_logger->log("Error: changeMotion: motion alias is not specified.");
      return false;
   }

   /* motion file */
#ifdef NEED_AMEND_TO_LOAD_FROM_ZIP
   vmd = m_motion->loadFromFile(fileName);
   if (vmd == NULL) {
      m_logger->log("Error: changeMotion: %s cannot be loaded.", fileName);
      return false;
   }
#endif
    
   /* get motion before change */
   for (motionPlayer = m_models[id].getMotionManager()->getMotionPlayerList(); motionPlayer; motionPlayer = motionPlayer->next) {
      if (motionPlayer->active && MMDAgent_strequal(motionPlayer->name, motionAlias)) {
         old = motionPlayer->vmd;
         /* when smoothing has been disabled, skip next physics simulation for warping at beginning of changed motion */
         if (motionPlayer->enableSmooth == false)
            m_models[id].skipNextSimulation();
         break;
      }
   }
   if(old == NULL) {
      m_logger->log("Error: changeMotion: %s is not found.", motionAlias);
      m_motion->unload(vmd);
      return false;
   }

   /* change motion */
   if (m_models[id].swapMotion(vmd, motionAlias) == false) {
      m_logger->log("Error: changeMotion: %s is not found.", motionAlias);
      m_motion->unload(vmd);
      return false;
   }

   /* unload old motion from motion stocker */
   m_motion->unload(old);

   /* send message */
   sendMessage(MMDAGENT_EVENT_MOTIONCHANGE, "%s|%s", modelAlias, motionAlias);
   return true;
}

/* MMDAgent::accelerateMotion: accelerate motion */
bool MMDAgent::accelerateMotion(const char *modelAlias, const char *motionAlias, float speed, float durationTime, float targetTime)
{
   int id;

   /* ID */
   id = findModelAlias(modelAlias);
   if (id < 0) {
      m_logger->log("Error: accelerateMotion: %s is not found.", modelAlias);
      return false;
   }

   /* check */
   if (!motionAlias) {
      m_logger->log("Error: accelerateMotion: motion alias is not specified.");
      return false;
   }

   /* change motion speed */
   if (m_models[id].getMotionManager()->setMotionSpeedRate(motionAlias, speed, durationTime * 30.0f, targetTime * 30.0f) == false) {
      m_logger->log("Error: accelerateMotion: %s is not found.", motionAlias);
      return false;
   }

   /* don't send message yet */
   return true;
}

/* MMDAgent::deleteMotion: delete motion */
bool MMDAgent::deleteMotion(const char *modelAlias, const char *motionAlias)
{
   int id;

   /* ID */
   id = findModelAlias(modelAlias);
   if (id < 0) {
      m_logger->log("Error: deleteMotion: %s is not found.", modelAlias);
      return false;
   }

   /* delete motion */
   if (m_models[id].getMotionManager()->deleteMotion(motionAlias) == false) {
      m_logger->log("Error: deleteMotion: %s is not found.", motionAlias);
      return false;
   }

   /* don't send message yet */
   return true;
}

/* MMDAgent::startMove: start moving */
bool MMDAgent::startMove(const char *modelAlias, btVector3 *pos, bool local, float speed)
{
   int id;
   btVector3 currentPos;
   btQuaternion currentRot;
   btVector3 targetPos;
   btTransform tr;

   /* ID */
   id = findModelAlias(modelAlias);
   if (id < 0) {
      m_logger->log("Error: startMove: %s is not found.", modelAlias);
      return false;
   }

   if(m_models[id].isMoving() == true)
      sendMessage(MMDAGENT_EVENT_MOVESTOP, "%s", modelAlias);

   /* get */
   m_models[id].getCurrentPosition(&currentPos);
   targetPos = (*pos);

   /* local or global */
   if (local) {
      m_models[id].getCurrentRotation(&currentRot);
      tr = btTransform(currentRot, currentPos);
      targetPos = tr * targetPos;
   }

   /* not need to start */
   if (currentPos == targetPos) {
      sendMessage(MMDAGENT_EVENT_MOVESTART, "%s", modelAlias);
      sendMessage(MMDAGENT_EVENT_MOVESTOP, "%s", modelAlias);
      return true;
   }

   m_models[id].setMoveSpeed(speed);
   m_models[id].setPosition(&targetPos);
   sendMessage(MMDAGENT_EVENT_MOVESTART, "%s", modelAlias);
   return true;
}

/* MMDAgent::stopMove: stop moving */
bool MMDAgent::stopMove(const char *modelAlias)
{
   int id;
   btVector3 currentPos;

   /* ID */
   id = findModelAlias(modelAlias);
   if (id < 0) {
      m_logger->log("Error: stopMove: %s is not found.", modelAlias);
      return false;
   }

   if(m_models[id].isMoving() == false) {
      m_logger->log("Error: stopMove: %s is not moving.", modelAlias);
      return false;
   }

   /* get */
   m_models[id].getCurrentPosition(&currentPos);

   m_models[id].setPosition(&currentPos);
   sendMessage(MMDAGENT_EVENT_MOVESTOP, "%s", modelAlias);
   return true;
}

/* MMDAgent::startTurn: start turn */
bool MMDAgent::startTurn(const char *modelAlias, btVector3 *pos, bool local, float speed)
{
   int id;
   btVector3 currentPos;
   btQuaternion currentRot;
   btVector3 targetPos;
   btQuaternion targetRot;

   float z, rad;
   btVector3 axis;

   /* ID */
   id = findModelAlias(modelAlias);
   if (id < 0) {
      m_logger->log("Error: startTurn: %s is not found.", modelAlias);
      return false;
   }

   if(m_models[id].isRotating() == true) {
      if(m_models[id].isTurning() == true)
         sendMessage(MMDAGENT_EVENT_TURNSTOP, "%s", modelAlias);
      else
         sendMessage(MMDAGENT_EVENT_ROTATESTOP, "%s", modelAlias);
   }

   /* get */
   m_models[id].getCurrentPosition(&currentPos);
   m_models[id].getCurrentRotation(&currentRot);

   /* get vector from current position to target position */
   if(local == true)
      targetPos = (*pos);
   else
      targetPos = (*pos) - currentPos;
   targetPos.normalize();

   /* calculate target rotation from (0,0,1) */
   z = targetPos.z();
   if (z > 1.0f) z = 1.0f;
   if (z < -1.0f) z = -1.0f;
   rad = acosf(z);
   axis = btVector3(btScalar(0.0f), btScalar(0.0f), btScalar(1.0f)).cross(targetPos);
   if(axis.length2() < PMDOBJECT_MINSPINDIFF) {
      targetRot = btQuaternion(btScalar(0.0f), btScalar(0.0f), btScalar(0.0f), btScalar(1.0f));
   } else {
      axis.normalize();
      targetRot = btQuaternion(axis, btScalar(rad));
   }

   /* local or global */
   if (local)
      targetRot = currentRot * targetRot;
   else
      targetRot = currentRot.nearest(targetRot);

   /* not need to turn */
   if (currentRot == targetRot) {
      sendMessage(MMDAGENT_EVENT_TURNSTART, "%s", modelAlias);
      sendMessage(MMDAGENT_EVENT_TURNSTOP, "%s", modelAlias);
      return true;
   }

   m_models[id].setSpinSpeed(speed);
   m_models[id].setRotation(&targetRot);
   m_models[id].setTurningFlag(true);
   sendMessage(MMDAGENT_EVENT_TURNSTART, "%s", modelAlias);
   return true;
}

/* MMDAgent::stopTurn: stop turn */
bool MMDAgent::stopTurn(const char *modelAlias)
{
   int id;
   btQuaternion currentRot;

   id = findModelAlias(modelAlias);
   if (id < 0) {
      m_logger->log("Error: stopTurn: %s is not found.", modelAlias);
      return false;
   }

   /* not need to stop turn */
   if (m_models[id].isRotating() == false || m_models[id].isTurning() == false) {
      m_logger->log("Error: stopTurn: %s is not turning.", modelAlias);
      return false;
   }

   /* get */
   m_models[id].getCurrentRotation(&currentRot);

   m_models[id].setRotation(&currentRot);
   sendMessage(MMDAGENT_EVENT_TURNSTOP, "%s", modelAlias);
   return true;
}

/* MMDAgent::startRotation: start rotation */
bool MMDAgent::startRotation(const char *modelAlias, btQuaternion *rot, bool local, float speed)
{
   int id;
   btQuaternion targetRot;
   btQuaternion currentRot;

   id = findModelAlias(modelAlias);
   if (id < 0) {
      m_logger->log("Error: startRotation: %s is not found.", modelAlias);
      return false;
   }

   if(m_models[id].isRotating() == true) {
      if(m_models[id].isTurning() == true)
         sendMessage(MMDAGENT_EVENT_TURNSTOP, "%s", modelAlias);
      else
         sendMessage(MMDAGENT_EVENT_ROTATESTOP, "%s", modelAlias);
   }

   /* get */
   m_models[id].getCurrentRotation(&currentRot);
   targetRot = (*rot);

   /* local or global */
   if (local)
      targetRot = currentRot * targetRot;
   else
      targetRot = currentRot.nearest(targetRot);

   /* not need to start */
   if (currentRot == targetRot) {
      sendMessage(MMDAGENT_EVENT_ROTATESTART, "%s", modelAlias);
      sendMessage(MMDAGENT_EVENT_ROTATESTOP, "%s", modelAlias);
      return true;
   }

   m_models[id].setSpinSpeed(speed);
   m_models[id].setRotation(&targetRot);
   m_models[id].setTurningFlag(false);
   sendMessage(MMDAGENT_EVENT_ROTATESTART, "%s", modelAlias);
   return true;
}

/* MMDAgent::stopRotation: stop rotation */
bool MMDAgent::stopRotation(const char *modelAlias)
{
   int id;
   btQuaternion currentRot;

   id = findModelAlias(modelAlias);
   if (id < 0) {
      m_logger->log("Error: stopRotation: %s is not found.", modelAlias);
      return false;
   }

   /* not need to stop rotation */
   if (m_models[id].isRotating() == false || m_models[id].isTurning() == true) {
      m_logger->log("Error: stopRotation: %s is not rotating.", modelAlias);
      return false;
   }

   /* get */
   m_models[id].getCurrentRotation(&currentRot);

   m_models[id].setRotation(&currentRot);
   sendMessage(MMDAGENT_EVENT_ROTATESTOP, "%s", modelAlias);
   return true;
}

/* MMDAgent::setFloor: set floor image */
bool MMDAgent::setFloor(char *fileName)
{
    
   /* load floor */
   if (m_stage->loadFloor(fileName) == false) {
      m_logger->log("Error: setFloor: %s cannot be set for floor.", fileName);
      return false;
   }

   /* don't send message */
   return true;
}

/* MMDAgent::setBackground: set background image */
bool MMDAgent::setBackground(char *fileName)
{
    
   /* load background */
   if (m_stage->loadBackground(fileName) == false) {
      m_logger->log("Error: setBackground: %s cannot be set for background.", fileName);
      return false;
   }

   /* don't send message */
   return true;
}

/* MMDAgent::setStage: set stage */
bool MMDAgent::setStage(ScenarioData *_scenarioData)
{
    char *fileName;
    
    ScenarioData *scenarioData = _scenarioData;
    fileName = (char*) [[scenarioData getCurrentModelPath] cStringUsingEncoding:NSUTF8StringEncoding];

    if (m_stage->loadStagePMD(_scenarioData, m_bullet, m_systex, m_option) == false) {
        m_logger->log("Error: setStage: %s cannot be set for stage.", fileName);
        return false;
    }

   /* don't send message */
   return true;
}

/* MMDAgent::changeCamera: change camera setting */
bool MMDAgent::changeCamera(const char *posOrVMD, const char *rot,
                            const char *distance, const char *fovy,
                            const char *time, ScenarioData *_scenarioData)
{
   float p[3], r[3];
   VMD *vmd;

    char *fileName;
    
    ScenarioData *scenarioData = _scenarioData;
    fileName = (char*) [[scenarioData getCurrentMotionPath] cStringUsingEncoding:NSUTF8StringEncoding];
    
    if (posOrVMD == NULL) {
        posOrVMD = fileName;
    }

   if(MMDAgent_str2fvec(posOrVMD, p, 3) == true && MMDAgent_str2fvec(rot, r, 3) == true) {
      m_render->resetCameraView(p, r, MMDAgent_str2float(distance), MMDAgent_str2float(fovy));
      if (time) {
         m_render->setViewMoveTimer(MMDAgent_str2double(time));
         m_timer->start();
      } else {
         //m_render->setViewMoveTimer(-1.0);
          m_render->setViewMoveTimer(0.0);
      }
      return true;
   }

   vmd = m_motion->loadFromFile(_scenarioData);
   if(vmd != NULL) {
      m_camera.setup(vmd);
      m_camera.reset();
      m_cameraControlled = true;
      return true;
   }

   return false;
}

/* MMDAgent::changeLightColor: change light color */
bool MMDAgent::changeLightColor(float r, float g, float b)
{
   float f[3];

   f[0] = r;
   f[1] = g;
   f[2] = b;
   m_option->setLightColor(f);
   updateLight();

   /* don't send message */
   return true;
}

/* MMDAgent::changeLightDirection: change light direction */
bool MMDAgent::changeLightDirection(float x, float y, float z)
{
   float f[4];

   f[0] = x;
   f[1] = y;
   f[2] = z;
   f[3] = 0.0f;
   m_option->setLightDirection(f);
   updateLight();

   /* don't send message */
   return true;
}

/* MMDAgent::startLipSync: start lip sync */
bool MMDAgent::startLipSync(const char *modelAlias, const char *seq)
{
   int id;
   unsigned char *vmdData;
   unsigned int vmdSize;
   VMD *vmd;
   bool find = false;
   MotionPlayer *motionPlayer;

   /* ID */
   id = findModelAlias(modelAlias);
   if (id < 0) {
      m_logger->log("Error: startLipSync: %s is not found.", modelAlias);
      return false;
   }

   /* create motion */
   if(m_models[id].createLipSyncMotion(seq, &vmdData, &vmdSize) == false) {
      m_logger->log("Error: startLipSync: cannot create lip motion.");
      return false;
   }
   vmd = m_motion->loadFromData(vmdData, vmdSize);
   free(vmdData);

   /* search running lip motion */
   for (motionPlayer = m_models[id].getMotionManager()->getMotionPlayerList(); motionPlayer; motionPlayer = motionPlayer->next) {
      if (motionPlayer->active && MMDAgent_strequal(motionPlayer->name, LIPSYNC_MOTIONNAME)) {
         find = true;
         break;
      }
   }

   /* start lip sync */
   if(find == true) {
      if (m_models[id].swapMotion(vmd, LIPSYNC_MOTIONNAME) == false) {
         m_logger->log("Error: startLipSync: lip sync cannot be started.");
         m_motion->unload(vmd);
         return false;
      }
      sendMessage(MMDAGENT_EVENT_LIPSYNCSTOP, "%s", modelAlias);
   } else {
      if (m_models[id].startMotion(vmd, LIPSYNC_MOTIONNAME, false, true, true, true, m_option->getLipsyncPriority()) == false) {
         m_logger->log("Error: startLipSync: lip sync cannot be started.");
         m_motion->unload(vmd);
         return false;
      }
   }

   /* send message */
   sendMessage(MMDAGENT_EVENT_LIPSYNCSTART, "%s", modelAlias);
   return true;
}

/* MMDAgent::stopLipSync: stop lip sync */
bool MMDAgent::stopLipSync(const char *modelAlias)
{
   int id;

   /* ID */
   id = findModelAlias(modelAlias);
   if (id < 0) {
      m_logger->log("Error: stopLipSync: %s is not found.", modelAlias);
      return false;
   }

   /* stop lip sync */
   if (m_models[id].getMotionManager()->deleteMotion(LIPSYNC_MOTIONNAME) == false) {
      m_logger->log("Error: stopLipSync: lipsync motion is not found.");
      return false;
   }

   /* don't send message yet */
   return true;
}

/* MMDAgent::initialize: initialize MMDAgent */
void MMDAgent::initialize()
{
   m_enable = false;

   m_configFileName = NULL;
   m_configDirName = NULL;
   m_appDirName = NULL;

   m_option = NULL;
   m_screen = NULL;
   m_message = NULL;
   m_bullet = NULL;
   //m_plugin = NULL;
   m_stage = NULL;
   m_systex = NULL;
   m_lipSync = NULL;
   m_render = NULL;
   m_timer = NULL;
   m_text = NULL;
   m_logger = NULL;

   m_models = NULL;
   m_renderOrder = NULL;
   m_numModel = 0;
   m_motion = NULL;

   m_cameraControlled = false;

   m_keyCtrl = false;
   m_keyShift = false;
   m_selectedModel = -1;
   m_highLightingModel = -1;
   m_doubleClicked = false;
   m_mousePosY = 0;
   m_mousePosX = 0;
   m_leftButtonPressed = false;
   m_restFrame = 0.0;

   m_enablePhysicsSimulation = true;
   m_dispLog = false;
   m_dispBulletBodyFlag = false;
   m_dispModelDebug = false;
   m_holdMotion = false;
}

/* MMDAgent::clear: free MMDAgent */
void MMDAgent::clear()
{
   m_enable = false;

   if(m_configFileName)
      free(m_configFileName);
   if(m_configDirName)
      free(m_configDirName);
   if(m_appDirName)
      free(m_appDirName);
   if(m_motion)
      delete m_motion;
   if (m_renderOrder)
      free(m_renderOrder);
   if (m_models)
      delete [] m_models;
   if (m_logger)
      delete m_logger;
   if (m_text)
      delete m_text;
   if (m_timer)
      delete m_timer;
   if (m_render)
      delete m_render;
   if (m_lipSync)
      delete m_lipSync;
   if (m_systex)
      delete m_systex;
   if (m_stage)
      delete m_stage;
    
   //if (m_plugin) delete m_plugin;
    
   if (m_bullet)
      delete m_bullet;
   if (m_message)
      delete m_message;
   if (m_screen)
      delete m_screen;
   if (m_option)
      delete m_option;

   initialize();
}

/* MMDAgent::MMDAgent: constructor */
MMDAgent::MMDAgent()
{
   initialize();
    
    /* initialize Option */
    m_option = new Option();

}

/* MMDAgent::~MMDAgent: destructor */
MMDAgent::~MMDAgent()
{
   clear();
}

Option *MMDAgent::getOption( void )
{
    return m_option;
}

void MMDAgent::translate(float x, float y, float z)
{
    if (m_render) {
        m_render->translate(x, y, z);
    }
}

void MMDAgent::jump(float height, float dist, float duration)
{
    if (m_render) {
        m_render->jump(height, dist, duration);
    }
}

int MMDAgent::getJumpState()
{
    int jumpState = 0;
    if (m_render) {
        jumpState = m_render->getJumpState();
    }
    
    return jumpState;
}

float MMDAgent::getDistance( void )
{
    float distance = -999999.0f;
    if (m_render) {
        distance = m_render->getDistance();
    }
    return distance;
}

void MMDAgent::addDistance( float delta )
{
    if (m_render) {
        m_render->setDistance(m_render->getDistance() + delta);
    }
}


void MMDAgent::setDistance( float dist )
{
    if (m_render) {
        m_render->setDistance(dist);
    }
}

void MMDAgent::setAngleXNoUpdate(float x)
{
    if (m_render) {
        m_render->setAngleXNoUpdate(x);
    }
}

void MMDAgent::setAngleYNoUpdate(float y)
{
    if (m_render) {
        m_render->setAngleYNoUpdate(y);
    }
}

void MMDAgent::setAngleZNoUpdate(float z)
{
    if (m_render) {
        m_render->setAngleZNoUpdate(z);
    }
}

float MMDAgent::getAngleX()
{
    if (m_render) {
        return m_render->getAngleX();
    }
    
    return 0.0;
}

float MMDAgent::getAngleY()
{
    if (m_render) {
        return m_render->getAngleY();
    }
    return 0.0;
}

float MMDAgent::getAngleZ()
{
    if (m_render) {
        return m_render->getAngleZ();
    }
    return 0.0;
}

void MMDAgent::rotateView(float x, float y, float z)
{
    if (m_render) {
        m_render->rotate(x, y, z);
    }
}

void MMDAgent::setPhysicsFps(int fps)
{
    if (m_option) {
        m_option->setBulletFps(fps);
    }
}

int MMDAgent::getPhysicsFps()
{
    int fps = 0;

    if (m_option) {
        fps = m_option->getBulletFps();
    }
    return fps;
}

/* MMDAgent::setup: initialize and setup MMDAgent */
bool MMDAgent::setup( int screenWidth, int screenHeight )
{
    if (m_option == NULL) {
        m_option = new Option();
    }

   /* set local to japan */
   setlocale(LC_CTYPE, "jpn");

   /* get application directory */

   /* load default config file */

   /* load additional config files */

   /* get config directory name */
    
    m_option->setWindowSize(screenWidth, screenHeight);

   /* create window */
   m_screen = new ScreenWindow();

   /* initialize message queue */
   m_message = new Message();
   m_message->setup();

    /* initialize BulletPhysics */
    m_bullet = new BulletPhysics();
    m_bullet->setup(m_option->getBulletFps(), m_option->getGravityFactor());

   /* create stage */
   m_stage = new Stage();
    m_stage->setMMDAgent(this);
   m_stage->setSize(m_option->getStageSize(), 1.0f, 1.0f);

   /* load toon textures from system directory */
   m_systex = new SystemTexture();
   if (m_systex->load() == false) {
      clear();
      return 0;
   }

   /* setup lipsync */
   m_lipSync = new LipSync();
    /*******
   sprintf(buff, "%s%c%s", m_appDirName, MMDAGENT_DIRSEPARATOR, LIPSYNC_CONFIGFILE);
   if (m_lipSync->load(buff) == false) {
      clear();
      return 0;
   }
     *******/
    
    /* setup timer */
    m_timer = new Timer();
    m_timer->setup();
    m_timer->startAdjustment();
    
   /* setup render */
   m_render = new Render();
   if (m_render->setup(m_option->getWindowSize(), m_option->getCampusColor(), m_option->getCameraTransition(), m_option->getCameraRotation(), m_option->getCameraDistance(), m_option->getCameraFovy(), m_option->getUseShadowMapping(), m_option->getShadowMappingTextureSize(), m_option->getShadowMappingLightFirst(), m_option->getMaxNumModel()) == false) {
      clear();
      return 0;
   }
    m_render->setTimer(m_timer);

   /* setup text render */
   m_text = new TextRenderer();
   m_text->setup();

   /* setup logger */
   m_logger = new LogText();
   m_logger->setup(m_text, m_option->getLogSize(), m_option->getLogPosition(), m_option->getLogScale());

   /* setup models */
   m_models = new PMDObject[m_option->getMaxNumModel()];
   m_renderOrder = (int *) malloc(sizeof(int) * m_option->getMaxNumModel());

   /* setup motions */
   m_motion = new MotionStocker();

   /* set full screen */
   if (m_option->getFullScreen() == true)
      m_screen->setFullScreen();

   /* set mouse enable timer */
   m_screen->setMouseActiveTime(45.0f);

   /* update light */
   updateLight();

   m_enable = true;
    
   return true;
}

/* MMDAgent::updateAndRender: update and render the whole scene */
bool MMDAgent::updateAndRender(int mode)
{
   static char buf1[MMDAGENT_MAXBUFLEN];
   static char buf2[MMDAGENT_MAXBUFLEN];

   if(m_enable == false)
      return false;

   /* check stored message */
   while(m_message->dequeueMessage(buf1, buf2) == true)
      procReceivedMessage(buf1, buf2);
   while(m_message->dequeueLogString(buf1) == true)
      procReceivedLogString(buf1);

    if (mode != 2) {
        // mode is 0 or 1
        /* update */
        if(updateScene() != true)
            return false;
        
    }

    if (mode != 1) {
        // mode is 0 or 2
        /* render */
        if(renderScene() != true)
            return false;
        
    }

   return true;
}

void MMDAgent::rewindScene()
{
    int i;
    
    for (i = 0; i < m_numModel; i++) {
        m_models[i].rewindMotion();
    }
}

void MMDAgent::restartScene()
{
    int i;
    
    for (i = 0; i < m_numModel; i++) {
        m_models[i].restartMotion();
    }
}

/* MMDAgent::updateScene: update the whole scene */
bool MMDAgent::updateScene()
{
   int i, ite;
   double intervalFrame;
   int stepmax;
   double stepFrame;
   double restFrame;
   double procFrame;
   double adjustFrame;
   MotionPlayer *motionPlayer;
    bool motionActive;

   if(m_enable == false)
      return false;

   if (m_cameraControlled == false)
      m_render->setCameraFromController(NULL);

   /* get frame interval */
   intervalFrame = m_timer->getFrameInterval();

   if (m_holdMotion == true) {
      /* minimal update with no frame advance */
      for (i = 0; i < m_numModel; i++) {
         if (m_models[i].isEnable() == false) continue;
         if(m_models[i].isMoving() == true) {
            m_models[i].updateRootBone();
            m_models[i].updateMotion(0);
         }
         m_models[i].updateAfterSimulation(m_enablePhysicsSimulation);
         m_models[i].updateSkin();
      }
      return true;
   }

   stepmax = m_option->getBulletFps();
   stepFrame = 30.0 / m_option->getBulletFps();
   restFrame = intervalFrame + m_restFrame;
   m_restFrame = 0.0;

   if (restFrame <= stepFrame * 0.5 && m_screen->getVSync() == true) {
      /* skip update and render */
      m_restFrame = restFrame;
      return false;
   }

    motionActive = false;

   for (ite = 0; ite < stepmax; ite++) {
      /* determine frame amount */
      if (restFrame <= stepFrame) {
         if (m_screen->getVSync() == true) {
            if (restFrame > stepFrame * 0.5) {
               /* process one step in advance */
               procFrame = stepFrame;
               m_restFrame = restFrame - stepFrame;
            } else if (restFrame <= stepFrame * 0.5) {
               /* leave for next call */
               m_restFrame = restFrame;
               break;
            } else {
               /* process as is */
               procFrame = restFrame;
            }
         } else {
            /* process as is */
            procFrame = restFrame;
         }
         ite = stepmax;
      } else {
         /* process by stepFrame */
         procFrame = stepFrame;
         restFrame -= stepFrame;
      }
      /* calculate adjustment time for audio */
      adjustFrame = m_timer->getAdditionalFrame(procFrame);

       /* update motion */
       
       bool useGlobalPhysicsSimulation = false;

       for (i = 0; i < m_numModel; i++) {
          
         if (m_models[i].isEnable() == false) continue;

          useGlobalPhysicsSimulation = useGlobalPhysicsSimulation || m_models[i].usePhysicsSimulation() == 2;

          /* update motion speed */
         if (m_models[i].getMotionManager()->updateMotionSpeedRate(procFrame + adjustFrame)) {
            /* search event in motion */
            for (motionPlayer = m_models[i].getMotionManager()->getMotionPlayerList(); motionPlayer; motionPlayer = motionPlayer->next) {
               if (motionPlayer->accelerationStatusFlag == ACCELERATION_STATUS_ENDED) {
                  /* send message */
                  sendMessage(MMDAGENT_EVENT_MOTIONACCELERATE, "%s|%s", m_models[i].getAlias(), motionPlayer->name);
               }
            }
         }

         /* look through the last motion status to check if the next motion update needs physics reset */
         for (motionPlayer = m_models[i].getMotionManager()->getMotionPlayerList(); motionPlayer; motionPlayer = motionPlayer->next) {
            if (motionPlayer->statusFlag == MOTION_STATUS_DELETED || motionPlayer->statusFlag == MOTION_STATUS_LOOPED) {
                if (motionPlayer->enableSmooth == false || true) {
                  m_models[i].skipNextSimulation();
                }
            }
         }

         /* update root bone */
         m_models[i].updateRootBone();
         if (m_models[i].updateMotion(procFrame + adjustFrame)) {
            /* search end of motion */
            for (motionPlayer = m_models[i].getMotionManager()->getMotionPlayerList(); motionPlayer; motionPlayer = motionPlayer->next) {
               if (motionPlayer->statusFlag == MOTION_STATUS_DELETED) {
                  /* send message */
                  if (MMDAgent_strequal(motionPlayer->name, LIPSYNC_MOTIONNAME))
                     sendMessage(MMDAGENT_EVENT_LIPSYNCSTOP, "%s", m_models[i].getAlias());
                  else {
                     sendMessage(MMDAGENT_EVENT_MOTIONDELETE, "%s|%s", m_models[i].getAlias(), motionPlayer->name);
                  }
                  /* unload from motion stocker */
                  m_motion->unload(motionPlayer->vmd);
               }
            }
         } else {
             motionActive = true;
         }
           
         /* update alpha for appear or disappear */
         if (m_models[i].updateAlpha(procFrame + adjustFrame))
            removeRelatedModels(i); /* remove model and accessories */
          
          if (m_enablePhysicsSimulation) {
              if (m_models[i].usePhysicsSimulation() == 1) {
                  // local physics instance, ignore colligions
                  m_models[i].updateBullet((float) procFrame);
              }
          }

      }
      /* execute plugin */
      //m_plugin->execUpdate(this, procFrame + adjustFrame);
       
       /* update bullet physics, check the colligions */
       if (m_enablePhysicsSimulation && useGlobalPhysicsSimulation) {
           if (m_bullet) {
               m_bullet->update((float) procFrame);
           }
       }

      /* camera motion */
      if (m_cameraControlled == true) {
         if (m_camera.advance(procFrame + adjustFrame) == true && m_camera.getCurrentFrame() == m_camera.getPreviousFrame()) {
            /* reached end */
            m_cameraControlled = false;
         }
         m_render->setCameraFromController(&m_camera);
      }
   }
   /* update after simulation */
   for (i = 0; i < m_numModel; i++)
      if (m_models[i].isEnable() == true) {
         m_models[i].updateAfterSimulation(m_enablePhysicsSimulation);
         m_models[i].updateSkin();
      }

   /* calculate rendering range for shadow mapping */
   if(m_option->getUseShadowMapping())
      m_render->updateDepthTextureViewParam(m_models, m_numModel);

   /* decrement mouse active time */
   m_screen->updateMouseActiveTime(intervalFrame);

   return motionActive;
}

/* MMDAgent::renderScene: render the whole scene */
bool MMDAgent::renderScene()
{
   int i;
   btVector3 pos;

#ifndef MMDAGENT_DONTRENDERDEBUG
   char buff[MMDAGENT_MAXBUFLEN];
   static const GLfloat vertices[8][3] = {
      { -0.5f, -0.5f, 0.5f},
      { 0.5f, -0.5f, 0.5f},
      { 0.5f, 0.5f, 0.5f},
      { -0.5f, 0.5f, 0.5f},
      { 0.5f, -0.5f, -0.5f},
      { -0.5f, -0.5f, -0.5f},
      { -0.5f, 0.5f, -0.5f},
      { 0.5f, 0.5f, -0.5f}
   };
#endif /* !MMDAGENT_DONTRENDERDEBUG */

   if(m_enable == false)
      return false;

   /* update model position and rotation */
   m_fps = m_timer->getFps();

    //NSLog(@"xxx MMDAgent::renderScene fps = [%f]", fps);

   for (i = 0; i < m_numModel; i++) {
      if (m_models[i].isEnable() == true) {
         if (m_models[i].updateModelRootOffset(m_fps))
            sendMessage(MMDAGENT_EVENT_MOVESTOP, "%s", m_models[i].getAlias());
         if (m_models[i].updateModelRootRotation(m_fps)) {
            if (m_models[i].isTurning()) {
               sendMessage(MMDAGENT_EVENT_TURNSTOP, "%s", m_models[i].getAlias());
               m_models[i].setTurningFlag(false);
            } else {
               sendMessage(MMDAGENT_EVENT_ROTATESTOP, "%s", m_models[i].getAlias());
            }
         }
      }
   }

   /* update rendering order */
   m_render->getRenderOrder(m_renderOrder, m_models, m_numModel);

   /* render scene */
   m_render->render(m_models, m_renderOrder, m_numModel, m_stage, m_option->getUseMMDLikeCartoon(), m_option->getUseCartoonRendering(), m_option->getLightIntensity(), m_option->getLightDirection(), m_option->getLightColor(), m_option->getUseShadowMapping(), m_option->getShadowMappingTextureSize(), m_option->getShadowMappingLightFirst(), m_option->getShadowMappingSelfDensity(), m_option->getShadowMappingFloorDensity(), m_render->isViewMoving() ? m_timer->ellapsed() : 0.0);

   /* show debug display */
   if (m_dispModelDebug)
      for (i = 0; i < m_numModel; i++)
         if (m_models[m_renderOrder[i]].isEnable() == true)
            m_models[m_renderOrder[i]].renderDebug(m_text);

   /* show bullet body */
   if (m_dispBulletBodyFlag)
      m_bullet->debugDisplay();

   /* show log window */
   if (m_dispLog)
      m_logger->render();

   /* count fps */
   m_timer->countFrame();

#ifndef MMDAGENT_DONTRENDERDEBUG
   /* show fps */
   if (m_option->getShowFps()) {
      if(m_screen->getNumMultiSampling() > 0)
         sprintf(buff, "%5.1ffps %dx MSAA", m_timer->getFps(), m_screen->getNumMultiSampling());
      else
         sprintf(buff, "%5.1ffps No AA", m_timer->getFps());
      glDisable(GL_LIGHTING);
      glColor4f(1.0f, 0.0f, 0.0f, 1.0f);
      glPushMatrix();
       
      //glRasterPos3fv(m_option->getFpsPosition());

       m_text->drawAsciiStringBitmap(buff);
      glPopMatrix();
      glEnable(GL_LIGHTING);
   }

   /* show holding message */
   if (m_holdMotion) {
      sprintf(buff, "<<HOLD>>");
      glDisable(GL_LIGHTING);
      glColor4f(0.0f, 1.0f, 0.0f, 1.0f);
      glPushMatrix();
      //glWindowPos2f(m_render->getWidth() / 2 - 30.0f, m_render->getHeight() - 50.0f);
      m_text->drawAsciiStringBitmap(buff);
      glPopMatrix();
      glEnable(GL_LIGHTING);
   }

   if (m_dispLog) {
      /* show adjustment time for audio */
      if (m_option->getMotionAdjustTime() > 0.0f)
         sprintf(buff, "%d msec advance (current motion: %+d)", (int) (m_option->getMotionAdjustTime() * 1000.0f + 0.5f), (int)(m_timer->getCurrentAdjustmentFrame() * 1000.0 / 30.0 + 0.5f));
      else if (m_option->getMotionAdjustTime() < 0.0f)
         sprintf(buff, "%d msec delay (current motion: %+d)", (int) (m_option->getMotionAdjustTime() * 1000.0f - 0.5f), (int)(m_timer->getCurrentAdjustmentFrame() * 1000.0 / 30.0 - 0.5f));
      else
         sprintf(buff, "%d msec (current motion: %+d)", (int) (m_option->getMotionAdjustTime() * 1000.0f + 0.5f), (int)(m_timer->getCurrentAdjustmentFrame() * 1000.0 / 30.0 + 0.5f));
      glDisable(GL_LIGHTING);
      //glColor3f(1.0f, 0.0f, 0.0f);
       glColor4f(1.0f, 0.0f, 0.0f, 1.0f);
      glPushMatrix();
      //glWindowPos2f(5.0f, 5.0f + 18.0f * 2);
      m_text->drawAsciiStringBitmap(buff);
      glPopMatrix();
      glEnable(GL_LIGHTING);
      /* show model position */
      strcpy(buff, "");
      for (i = 0; i < m_numModel; i++) {
         if (m_models[i].isEnable() == true) {
            m_models[i].getCurrentPosition(&pos);
            if(MMDAgent_strlen(buff) <= 0)
               sprintf(buff, "(%.2f, %.2f, %.2f)", pos.x(), pos.y(), pos.z());
            else
               sprintf(buff, "%s (%.2f, %.2f, %.2f)", buff, pos.x(), pos.y(), pos.z());
         }
      }
      if (MMDAgent_strlen(buff) > 0) {
         glDisable(GL_LIGHTING);
         //glColor3f(1.0f, 0.0f, 0.0f);
          glColor4f(1.0f, 0.0f, 0.0f, 1.0f);
         glPushMatrix();
         //glWindowPos2f(5.0f, 5.0f);
         m_text->drawAsciiStringBitmap(buff);
         glPopMatrix();
         glEnable(GL_LIGHTING);
      }
      /* show camera parameters */
      m_render->getInfoString(buff);
      glDisable(GL_LIGHTING);
      //glColor3f(1.0f, 1.0f, 0.0f);
      glPushMatrix();
      //glWindowPos2f(5.0f, 5.0f + 18.0f);
      m_text->drawAsciiStringBitmap(buff);
      glPopMatrix();
      /* show camera eye point */
      glPushMatrix();
      m_render->getCurrentViewCenterPos(&pos);
      glTranslatef(pos.x(), pos.y(), pos.z());
      glColor4f(0.9f, 0.4f, 0.0f, 1.0f);
       /*****
      glScaled(0.3, 0.3, 0.3);
      glBegin(GL_POLYGON);
      glVertex3fv(vertices[0]);
      glVertex3fv(vertices[1]);
      glVertex3fv(vertices[2]);
      glVertex3fv(vertices[3]);
      glEnd();
      glBegin(GL_POLYGON);
      glVertex3fv(vertices[4]);
      glVertex3fv(vertices[5]);
      glVertex3fv(vertices[6]);
      glVertex3fv(vertices[7]);
      glEnd();
      glBegin(GL_POLYGON);
      glVertex3fv(vertices[1]);
      glVertex3fv(vertices[4]);
      glVertex3fv(vertices[7]);
      glVertex3fv(vertices[2]);
      glEnd();
      glBegin(GL_POLYGON);
      glVertex3fv(vertices[5]);
      glVertex3fv(vertices[0]);
      glVertex3fv(vertices[3]);
      glVertex3fv(vertices[6]);
      glEnd();
      glBegin(GL_POLYGON);
      glVertex3fv(vertices[3]);
      glVertex3fv(vertices[2]);
      glVertex3fv(vertices[7]);
      glVertex3fv(vertices[6]);
      glEnd();
      glBegin(GL_POLYGON);
      glVertex3fv(vertices[1]);
      glVertex3fv(vertices[0]);
      glVertex3fv(vertices[5]);
      glVertex3fv(vertices[4]);
      glEnd();
       *******/
       
      glPopMatrix();
      glEnable(GL_LIGHTING);
   }

   /* show model comments and error */
   for (i = 0; i < m_numModel; i++) {
      if (m_models[m_renderOrder[i]].isEnable() == true) {
         glPushMatrix();
         m_models[m_renderOrder[i]].renderComment(m_text);
         m_models[m_renderOrder[i]].renderError(m_text);
         glPopMatrix();
      }
   }
#endif /* !MMDAGENT_DONTRENDERDEBUG */

   /* swap buffer */
   m_screen->swapBuffers();

   return true;
}

// get frame per second
float MMDAgent::getFPS()
{
    m_fps = m_timer->getFps();
    return m_fps;
}

/* MMDAgent::drawString: draw string */
void MMDAgent::drawString(const char *str)
{
   if(m_enable == false)
      return;

   m_text->drawString(str);
}

/* resetAdjustmentTimer: reset adjustment timer */
void MMDAgent::resetAdjustmentTimer()
{
   if(m_enable == false)
      return;

   m_timer->setTargetAdjustmentFrame((double) m_option->getMotionAdjustTime() * 30.0f);
   m_timer->startAdjustment();
}

/* MMDAgent::sendMessage: send message to grobal message queue */
void MMDAgent::sendMessage(const char * type, const char * format, ...)
{
   va_list argv;
   char buf[MMDAGENT_MAXBUFLEN];

   if(m_enable == false)
      return;

   if (format == NULL) {
      m_message->enqueueMessage(type, NULL);
      return;
   }

   va_start(argv, format);
   vsprintf(buf, format, argv);
   va_end(argv);

   m_message->enqueueMessage(type, buf);
}

/* MMDAgent::sendLogString: show log string */
void MMDAgent::sendLogString(const char * format, ...)
{
   va_list argv;
   char buf[MMDAGENT_MAXBUFLEN];

   if(m_enable == false)
      return;

   if (MMDAgent_strlen(format) <= 0)
      return;

   va_start(argv, format);
   vsprintf(buf, format, argv);
   va_end(argv);

   m_message->enqueueLogString(buf);
}

/* MMDAgent::findModelAlias: find a model with the specified alias */
int MMDAgent::findModelAlias(const char * alias)
{
   int i;

   if(m_enable == false)
      return 0;

   if(alias)
      for (i = 0; i < m_numModel; i++)
         if (m_models[i].isEnable() && MMDAgent_strequal(m_models[i].getAlias(), alias))
            return i;

   return -1;
}

/* MMDAgent::getMoelList: get model list */
PMDObject *MMDAgent::getModelList()
{
   if(m_enable == false)
      return NULL;

   return m_models;
}

/* MMDAgent::getNumModel: get number of models */
short MMDAgent::getNumModel()
{
   if(m_enable == false)
      return 0;

   return m_numModel;
}

/* MMDAgent::getMousePosition:: get mouse position */
void MMDAgent::getMousePosition(int *x, int *y)
{
   if(m_enable == false)
      return;

   *x = m_mousePosX;
   *y = m_mousePosY;
}

/* MMDAgent::getScreenPointPosition: convert screen position to object position */
void MMDAgent::getScreenPointPosition(btVector3 * dst, btVector3 * src)
{
   if(m_enable == false)
      return;

   m_render->getScreenPointPosition(dst, src);
}

/* MMDAgent::getWindowSize: get window size */
void MMDAgent::getWindowSize(int *w, int *h)
{
   int *size;

   if(m_enable == false)
      return;

   size = m_option->getWindowSize();
   *w = size[0];
   *h = size[1];
}

/* MMDAgent::getConfigFileName: get config file name for plugin */
char *MMDAgent::getConfigFileName()
{
   if(m_enable == false)
      return NULL;

   return m_configFileName;
}

/* MMDAgent::getConfigDirName: get directory of config file for plugin */
char *MMDAgent::getConfigDirName()
{
   if(m_enable == false)
      return NULL;

   return m_configDirName;
}

/* MMDAgent::getAppDirName: get application directory name for plugin */
char *MMDAgent::getAppDirName()
{
   if(m_enable == false)
      return NULL;

   return m_appDirName;
}

/* MMDAgent::procWindowDestroyMessage: process window destroy message */
void MMDAgent::procWindowDestroyMessage()
{
   if(m_enable == false)
      return;

   //if(m_plugin) m_plugin->execAppEnd(this);

    clear();
}

/* MMDAgent::procMouseLeftButtonDoubleClickMessage: process mouse left button double click message */
void MMDAgent::procMouseLeftButtonDoubleClickMessage(int x, int y)
{
   if(m_enable == false)
      return;

   /* double click */
   m_mousePosX = x;
   m_mousePosY = y;
   /* store model ID */
   m_selectedModel = m_render->pickModel(m_models, m_numModel, x, y, NULL);
   /* make model highlight */
   setHighLight(m_selectedModel);
   m_doubleClicked = true;
}

/* MMDAgent::procMouseLeftButtonDownMessage: process mouse left button down message */
void MMDAgent::procMouseLeftButtonDownMessage(int x, int y, bool withCtrl, bool withShift)
{
   if(m_enable == false)
      return;

   /* start hold */
   m_mousePosX = x;
   m_mousePosY = y;
   m_leftButtonPressed = true;
   m_doubleClicked = false;
   /* store model ID */
   m_selectedModel = m_render->pickModel(m_models, m_numModel, x, y, NULL);
   if (withCtrl == true && withShift == false) /* with Ctrl-key */
      setHighLight(m_selectedModel);
}

/* MMDAgent::procMouseLeftButtonUpMessage: process mouse left button up message */
void MMDAgent::procMouseLeftButtonUpMessage()
{
   if(m_enable == false)
      return;

   /* if highlight, trun off */
   if (!m_doubleClicked)
      setHighLight(-1);
   /* end of hold */
   m_leftButtonPressed = false;
}

/* MMDAgent::procMouseWheelMessage: process mouse wheel message */
void MMDAgent::procMouseWheelMessage(bool zoomup, bool withCtrl, bool withShift)
{
   float tmp1, tmp2;

   if(m_enable == false)
      return;

   if (withCtrl && withShift) {
      /* move camera fovy */
      tmp1 = m_option->getFovyStep();
      tmp2 = m_render->getFovy();
      if (tmp1 != 0.0) {
         if (zoomup)
            tmp2 -= tmp1;
         else
            tmp2 += tmp1;
         m_render->setFovy(tmp2);
      }
   } else {
      /* move camera distance */
      tmp1 = m_option->getDistanceStep();
      tmp2 = m_render->getDistance();
      if (withCtrl) /* faster */
         tmp1 = tmp1 * 5.0f;
      else if (withShift) /* slower */
         tmp1 = tmp1 * 0.2f;
      if (tmp1 != 0.0) {
         if (zoomup)
            tmp2 -= tmp1;
         else
            tmp2 += tmp1;
         m_render->setDistance(tmp2);
      }
   }
}

/* MMDAgent::procMousePosMessage: process mouse position message */
void MMDAgent::procMousePosMessage(int x, int y, bool withCtrl, bool withShift)
{
   float *f;
   int r1, r2;
   btVector3 v;
   btMatrix3x3 bm;
   btTransform tr;
   float factor;

   if(m_enable == false)
      return;

   /* store Ctrl-key and Shift-key state for drag and drop */
   m_keyCtrl = withCtrl;
   m_keyShift = withShift;
   /* left-button is dragged in window */
   if (m_leftButtonPressed) {
      r1 = x;
      r2 = y;
      r1 -= m_mousePosX;
      r2 -= m_mousePosY;
      if (r1 > 32767) r1 -= 65536;
      if (r1 < -32768) r1 += 65536;
      if (r2 > 32767) r2 -= 65536;
      if (r2 < -32768) r2 += 65536;
      factor = fabs(m_render->getDistance());
      if (factor < 10.0f) factor = 10.0f;
      if (withShift && withCtrl && m_selectedModel == -1) {
         /* if Shift- and Ctrl-key, and no model is pointed, rotate light direction */
         f = m_option->getLightDirection();
         v = btVector3(btScalar(f[0]), btScalar(f[1]), btScalar(f[2]));
         bm = btMatrix3x3(btQuaternion(btScalar(0.0f), btScalar(r2 * 0.1f * MMDFILES_RAD(m_option->getRotateStep())), btScalar(0.0f)) * btQuaternion(btScalar(r1 * 0.1f * MMDFILES_RAD(m_option->getRotateStep())), btScalar(0.0f), btScalar(0.0f)));
         v = bm * v;
         changeLightDirection(v.x(), v.y(), v.z());
      } else if (withCtrl) {
         /* if Ctrl-key and model is pointed, move the model */
         if (m_selectedModel != -1) {
            setHighLight(m_selectedModel);
            m_models[m_selectedModel].getTargetPosition(&v);
            if (withShift) {
               /* with Shift-key, move on XY (coronal) plane */
               v.setX(btScalar(v.x() + r1 * 0.001f * m_option->getTranslateStep() * factor));
               v.setY(btScalar(v.y() - r2 * 0.001f * m_option->getTranslateStep() * factor));
            } else {
               /* else, move on XZ (axial) plane */
               v.setX(btScalar(v.x() + r1 * 0.001f * m_option->getTranslateStep() * factor));
               v.setZ(btScalar(v.z() + r2 * 0.001f * m_option->getTranslateStep() * factor));
            }
            m_models[m_selectedModel].setPosition(&v);
            m_models[m_selectedModel].setMoveSpeed(-1.0f);
         }
      } else if (withShift) {
         /* if Shift-key, translate display */
         v = btVector3(btScalar(r1 * 0.0005f * factor), btScalar(-r2 * 0.0005f * factor), btScalar(0.0f));
         m_render->getCurrentViewTransform(&tr);
         tr.setOrigin(btVector3(btScalar(0.0f), btScalar(0.0f), btScalar(0.0f)));
         v = tr.inverse() * v;
         m_render->translate(-v.x(), -v.y(), -v.z());
      } else {
         /* if no key, rotate display */
         m_render->rotate(r2 * 0.1f * m_option->getRotateStep(), r1 * 0.1f * m_option->getRotateStep(), 0.0f);
      }
   } else if (m_mousePosX != x || m_mousePosY != y) {
      /* set mouse enable timer */
      m_screen->setMouseActiveTime(45.0f);
   }
   m_mousePosX = x;
   m_mousePosY = y;
}

/* MMDAgent::procMouseRightButtonDownMessage: process mouse right button down message */
void MMDAgent::procMouseRightButtonDownMessage()
{
   if(m_enable == false)
      return;

   m_screen->setMouseActiveTime(45.0f);
}

/* MMDAgent::procFullScreenMessage: process full screen message */
void MMDAgent::procFullScreenMessage()
{
   if(m_enable == false)
      return;

   if (m_option->getFullScreen() == true) {
      m_screen->exitFullScreen();
      m_option->setFullScreen(false);
   } else {
      m_screen->setFullScreen();
      m_option->setFullScreen(true);
   }
}

/* MMDAgent::procInfoStringMessage: process information string message */
void MMDAgent::procInfoStringMessage()
{
   if(m_enable == false)
      return;

   if(m_option->getShowFps() == true)
      m_option->setShowFps(false);
   else
      m_option->setShowFps(true);
}

/* MMDAgent::procVSyncMessage: process vsync message */
void MMDAgent::procVSyncMessage()
{
   if(m_enable == false)
      return;

   m_screen->toggleVSync();
}

/* MMDAgent::procShadowMappingMessage: process shadow mapping message */
void MMDAgent::procShadowMappingMessage()
{
   if(m_enable == false)
      return;

   if(m_option->getUseShadowMapping() == true) {
      m_option->setUseShadowMapping(false);
   } else {
      m_option->setUseShadowMapping(true);
   }
   m_render->setShadowMapping(m_option->getUseShadowMapping(), m_option->getShadowMappingTextureSize(), m_option->getShadowMappingLightFirst());
}

/* MMDAgent::procShadowMappingOrderMessage: process shadow mapping order message */
void MMDAgent::procShadowMappingOrderMessage()
{
   if(m_enable == false)
      return;

   if(m_option->getShadowMappingLightFirst() == true)
      m_option->setShadowMappingLightFirst(false);
   else
      m_option->setShadowMappingLightFirst(true);
   m_render->setShadowMapping(m_option->getUseShadowMapping(), m_option->getShadowMappingTextureSize(), m_option->getShadowMappingLightFirst());
}

/* MMDAgent::procDisplayRigidBodyMessage: process display rigid body message */
void MMDAgent::procDisplayRigidBodyMessage()
{
   if(m_enable == false)
      return;

   m_dispBulletBodyFlag = !m_dispBulletBodyFlag;
}

/* MMDAnget::procDisplayWireMessage: process display wire message */
void MMDAgent::procDisplayWireMessage()
{
#ifndef MMDAGENT_DONTRENDERDEBUG
   //GLint polygonMode[2];

   if(m_enable == false)
      return;

    /*******
   glGetIntegerv(GL_POLYGON_MODE, polygonMode);
   if (polygonMode[1] == GL_LINE)
      glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
   else
      glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
     ********/
    
#endif /* !MMDAGENT_DONTRENDERDEBUG */
}

/* MMDAgent::procDisplayBoneMessage: process display bone message */
void MMDAgent::procDisplayBoneMessage()
{
   if(m_enable == false)
      return;

   m_dispModelDebug = !m_dispModelDebug;
}

/* MMDAgent::procCartoonEdgeMessage: process cartoon edge message */
void MMDAgent::procCartoonEdgeMessage(bool plus)
{
   int i;

   if(m_enable == false)
      return;

   if(plus)
      m_option->setCartoonEdgeWidth(m_option->getCartoonEdgeWidth() * m_option->getCartoonEdgeStep());
   else
      m_option->setCartoonEdgeWidth(m_option->getCartoonEdgeWidth() / m_option->getCartoonEdgeStep());
   for (i = 0; i < m_numModel; i++)
      m_models[i].getPMDModel()->setEdgeThin(m_option->getCartoonEdgeWidth());
}

/* MMDAgent::procTimeAdjustMessage: process time adjust message */
void MMDAgent::procTimeAdjustMessage(bool plus)
{
   if(m_enable == false)
      return;

   if(plus)
      m_option->setMotionAdjustTime(m_option->getMotionAdjustTime() + 0.01f);
   else
      m_option->setMotionAdjustTime(m_option->getMotionAdjustTime() - 0.01f);
   m_timer->setTargetAdjustmentFrame(m_option->getMotionAdjustTime() * 30.0);
}

/* MMDAgent::procHorizontalRotateMessage: process horizontal rotate message */
void MMDAgent::procHorizontalRotateMessage(bool right)
{
   if(m_enable == false)
      return;

   if(right)
      m_render->rotate(0.0f, m_option->getRotateStep(), 0.0f);
   else
      m_render->rotate(0.0f, -m_option->getRotateStep(), 0.0f);
}

/* MMDAgent::procVerticalRotateMessage: process vertical rotate message */
void MMDAgent::procVerticalRotateMessage(bool up)
{
   if(m_enable == false)
      return;

   if(up)
      m_render->rotate(-m_option->getRotateStep(), 0.0f, 0.0f);
   else
      m_render->rotate(m_option->getRotateStep(), 0.0f, 0.0f);
}

/* MMDAgent::procHorizontalMoveMessage: process horizontal move message */
void MMDAgent::procHorizontalMoveMessage(bool right)
{
   if(m_enable == false)
      return;

   if(right)
      m_render->translate(m_option->getTranslateStep(), 0.0f, 0.0f);
   else
      m_render->translate(-m_option->getTranslateStep(), 0.0f, 0.0f);
}

/* MMDAgent::procVerticalMoveMessage: process vertical move message */
void MMDAgent::procVerticalMoveMessage(bool up)
{
   if(m_enable == false)
      return;

   if(up)
      m_render->translate(0.0f, m_option->getTranslateStep(), 0.0f);
   else
      m_render->translate(0.0f, -m_option->getTranslateStep(), 0.0f);
}

/* MMDAgent::procDeleteModelMessage: process delete model message */
void MMDAgent::procDeleteModelMessage()
{
   if(m_enable == false)
      return;

   if (m_doubleClicked && m_selectedModel != -1) {
      deleteModel(m_models[m_selectedModel].getAlias());
      m_doubleClicked = false;
   }
}

/* MMDAgent::procPhysicsMessage: process physics message */
void MMDAgent::procPhysicsMessage(bool enable)
{
   int i;

   if(m_enable == false)
      return;

   m_enablePhysicsSimulation = enable;
    for (i = 0; i < m_numModel; i++) {
        m_models[i].getPMDModel()->setPhysicsControl(m_enablePhysicsSimulation);
        m_models[i].getPMDModel()->setUsePhysicsSimulation(m_enablePhysicsSimulation);
        m_models[i].setUsePhysicsSimulation(2);
    }
}

/* MMDAgent::procDisplayLogMessage: process display log message */
void MMDAgent::procDisplayLogMessage()
{
   if(m_enable == false)
      return;

   m_dispLog = !m_dispLog;
}

/* MMDAgent::procHoldMessage: process hold message */
void MMDAgent::procHoldMessage(bool hold)
{
   if(m_enable == false)
      return;

   m_holdMotion = hold;
}

/* MMDAgent::procWindowSizeMessage: process window size message */
void MMDAgent::procWindowSizeMessage(int x, int y)
{
   int size[2];

   if(m_enable == false)
      return;

   size[0] = x;
   size[1] = y;
   m_option->setWindowSize(size);

   m_render->setSize(x, y);
}

/* MMDAgent::procKeyMessage: process key message */
void MMDAgent::procKeyMessage(char c)
{
   if(m_enable == false)
      return;

   sendMessage(MMDAGENT_EVENT_KEY, "%C", c);
}

/* MMDAgent::procReceivedMessage: process received message */
void MMDAgent::procReceivedMessage(const char *type, const char *value)
{
   static char buff[MMDAGENT_MAXBUFLEN];    /* static buffer */
   static char *argv[MMDAGENT_MAXNCOMMAND];
   int num = 0;

   char *str1, *str2, *str3;
   bool bool1, bool2, bool3, bool4;
   float f;
   btVector3 pos;
   btQuaternion rot;
   float fvec[3];

   if(m_enable == false)
      return;

   if(MMDAgent_strlen(type) <= 0)
      return;

   //if(m_plugin)  m_plugin->execProcMessage(this, type, value);

   /* divide string into arguments */
   if (MMDAgent_strlen(value) <= 0) {
      m_logger->log("%s", type);
   } else {
      m_logger->log("%s|%s", type, value);
      strncpy(buff, value, MMDAGENT_MAXBUFLEN - 1);
      buff[MMDAGENT_MAXBUFLEN - 1] = '\0';
      for (str1 = MMDAgent_strtok(buff, "|", &str2); str1; str1 = MMDAgent_strtok(NULL, "|", &str2)) {
         if (num >= MMDAGENT_MAXNCOMMAND) {
            m_logger->log("Error: %s: number of arguments exceed the limit.", type);
            break;
         }
         argv[num] = str1;
         num++;
      }
   }

   if (MMDAgent_strequal(type, MMDAGENT_COMMAND_MODELADD)) {
      bool1 = true;
      str1 = NULL;
      str2 = NULL;
      if (num < 2 || num > 7) {
         m_logger->log("Error: %s: number of arguments should be 2-7.", type);
         return;
      }
      if (num >= 3) {
         if (MMDAgent_str2pos(argv[2], &pos) == false) {
            m_logger->log("Error: %s: %s is not a position string.", type, argv[2]);
            return;
         }
      } else {
         pos = btVector3(btScalar(0.0f), btScalar(0.0f), btScalar(0.0f));
      }
      if (num >= 4) {
         if (MMDAgent_str2rot(argv[3], &rot) == false) {
            m_logger->log("Error: %s: %s is not a rotation string.", type, argv[3]);
            return;
         }
      } else {
         rot.setEulerZYX(btScalar(0.0f), btScalar(0.0f), btScalar(0.0f));
      }
      if(num >= 5) {
         if(MMDAgent_strequal(argv[4], "ON")) {
            bool1 = true;
         } else if(MMDAgent_strequal(argv[4], "OFF")) {
            bool1 = false;
         } else {
            m_logger->log("Error: %s: 5th argument should be \"ON\" or \"OFF\".", type);
            return;
         }
      }
      if (num >= 6) {
         str1 = argv[5];
      }
      if (num >= 7) {
         str2 = argv[6];
      }
       
       ;//addModel(argv[0], argv[1], &pos, &rot, bool1, str1, str2, true, 2);
       
   } else if (MMDAgent_strequal(type, MMDAGENT_COMMAND_MODELCHANGE)) {
      /* change model */
      if (num != 2) {
         m_logger->log("Error: %s: number of arguments should be 2.", type);
         return;
      }
       ;//changeModel(argv[0], argv[1]);
   } else if (MMDAgent_strequal(type, MMDAGENT_COMMAND_MODELDELETE)) {
      /* delete model */
      if (num != 1) {
         m_logger->log("Error: %s: number of arguments should be 1.", type);
         return;
      }
      deleteModel(argv[0]);
   } else if (MMDAgent_strequal(type, MMDAGENT_COMMAND_MOTIONADD)) {
      /* add motion */
      bool1 = true; /* full */
      bool2 = true; /* once */
      bool3 = true; /* enableSmooth */
      bool4 = true; /* enableRePos */
      f = MOTIONMANAGER_DEFAULTPRIORITY; /* priority */
      if (num < 3 || num > 8) {
         m_logger->log("Error: %s: number of arguments should be 4-7.", type);
         return;
      }
      if (num >= 4) {
         if (MMDAgent_strequal(argv[3], "FULL")) {
            bool1 = true;
         } else if (MMDAgent_strequal(argv[3], "PART")) {
            bool1 = false;
         } else {
            m_logger->log("Error: %s: 4th argument should be \"FULL\" or \"PART\".", type);
            return;
         }
      }
      if (num >= 5) {
         if (MMDAgent_strequal(argv[4], "ONCE")) {
            bool2 = true;
         } else if (MMDAgent_strequal(argv[4], "LOOP")) {
            bool2 = false;
         } else {
            m_logger->log("Error: %s: 5th argument should be \"ONCE\" or \"LOOP\".", type);
            return;
         }
      }
      if (num >= 6) {
         if (MMDAgent_strequal(argv[5], "ON")) {
            bool3 = true;
         } else if (MMDAgent_strequal(argv[5], "OFF")) {
            bool3 = false;
         } else {
            m_logger->log("Error: %s: 6th argument should be \"ON\" or \"OFF\".", type);
            return;
         }
      }
      if (num >= 7) {
         if (MMDAgent_strequal(argv[6], "ON")) {
            bool4 = true;
         } else if (MMDAgent_strequal(argv[6], "OFF")) {
            bool4 = false;
         } else {
            m_logger->log("Error: %s: 7th argument should be \"ON\" or \"OFF\".", type);
            return;
         }
      }
      if (num >= 8) {
         f = MMDAgent_str2float(argv[7]);
      }
       ;//addMotion(argv[0], argv[1], argv[2], bool1, bool2, bool3, bool4, f);
   } else if (MMDAgent_strequal(type, MMDAGENT_COMMAND_MOTIONCHANGE)) {
      /* change motion */
      if (num != 3) {
         m_logger->log("Error: %s: number of arguments should be 3.", type);
         return;
      }
       ;//changeMotion(argv[0], argv[1], argv[2]);
   } else if (MMDAgent_strequal(type, MMDAGENT_COMMAND_MOTIONACCELERATE)) {
      /* accelerate motion */
      fvec[0] = 0.0f;  /* speed */
      fvec[1] = 0.0f;  /* duration time in sec */
      fvec[2] = -1.0f; /* specified frame index for end of acceleration */
      if (num < 3 || num > 5) {
         m_logger->log("Error: %s: number of arguments should be 3-5.", type);
         return;
      }
      if(num >= 3)
         fvec[0] = MMDAgent_str2float(argv[2]);
      if (num >= 4)
         fvec[1] = MMDAgent_str2float(argv[3]);
      if (num >= 5)
         fvec[2] = MMDAgent_str2float(argv[4]);
      accelerateMotion(argv[0], argv[1], fvec[0], fvec[1], fvec[2]);
   } else if (MMDAgent_strequal(type, MMDAGENT_COMMAND_MOTIONDELETE)) {
      /* delete motion */
      if (num != 2) {
         m_logger->log("Error: %s: number of arguments should be 2.", type);
         return;
      }
      deleteMotion(argv[0], argv[1]);
   } else if (MMDAgent_strequal(type, MMDAGENT_COMMAND_MOVESTART)) {
      /* start moving */
      bool1 = false;
      f = -1.0;
      if (num < 2 || num > 4) {
         m_logger->log("Error: %s: number of arguments should be 2-4.", type);
         return;
      }
      if (MMDAgent_str2pos(argv[1], &pos) == false) {
         m_logger->log("Error: %s: %s is not a position string.", type, argv[1]);
         return;
      }
      if (num >= 3) {
         if (MMDAgent_strequal(argv[2], "LOCAL")) {
            bool1 = true;
         } else if (MMDAgent_strequal(argv[2], "GLOBAL")) {
            bool1 = false;
         } else {
            m_logger->log("Error: %s: 3rd argument should be \"GLOBAL\" or \"LOCAL\".", type);
            return;
         }
      }
      if (num >= 4)
         f = MMDAgent_str2float(argv[3]);
      startMove(argv[0], &pos, bool1, f);
   } else if (MMDAgent_strequal(type, MMDAGENT_COMMAND_MOVESTOP)) {
      /* stop moving */
      if (num != 1) {
         m_logger->log("Error: %s: number of arguments should be 1.", type);
         return;
      }
      stopMove(argv[0]);
   } else if (MMDAgent_strequal(type, MMDAGENT_COMMAND_ROTATESTART)) {
      /* start rotation */
      bool1 = false;
      f = -1.0;
      if (num < 2 || num > 4) {
         m_logger->log("Error: %s: number of arguments should be 2-4.", type);
         return;
      }
      if (MMDAgent_str2rot(argv[1], &rot) == false) {
         m_logger->log("Error: %s: %s is not a rotation string.", type, argv[1]);
         return;
      }
      if (num >= 3) {
         if (MMDAgent_strequal(argv[2], "LOCAL")) {
            bool1 = true;
         } else if (MMDAgent_strequal(argv[2], "GLOBAL")) {
            bool1 = false;
         } else {
            m_logger->log("Error: %s: 3rd argument should be \"GLOBAL\" or \"LOCAL\".", type);
            return;
         }
      }
      if (num >= 4)
         f = MMDAgent_str2float(argv[3]);
      startRotation(argv[0], &rot, bool1, f);
   } else if (MMDAgent_strequal(type, MMDAGENT_COMMAND_ROTATESTOP)) {
      /* stop rotation */
      if (num != 1) {
         m_logger->log("Error: %s: number of arguments should be 1.", type);
         return;
      }
      stopRotation(argv[0]);
   } else if (MMDAgent_strequal(type, MMDAGENT_COMMAND_TURNSTART)) {
      /* turn start */
      bool1 = false;
      f = -1.0;
      if (num < 2 || num > 4) {
         m_logger->log("Error: %s: number of arguments should be 2-4.", type);
         return;
      }
      if (MMDAgent_str2pos(argv[1], &pos) == false) {
         m_logger->log("Error: %s: %s is not a position string.", type, argv[1]);
         return;
      }
      if (num >= 3) {
         if (MMDAgent_strequal(argv[2], "LOCAL")) {
            bool1 = true;
         } else if (MMDAgent_strequal(argv[2], "GLOBAL")) {
            bool1 = false;
         } else {
            m_logger->log("Error: %s: 3rd argument should be \"GLOBAL\" or \"LOCAL\".", type);
            return;
         }
      }
      if (num >= 4)
         f = MMDAgent_str2float(argv[3]);
      startTurn(argv[0], &pos, bool1, f);
   } else if (MMDAgent_strequal(type, MMDAGENT_COMMAND_TURNSTOP)) {
      /* stop turn */
      if (num != 1) {
         m_logger->log("Error: %s: number of arguments should be 1.", type);
         return;
      }
      stopTurn(argv[0]);
   } else if (MMDAgent_strequal(type, MMDAGENT_COMMAND_STAGE)) {
      /* change stage */
      if (num != 1) {
         m_logger->log("Error: %s: number of arguments should be 1.", type);
         return;
      }
      /* pmd or bitmap */
      str1 = MMDAgent_strtok(argv[0], ",", &str3);
      str2 = MMDAgent_strtok(NULL, ",", &str3);
      if (str2 == NULL) {
          ;//setStage(str1);
      } else {
         setFloor(str1);
         setBackground(str2);
      }
   } else if (MMDAgent_strequal(type, MMDAGENT_COMMAND_CAMERA)) {
      /* camera */
      if((num < 4 || num > 5) && num != 1) {
         m_logger->log("Error: %s: number of arguments should be 1 or 4-5.", type);
         return;
      }
      if (num == 1) {
         changeCamera(argv[0], NULL, NULL, NULL, NULL);
      } else {
         changeCamera(argv[0], argv[1], argv[2], argv[3], (num == 5) ? argv[4] : NULL);
      }
   } else if (MMDAgent_strequal(type, MMDAGENT_COMMAND_LIGHTCOLOR)) {
      /* change light color */
      if (num != 1) {
         m_logger->log("Error: %s: number of arguments should be 1.", type);
         return;
      }
      if (MMDAgent_str2fvec(argv[0], fvec, 3) == false) {
         m_logger->log("Error: %s: \"%s\" is not RGB value.", type, argv[0]);
         return;
      }
      changeLightColor(fvec[0], fvec[1], fvec[2]);
   } else if (MMDAgent_strequal(type, MMDAGENT_COMMAND_LIGHTDIRECTION)) {
      /* change light direction */
      if (num != 1) {
         m_logger->log("Error: %s: number of arguments should be 1.", type);
         return;
      }
      if (MMDAgent_str2fvec(argv[0], fvec, 3) == false) {
         m_logger->log("Error: %s: \"%s\" is not XYZ value.", type, argv[0]);
         return;
      }
      changeLightDirection(fvec[0], fvec[1], fvec[2]);
   } else if (MMDAgent_strequal(type, MMDAGENT_COMMAND_LIPSYNCSTART)) {
      /* start lip sync */
      if (num != 2) {
         m_logger->log("Error: %s: number of arguments should be 2.", type);
         return;
      }
      startLipSync(argv[0], argv[1]);
   } else if (MMDAgent_strequal(type, MMDAGENT_COMMAND_LIPSYNCSTOP)) {
      /* stop lip sync */
      if (num != 1) {
         m_logger->log("Error: %s: number of arguments should be 1.", type);
         return;
      }
      stopLipSync(argv[0]);
   }
}

/* MMDAgent::procReceivedLogString: process log string */
void MMDAgent::procReceivedLogString(const char *log)
{
   if(m_enable == false)
      return;

   if (MMDAgent_strlen(log) <= 0)
      return;

   m_logger->log("Log: %s", log);
}

/* MMDAgent::procScrollLogMessage: process log scroll message */
void MMDAgent::procScrollLogMessage(bool up)
{
   int *size = m_option->getLogSize();

   m_logger->scroll((int) (size[1] * (up == true ? 0.5 : -0.5)));
}

/* MMDAgent::procDropFileMessage: process file drops message */
void MMDAgent::procDropFileMessage(ScenarioData *_scenarioData, int x, int y)
{
   int i;
   int dropAllowedModelID;
   int targetModelID;
    char *file = NULL;

   /* for motion */
   MotionPlayer *motionPlayer;

   if(m_enable == false) return;

   if(MMDAgent_strlen(file) <= 0) return;

    ScenarioData *scenarioData = _scenarioData;
    file = (char*) [[scenarioData getCurrentMotionPath] cStringUsingEncoding:NSUTF8StringEncoding];

   sendMessage(MMDAGENT_EVENT_DRAGANDDROP, "%s|%d|%d", file, x, y);

   if (MMDAgent_strtailmatch(file, ".vmd") || MMDAgent_strtailmatch(file, ".VMD")) {
      dropAllowedModelID = -1;
      targetModelID = -1;
      if (m_keyCtrl) {
         /* if Ctrl-key, start motion on all models */
         targetModelID = m_option->getMaxNumModel();
      } else if (m_doubleClicked && m_selectedModel != -1 && m_models[m_selectedModel].allowMotionFileDrop()) {
         targetModelID = m_selectedModel;
      } else {
         targetModelID = m_render->pickModel(m_models, m_numModel, x, y, &dropAllowedModelID); /* model ID in curpor position */
         if (targetModelID == -1)
            targetModelID = dropAllowedModelID;
      }
      if (targetModelID == -1) {
         m_logger->log("Warning: procDropFileMessage: there is no model at the point.");
      } else {
         if (m_keyShift) { /* if Shift-key, insert motion */
            if (targetModelID == m_option->getMaxNumModel()) {
               /* all model */
               for (i = 0; i < m_numModel; i++) {
                  if (m_models[i].isEnable() && m_models[i].allowMotionFileDrop())
                      ;//addMotion(m_models[i].getAlias(), NULL, file, false, true, true, true, MOTIONMANAGER_DEFAULTPRIORITY);
               }
            } else {
               /* target model */
               if (m_models[targetModelID].isEnable() && m_models[targetModelID].allowMotionFileDrop())
                   ;//addMotion(m_models[targetModelID].getAlias(), NULL, file, false, true, true, true, MOTIONMANAGER_DEFAULTPRIORITY);
               else
                  m_logger->log("Warning: procDropFileMessage: there is no model at the point.");
            }
         } else {
            /* change base motion */
            if (targetModelID == m_option->getMaxNumModel()) {
               /* all model */
               for (i = 0; i < m_numModel; i++) {
                  if (m_models[i].isEnable() && m_models[i].allowMotionFileDrop()) {
                     for (motionPlayer = m_models[i].getMotionManager()->getMotionPlayerList(); motionPlayer; motionPlayer = motionPlayer->next) {
                        if (motionPlayer->active && MMDAgent_strequal(motionPlayer->name, "base")) {
                            ;//changeMotion(m_models[i].getAlias(), "base", file); /* if 'base' motion is already used, change motion */
                           break;
                        }
                     }
                     if (!motionPlayer)
                         ;//addMotion(m_models[i].getAlias(), "base", file, true, false, true, true, MOTIONMANAGER_DEFAULTPRIORITY);
                  }
               }
            } else {
               /* target model */
               if(m_models[targetModelID].isEnable() && m_models[targetModelID].allowMotionFileDrop()) {
                  for (motionPlayer = m_models[targetModelID].getMotionManager()->getMotionPlayerList(); motionPlayer; motionPlayer = motionPlayer->next) {
                     if (motionPlayer->active && MMDAgent_strequal(motionPlayer->name, "base")) {
                         ;//changeMotion(m_models[targetModelID].getAlias(), "base", file); /* if 'base' motion is already used, change motion */
                        break;
                     }
                  }
                  if (!motionPlayer)
                      ;//addMotion(m_models[targetModelID].getAlias(), "base", file, true, false, true, true, MOTIONMANAGER_DEFAULTPRIORITY);
               } else {
                  m_logger->log("Warning: procDropFileMessage: there is no model at the point.");
               }
            }
         }
      }
   } else if (MMDAgent_strtailmatch(file, ".xpmd") || MMDAgent_strtailmatch(file, ".XPMD")) {
      /* load stage */
       ;//setStage(file);
   } else if (MMDAgent_strtailmatch(file, ".pmd") || MMDAgent_strtailmatch(file, ".PMD")) {
      /* drop model */
      if (m_keyCtrl) {
         /* if Ctrl-key, add model */
         
          ;//addModel(NULL, file, NULL, NULL, true, NULL, NULL, true, 2);
          
      } else {
         /* change model */
         if (m_doubleClicked && m_selectedModel != -1) /* already selected */
            targetModelID = m_selectedModel;
         else
            targetModelID = m_render->pickModel(m_models, m_numModel, x, y, &dropAllowedModelID);
         if (targetModelID == -1) {
            m_logger->log("Warning: procDropFileMessage: there is no model at the point.");
         } else {
             ;//changeModel(m_models[targetModelID].getAlias(), file);
         }
      }
   } else if (MMDAgent_strtailmatch(file, ".bmp") || MMDAgent_strtailmatch(file, ".tga") || MMDAgent_strtailmatch(file, ".png") || MMDAgent_strtailmatch(file, ".jpg") || MMDAgent_strtailmatch(file, ".jpeg") ||
              MMDAgent_strtailmatch(file, ".BMP") || MMDAgent_strtailmatch(file, ".TGA") || MMDAgent_strtailmatch(file, ".PNG") || MMDAgent_strtailmatch(file, ".JPG") || MMDAgent_strtailmatch(file, ".JPEG")) {
      if (m_keyCtrl)
         setFloor(file); /* change floor with Ctrl-key */
      else
         setBackground(file); /* change background without Ctrl-key */
   }
}
