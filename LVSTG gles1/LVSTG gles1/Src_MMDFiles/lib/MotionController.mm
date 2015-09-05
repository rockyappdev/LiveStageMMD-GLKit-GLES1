/* ----------------------------------------------------------------- */
/*           The Toolkit for Building Voice Interaction Systems      */
/*           "MMDAgent" developed by MMDAgent Project Team           */
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

#include "MMDFiles.h"

/* MotionController::calcBoneAt: calculate bone pos/rot at the given frame */
void MotionController::calcBoneAt(MotionControllerBoneElement *mc, float frameNow)
{
   BoneMotion *bm = mc->motion;
   float frame = frameNow;
   unsigned long k1, k2 = 0;
   unsigned long i;
   float time1;
   float time2;
   btVector3 pos1, pos2;
   btQuaternion rot1, rot2;
   BoneKeyFrame *keyFrameForInterpolation;
   float x, y, z, ww;
   float w;
   short idx;

   /* clamp frame to the defined last frame */
   if (frame > bm->keyFrameList[bm->numKeyFrame - 1].keyFrame)
      frame = bm->keyFrameList[bm->numKeyFrame - 1].keyFrame;

   /* find key frames between which the given frame exists */
   if (frame >= bm->keyFrameList[mc->lastKey].keyFrame) {
      /* start searching from last used key frame */
      for (i = mc->lastKey; i < bm->numKeyFrame; i++) {
         if (frame <= bm->keyFrameList[i].keyFrame) {
            k2 = i;
            break;
         }
      }
   } else {
      for (i = 0; i <= mc->lastKey && i < bm->numKeyFrame; i++) {
         if (frame <= bm->keyFrameList[i].keyFrame) {
            k2 = i;
            break;
         }
      }
   }

   /* bounding */
   if (k2 >= bm->numKeyFrame)
      k2 = bm->numKeyFrame - 1;
   if (k2 <= 1)
      k1 = 0;
   else
      k1 = k2 - 1;

   /* store the last key frame for next call */
   mc->lastKey = k1;

   /* get the pos/rot at each key frame */
   time1 = bm->keyFrameList[k1].keyFrame;
   time2 = bm->keyFrameList[k2].keyFrame;
   keyFrameForInterpolation = &(bm->keyFrameList[k2]);
   pos1 = bm->keyFrameList[k1].pos;
   rot1 = bm->keyFrameList[k1].rot;
   pos2 = bm->keyFrameList[k2].pos;
   rot2 = bm->keyFrameList[k2].rot;

   if (m_overrideFirst && mc->looped) {
      /* replace the first position/rotation at the first frame with end-of-motion ones */
      if (k1 == 0 || time1 == 0.0f) {
         pos1 = bm->keyFrameList[bm->numKeyFrame - 1].pos;
         rot1 = bm->keyFrameList[bm->numKeyFrame - 1].rot;
      }
      if (k2 == 0 || time2 == 0.0f) {
         pos2 = bm->keyFrameList[bm->numKeyFrame - 1].pos;
         rot2 = bm->keyFrameList[bm->numKeyFrame - 1].rot;
      }
   }

   /* calculate the position and rotation */
   if (time1 != time2) {
      if (frame <= time1) {
         mc->pos = pos1;
         mc->rot = rot1;
      } else if (frame >= time2) {
         mc->pos = pos2;
         mc->rot = rot2;
      } else {
         /* lerp */
         w = (frame - time1) / (time2 - time1);
         idx = (short)(w * VMD_INTERPOLATIONTABLESIZE);
         if (keyFrameForInterpolation->linear[0]) {
            x = pos1.x() * (1.0f - w) + pos2.x() * w;
         } else {
            ww = keyFrameForInterpolation->interpolationTable[0][idx] + (keyFrameForInterpolation->interpolationTable[0][idx + 1] - keyFrameForInterpolation->interpolationTable[0][idx]) * (w * VMD_INTERPOLATIONTABLESIZE - idx);
            x = pos1.x() * (1.0f - ww) + pos2.x() * ww;
         }
         if (keyFrameForInterpolation->linear[1]) {
            y = pos1.y() * (1.0f - w) + pos2.y() * w;
         } else {
            ww = keyFrameForInterpolation->interpolationTable[1][idx] + (keyFrameForInterpolation->interpolationTable[1][idx + 1] - keyFrameForInterpolation->interpolationTable[1][idx]) * (w * VMD_INTERPOLATIONTABLESIZE - idx);
            y = pos1.y() * (1.0f - ww) + pos2.y() * ww;
         }
         if (keyFrameForInterpolation->linear[2]) {
            z = pos1.z() * (1.0f - w) + pos2.z() * w;
         } else {
            ww = keyFrameForInterpolation->interpolationTable[2][idx] + (keyFrameForInterpolation->interpolationTable[2][idx + 1] - keyFrameForInterpolation->interpolationTable[2][idx]) * (w * VMD_INTERPOLATIONTABLESIZE - idx);
            z = pos1.z() * (1.0f - ww) + pos2.z() * ww;
         }
         mc->pos.setValue(btScalar(x), btScalar(y), btScalar(z));
         if (keyFrameForInterpolation->linear[3]) {
            mc->rot = rot1.slerp(rot2, btScalar(w));
         } else {
            ww = keyFrameForInterpolation->interpolationTable[3][idx] + (keyFrameForInterpolation->interpolationTable[3][idx + 1] - keyFrameForInterpolation->interpolationTable[3][idx]) * (w * VMD_INTERPOLATIONTABLESIZE - idx);
            mc->rot = rot1.slerp(rot2, btScalar(ww));
         }
      }
   } else {
      /* both keys have the same time, just apply one of them */
      mc->pos = pos1;
      mc->rot = rot1;
   }

   if (m_overrideFirst && m_noBoneSmearFrame > 0.0f) {
      /* lerp with the initial position/rotation at the time of starting motion */
      w = (float) (m_noBoneSmearFrame / MOTIONCONTROLLER_BONESTARTMARGINFRAME);
      mc->pos = mc->pos.lerp(mc->snapPos, btScalar(w));
      mc->rot = btTransform(btTransform(mc->rot).getBasis() * (1.0f - w) + btTransform(mc->snapRot).getBasis() * w).getRotation();
   }
}

