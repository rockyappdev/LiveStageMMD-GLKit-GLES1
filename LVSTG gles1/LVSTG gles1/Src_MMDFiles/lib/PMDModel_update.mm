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

/* PMDModel::resetBone: reset bones */
void PMDModel::resetBone()
{
   unsigned short i;
   btVector3 zeroPos(btScalar(0.0f), btScalar(0.0f), btScalar(0.0f));
   btQuaternion zeroRot(btScalar(0.0f), btScalar(0.0f), btScalar(0.0f), btScalar(1.0f));

   /* set zero position for IK-controlled bones before applying motion */
   for (i = 0; i < m_numBone; i++)
      switch(m_boneList[i].getType()) {
      case UNDER_IK:
      case IK_TARGET:
         m_boneList[i].setCurrentPosition(&zeroPos);
         m_boneList[i].setCurrentRotation(&zeroRot);
         break;
      }
}

/* PMDModel::updateBone: update bones */
void PMDModel::updateBone()
{
   unsigned short i;

   /* update bone matrix from current position and rotation */
   for (i = 0; i < m_numBone; i++)
      m_orderedBoneList[i]->update();

   /* solve IK chains */
   if (m_enableSimulation) {
      /* IK with simulated bones can be skipped */
      for (i = 0; i < m_numIK; i++)
         if (!m_IKSimulated[i]) m_IKList[i].solve();
   } else {
      /* all IK should be solved when simulation is off */
      for (i = 0; i < m_numIK; i++)
         m_IKList[i].solve();
   }

   /* apply under-rotate effects */
   for (i = 0; i < m_numRotateBone; i++)
      m_boneList[m_rotateBoneIDList[i]].update();
}

/* PMDModel::updateBoneFromSimulation: update bone transform from rigid body */
void PMDModel::updateBoneFromSimulation()
{
   unsigned int i;

    if (m_usePhysicsSimuration && m_enableSimulation) {
        PMDRigidBody *pRB = m_rigidBodyList;
        for (i = 0; i < m_numRigidBody; i++, pRB++)
            pRB->applyTransformToBone();
    }
}

/* PMDModel::updateFace: update face morph from current face weights */
void PMDModel::updateFace()
{
   unsigned short i;

   if (m_faceList) {
      m_baseFace->apply(m_vertexList);
      for (i = 0; i < m_numFace; i++)
         if (m_faceList[i].getWeight() > PMDMODEL_MINFACEWEIGHT)
            m_faceList[i].add(m_vertexList, m_faceList[i].getWeight());
   }
}

/* PMDModel::updateSkin: update skin data from bone orientation, toon and edges */
void PMDModel::updateSkin()
{
   unsigned short i;
   unsigned int j;
   btVector3 v, v2, n, n2, vv, nn;
   btVector3 *vertexList, *normalList, *edgeVertexList = NULL;
   TexCoord *texCoordList = NULL;
   char *ptr;

   /* calculate transform matrix for skinning (global -> local) */
   for (i = 0; i < m_numBone; i++)
      m_boneList[i].calcSkinningTrans(&(m_boneSkinningTrans[i]));

   glBindBuffer(GL_ARRAY_BUFFER, m_vboBufDynamic);
#ifdef MMDFILES_DONTUSEGLMAPBUFFER
   ptr = (char *) malloc(m_vboBufDynamicLen);
   memset(ptr, 0, m_vboBufDynamicLen);
#else
   glBufferData(GL_ARRAY_BUFFER, m_vboBufDynamicLen, NULL, GL_DYNAMIC_DRAW);
   ptr = (char *) glMapBuffer(GL_ARRAY_BUFFER, GL_WRITE_ONLY);
   if (!ptr) {
      glBindBuffer(GL_ARRAY_BUFFER, 0);
      return;
   }
#endif /* MMDFILES_DONTUSEGLMAPBUFFER */
   vertexList = (btVector3 *)(ptr + m_vboOffsetVertex);
   normalList = (btVector3 *)(ptr + m_vboOffsetNormal);
   if (m_toon) {
      texCoordList = (TexCoord *)(ptr + m_vboOffsetToon);
      edgeVertexList = (btVector3 *)(ptr + m_vboOffsetEdge);
   }

   /* do skinning */
   for (j = 0; j < m_numVertex; j++) {
      if (m_boneWeight1[j] >= 1.0f - PMDMODEL_MINBONEWEIGHT) {
         /* bone 1 */
         vv = m_boneSkinningTrans[m_bone1List[j]] * m_vertexList[j];
         nn = m_boneSkinningTrans[m_bone1List[j]].getBasis() * m_normalList[j];
      } else if (m_boneWeight1[j] <= PMDMODEL_MINBONEWEIGHT) {
         /* bone 2 */
         vv = m_boneSkinningTrans[m_bone2List[j]] * m_vertexList[j];
         nn = m_boneSkinningTrans[m_bone2List[j]].getBasis() * m_normalList[j];
      } else {
         /* lerp */
         v = m_boneSkinningTrans[m_bone1List[j]] * m_vertexList[j];
         n = m_boneSkinningTrans[m_bone1List[j]].getBasis() * m_normalList[j];
         v2 = m_boneSkinningTrans[m_bone2List[j]] * m_vertexList[j];
         n2 = m_boneSkinningTrans[m_bone2List[j]].getBasis() * m_normalList[j];
         vv = v2.lerp(v, btScalar(m_boneWeight1[j]));
         nn = n2.lerp(n, btScalar(m_boneWeight1[j]));
      }
      vertexList[j] = vv;
      normalList[j] = nn;
      if (m_toon) {
         texCoordList[j].u = 0.0f;
         texCoordList[j].v = (1.0f - m_light.dot(nn)) * 0.5f;
         if (m_noEdgeFlag[j] == 1)
            edgeVertexList[j] = vv;
         else
            edgeVertexList[j] = vv + nn * m_edgeOffset;
      }
   }

#ifdef MMDFILES_DONTUSEGLMAPBUFFER
   glBufferData(GL_ARRAY_BUFFER, m_vboBufDynamicLen, ptr, GL_DYNAMIC_DRAW);
   free(ptr);
#else
   glUnmapBuffer(GL_ARRAY_BUFFER);
#endif /* MMDFILES_DONTUSEGLMAPBUFFER */
   glBindBuffer(GL_ARRAY_BUFFER, 0);
}

