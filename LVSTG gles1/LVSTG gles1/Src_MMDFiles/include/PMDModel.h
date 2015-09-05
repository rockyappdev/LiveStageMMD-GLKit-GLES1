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

#define PMDMODEL_CENTERBONENAME "センター" /* center */

#define PMDMODEL_MINBONEWEIGHT 0.0001f
#define PMDMODEL_MINFACEWEIGHT 0.001f

#define PMDMODEL_EDGECOLORR 0.0f
#define PMDMODEL_EDGECOLORG 0.0f
#define PMDMODEL_EDGECOLORB 0.0f
#define PMDMODEL_EDGECOLORA 1.0f

#define PMDMODEL_BOUNDINGSPHEREPOINTS    1000
#define PMDMODEL_BOUNDINGSPHEREPOINTSMIN 5
#define PMDMODEL_BOUNDINGSPHEREPOINTSMAX 20

class MMDAgent;

/* TexCoord: texture coordinaiton */
typedef struct {
   float u;
   float v;
} TexCoord;

typedef struct {
   float dist;
   float alpha;
   unsigned int id;
} MaterialDistanceData;

/* PMDModel: model of PMD */
class PMDModel
{
private:

   /* model definition */
   char *m_name;    /* model name */
   char *m_comment; /* comment string */
    MMDAgent *m_mmdagent; // MMDAgent
    bool m_latmiku; /* true if model is Lat Miku */

   unsigned int m_numVertex; /* number of vertices */
   btVector3 *m_vertexList;  /* vertex list */
   btVector3 *m_normalList;  /* normal list */
   TexCoord *m_texCoordList; /* texture coordinate list */
   short *m_bone1List;       /* weighted bone ID list */
   short *m_bone2List;       /* weighted bone ID list */
   float *m_boneWeight1;     /* weight list for m_Bone1List */
   bool *m_noEdgeFlag;       /* true if no edge should be drawn for this vertex */

   unsigned int m_numSurface;     /* number of surface definitions */
   unsigned short *m_surfaceList; /* list of surface definitions (index to 3 vertices per surface) */

   unsigned int m_numMaterial; /* number of material definitions */
   PMDMaterial *m_material;    /* material list */

   unsigned short m_numBone; /* number of bones */
   PMDBone *m_boneList;      /* bone list */

   unsigned short m_numIK; /* number of IK chains */
   PMDIK *m_IKList;        /* IK chain list */

   unsigned short m_numFace; /* number of face definitions */
   PMDFace *m_faceList;      /* face definition list */

   unsigned int m_numRigidBody;   /* number of rigid bodies (Bullet Physics) */
   PMDRigidBody *m_rigidBodyList; /* rigid body list */

   unsigned int m_numConstraint;    /* number of constraints (Bullet Physics) */
   PMDConstraint *m_constraintList; /* rigid body list */

   /* work area for toon renderling */
   PMDTextureLoader m_textureLoader;                      /* texture loader for this model */
   unsigned int m_toonTextureID[SYSTEMTEXTURE_NUMFILES];  /* texture ID for toon shading */
   PMDTexture m_localToonTexture[SYSTEMTEXTURE_NUMFILES]; /* toon textures for this model only */
   btVector3 m_light;                                     /* toon light direction */