/* MotionController::calcFaceAt: calculate face weight at the given frame */
void MotionController::calcFaceAt(MotionControllerFaceElement *mc, float frameNow)
{
   FaceMotion *fm = mc->motion;
   float frame = frameNow;
   unsigned long k1, k2 = 0;
   unsigned long i;
   float time1, time2, weight1, weight2 = 0.0f;
   float w;

   /* clamp frame to the defined last frame */
   if (frame > fm->keyFrameList[fm->numKeyFrame - 1].keyFrame)
      frame = fm->keyFrameList[fm->numKeyFrame - 1].keyFrame;

   /* find key frames between which the given frame exists */
   if (frame >= fm->keyFrameList[mc->lastKey].keyFrame) {
      /* start searching from last used key frame */
      for (i = mc->lastKey; i < fm->numKeyFrame; i++) {
         if (frame <= fm->keyFrameList[i].keyFrame) {
            k2 = i;
            break;
         }
      }
   } else {
      for (i = 0; i <= mc->lastKey && i < fm->numKeyFrame; i++) {
         if (frame <= fm->keyFrameList[i].keyFrame) {
            k2 = i;
            break;
         }
      }
   }

   /* bounding */
   if (k2 >= fm->numKeyFrame)
      k2 = fm->numKeyFrame - 1;
   if (k2 <= 1)
      k1 = 0;
   else
      k1 = k2 - 1;

   /* store the last key frame for next call */
   mc->lastKey = k1;

   /* get the pos/rot at each key frame */
   time1 = fm->keyFrameList[k1].keyFrame;
   time2 = fm->keyFrameList[k2].keyFrame;
   weight1 = fm->keyFrameList[k1].weight;
   weight2 = fm->keyFrameList[k2].weight;

   if (m_overrideFirst && mc->looped) {
      /* replace the first weight at the first frame with end-of-motion ones */
      if (k1 == 0 || time1 == 0.0f) {
         weight1 = fm->keyFrameList[fm->numKeyFrame - 1].weight;
      }
      if (k2 == 0 || time2 == 0.0f) {
         weight2 = fm->keyFrameList[fm->numKeyFrame - 1].weight;
      }
   }

   /* get value between [time0-time1][weight1-weight2] */
   if (time1 != time2) {
      w = (frame - time1) / (time2 - time1);
      mc->weight = weight1 * (1.0f - w) + weight2 * w;
   } else {
      mc->weight = weight1;
   }

   if (m_overrideFirst && m_noFaceSmearFrame > 0.0f) {
      /* interpolate with the initial weight at the time of starting motion */
      w = (float) (m_noFaceSmearFrame / MOTIONCONTROLLER_FACESTARTMARGINFRAME);
      mc->weight = mc->weight * (1.0f - w) + mc->snapWeight * w;
   }

}

