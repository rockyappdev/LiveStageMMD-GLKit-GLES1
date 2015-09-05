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

/* PMDMaterial: material of PMD */
class PMDMaterial
{
private:

   float m_diffuse[3];  /* diffuse color */
   float m_ambient[3];  /* ambient color */
   float m_avgcol[3];   /* average of diffuse and ambient */
   float m_specular[3]; /* specular color */
   float m_alpha;       /* alpha color */
   float m_shiness;     /* shiness intensity */

   unsigned int m_numSurface; /* number of surface indices for this material */

   unsigned char m_toonID; /* toon index */
   bool m_edgeFlag;        /* true if edge should be drawn */

   PMDTexture *m_texture;           /* pointer to texture */
   PMDTexture *m_additionalTexture; /* pointer to additional sphere map */

   unsigned int m_surfaceList;       /* surface index of this material */
   unsigned int m_centerVertexIndex; /* center vertex index for this material */
   float m_centerVertexRadius;       /* maximum radius from center vertex */
    
    bool m_latmiku; /* true if model is Lat Miku */

   /* initialize: initialize material */
   void initialize();

   /* clear: free material */
   void clear();

public:

   /* PMDMaterial: constructor */
   PMDMaterial();

   /* ~PMDMaterial: destructor */
   ~PMDMaterial();

   /* setup: initialize and setup material */
   //bool setup(PMDFile_Material *m, PMDTextureLoader *textureLoader, const char *dir, unsigned int indices, btVector3 *vertices, unsigned short *surfaces);
    bool setup(PMDFile_Material *m, PMDTextureLoader *textureLoader,
               unsigned int indices, btVector3 *vertices,
               unsigned short *surfaces, ScenarioData *_scenarioData,
               int textureLib, bool isLatMiku);

   /* hasSingleSphereMap: return if it has single sphere maps */
   bool hasSingleSphereMap();

   /* hasMultipleSphereMap: return if it has multiple sphere map */
   bool hasMultipleSphereMap();

   /* copyDiffuse: get diffuse colors */
   void copyDiffuse(float *c);

   /* copyAvgcol: get average colors of diffuse and ambient */
   void copyAvgcol(float *c);

   /* copyAmbient: get ambient colors */
   void copyAmbient(float *c);

   /* copySpecular: get specular colors */
   void copySpecular(float *c);

   /* getAlpha: get alpha color */
   float getAlpha();

   /* getShiness: get shiness intensity */
   float getShiness();

   /* getNumSurface: get number of surface */
   unsigned int getNumSurface();

   /* getToonID: get toon index */
   unsigned char getToonID();

   /* getEdgeFlag: get edge flag */
   bool getEdgeFlag();

   /* getTexture: get texture */
   PMDTexture *getTexture();

   /* getAdditionalTexture: get additional sphere map */
   PMDTexture *getAdditionalTexture();

   /* getCenterPositionIndex: get center position index */
   unsigned int getCenterPositionIndex();

   /* getCenterVertexRadius: get maximum radius from center position index */
   float getCenterVertexRadius();

   /* getSurfaceListIndex: get surface list index */
   unsigned int getSurfaceListIndex();
    
};
