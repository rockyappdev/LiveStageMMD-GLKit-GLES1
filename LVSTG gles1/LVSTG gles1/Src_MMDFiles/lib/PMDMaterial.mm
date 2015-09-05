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

//#import <GLKit/GLKTextureLoader.h>
#import "TextureList.h"
#import  "ScenarioData.h"
#include "MMDFiles.h"

cTextureList g_textureGen;

/* PMDMaterial::initialize: initialize material */
void PMDMaterial::initialize()
{
   int i;

   for (i = 0; i < 3; i++) {
      m_diffuse[i] = 0.0f;
      m_ambient[i] = 0.0f;
      m_avgcol[i] = 0.0f;
      m_specular[i] = 0.0f;
   }
   m_alpha = 0.0f;
   m_shiness = 0.0f;
   m_numSurface = 0;
   m_toonID = 0;
   m_edgeFlag = false;
   m_texture = NULL;
   m_additionalTexture = NULL;
   m_surfaceList = 0;
   m_centerVertexIndex = 0;
   m_centerVertexRadius = 0.0f;
}

/* PMDMaterial::clear: free material */
void PMDMaterial::clear()
{
   /* actual texture data will be released inside textureLoader, so just reset pointer here */
   initialize();
}

/* PMDMaterial:: constructor */
PMDMaterial::PMDMaterial()
{
   initialize();
}

/* ~PMDMaterial:: destructor */
PMDMaterial::~PMDMaterial()
{
   clear();
}

#define USE_MALLOC_FOR_NSDATA  0