/* MotionController::calcSwitchAt: calculate switches at the given frame */
void MotionController::calcSwitchAt(MotionControllerSwitchElement *mc, float frameNow)
{
   SwitchMotion *sm = mc->motion;
   float frame = frameNow;
   unsigned long k1, k2 = 0;
   unsigned long i;
   float time1, time2;

   /* clamp frame to the defined last frame */
   if (frame > sm->keyFrameList[sm->numKeyFrame - 1].keyFrame)
      frame = sm->keyFrameList[sm->numKeyFrame - 1].keyFrame;

   /* find key frames between which the given frame exists */
   if (frame >= sm->keyFrameList[mc->lastKey].keyFrame) {
      /* start searching from last used key frame */
      for (i = mc->lastKey; i < sm->numKeyFrame; i++) {
         if (frame <= sm->keyFrameList[i].keyFrame) {
            k2 = i;
            break;
         }
      }
   } else {
      for (i = 0; i <= mc->lastKey && i < sm->numKeyFrame; i++) {
         if (frame <= sm->keyFrameList[i].keyFrame) {
            k2 = i;
            break;
         }
      }
   }

   /* bounding */
   if (k2 >= sm->numKeyFrame)
      k2 = sm->numKeyFrame - 1;
   if (k2 <= 1)
      k1 = 0;
   else
      k1 = k2 - 1;

   /* store the last key frame for next call */
   mc->lastKey = k1;

   /* store the current key frame to be applied */
   time1 = sm->keyFrameList[k1].keyFrame;
   time2 = sm->keyFrameList[k2].keyFrame;
   if (time1 != time2) {
      if (time2 == frame) {
         mc->current = &(sm->keyFrameList[k2]);
      } else {
         mc->current = &(sm->keyFrameList[k1]);
      }
   } else {
      mc->current = &(sm->keyFrameList[k1]);
   }
}

/* MotionController::control: set bone position/rotation and face weights according to the motion to the specified frame */
void MotionController::control(float frameNow)
{
   unsigned long i;
   MotionControllerBoneElement *mcb;
   MotionControllerFaceElement *mcf;
   MotionControllerSwitchElement *mcs;
   btVector3 tmpPos;
   btQuaternion tmpRot;
   PMDBone *bone;

   /* update bone positions / rotations at current frame by the correponding motion data */
   /* if blend rate is 1.0, the values will override the current bone pos/rot */
   /* otherwise, the values are blended to the current bone pos/rot */
   for (i = 0; i < m_numBoneCtrl; i++) {
      mcb = &(m_boneCtrlList[i]);
      /* if ignore static flag is set and this motion has only one frame (= first), skip it in this controller */
      if (m_ignoreSingleMotion && mcb->motion->numKeyFrame <= 1)
         continue;
      /* calculate bone position / rotation */
      calcBoneAt(mcb, frameNow);
      /* set the calculated position / rotation to the bone */
      if (m_boneBlendRate == 1.0f) {
         /* override */
         mcb->bone->setCurrentPosition(&mcb->pos);
         mcb->bone->setCurrentRotation(&mcb->rot);
      } else {
         /* lerp */
         mcb->bone->getCurrentPosition(&tmpPos);
         tmpPos = tmpPos.lerp(mcb->pos, btScalar(m_boneBlendRate));
         mcb->bone->setCurrentPosition(&tmpPos);
         mcb->bone->getCurrentRotation(&tmpRot);
         tmpRot = tmpRot.slerp(mcb->rot, btScalar(m_boneBlendRate));
         mcb->bone->setCurrentRotation(&tmpRot);
      }
   }
   /* update face weights by the correponding motion data */
   /* unlike bones, the blend rate is ignored, and values will override the current face weight */
   for (i = 0; i < m_numFaceCtrl; i++) {
      mcf = &(m_faceCtrlList[i]);
      /* if ignore static flag is set and this motion has only one frame (= first), skip it in this controller */
      if (m_ignoreSingleMotion && mcf->motion->numKeyFrame <= 1)
         continue;
      /* calculate face weight */
      calcFaceAt(mcf, frameNow);
      /* set the calculated weight to the face */
      if (m_faceBlendRate == 1.0f)
         mcf->face->setWeight(mcf->weight);
      else
         mcf->face->setWeight(mcf->face->getWeight() * (1.0f - m_faceBlendRate) + mcf->weight * m_faceBlendRate);
   }
   /* update switches by the correponding motion data */
   /* if ignore static flag is set and this motion has only one frame (= first), skip it in this controller */
   if (m_switchCtrl) {
      if(m_ignoreSingleMotion && m_switchCtrl->motion->numKeyFrame <= 1)
         return;
      mcs = m_switchCtrl;
      /* calculate which switches to apply */
      calcSwitchAt(mcs, frameNow);
      /* set the switches to the model */
      mcs->pmd->setShowFlag(mcs->current->display);
      for (i = 0; i < mcs->current->numIK; i++) {
         bone = mcs->pmd->getBone(mcs->current->ikList[i].name);
         if (bone)
            bone->setIKSwitchFlag(mcs->current->ikList[i].enable);
      }
   }
}