/* PMDModel::setToonLight: set light direction for toon coordinates */
void PMDModel::setToonLight(btVector3 *light)
{
   m_light = *light;
}

/* PMDModel::updateShadowColorTexCoord: update / create pseudo toon coordinates for shadow rendering pass on shadow mapping */
void PMDModel::updateShadowColorTexCoord(float coef)
{
   unsigned int i;
   TexCoord *tmp;

   if (!m_toon) return;

   if (m_vboOffsetCoordForShadowMap == 0 || m_selfShadowDensityCoef != coef) {
      glBindBuffer(GL_ARRAY_BUFFER, m_vboBufStatic);
      glBufferData(GL_ARRAY_BUFFER, sizeof(TexCoord) * m_numVertex * 2, NULL, GL_STATIC_DRAW);
      glBufferSubData(GL_ARRAY_BUFFER, (GLintptr) NULL, sizeof(TexCoord) * m_numVertex, m_texCoordList);
      m_vboOffsetCoordForShadowMap =  sizeof(TexCoord) * m_numVertex;
      tmp = (TexCoord *) malloc(sizeof(TexCoord) * m_numVertex);
      for (i = 0 ; i < m_numVertex ; i++) {
         tmp[i].u = 0.0f;
         tmp[i].v = coef;
      }
      glBufferSubData(GL_ARRAY_BUFFER, (GLintptr) m_vboOffsetCoordForShadowMap, sizeof(TexCoord) * m_numVertex, tmp);
      free(tmp);
      m_selfShadowDensityCoef = coef;
      glBindBuffer(GL_ARRAY_BUFFER, 0);
   }
}

/* PMDModel::calculateBoundingSphereRange: calculate the bounding sphere for depth texture rendering on shadow mapping */
float PMDModel::calculateBoundingSphereRange(btVector3 *cpos)
{
#ifdef MMDFILES_DONTUSEGLMAPBUFFER
   return 0.0f;
#else
   unsigned int i;
   btVector3 centerPos(btScalar(0.0f), btScalar(0.0f), btScalar(0.0f)), v;
   float maxR = 0.0f, r2;
   btVector3 *vertexList;
   char *ptr;

   glBindBuffer(GL_ARRAY_BUFFER, m_vboBufDynamic);
   ptr = (char *) glMapBuffer(GL_ARRAY_BUFFER, GL_READ_ONLY);
   if (!ptr) {
      glBindBuffer(GL_ARRAY_BUFFER, 0);
      return 0.0f;
   }
   vertexList = (btVector3 *)(ptr + m_vboOffsetVertex);

   if (m_centerBone) {
      centerPos = m_centerBone->getTransform()->getOrigin();
      for (i = 0; i < m_numVertex; i += m_boundingSphereStep) {
         r2 = centerPos.distance2(vertexList[i]);
         if (maxR < r2) maxR = r2;
      }
      maxR = sqrtf(maxR) * 1.1f;
   } else {
      maxR = 0.0f;
   }

   if (cpos) *cpos = centerPos;

   glUnmapBuffer(GL_ARRAY_BUFFER);
   glBindBuffer(GL_ARRAY_BUFFER, 0);

   return maxR;
#endif /* MMDFILES_DONTUSEGLMAPBUFFER */
}