   /* work area for OpenGL rendering */
   btTransform *m_boneSkinningTrans;           /* transform matrices of bones for skinning */
   unsigned int m_numSurfaceForEdge;           /* number of edge-drawing surface list */
   GLuint m_vboBufDynamic;                     /* VBO buffers for dynamic data */
   GLuint m_vboBufStatic;                      /* VBO buffers for static  data */
   GLuint m_vboBufElement;                     /* VBO buffers for element data */
   unsigned long m_vboBufDynamicLen;           /* length of the dynamic VBO buffer */
   unsigned long m_vboOffsetVertex;            /* byte offset for the vertex list in the dynamic VBO buffer */
   unsigned long m_vboOffsetNormal;            /* byte offset for the normal list in the dynamic VBO buffer */
   unsigned long m_vboOffsetToon;              /* byte offset for the toon texture coordinate list in the dynamic VBO buffer */
   unsigned long m_vboOffsetEdge;              /* byte offset for the edge vertex list in the dynamic VBO buffer */
   unsigned long m_vboOffsetSurfaceForEdge;    /* byte offset for the surface list for edge in the dynamic VBO buffer */
   unsigned long m_vboOffsetCoordForShadowMap; /* byte offset for the toon texture corrdinate for shadow rendering in shadow map */

   /* flags and short lists extracted from the model data */
   PMDBone *m_centerBone;              /* center bone */
   PMDFace *m_baseFace;                /* base face definition */
   PMDBone **m_orderedBoneList;        /* bone list in update order */
   bool m_hasSingleSphereMap;          /* true if this model has Sphere map texture */
   bool m_hasMultipleSphereMap;        /* true if this model has additional sphere map texture */
   unsigned short m_numRotateBone;     /* number of bones under rotatation of other bone (type == 5 or 9) */
   unsigned short *m_rotateBoneIDList; /* ID list of under-rotate bones */
   bool *m_IKSimulated;                /* boolean list whether an IK should be disabled due to simulation */
   bool m_enableSimulation;            /* true when physics bone control is enabled and simulated IK should be skipped */
    
    int m_textureLib;                  /* choose textureLoader 0:custom 1:apple */

    bool m_usePhysicsSimuration;        // flag to use or not use bullet physics simulation

    float m_maxHeight;                  /* maximum height of this model */
   unsigned int m_boundingSphereStep;  /* vertex step to calculate bounding sphere for shadow mapping */

   /* configuration parameters given from outside */
   bool m_toon;                   /* true when enable toon rendering */
   float m_globalAlpha;           /* global alpha value */
   float m_edgeOffset;            /* edge offset */
   bool m_selfShadowDrawing;      /* true when render with self shadow color */
   float m_selfShadowDensityCoef; /* shadow density coefficient for self shadow */
   float m_edgeColor[4];          /* edge color */
   bool m_forceEdge;              /* true when force edge drawing for all objects */

   /* additional information for managing model */
   BulletPhysics *m_bulletPhysics; /* pointer to BulletPhysics class, under which this model is controlled */
   PMDBone m_rootBone;             /* model root bone for global model offset / rotation / bone binding */
   PTree m_name2bone;              /* name-to-bone index for fast lookup */
   PTree m_name2face;              /* name-to-face index for fast lookup */
   unsigned int *m_materialRenderOrder;
   MaterialDistanceData *m_materialDistance;

   /* work data */
   bool m_showFlag; /* switch whether to show this model */

    SystemTexture *m_systex;   // system textures
    PMDFile_Header *m_pmdFileHeader;
    
    /* parse: initialize and load from data memories */
    bool parse(const unsigned char *data, unsigned long size, BulletPhysics *bullet, SystemTexture *systex, ScenarioData *_scenarioData);
    bool parsePMD(const unsigned char *data, unsigned long size, ScenarioData *_scenarioData);

   /* initialize: initialize PMDModel */
   void initialize();

   /* clear: free PMDModel */
   void clear();

public:

   /* PMDModel: constructor */
   PMDModel(MMDAgent *mmdagent);

   /* ~PMDModel: destructor */
   ~PMDModel();

   /* load: load from file name */
    bool load(ScenarioData *_scenarioData, void *bullet, void *systex);

   /* getBone: find bone data by name */
   PMDBone *getBone(const char *name);

   /* getFace: find face data by name */
   PMDFace *getFace(const char *name);

   /* getChildBoneList: return list of child bones, in decent order */
   int getChildBoneList(PMDBone **bone, unsigned short numBone, PMDBone **childBoneList);