/* MotionController::takeSnap: take a snap shot of bones/faces for motion smoothing at beginning of a motion */
void MotionController::takeSnap(btVector3 *centerPos)
{
   unsigned long i;
   MotionControllerBoneElement *mcb;
   MotionControllerFaceElement *mcf;

   for (i = 0; i < m_numBoneCtrl; i++) {
      mcb = &(m_boneCtrlList[i]);
      mcb->bone->getCurrentPosition(&mcb->snapPos);
      if (centerPos && mcb->bone->hasMotionIndependency()) {
         /* consider center offset for snapshot */
         mcb->snapPos -= *centerPos;
      }
      mcb->bone->getCurrentRotation(&mcb->snapRot);
   }
   for (i = 0; i < m_numFaceCtrl; i++) {
      mcf = &(m_faceCtrlList[i]);
      mcf->snapWeight = mcf->face->getWeight();
   }
}

/* MotionController::setLoopedFlags: set flag if the stored end-of-motion position/rotation/weight should be applied at first frame */
void MotionController::setLoopedFlags(bool flag)
{
   unsigned long i;

   for (i = 0; i < m_numBoneCtrl; i++)
      m_boneCtrlList[i].looped = flag;
   for (i = 0; i < m_numFaceCtrl; i++)
      m_faceCtrlList[i].looped = flag;
}

/* MotionController::initialize: initialize controller */
void MotionController::initialize()
{
   m_maxFrame = 0.0f;
   m_numBoneCtrl = 0;
   m_boneCtrlList = NULL;
   m_numFaceCtrl = 0;
   m_faceCtrlList = NULL;
   m_switchCtrl = NULL;
   m_hasCenterBoneMotion = false;
   m_boneBlendRate = 1.0f;
   m_faceBlendRate = 1.0f;
   m_ignoreSingleMotion = false;
   m_currentFrame = 0.0;
   m_previousFrame = 0.0;
   m_noBoneSmearFrame = 0.0f;
   m_noFaceSmearFrame = 0.0f;
   m_overrideFirst = false;
}

/* MotionController::clear: free controller */
void MotionController::clear()
{
   if (m_boneCtrlList)
      delete [] m_boneCtrlList;
   if (m_faceCtrlList)
      delete [] m_faceCtrlList;
   if (m_switchCtrl)
      delete m_switchCtrl;
   initialize();
}

/* MotionController::MotionController: constructor */
MotionController::MotionController()
{
   initialize();
}

/* MotionController::~MotionController: destructor */
MotionController::~MotionController()
{
   clear();
}