/* PMDModel::smearAllBonesToDefault: smear all bone pos/rot into default value (rate 1.0 = keep, rate 0.0 = reset) */
void PMDModel::smearAllBonesToDefault(float rate)
{
   unsigned short i;
   const btVector3 v(btScalar(0.0f), btScalar(0.0f), btScalar(0.0f));
   const btQuaternion q(btScalar(0.0f), btScalar(0.0f), btScalar(0.0f), btScalar(1.0f));
   btVector3 tmpv;
   btQuaternion tmpq;

   for (i = 0; i < m_numBone; i++) {
      m_boneList[i].getCurrentPosition(&tmpv);
      tmpv = v.lerp(tmpv, btScalar(rate));
      m_boneList[i].setCurrentPosition(&tmpv);
      m_boneList[i].getCurrentRotation(&tmpq);
      tmpq = q.slerp(tmpq, btScalar(rate));
      m_boneList[i].setCurrentRotation(&tmpq);
   }
   for (i = 0; i < m_numFace; i++) {
      m_faceList[i].setWeight(m_faceList[i].getWeight() * rate);
   }
}

#if !defined(MMDFILES_DONTSORTORDERFORALPHARENDERING) && !defined(MMDFILES_DONTUSEGLMAPBUFFER)
/* compareAlphaDepth: qsort function for reordering material */
static int compareAlphaDepth(const void *a, const void *b)
{
   MaterialDistanceData *x = (MaterialDistanceData *) a;
   MaterialDistanceData *y = (MaterialDistanceData *) b;

   if (x->alpha < 1.0f && y->alpha < 1.0f) {
      if (x->dist == y->dist)
         return 0;
      return ( (x->dist > y->dist) ? 1 : -1 );
   } else if (x->alpha == 1.0f && y->alpha < 1.0f) {
      return -1;
   } else if (x->alpha < 1.0f && y->alpha == 1.0f) {
      return 1;
   } else {
      return 0;
   }
}
#endif /* !MMDFILES_DONTSORTORDERFORALPHARENDERING && !MMDFILES_DONTUSEGLMAPBUFFER */

/* PMDModel::updateMaterialOrder: update material order */
void PMDModel::updateMaterialOrder(btTransform *trans)
{
#if !defined(MMDFILES_DONTSORTORDERFORALPHARENDERING) && !defined(MMDFILES_DONTUSEGLMAPBUFFER)
   unsigned int i;
   btVector3 pos;
   btVector3 *vertexList;
   char *ptr;

   glBindBuffer(GL_ARRAY_BUFFER, m_vboBufDynamic);
   ptr = (char *) glMapBuffer(GL_ARRAY_BUFFER, GL_READ_ONLY);
   if (!ptr) {
      glBindBuffer(GL_ARRAY_BUFFER, 0);
      return;
   }
   vertexList = (btVector3 *)(ptr + m_vboOffsetVertex);

   for (i = 0; i < m_numMaterial; i++) {
      pos = vertexList[m_material[i].getCenterPositionIndex()];
      pos = *trans * pos;
      m_materialDistance[i].dist = pos.z() + m_material[i].getCenterVertexRadius();
      if (m_material[i].getAlpha() == 1.0f && m_material[i].getTexture() != NULL && m_material[i].getTexture()->isTransparent())
         m_materialDistance[i].alpha = 0.99f;
      else
         m_materialDistance[i].alpha = m_material[i].getAlpha();
      m_materialDistance[i].id = i;
   }

   glUnmapBuffer(GL_ARRAY_BUFFER);
   glBindBuffer(GL_ARRAY_BUFFER, 0);

   qsort(m_materialDistance, m_numMaterial, sizeof(MaterialDistanceData), compareAlphaDepth);
   for (i = 0; i < m_numMaterial; i++)
      m_materialRenderOrder[i] = m_materialDistance[i].id;
#endif /* !MMDFILES_DONTSORTORDERFORALPHARENDERING && !MMDFILES_DONTUSEGLMAPBUFFER */
}

/* PMDModel::getMaterialRenderOrder: get material rendering order */
unsigned int *PMDModel::getMaterialRenderOrder()
{
   return m_materialRenderOrder;
}