   /* setPhysicsControl switch bone control by physics simulation */
   void setPhysicsControl(bool flag);

    void setUsePhysicsSimulation(bool flag);
    bool usePhysicsSimulation( void );

   /* release: free PMDModel */
   void release();
    
    void setTextureLib(int ival);
    int getTextureLib();

   /* setShowFlag: set show flag */
   void setShowFlag(bool flag);

   /* PMDModel:;setEdgeThin: set edge offset */
   void setEdgeThin(float thin);

   /* PMDModel:;setToonFlag: set toon rendering flag */
   void setToonFlag(bool flag);

   /* getToonFlag: return true when enable toon rendering */
   bool getToonFlag();

   /* setSelfShadowDrawing: set self shadow drawing flag */
   void setSelfShadowDrawing(bool flag);

   /* setEdgeColor: set edge color */
   void setEdgeColor(float *color);

   /* setGlobalAlpha: set global alpha value */
   void setGlobalAlpha(float alpha);

   /* updateMaterialOrder: update material order */
   void updateMaterialOrder(btTransform *trans);

   /* getMaterialRenderOrder: get material rendering order */
   unsigned int *getMaterialRenderOrder();

   /* getRootBone: get root bone */
   PMDBone *getRootBone();

   /* getCenterBone: get center bone */
   PMDBone *getCenterBone();

   /* getName: get model name */
   char * getName();

   /* getNumVertex: get number of vertics */
   unsigned int getNumVertex();

   /* getNumSurface: get number of surface definitions */
   unsigned int getNumSurface();

   /* getNumMaterial: get number of material definitions */
   unsigned int getNumMaterial();

   /* getNumBone: get number of bones */
   unsigned short getNumBone();

   /* getNumIK: get number of IK chains */
   unsigned short getNumIK();

   /* getNumFace: get number of faces */
   unsigned short getNumFace();

   /* getNumRigidBody: get number of rigid bodies */
   unsigned int getNumRigidBody();

   /* getNumConstraint: get number of constraints */
   unsigned int getNumConstraint();

   /* getErrorTextureList: get error texture list */
   void getErrorTextureList(char *buf, int size);

   /* getMaxHeight: get max height */
   float getMaxHeight();

   /* getComment: get comment of PMD */
   char *getComment();

   /* setForceEdgeFlag: set force edge flag */
   void setForceEdgeFlag(bool flag);

   /* resetBone: reset bones */
   void resetBone();

   /* updateBone: update bones */
   void updateBone();

   /* updateBoneFromSimulation: update bone transform from rigid body */
   void updateBoneFromSimulation();

   /* updateFace: update face morph from current face weights */
   void updateFace();

   /* updateSkin: update skin data from bone orientation, toon and edges */
   void updateSkin();

   /* setToonLight: set light direction for toon coordinates */
   void setToonLight(btVector3 *light);

   /* updateShadowColorTexCoord: update / create pseudo toon coordinates for shadow rendering pass on shadow mapping */
   void updateShadowColorTexCoord(float coef);

   /* calculateBoundingSphereRange: calculate the bounding sphere for depth texture rendering on shadow mapping */
   float calculateBoundingSphereRange(btVector3 *cpos);

   /* smearAllBonesToDefault: smear all bone pos/rot into default value (rate 1.0 = keep, rate 0.0 = reset) */
   void smearAllBonesToDefault(float rate);

   /* renderModel: render the model */
   void renderModel();

   /* renderForShadow: render for shadow */
   void renderForShadow();

   /* renderForPick: render for pick */
   void renderForPick();

   /* renderDebug: render for debug view */
   void renderDebug();

    /* renderModel: render the model */
    void renderModel2();
    
    /* renderForShadow: render for shadow */
    void renderForShadow2();
    
    /* renderForPick: render for pick */
    void renderForPick2();
    
    /* renderDebug: render for debug view */
    void renderDebug2();
};