/* MotionController::setup: initialize and set up controller */
void MotionController::setup(PMDModel *pmd, VMD *vmd)
{
   unsigned long i;
   BoneMotionLink *bmlink;
   BoneMotion *bm;
   PMDBone *b;
   FaceMotionLink *fmlink;
   FaceMotion *fm;
   PMDFace *f;

   clear();
   m_hasCenterBoneMotion = false;

   /* store maximum frame len */
   m_maxFrame = vmd->getMaxFrame();

   /* allocate bone controller */
   m_numBoneCtrl = vmd->getNumBoneKind();
   if (m_numBoneCtrl > pmd->getNumBone()) /* their maximum will be smaller one between pmd and vmd */
      m_numBoneCtrl = pmd->getNumBone();
   m_boneCtrlList = new MotionControllerBoneElement[m_numBoneCtrl];
   for(i = 0; i < m_numBoneCtrl; i++) {
      m_boneCtrlList[i].bone = NULL;
      m_boneCtrlList[i].motion = NULL;
      m_boneCtrlList[i].pos = btVector3(btScalar(0.0f), btScalar(0.0f), btScalar(0.0f));
      m_boneCtrlList[i].rot = btQuaternion(btScalar(0.0f), btScalar(0.0f), btScalar(0.0f), btScalar(1.0f));
      m_boneCtrlList[i].snapPos = btVector3(btScalar(0.0f), btScalar(0.0f), btScalar(0.0f));
      m_boneCtrlList[i].snapRot = btQuaternion(btScalar(0.0f), btScalar(0.0f), btScalar(0.0f), btScalar(1.0f));
      m_boneCtrlList[i].lastKey = 0;
      m_boneCtrlList[i].looped = false;
   }
   /* check all bone definitions in vmd to match the pmd, and store if match */
   m_numBoneCtrl = 0;
   for (bmlink = vmd->getBoneMotionLink(); bmlink; bmlink = bmlink->next) {
      bm = &(bmlink->boneMotion);
      if ((b = pmd->getBone(bm->name))) {
         m_boneCtrlList[m_numBoneCtrl].bone = b;
         m_boneCtrlList[m_numBoneCtrl].motion = bm;
         m_numBoneCtrl++;
         if (bm->numKeyFrame > 1 && MMDFiles_strequal(bm->name, MOTIONCONTROLLER_CENTERBONENAME) == true) {
            /* This motion has more than 1 key frames for Center Bone, so need re-location */
            m_hasCenterBoneMotion = true;
         }
      }
   }

   /* allocate face controller */
   m_numFaceCtrl = vmd->getNumFaceKind();
   if (m_numFaceCtrl > pmd->getNumFace()) /* their maximum will be smaller one between pmd and vmd */
      m_numFaceCtrl = pmd->getNumFace();
   m_faceCtrlList = new MotionControllerFaceElement[m_numFaceCtrl];
   for(i = 0; i < m_numFaceCtrl; i++) {
      m_faceCtrlList[i].face = NULL;
      m_faceCtrlList[i].motion = NULL;
      m_faceCtrlList[i].weight = 0.0f;
      m_faceCtrlList[i].snapWeight = 0.0f;
      m_faceCtrlList[i].lastKey = 0;
      m_faceCtrlList[i].looped = false;
   }
   /* check all face definitions in vmd to match the pmd, and store if match */
   m_numFaceCtrl = 0;
   for (fmlink = vmd->getFaceMotionLink(); fmlink; fmlink = fmlink->next) {
      fm = &(fmlink->faceMotion);
      if ((f = pmd->getFace(fm->name))) {
         m_faceCtrlList[m_numFaceCtrl].face = f;
         m_faceCtrlList[m_numFaceCtrl].motion = fm;
         m_numFaceCtrl++;
      }
   }

   /* allocate switch controller */
   if (vmd->getSwitchMotion()) {
      m_switchCtrl = new MotionControllerSwitchElement;
      m_switchCtrl->pmd = pmd;
      m_switchCtrl->motion = vmd->getSwitchMotion();
      m_switchCtrl->current = NULL;
      m_switchCtrl->lastKey = 0;
   }
}

/* MotionController::reset: reset values */
void MotionController::reset()
{
   unsigned long i;

   for (i = 0; i < m_numBoneCtrl; i++)
      m_boneCtrlList[i].lastKey = 0;
   for (i = 0; i < m_numFaceCtrl; i++)
      m_faceCtrlList[i].lastKey = 0;
   if (m_switchCtrl)
      m_switchCtrl->lastKey = 0;
   m_currentFrame = 0.0;
   m_previousFrame = 0.0;
   m_noBoneSmearFrame = 0.0f;
   m_noFaceSmearFrame = 0.0f;
   m_boneBlendRate = 1.0f;
   m_faceBlendRate = 1.0f;
   m_ignoreSingleMotion = false;
   m_overrideFirst = false;
   setLoopedFlags(false);
}