/* PMDMaterial::setup: initialize and setup material */
bool PMDMaterial::setup(PMDFile_Material *m, PMDTextureLoader *textureLoader,
                        unsigned int indices, btVector3 *vertices,
                        unsigned short *surfaces, ScenarioData *_scenarioData,
                        int textureLib, bool isLatMiku)
{
   int i, len;
   char *p;
   bool ret = false;
   char name[21];
   unsigned int j;
   float f[3], d, tmp = 0.0f;
   unsigned short *surface;

    ScenarioData *scenarioData = _scenarioData;

   clear();
    
    m_latmiku = isLatMiku;

    NSString *currentModelPathBase = [[scenarioData getCurrentModelPath] stringByDeletingLastPathComponent];

    /* load model texture */
    strncpy(name, m->textureFile, 20);
    name[20] = '\0';

    NSString *nsStr = [NSString stringWithCString:name encoding:NSShiftJISStringEncoding];
    if (nsStr == nil){
        nsStr = [NSString stringWithCharacters:(const unichar*)name length:sizeof(name)];
    }

    NSLog(@"... PMDMaterial::setup: textureFile=[%@][%s] textureLib=[%d]", nsStr, name, textureLib);
    
   /* colors */
   for (i = 0; i < 3; i++) {
      m_diffuse[i] = m->diffuse[i];
      m_ambient[i] = m->ambient[i];
      /* calculate color for toon rendering */
      m_avgcol[i] = m_diffuse[i] * 0.5f + m_ambient[i] * 0.5f;
      if (m_avgcol[i] > 1.0f)
         m_avgcol[i] = 1.0f;
      m_specular[i] = m->specular[i];
   }
   m_alpha = m->alpha;
   m_shiness = m->shiness;
    
    if (m_latmiku && 0) {
        if (name[0] == 0) {
            if ((m_ambient[0]+m_ambient[1]+m_ambient[2]) == 0) {
                m_ambient[0] = 0.909804f;
                m_ambient[1] = 0.294118f;
                m_ambient[2] = 0.0f;
            }
        }
        
    }

    NSLog(@"... PMDMaterial::setup: diffuse =[%f][%f][%f]", m_diffuse[0],m_diffuse[1],m_diffuse[2]);
    NSLog(@"... PMDMaterial::setup: ambient =[%f][%f][%f]", m_ambient[0],m_ambient[1],m_ambient[2]);
    NSLog(@"... PMDMaterial::setup: specular=[%f][%f][%f]", m_specular[0],m_specular[1],m_specular[2]);
    NSLog(@"... PMDMaterial::setup:  avgcol =[%f][%f][%f]", m_avgcol[0],m_avgcol[1],m_avgcol[2]);

   /* number of surface indices whose material should be assigned by this */
   m_numSurface = m->numSurfaceIndex;

   /* toon texture ID */
   if (m->toonID == 0xff)
      m_toonID = 0;
   else
      m_toonID = m->toonID + 1;
   /* edge drawing flag */
   m_edgeFlag = m->edgeFlag ? true : false;

    NSData *nsData;
    NSString *ext, *extLowercase;
    unsigned char *pData;
    size_t xlen;
    unsigned int uiTexID;
    
   if (MMDFiles_strlen(name) > 0) {
      p = strchr(name, '*');
      if (p) {
         /* has extra sphere map */
         len = (int) (p - &(name[0]));
          *p = 0;
          NSString *fpath = [NSString stringWithCString:name encoding:NSShiftJISStringEncoding];
          if (fpath == nil){
              fpath = [NSString stringWithCharacters:(const unichar*)name length:sizeof(name)];
          }
          
          fpath = [fpath stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];
          fpath = [currentModelPathBase stringByAppendingPathComponent:fpath];
          
          nsData = [scenarioData readZipContentFile:fpath];
          
          if(nsData == nil) {
              NSLog(@"**** PMDMaterial::setup: could not readZipContent fpath=[%@]", fpath);
              // try covert ext to other case uppercase or lowercase
              ext = [fpath pathExtension];
              extLowercase = [ext lowercaseString];
              if ([ext isEqualToString:extLowercase]) {
                  ext = [ext uppercaseString];
              } else {
                  ext = extLowercase;
              }
              fpath = [fpath stringByDeletingPathExtension];
              fpath = [fpath stringByAppendingPathExtension:ext];
              nsData = [scenarioData readZipContentFile:fpath];
              
              if (nsData == nil) {
                  NSLog(@"**** PMDMaterial::setup: could not readZipContent fpath=[%@]", fpath);
                  ret = false;
              }
          }
          
          if (nsData != nil) {

              ret = false;
              bool already_fail;

              /* consult cache */
              m_texture = textureLoader->lookup(name, &already_fail);

              if (m_texture == NULL) {
                  if (ret == false) {
                      ext = [[fpath pathExtension] lowercaseString];
                      if (![ext isEqualToString:@"sph"] && ![ext isEqualToString:@"spa"]) {
                          ret = g_textureGen.createTexture(nsData, fpath, &uiTexID, textureLib );
                          ret = false;
                          if (uiTexID != -1) {
                              m_texture = new PMDTexture();
                              m_texture->setID(uiTexID);
                              if ([ext isEqualToString:@"sph"]) {
                                  m_texture->setSphereMap(true);
                                  m_texture->setSphereMapAdd(false);
                              } else if ([ext isEqualToString:@"spa"]) {
                                  m_texture->setSphereMap(true);
                                  m_texture->setSphereMapAdd(true);
                              }
                              
                              textureLoader->store(m_texture, name);
                              ret = true;
                          }
                      }
                  }
                  
                  if (ret == false) {
                      xlen = nsData.length;
#ifdef USE_MALLOC_FOR_NSDATA
                      pData = (unsigned char *)malloc( xlen );
                      if (pData == NULL) {
                          NSLog(@"***** PMDMaterial::setup: could not allocate pData for malloc(%ld)", xlen);
                          ret = false;
                      }
                      [nsData getBytes:pData];
#else
                      pData = (unsigned char*) [nsData bytes];
#endif
                      
                      if (pData) {
                          m_texture = textureLoader->load(pData, xlen, name);
#ifdef USE_MALLOC_FOR_NSDATA
                          free(pData);
#endif
                          if ([ext isEqualToString:@"sph"]) {
                              m_texture->setSphereMap(true);
                              m_texture->setSphereMapAdd(false);
                          } else if ([ext isEqualToString:@"spa"]) {
                              m_texture->setSphereMap(true);
                              m_texture->setSphereMapAdd(true);
                          }

                      }
                  }
                  
              }
              
              if (m_texture) {
                  NSLog(@"xxxxxxxxxxx textureId = [%d] [%@]", m_texture->getID(), fpath);
                  ret = true;
              } else {
                  NSLog(@"xxxxxxxxxxx textureId = [NULL] [%@]", fpath);
                  ret = false;
              }
          } else {
              NSLog(@"xxxxxxxxxxx textureId = [NULL] [%@]", fpath);
              ret = false;
          }
          
          p++;
          len = (int) strlen(p);
          NSString *fpath2 = [NSString stringWithCString:p encoding:NSShiftJISStringEncoding];
          if (fpath2 == nil){
              fpath2 = [NSString stringWithCharacters:(const unichar*)p length:len];
          }
          
          fpath2 = [fpath2 stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];
          fpath2 = [currentModelPathBase stringByAppendingPathComponent:fpath2];
          
          nsData = [scenarioData readZipContentFile:fpath2];
          
          if (nsData == nil) {
              NSLog(@"**** PMDMaterial::setup: could not readZipContent fpath=[%@]", fpath2);

              // try covert ext to other case uppercase or lowercase
              ext = [fpath2 pathExtension];
              extLowercase = [ext lowercaseString];
              if ([ext isEqualToString:extLowercase]) {
                  ext = [ext uppercaseString];
              } else {
                  ext = extLowercase;
              }
              fpath2 = [fpath2 stringByDeletingPathExtension];
              fpath2 = [fpath2 stringByAppendingPathExtension:ext];
              nsData = [scenarioData readZipContentFile:fpath2];
              
              if (nsData == nil) {
                  NSLog(@"**** PMDMaterial::setup: could not readZipContent fpath=[%@]", fpath2);
                  ret = false;
              }
          }
          
          if (nsData != nil) {

              ret = false;
              bool already_fail;
              /* consult cache */
              m_additionalTexture = textureLoader->lookup(p, &already_fail);

              if (m_additionalTexture == NULL) {
                  ext = [[fpath2 pathExtension] lowercaseString];

                  if (![ext isEqualToString:@"sph"] && ![ext isEqualToString:@"spa"]) {
                      ret = g_textureGen.createTexture(nsData, fpath2, &uiTexID, textureLib );
                      ret = false;
                      if (uiTexID != -1) {
                          m_additionalTexture = new PMDTexture();
                          m_additionalTexture->setID(uiTexID);
                          if ([ext isEqualToString:@"sph"]) {
                              m_additionalTexture->setSphereMap(true);
                              m_additionalTexture->setSphereMapAdd(false);
                          } else if ([ext isEqualToString:@"spa"]) {
                              m_additionalTexture->setSphereMap(true);
                              m_additionalTexture->setSphereMapAdd(true);
                          }
                          
                          textureLoader->store(m_additionalTexture, p);
                          ret = true;
                      }
                  }
                  
                  if (ret == false) {
                      xlen = nsData.length;
#ifdef USE_MALLOC_FOR_NSDATA
                      pData = (unsigned char *)malloc( xlen );
                      if (pData == NULL) {
                          NSLog(@"***** PMDMaterial::setup: could not allocate pData for malloc(%ld)", xlen);
                          ret = false;
                      }
                      [nsData getBytes:pData];
#else
                      pData = (unsigned char*) [nsData bytes];
#endif
                      
                      if (pData) {
                          m_additionalTexture = textureLoader->load(pData, xlen, p);
#ifdef USE_MALLOC_FOR_NSDATA
                          free(pData);
#endif
                          if ([ext isEqualToString:@"sph"]) {
                              m_additionalTexture->setSphereMap(true);
                              m_additionalTexture->setSphereMapAdd(false);
                          } else if ([ext isEqualToString:@"spa"]) {
                              m_additionalTexture->setSphereMap(true);
                              m_additionalTexture->setSphereMapAdd(true);
                          }

                      }
                  }
                  
              }
              
              if (m_additionalTexture) {
                  NSLog(@"xxxxxxxxxxx additional textureId = [%d] [%@]", m_additionalTexture->getID(), fpath2);
              } else {
                  NSLog(@"xxxxxxxxxxx additional textureId = [NULL] [%@]", fpath2);
                  ret = false;
              }
          } else {
              NSLog(@"xxxxxxxxxxx additional textureId = [NULL] [%@]", fpath2);
              ret = false;
              
          }
          
      } else {
          len = (int) strlen(name);
          NSString *fpath = [NSString stringWithCString:name encoding:NSShiftJISStringEncoding];
          if (fpath == nil) {
              fpath = [NSString stringWithCharacters:(const unichar*)name length:sizeof(name)];
          }
          
          fpath = [fpath stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];
          fpath = [currentModelPathBase stringByAppendingPathComponent:fpath];
          
          nsData = [scenarioData readZipContentFile:fpath];
          
          if (nsData == nil) {
              NSLog(@"**** PMDMaterial::setup: could not readZipContent fpath=[%@]", fpath);

              // try covert ext to other case uppercase or lowercase
              ext = [fpath pathExtension];
              extLowercase = [ext lowercaseString];
              if ([ext isEqualToString:extLowercase]) {
                  ext = [ext uppercaseString];
              } else {
                  ext = extLowercase;
              }
              fpath = [fpath stringByDeletingPathExtension];
              fpath = [fpath stringByAppendingPathExtension:ext];
              nsData = [scenarioData readZipContentFile:fpath];
              
              if (nsData == nil) {
                  NSLog(@"**** PMDMaterial::setup: could not readZipContent fpath=[%@]", fpath);
                  ret = false;
              }
          }
          
          if (nsData != nil) {

              ret = false;
              bool already_fail;
              /* consult cache */
              m_texture = textureLoader->lookup(name, &already_fail);
              
              if (m_texture == NULL) {
                  ext = [[fpath pathExtension] lowercaseString];
                  
                  if (![ext isEqualToString:@"sph"] && ![ext isEqualToString:@"spa"]) {
                      ret = g_textureGen.createTexture(nsData, fpath, &uiTexID, textureLib );
                      ret = false;
                      if (uiTexID != -1) {
                          m_texture = new PMDTexture();
                          m_texture->setID(uiTexID);
                          if ([ext isEqualToString:@"sph"]) {
                              m_texture->setSphereMap(true);
                              m_texture->setSphereMapAdd(false);
                          } else if ([ext isEqualToString:@"spa"]) {
                              m_texture->setSphereMap(true);
                              m_texture->setSphereMapAdd(true);
                          }
                          
                          textureLoader->store(m_texture, name);
                          ret = true;
                      }
                  }
                  
                  if (ret == false) {
                      xlen = nsData.length;
#ifdef USE_MALLOC_FOR_NSDATA
                      pData = (unsigned char *)malloc( xlen );
                      if (pData == NULL) {
                          NSLog(@"***** PMDMaterial::setup: could not allocate pData for malloc(%ld)", xlen);
                          ret = false;
                      }
                      [nsData getBytes:pData];
#else
                      pData = (unsigned char*) [nsData bytes];
#endif
                      if (pData) {
                          m_texture = textureLoader->load(pData, xlen, name);
#ifdef USE_MALLOC_FOR_NSDATA
                          free(pData);
#endif
                          if ([ext isEqualToString:@"sph"]) {
                              m_texture->setSphereMap(true);
                              m_texture->setSphereMapAdd(false);
                          } else if ([ext isEqualToString:@"spa"]) {
                              m_texture->setSphereMap(true);
                              m_texture->setSphereMapAdd(true);
                          }

                      }
                  }
              }
              
              if (m_texture) {
                  NSLog(@"xxxxxxxxxxx textureId = [%d], [%@]", m_texture->getID(), fpath);
              } else {
                  NSLog(@"xxxxxxxxxxx textureId = [NULL], [%@]", fpath);
                  ret = false;
              }
          } else {
              NSLog(@"xxxxxxxxxxx textureId = [NULL], [%@]", fpath);
              ret = false;
              
          }
      }
   }

   /* store pointer to surface */
   m_surfaceList = indices;

   /* calculate for center vertex */
   surface = &(surfaces[indices]);
    
    f[0] = f[1] = f[2] = 0.0f;
   
    for (j = 0; j < m_numSurface; j++) {
      f[0] += vertices[surface[j]].getX();
      f[1] += vertices[surface[j]].getY();
      f[2] += vertices[surface[j]].getZ();
    }

    f[0] /= (float)m_numSurface;
    f[1] /= (float)m_numSurface;
    f[2] /= (float)m_numSurface;
    
   for (j = 0; j < m_numSurface; j++) {
      d = (f[0] - vertices[surface[j]].getX()) * (f[0] - vertices[surface[j]].getX())
          + (f[1] - vertices[surface[j]].getY()) * (f[1] - vertices[surface[j]].getY())
          + (f[2] - vertices[surface[j]].getZ()) * (f[2] - vertices[surface[j]].getZ());
      if (j == 0 || tmp > d) {
         tmp = d;
         m_centerVertexIndex = surface[j];
      }
   }
   /* get maximum radius from the center vertex */
   for (j = 0; j < m_numSurface; j++) {
      d = vertices[m_centerVertexIndex].distance2(vertices[surface[j]]);
      if (j == 0 || m_centerVertexRadius < d) {
         m_centerVertexRadius = d;
      }
   }
   m_centerVertexRadius = sqrt(m_centerVertexRadius);

   return ret;
}

/* PMDMaterial::hasSingleSphereMap: return if it has single sphere maps */
bool PMDMaterial::hasSingleSphereMap()
{
   if (m_texture && m_texture->isSphereMap() && m_additionalTexture == NULL)
      return true;
   else
      return false;
}

/* PMDMaterial::hasMultipleSphereMap: return if it has multiple sphere map */
bool PMDMaterial::hasMultipleSphereMap()
{
   if (m_additionalTexture)
      return true;
   else
      return false;
}

/* PMDMaterial::copyDiffuse: get diffuse colors */
void PMDMaterial::copyDiffuse(float *c)
{
    float *pf = m_diffuse;
    *c++ = *pf++;
    *c++ = *pf++;
    *c++ = *pf++;
}

/* PMDMaterial::copyAvgcol: get average colors of diffuse and ambient */
void PMDMaterial::copyAvgcol(float *c)
{
    float *pf = m_avgcol;
    *c++ = *pf++;
    *c++ = *pf++;
    *c++ = *pf++;
}

/* PMDMaterial::copyAmbient: get ambient colors */
void PMDMaterial::copyAmbient(float *c)
{
    float *pf = m_ambient;
    *c++ = *pf++;
    *c++ = *pf++;
    *c++ = *pf++;
}

/* PMDMaterial::copySpecular: get specular colors */
void PMDMaterial::copySpecular(float *c)
{
    float *pf = m_specular;
    *c++ = *pf++;
    *c++ = *pf++;
    *c++ = *pf++;
}