/* MotionController::advance: advance motion controller by the given frame, return true when reached end */
bool MotionController::advance(double deltaFrame)
{
   if (m_boneCtrlList == NULL && m_faceCtrlList == NULL)
      return false;

   /* apply motion at current frame to bones and faces */
   control((float) m_currentFrame);

   /* advance the current frame count */
   if (m_noBoneSmearFrame > 0.0f) {
      m_noBoneSmearFrame -= deltaFrame;
      if (m_noBoneSmearFrame < 0.0f)
         m_noBoneSmearFrame = 0.0f;
   }
   if (m_noFaceSmearFrame > 0.0f) {
      m_noFaceSmearFrame -= deltaFrame;
      if (m_noFaceSmearFrame < 0.0f)
         m_noFaceSmearFrame = 0.0f;
   }
   /* store the last frame to m_previousFrame */
   m_previousFrame = m_currentFrame;
   m_currentFrame += deltaFrame;
   if (m_currentFrame >= m_maxFrame) {
      /* we have reached the last key frame of this motion */
      /* clamp the frame to the maximum */
      m_currentFrame = m_maxFrame;
      /* return finished status */
      return true;
   }
   return false;
}

/* MotionController::rewind: rewind motion controller to the given frame */
void MotionController::rewind(float targetFrame, float frame)
{
   /* rewind current frame */
   m_currentFrame = m_previousFrame + frame - m_maxFrame + targetFrame;
   m_previousFrame = targetFrame;
   if (m_overrideFirst) {
      /* set end-of-motion snapshot application flag */
      setLoopedFlags(true);
   }
}

/* MotionController::setOverrideFirst: should be called at the first frame, to tell controller to take snapshot */
void MotionController::setOverrideFirst(btVector3 *centerPos)
{
   /* take snapshot of current pose, to be used as initial values at frame 0 */
   takeSnap(centerPos);
   /* reset end-of-motion snapshot application flag */
   setLoopedFlags(false);
   /* tell controller that we have snapshot, and should take snap at loop */
   m_overrideFirst = true;
   m_noBoneSmearFrame = MOTIONCONTROLLER_BONESTARTMARGINFRAME;
   m_noFaceSmearFrame = MOTIONCONTROLLER_FACESTARTMARGINFRAME;
}

/* MotionController::setBoneBlendRate: set bone blend rate */
void MotionController::setBoneBlendRate(float rate)
{
   m_boneBlendRate = rate;
}

/* MotionController::setFaceBlendRate: set face blend rate */
void MotionController::setFaceBlendRate(float rate)
{
   m_faceBlendRate = rate;
}

/* MotionController::setIgnoreSingleMotion: set insert motion flag */
void MotionController::setIgnoreSingleMotion(bool val)
{
   m_ignoreSingleMotion = val;
}

/* MotionController::hasCenter: return true if the motion has more than 1 key frames for center bone */
bool MotionController::hasCenter()
{
   return m_hasCenterBoneMotion;
}

/* MotionController::getMaxFrame: get max frame */
float MotionController::getMaxFrame()
{
   return m_maxFrame;
}

/* MotionController::getCurrentFrame: get current frame */
double MotionController::getCurrentFrame()
{
   return m_currentFrame;
}

/* MotionController::setCurrentFrame: set current frame */
void MotionController::setCurrentFrame(double frame)
{
   m_currentFrame = frame;
}

/* MotionController::getPreviousFrame: get previous frame */
double MotionController::getPreviousFrame()
{
   return m_previousFrame;
}

/* MotionController::setPreviousFrame: set previous frame */
void MotionController::setPreviousFrame(double frame)
{
   m_previousFrame = frame;
}

/* MotionController::getNumBoneCtrl: get number of bone controller */
unsigned long MotionController::getNumBoneCtrl()
{
   return m_numBoneCtrl;
}

/* MotionController::getBoneCtrlList: get list of bone controller */
MotionControllerBoneElement *MotionController::getBoneCtrlList()
{
   return m_boneCtrlList;
}