/* PMDMaterial::getAlpha: get alpha */
float PMDMaterial::getAlpha()
{
   return m_alpha;
}

/* PMDMaterial::getShiness: get shiness */
float PMDMaterial::getShiness()
{
   return m_shiness;
}

/* PMDMaterial::getNumSurface: get number of surface */
unsigned int PMDMaterial::getNumSurface()
{
   return m_numSurface;
}

/* PMDMaterial::getToonID: get toon index */
unsigned char PMDMaterial::getToonID()
{
   return m_toonID;
}

/* PMDMaterial::getEdgeFlag: get edge flag */
bool PMDMaterial::getEdgeFlag()
{
   return m_edgeFlag;
}

/* PMDMaterial::getTexture: get texture */
PMDTexture *PMDMaterial::getTexture()
{
   return m_texture;
}

/* PMDMaterial::getAdditionalTexture: get additional sphere map */
PMDTexture *PMDMaterial::getAdditionalTexture()
{
   return m_additionalTexture;
}

/* PMDMaterial::getCenterPositionIndex: get center position index */
unsigned int PMDMaterial::getCenterPositionIndex()
{
   return m_centerVertexIndex;
}

/* PMDMaterial::getCenterVertexRadius: get maximum radius from center position index */
float PMDMaterial::getCenterVertexRadius()
{
   return m_centerVertexRadius;
}

/* PMDMaterial::getSurfaceListIndex: get surface list index */
unsigned int PMDMaterial::getSurfaceListIndex()
{
   return m_surfaceList;
}
