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

#include "MMDAgent.h"
#include "MMDFiles.h"

/* PMDModel::renderModel: render the model */
/* needs multi-texture function on OpenGL: */
/* texture unit 0: model texture */
/* texture unit 1: toon texture for toon shading */
/* texture unit 2: additional sphere map texture, if exist */
void PMDModel::renderModel()
{
    unsigned int i;
    float c[4];
    PMDMaterial *m;
    float modelAlpha;
    unsigned int numSurface;
    unsigned int surfaceOffset;
    bool drawEdge;
    
    //NSLog(@"xxx PMDModel::renderModel");
    
    if (!m_vertexList) return;
    if (!m_showFlag) return;
    
    //NSLog(@"xxx PMDModel::renderModel 002");
    
#ifndef MMDFILES_CONVERTCOORDINATESYSTEM
    glPushMatrix();
    glScalef(1.0f, 1.0f, -1.0f); /* from left-hand to right-hand */
    //glCullFace(GL_FRONT);
    glDisable(GL_CULL_FACE);
#endif /* !MMDFILES_CONVERTCOORDINATESYSTEM */
    
    /* activate texture unit 0 */
    //glActiveTextureARB(GL_TEXTURE0_ARB);
    //glClientActiveTextureARB(GL_TEXTURE0_ARB);
    glActiveTexture(GL_TEXTURE0);
    glClientActiveTexture(GL_TEXTURE0);
    
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    glBindBuffer(GL_ARRAY_BUFFER, m_vboBufStatic);
    glTexCoordPointer(2, GL_FLOAT, 0, (const GLvoid *) NULL);
    
    glBindBuffer(GL_ARRAY_BUFFER, m_vboBufDynamic);
    
    /* set lists */
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_NORMAL_ARRAY);
    glVertexPointer(3, GL_FLOAT, sizeof(btVector3), (const GLvoid *) m_vboOffsetVertex);
    glNormalPointer(GL_FLOAT, sizeof(btVector3), (const GLvoid *) m_vboOffsetNormal);
    
    if (m_toon) {
        /* set toon texture coordinates to texture unit 1 */
        //glActiveTextureARB(GL_TEXTURE1_ARB);
        glActiveTexture(GL_TEXTURE1);
        glEnable(GL_TEXTURE_2D);
        //glClientActiveTextureARB(GL_TEXTURE1_ARB);
        glClientActiveTexture(GL_TEXTURE1);
        glEnableClientState(GL_TEXTURE_COORD_ARRAY);
        
        if (m_selfShadowDrawing) {
            glBindBuffer(GL_ARRAY_BUFFER, m_vboBufStatic);
            glTexCoordPointer(2, GL_FLOAT, 0, (const GLvoid *) m_vboOffsetCoordForShadowMap);
            glBindBuffer(GL_ARRAY_BUFFER, m_vboBufDynamic);
        } else {
            glTexCoordPointer(2, GL_FLOAT, 0, (const GLvoid *) m_vboOffsetToon);
        }
        //glActiveTextureARB(GL_TEXTURE0_ARB);
        //glClientActiveTextureARB(GL_TEXTURE0_ARB);
        glActiveTexture(GL_TEXTURE0);
        glClientActiveTexture(GL_TEXTURE0);
    }
    
    if (m_hasSingleSphereMap) {
        /* this model contains single sphere map texture */
        /* set texture coordinate generation for sphere map on texture unit 0 */
        glEnable(GL_TEXTURE_2D);
        //glTexGeni(GL_S, GL_TEXTURE_GEN_MODE, GL_SPHERE_MAP);
        //glTexGeni(GL_T, GL_TEXTURE_GEN_MODE, GL_SPHERE_MAP);
        glDisable(GL_TEXTURE_2D);
    }
    if (m_hasMultipleSphereMap) {
        /* this model contains additional sphere map texture */
        /* set texture coordinate generation for sphere map on texture unit 2 */
        //glActiveTextureARB(GL_TEXTURE2_ARB);
        glActiveTexture(GL_TEXTURE2);
        glEnable(GL_TEXTURE_2D);
        //glTexGeni(GL_S, GL_TEXTURE_GEN_MODE, GL_SPHERE_MAP);
        //glTexGeni(GL_T, GL_TEXTURE_GEN_MODE, GL_SPHERE_MAP);
        glDisable(GL_TEXTURE_2D);
        //glActiveTextureARB(GL_TEXTURE0_ARB);
        glActiveTexture(GL_TEXTURE0);
    }
    
    /* calculate alpha value, applying model global alpha */
    modelAlpha = m_globalAlpha;
    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, m_vboBufElement);
    
    /* render per material */
    for (i = 0; i < m_numMaterial; i++) {
        m = &(m_material[m_materialRenderOrder[i]]);
        /* set colors */
        c[3] = m->getAlpha() * modelAlpha;
        if (c[3] > 0.99f) c[3] = 1.0f; /* clamp to 1.0 */

        if (m_toon) {
            /* use averaged color of diffuse and ambient for both */
            m->copyAvgcol(c);
            glMaterialfv(GL_FRONT_AND_BACK, GL_AMBIENT_AND_DIFFUSE, &(c[0]));
            m->copySpecular(c);
            glMaterialfv(GL_FRONT_AND_BACK, GL_SPECULAR, &(c[0]));
        } else {
            /* use each color */
            m->copyDiffuse(c);
            if (m_latmiku && 0) {
                c[0] *= 1.4;
                c[1] *= 1.4;
                c[2] *= 1.4;
            }
            if (m_latmiku) {
                glMaterialfv(GL_BACK, GL_AMBIENT, &(c[0]));
            } else {
                glMaterialfv(GL_FRONT_AND_BACK, GL_AMBIENT, &(c[0]));
                //glMaterialfv(GL_FRONT_AND_BACK, GL_SPECULAR, &(c[0]));
                //glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, &(c[0]));
            }
            m->copyAmbient(c);
            if (m_latmiku && 0) {
                c[0] *= 1.2;
                c[1] *= 1.2;
                c[2] *= 1.2;
            }
            if (m_latmiku && 0) {
                //glMaterialfv(GL_FRONT_AND_BACK, GL_SPECULAR, &(c[0]));
                glMaterialfv(GL_BACK, GL_DIFFUSE, &(c[0]));
                //glMaterialfv(GL_FRONT_AND_BACK, GL_AMBIENT, &(c[0]));
            } else {
                //glMaterialfv(GL_FRONT_AND_BACK, GL_SPECULAR, &(c[0]));
                glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, &(c[0]));
                //glMaterialfv(GL_FRONT_AND_BACK, GL_AMBIENT, &(c[0]));
            }
            m->copySpecular(c);
            if (m_latmiku) {
                glMaterialfv(GL_BACK, GL_SPECULAR, &(c[0]));
            } else {
                //glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, &(c[0]));
                //glMaterialfv(GL_FRONT_AND_BACK, GL_AMBIENT, &(c[0]));
                glMaterialfv(GL_FRONT_AND_BACK, GL_SPECULAR, &(c[0]));
            }
        }

        if (m_latmiku) {
            glMaterialf(GL_BACK, GL_SHININESS, m->getShiness());
        } else {
            glMaterialf(GL_FRONT_AND_BACK, GL_SHININESS, m->getShiness());
        }
        
        /* disable face culling for transparent materials */

        if (m_latmiku) {
            //glDisable(GL_CULL_FACE);
            glEnable(GL_CULL_FACE);
            glCullFace(GL_BACK);
            //glCullFace(GL_FRONT);
            //glCullFace(GL_FRONT_AND_BACK );
        } else {
            if (m->getAlpha() < 1.0f)
                glDisable(GL_CULL_FACE);
            else {
                glEnable(GL_CULL_FACE);
                //glCullFace(GL_FRONT );
            }
            //glDisable(GL_CULL_FACE);
        }

        
        /* if using multiple texture units, set current unit to 0 */
        if (m_toon || m_hasMultipleSphereMap) {
            //glActiveTextureARB(GL_TEXTURE0_ARB);
            glActiveTexture(GL_TEXTURE0);
        }
        
        glActiveTexture(GL_TEXTURE0);

        if (m->getTexture()) {
            /* bind model texture */
            glEnable(GL_TEXTURE_2D);
            glBindTexture(GL_TEXTURE_2D, m->getTexture()->getID());
            
            if (m_hasSingleSphereMap) {
                if (m->getTexture()->isSphereMap()) {
                    /* this is sphere map */
                    /* enable texture coordinate generation */
                    //glEnable(GL_TEXTURE_GEN_S);
                    //glEnable(GL_TEXTURE_GEN_T);
                } else {
                    /* disable generation */
                    //glDisable(GL_TEXTURE_GEN_S);
                    //glDisable(GL_TEXTURE_GEN_T);
                }
            }
            
        } else {
            glDisable(GL_TEXTURE_2D);
        }
        
        if (m_toon) {
            /* set toon texture for texture unit 1 */
            //glActiveTextureARB(GL_TEXTURE1_ARB);
            glActiveTexture(GL_TEXTURE1);
            glEnable(GL_TEXTURE_2D);
            glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
            glBindTexture(GL_TEXTURE_2D, m_toonTextureID[m->getToonID()]);
            /* set GL_CLAMP_TO_EDGE for toon texture to avoid texture interpolation at edge */
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        }
        
        if (m_hasMultipleSphereMap) {
            if (m->getAdditionalTexture()) {
                /* this material has additional sphere map texture, bind it at texture unit 2 */
                //glActiveTextureARB(GL_TEXTURE2_ARB);
                glActiveTexture(GL_TEXTURE2);
                glEnable(GL_TEXTURE_2D);
                if (m->getAdditionalTexture()->isSphereMapAdd()) {
                    glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_ADD);
                } else {
                    glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
                }
                glBindTexture(GL_TEXTURE_2D, m->getAdditionalTexture()->getID());
                
                //glEnable(GL_TEXTURE_GEN_S);
                //glEnable(GL_TEXTURE_GEN_T);
            } else {
                /* disable generation */
                //glActiveTextureARB(GL_TEXTURE2_ARB);
                glActiveTexture(GL_TEXTURE2);
                glDisable(GL_TEXTURE_2D);
            }
        }
        
        /* draw elements */
        glDrawElements(GL_TRIANGLES, m->getNumSurface(), GL_UNSIGNED_SHORT, (const GLvoid *) (sizeof(unsigned short) * m->getSurfaceListIndex()));
        
        /* reset some parameters */
        if (m->getTexture() && m->getTexture()->isSphereMap() && m->getTexture()->isSphereMapAdd()) {
            if (m_toon) {
                //glActiveTextureARB(GL_TEXTURE0_ARB);
                glActiveTexture(GL_TEXTURE0);
            }
            //glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
        }
    }
    
    glDisableClientState(GL_NORMAL_ARRAY);
    
    if (m_toon) {
        //glClientActiveTextureARB(GL_TEXTURE0_ARB);
        glClientActiveTexture(GL_TEXTURE0);
        glDisableClientState(GL_TEXTURE_COORD_ARRAY);
        
        if (m_hasSingleSphereMap) {
            //glActiveTextureARB(GL_TEXTURE0_ARB);
            glActiveTexture(GL_TEXTURE0);
            //glDisable(GL_TEXTURE_GEN_S);
            //glDisable(GL_TEXTURE_GEN_T);
        }
        
        //glClientActiveTextureARB(GL_TEXTURE1_ARB);
        glClientActiveTexture(GL_TEXTURE1);
        glDisableClientState(GL_TEXTURE_COORD_ARRAY);
        
        if (m_hasMultipleSphereMap) {
            //glActiveTextureARB(GL_TEXTURE2_ARB);
            glActiveTexture(GL_TEXTURE2);
            //glDisable(GL_TEXTURE_GEN_S);
            //glDisable(GL_TEXTURE_GEN_T);
        }
        
        //glActiveTextureARB(GL_TEXTURE0_ARB);
        glActiveTexture(GL_TEXTURE0);
    } else {
        glDisableClientState(GL_TEXTURE_COORD_ARRAY);
        
        if (m_hasSingleSphereMap) {
            //glDisable(GL_TEXTURE_GEN_S);
            //glDisable(GL_TEXTURE_GEN_T);
        }
        if (m_hasMultipleSphereMap) {
            //glActiveTextureARB(GL_TEXTURE2_ARB);
            glActiveTexture(GL_TEXTURE2);
            //glDisable(GL_TEXTURE_GEN_S);
            //glDisable(GL_TEXTURE_GEN_T);
            //glActiveTextureARB(GL_TEXTURE0_ARB);
            glActiveTexture(GL_TEXTURE0);
        }
        
    }
    
    if (m_hasSingleSphereMap || m_hasMultipleSphereMap) {
        //glDisable(GL_TEXTURE_GEN_S);
        //glDisable(GL_TEXTURE_GEN_T);
    }
    
    if (m_toon) {
        //glActiveTextureARB(GL_TEXTURE1_ARB);
        glActiveTexture(GL_TEXTURE1);
        glDisable(GL_TEXTURE_2D);
    }

    if (m_hasMultipleSphereMap) {
        //glActiveTextureARB(GL_TEXTURE2_ARB);
        glActiveTexture(GL_TEXTURE2);
        glDisable(GL_TEXTURE_2D);
    }
    
    //glActiveTextureARB(GL_TEXTURE0_ARB);
    //glClientActiveTextureARB(GL_TEXTURE0_ARB);
    glActiveTexture(GL_TEXTURE0);
    glClientActiveTexture(GL_TEXTURE0);
    
    glDisable(GL_TEXTURE_2D);
    glEnable(GL_CULL_FACE);
    
#ifndef MMDFILES_CONVERTCOORDINATESYSTEM
    
    //glCullFace(GL_BACK);
    glPopMatrix();
    
#endif /* !MMDFILES_CONVERTCOORDINATESYSTEM */
    
    
    /* draw edge */
    drawEdge = true;
    if (m_forceEdge) {
        /* force edge drawing even if this model has no edge surface or no-toon mode */
        if (m_numSurfaceForEdge == 0) {
            numSurface = m_numSurface;
            surfaceOffset = 0;
        } else {
            numSurface = m_numSurfaceForEdge;
            surfaceOffset = m_vboOffsetSurfaceForEdge;
        }
    } else {
        /* draw edge when toon mode, skip when this model has no edge surface */
        if (!m_toon)
        drawEdge = false;
        if (m_numSurfaceForEdge == 0)
        drawEdge = false;
        numSurface = m_numSurfaceForEdge;
        surfaceOffset = m_vboOffsetSurfaceForEdge;
    }
    
    if (drawEdge) {
        
#ifndef MMDFILES_CONVERTCOORDINATESYSTEM
        glPushMatrix();
        glScalef(1.0f, 1.0f, -1.0f);
        //glCullFace(GL_BACK);
#else
        /* draw back surface only */
        //glCullFace(GL_FRONT);
#endif /* !MMDFILES_CONVERTCOORDINATESYSTEM */
        
        glDisable(GL_LIGHTING);
        glColor4f(m_edgeColor[0], m_edgeColor[1], m_edgeColor[2], m_edgeColor[3] * modelAlpha);
        glVertexPointer(3, GL_FLOAT, sizeof(btVector3), (const GLvoid *) m_vboOffsetEdge);
        glDrawElements(GL_TRIANGLES, numSurface, GL_UNSIGNED_SHORT, (const GLvoid *) surfaceOffset);
        glEnable(GL_LIGHTING);
        
        /* draw front again */
#ifndef MMDFILES_CONVERTCOORDINATESYSTEM
        glPopMatrix();
        //glCullFace(GL_FRONT);
#else
        //glCullFace(GL_BACK);
#endif /* !MMDFILES_CONVERTCOORDINATESYSTEM */
    }
    
    glDisableClientState(GL_VERTEX_ARRAY);
    
    /* unbind buffer */
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
}

/* PMDModel::renderForShadow: render for shadow */
void PMDModel::renderForShadow()
{
    // disabled function for debug
    return;
    
    if (!m_vertexList) return;
    if (!m_showFlag) return;
    
    /* plain drawing of only edge surfaces */
    if (m_numSurfaceForEdge == 0) return;
    
    glDisable(GL_CULL_FACE);
    glBindBuffer(GL_ARRAY_BUFFER, m_vboBufDynamic);
    glEnableClientState(GL_VERTEX_ARRAY);
    glVertexPointer(3, GL_FLOAT, sizeof(btVector3), (const GLvoid *) m_vboOffsetVertex);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, m_vboBufElement);
    glDrawElements(GL_TRIANGLES, m_numSurfaceForEdge, GL_UNSIGNED_SHORT, (const GLvoid *) m_vboOffsetSurfaceForEdge);
    glDisableClientState(GL_VERTEX_ARRAY);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
    glEnable(GL_CULL_FACE);
}

/* PMDModel::renderForPick: render for pick */
void PMDModel::renderForPick()
{
    unsigned int j;
    btVector3 *vertexList;
    btVector3 v1, v2;
    
    if (!m_vertexList) return;
    if (!m_showFlag) return;
    
    /* prepare vertex */
    vertexList = new btVector3[m_numVertex];
    for (j = 0; j < m_numVertex; j++) {
        if (m_boneWeight1[j] >= 1.0f - PMDMODEL_MINBONEWEIGHT) {
            /* bone 1 */
            vertexList[j] = m_boneSkinningTrans[m_bone1List[j]] * m_vertexList[j];
        } else if (m_boneWeight1[j] <= PMDMODEL_MINBONEWEIGHT) {
            /* bone 2 */
            vertexList[j] = m_boneSkinningTrans[m_bone2List[j]] * m_vertexList[j];
        } else {
            /* lerp */
            v1 = m_boneSkinningTrans[m_bone1List[j]] * m_vertexList[j];
            v2 = m_boneSkinningTrans[m_bone2List[j]] * m_vertexList[j];
            vertexList[j] = v2.lerp(v1, btScalar(m_boneWeight1[j]));
        }
    }
    
    /* plain drawing of all surfaces without VBO */
    glDisable(GL_CULL_FACE);
    glEnableClientState(GL_VERTEX_ARRAY);
    glVertexPointer(3, GL_FLOAT, sizeof(btVector3), vertexList);
    glDrawElements(GL_TRIANGLES, m_numSurface, GL_UNSIGNED_SHORT, m_surfaceList);
    glDisableClientState(GL_VERTEX_ARRAY);
    glEnable(GL_CULL_FACE);
    
    delete [] vertexList;
}

/* PMDModel::renderDebug: render for debug view */
void PMDModel::renderDebug()
{
    unsigned short i;
    
    if (!m_vertexList) return;
    
    glDisable(GL_DEPTH_TEST);
    glDisable(GL_LIGHTING);
    glDisable(GL_TEXTURE_2D);
    
    /* draw bones */
    for (i = 0; i < m_numBone; i++)
    m_boneList[i].renderDebug();
    
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_LIGHTING);
}

/* PMDModel::renderModel: render the model */
/* needs multi-texture function on OpenGL: */
/* texture unit 0: model texture */
/* texture unit 1: toon texture for toon shading */
/* texture unit 2: additional sphere map texture, if exist */
void PMDModel::renderModel2()
{
    unsigned int i;
    float c[4];
    PMDMaterial *m;
    float modelAlpha;
    unsigned int numSurface;
    unsigned int surfaceOffset;
    bool drawEdge;
    
    //NSLog(@"xxx PMDModel::renderModel");
    
    if (!m_vertexList) return;
    if (!m_showFlag) return;
    
    GLuint program = m_mmdagent->shader(SHADER_MODEL)._program;
    
    glUseProgram(program);

    //NSLog(@"xxx PMDModel::renderModel 002");
    
#ifndef MMDFILES_CONVERTCOORDINATESYSTEM
    glPushMatrix();
    glScalef(1.0f, 1.0f, -1.0f); /* from left-hand to right-hand */
    //glCullFace(GL_FRONT);
#endif /* !MMDFILES_CONVERTCOORDINATESYSTEM */
    
    /* activate texture unit 0 */
    //glActiveTextureARB(GL_TEXTURE0_ARB);
    //glClientActiveTextureARB(GL_TEXTURE0_ARB);
    glActiveTexture(GL_TEXTURE0);
    glClientActiveTexture(GL_TEXTURE0);
    
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    glBindBuffer(GL_ARRAY_BUFFER, m_vboBufStatic);
    //glTexCoordPointer(2, GL_FLOAT, 0, (const GLvoid *) NULL);
    glVertexAttribPointer(glGetUniformLocation(program, "inTexCoord"),
                          2, GL_FLOAT, GL_FALSE, sizeof(TexCoord), (const GLvoid *) NULL);
    glEnableVertexAttribArray(glGetUniformLocation(program, "inTexCoord"));

    
    glBindBuffer(GL_ARRAY_BUFFER, m_vboBufDynamic);
    
    
	//State
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_CULL_FACE);
	//glCullFace(GL_CCW);
    
    // Feed Projection and Model View matrices to the shaders
    PVRTMat4 mVP = m_mmdagent->getMatProjection() * m_mmdagent->getMatView();

    glUniformMatrix4fv(glGetUniformLocation(program, "modelViewProjectionMatrix"), 1, GL_FALSE, mVP.ptr());
    glUniform3f(glGetUniformLocation(program, "lightViewProjectionMatrix"), 0.f, 10.f, 1.f );
    
    /* set lists */
    //glEnableClientState(GL_VERTEX_ARRAY);
    //glVertexPointer(3, GL_FLOAT, sizeof(btVector3), (const GLvoid *) m_vboOffsetVertex);
    //glEnableClientState(GL_NORMAL_ARRAY);
    //glNormalPointer(GL_FLOAT, sizeof(btVector3), (const GLvoid *) m_vboOffsetNormal);

    glVertexAttribPointer(glGetUniformLocation(program, "inPosition"),
                          3, GL_FLOAT, GL_FALSE, sizeof(btVector3), (const GLvoid *) m_vboOffsetVertex);
    glEnableVertexAttribArray(glGetUniformLocation(program, "inPosition"));
    
    glVertexAttribPointer(glGetUniformLocation(program, "inNormal"),
                          3, GL_FLOAT, GL_FALSE, sizeof(btVector3), (const GLvoid *) m_vboOffsetNormal);
    glEnableVertexAttribArray(glGetUniformLocation(program, "inNormal"));
    
    if (m_toon) {
        /*
        // set toon texture coordinates to texture unit 1
        //glActiveTextureARB(GL_TEXTURE1_ARB);
        glActiveTexture(GL_TEXTURE1);
        glEnable(GL_TEXTURE_2D);
        //glClientActiveTextureARB(GL_TEXTURE1_ARB);
        glClientActiveTexture(GL_TEXTURE1);
        glEnableClientState(GL_TEXTURE_COORD_ARRAY);
         */
        
        /*
        if (m_selfShadowDrawing) {
            // probably this section is wrong
            glTexCoordPointer(2, GL_FLOAT, 0, (const GLvoid *) m_vboOffsetCoordForShadowMap);
            glVertexAttribPointer(glGetUniformLocation(program, "inTexCoord"),
                                  2, GL_FLOAT, GL_FALSE, sizeof(TexCoord), (const GLvoid *) m_vboOffsetCoordForShadowMap);
            glEnableVertexAttribArray(glGetUniformLocation(program, "inTexCoord"));
            
        } else {
            glVertexAttribPointer(glGetUniformLocation(program, "inTexCoord"),
                                  2, GL_FLOAT, GL_FALSE, sizeof(TexCoord), (const GLvoid *) m_vboOffsetToon);
            glEnableVertexAttribArray(glGetUniformLocation(program, "inTexCoord"));

        }

        glEnableVertexAttribArray(glGetUniformLocation(program, "inTexCoord"));
        */
        
        /*
        //glActiveTextureARB(GL_TEXTURE0_ARB);
        //glClientActiveTextureARB(GL_TEXTURE0_ARB);
        glActiveTexture(GL_TEXTURE0);
        glClientActiveTexture(GL_TEXTURE0);
        
        // set toon texture for texture unit 1
        glEnable(GL_TEXTURE_2D);
        glActiveTexture(GL_TEXTURE1);

        // set GL_CLAMP_TO_EDGE for toon texture to avoid texture interpolation at edge
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
         */
    }
    
#ifndef MMDFILES_DONTUSESPHEREMAP
    
    if (m_hasSingleSphereMap) {
        /* this model contains single sphere map texture */
        /* set texture coordinate generation for sphere map on texture unit 0 */
        //glEnable(GL_TEXTURE_2D);
        //glTexGeni(GL_S, GL_TEXTURE_GEN_MODE, GL_SPHERE_MAP);
        //glTexGeni(GL_T, GL_TEXTURE_GEN_MODE, GL_SPHERE_MAP);
        //glDisable(GL_TEXTURE_2D);
    }
    if (m_hasMultipleSphereMap) {
        /* this model contains additional sphere map texture */
        /* set texture coordinate generation for sphere map on texture unit 2 */
        //glActiveTextureARB(GL_TEXTURE2_ARB);
        //glActiveTexture(GL_TEXTURE2);
        //glEnable(GL_TEXTURE_2D);
        //glTexGeni(GL_S, GL_TEXTURE_GEN_MODE, GL_SPHERE_MAP);
        //glTexGeni(GL_T, GL_TEXTURE_GEN_MODE, GL_SPHERE_MAP);
        //glDisable(GL_TEXTURE_2D);
        //glActiveTextureARB(GL_TEXTURE0_ARB);
        //glActiveTexture(GL_TEXTURE0);
    }
    
#endif /* !MMDFILES_DONTUSESPHEREMAP */
    
    /* calculate alpha value, applying model global alpha */
    modelAlpha = m_globalAlpha;
    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, m_vboBufElement);
    
    /* render per material */
    for (i = 0; i < m_numMaterial; i++) {
        m = &(m_material[m_materialRenderOrder[i]]);
        /* set colors */
        c[3] = m->getAlpha() * modelAlpha;
        if (c[3] > 0.99f) c[3] = 1.0f; /* clamp to 1.0 */
        if (m_toon && FALSE) {
            /* use averaged color of diffuse and ambient for both */
            m->copyAvgcol(c);
            glMaterialfv(GL_FRONT_AND_BACK, GL_AMBIENT_AND_DIFFUSE, &(c[0]));
            m->copySpecular(c);
            glMaterialfv(GL_FRONT_AND_BACK, GL_SPECULAR, &(c[0]));
        } else {
            /* use each color */
            m->copyDiffuse(c);
            glUniform4f(glGetUniformLocation(program, "materialShininess"), c[0], c[1], c[2], c[3]);
            m->copyAmbient(c);
            glUniform3f(glGetUniformLocation(program, "materialColor"), c[0], c[1], c[2]);
            m->copySpecular(c);
            glUniform3f(glGetUniformLocation(program, "materialSpecular"), c[0], c[1], c[2]);

        }
        
        glUniform1f(glGetUniformLocation(program, "materialShininess"), m->getShiness());
        glUniform1f(glGetUniformLocation(program, "opacity"), 1.0f);
        
        /* disable face culling for transparent materials */
        if (m->getAlpha() < 1.0f)
        glDisable(GL_CULL_FACE);
        else
        glEnable(GL_CULL_FACE);
        
        /* if using multiple texture units, set current unit to 0 */
        if (m_toon || m_hasMultipleSphereMap) {
            //glActiveTextureARB(GL_TEXTURE0_ARB);
            glActiveTexture(GL_TEXTURE0);
        }
        
        if (m->getTexture()) {
            /* bind model texture */
            glEnable(GL_TEXTURE_2D);
            glBindTexture(GL_TEXTURE_2D, m->getTexture()->getID());
            glClientActiveTexture(GL_TEXTURE0);
            glUniform1i(glGetUniformLocation(program, "mainTexture"), 0);
            glUniform1i(glGetUniformLocation(program, "hasMainTexture"), 1);


#ifndef MMDFILES_DONTUSESPHEREMAP
            
            if (m_hasSingleSphereMap) {
                if (m->getTexture()->isSphereMap()) {
                    /* this is sphere map */
                    /* enable texture coordinate generation */
                    if (m->getTexture()->isSphereMapAdd()) {
                        glUniform1i(glGetUniformLocation(program, "isMainAdditive"), 1);
                    }
                    //glEnable(GL_TEXTURE_GEN_S);
                    //glEnable(GL_TEXTURE_GEN_T);
                } else {
                    /* disable generation */
                    //glDisable(GL_TEXTURE_GEN_S);
                    //glDisable(GL_TEXTURE_GEN_T);
                }
            }
            
#endif /* !MMDFILES_DONTUSESPHEREMAP */
            
        } else {
            glDisable(GL_TEXTURE_2D);
            glUniform1i(glGetUniformLocation(program, "hasMainTexture"), 0);
        }
        
        if (m_toon) {
            /* set toon texture for texture unit 1 */
            //glActiveTextureARB(GL_TEXTURE1_ARB);
            glActiveTexture(GL_TEXTURE1);
            glEnable(GL_TEXTURE_2D);
            glBindTexture(GL_TEXTURE_2D, m_toonTextureID[m->getToonID()]);
            glUniform1i(glGetUniformLocation(program, "toonTexture"), 1);
            glUniform1i(glGetUniformLocation(program, "useToon"), 1);

            /* set GL_CLAMP_TO_EDGE for toon texture to avoid texture interpolation at edge */
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        } else {
            glActiveTexture(GL_TEXTURE1);
            glDisable(GL_TEXTURE_2D);
            glUniform1i(glGetUniformLocation(program, "useToon"), 1);
        }
        
#ifndef MMDFILES_DONTUSESPHEREMAP
        if (m_hasMultipleSphereMap) {
            if (m->getAdditionalTexture()) {
                /* this material has additional sphere map texture, bind it at texture unit 2 */
                //glActiveTextureARB(GL_TEXTURE2_ARB);
                glActiveTexture(GL_TEXTURE2);
                glEnable(GL_TEXTURE_2D);
                glBindTexture(GL_TEXTURE_2D, m->getAdditionalTexture()->getID());
                glUniform1i(glGetUniformLocation(program, "subTexture"), 2);
                glUniform1i(glGetUniformLocation(program, "hasSubTexture"), 1);

                if (m->getAdditionalTexture()->isSphereMapAdd()) {
                    glUniform1i(glGetUniformLocation(program, "isSubAdditive"), 1);
                } else {
                    glUniform1i(glGetUniformLocation(program, "isSubAdditive"), 0);
                }
                
                //glEnable(GL_TEXTURE_GEN_S);
                //glEnable(GL_TEXTURE_GEN_T);
            } else {
                /* disable generation */
                //glActiveTextureARB(GL_TEXTURE2_ARB);
                glActiveTexture(GL_TEXTURE2);
                glDisable(GL_TEXTURE_2D);
                glUniform1i(glGetUniformLocation(program, "hasSubTexture"), 0);
            }
        }
#endif /* !MMDFILES_DONTUSESPHEREMAP */
        
        /* draw elements */
        glDrawElements(GL_TRIANGLES, m->getNumSurface(), GL_UNSIGNED_SHORT,
                       (const GLvoid *) (sizeof(unsigned short) * m->getSurfaceListIndex()));
        
        /* reset some parameters */
        if (m->getTexture() && m->getTexture()->isSphereMap() && m->getTexture()->isSphereMapAdd()) {
            if (m_toon) {
                //glActiveTextureARB(GL_TEXTURE0_ARB);
                glActiveTexture(GL_TEXTURE0);
            }
            //glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
        }
    }
    
    glDisableVertexAttribArray(glGetUniformLocation(program, "inPosition"));
    glDisableVertexAttribArray(glGetUniformLocation(program, "inNormal"));
    glDisableVertexAttribArray(glGetUniformLocation(program, "inTexCoord"));

    if (m_toon) {
        //glClientActiveTextureARB(GL_TEXTURE0_ARB);
        glClientActiveTexture(GL_TEXTURE0);
        glDisableClientState(GL_TEXTURE_COORD_ARRAY);
        
#ifndef MMDFILES_DONTUSESPHEREMAP
        
        if (m_hasSingleSphereMap) {
            //glActiveTextureARB(GL_TEXTURE0_ARB);
            glActiveTexture(GL_TEXTURE0);
            //glDisable(GL_TEXTURE_GEN_S);
            //glDisable(GL_TEXTURE_GEN_T);
        }
        
#endif /* !MMDFILES_DONTUSESPHEREMAP */
        
        //glClientActiveTextureARB(GL_TEXTURE1_ARB);
        glClientActiveTexture(GL_TEXTURE1);
        glDisableClientState(GL_TEXTURE_COORD_ARRAY);
        
#ifndef MMDFILES_DONTUSESPHEREMAP
        
        if (m_hasMultipleSphereMap) {
            //glActiveTextureARB(GL_TEXTURE2_ARB);
            glActiveTexture(GL_TEXTURE2);
            //glDisable(GL_TEXTURE_GEN_S);
            //glDisable(GL_TEXTURE_GEN_T);
        }
        
#endif /* !MMDFILES_DONTUSESPHEREMAP */
        
        //glActiveTextureARB(GL_TEXTURE0_ARB);
        glActiveTexture(GL_TEXTURE0);
    } else {
        glDisableClientState(GL_TEXTURE_COORD_ARRAY);
        
#ifndef MMDFILES_DONTUSESPHEREMAP
        
        if (m_hasSingleSphereMap) {
            //glDisable(GL_TEXTURE_GEN_S);
            //glDisable(GL_TEXTURE_GEN_T);
        }
        if (m_hasMultipleSphereMap) {
            //glActiveTextureARB(GL_TEXTURE2_ARB);
            glActiveTexture(GL_TEXTURE2);
            //glDisable(GL_TEXTURE_GEN_S);
            //glDisable(GL_TEXTURE_GEN_T);
            //glActiveTextureARB(GL_TEXTURE0_ARB);
            glActiveTexture(GL_TEXTURE0);
        }
        
#endif /* !MMDFILES_DONTUSESPHEREMAP */
        
    }
    
#ifndef MMDFILES_DONTUSESPHEREMAP
    
    if (m_hasSingleSphereMap || m_hasMultipleSphereMap) {
        //glDisable(GL_TEXTURE_GEN_S);
        //glDisable(GL_TEXTURE_GEN_T);
    }
    
#endif /* !MMDFILES_DONTUSESPHEREMAP */
    
    if (m_toon) {
        //glActiveTextureARB(GL_TEXTURE1_ARB);
        glActiveTexture(GL_TEXTURE1);
        glDisable(GL_TEXTURE_2D);
    }
#ifndef MMDFILES_DONTUSESPHEREMAP
    if (m_hasMultipleSphereMap) {
        //glActiveTextureARB(GL_TEXTURE2_ARB);
        glActiveTexture(GL_TEXTURE2);
        glDisable(GL_TEXTURE_2D);
    }
    
#endif /* !MMDFILES_DONTUSESPHEREMAP */
    
    //glActiveTextureARB(GL_TEXTURE0_ARB);
    //glClientActiveTextureARB(GL_TEXTURE0_ARB);
    glActiveTexture(GL_TEXTURE0);
    glClientActiveTexture(GL_TEXTURE0);
    
    glDisable(GL_TEXTURE_2D);
    glEnable(GL_CULL_FACE);
    
#ifndef MMDFILES_CONVERTCOORDINATESYSTEM
    
    //glCullFace(GL_BACK);
    glPopMatrix();
    
#endif /* !MMDFILES_CONVERTCOORDINATESYSTEM */
    
    
    /* draw edge */
    drawEdge = true;
    if (m_forceEdge) {
        /* force edge drawing even if this model has no edge surface or no-toon mode */
        if (m_numSurfaceForEdge == 0) {
            numSurface = m_numSurface;
            surfaceOffset = 0;
        } else {
            numSurface = m_numSurfaceForEdge;
            surfaceOffset = m_vboOffsetSurfaceForEdge;
        }
    } else {
        /* draw edge when toon mode, skip when this model has no edge surface */
        if (!m_toon)
        drawEdge = false;
        if (m_numSurfaceForEdge == 0)
        drawEdge = false;
        numSurface = m_numSurfaceForEdge;
        surfaceOffset = m_vboOffsetSurfaceForEdge;
    }
    
    if (drawEdge) {
        
#ifndef MMDFILES_CONVERTCOORDINATESYSTEM
        glPushMatrix();
        glScalef(1.0f, 1.0f, -1.0f);
        //glCullFace(GL_BACK);
#else
        /* draw back surface only */
        //glCullFace(GL_FRONT);
#endif /* !MMDFILES_CONVERTCOORDINATESYSTEM */
        
        glDisable(GL_LIGHTING);
        glColor4f(m_edgeColor[0], m_edgeColor[1], m_edgeColor[2], m_edgeColor[3] * modelAlpha);
        glVertexPointer(3, GL_FLOAT, sizeof(btVector3), (const GLvoid *) m_vboOffsetEdge);
        glDrawElements(GL_TRIANGLES, numSurface, GL_UNSIGNED_SHORT, (const GLvoid *) surfaceOffset);
        glEnable(GL_LIGHTING);
        
        /* draw front again */
#ifndef MMDFILES_CONVERTCOORDINATESYSTEM
        glPopMatrix();
        //glCullFace(GL_FRONT);
#else
        //glCullFace(GL_BACK);
#endif /* !MMDFILES_CONVERTCOORDINATESYSTEM */
    }
    
    glDisableClientState(GL_VERTEX_ARRAY);
    
    /* unbind buffer */
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
}

/* PMDModel::renderForShadow: render for shadow */
void PMDModel::renderForShadow2()
{
   if (!m_vertexList) return;
   if (!m_showFlag) return;

   /* plain drawing of only edge surfaces */
   if (m_numSurfaceForEdge == 0) return;

   glDisable(GL_CULL_FACE);
   glBindBuffer(GL_ARRAY_BUFFER, m_vboBufDynamic);
   glEnableClientState(GL_VERTEX_ARRAY);
   glVertexPointer(3, GL_FLOAT, sizeof(btVector3), (const GLvoid *) m_vboOffsetVertex);
   glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, m_vboBufElement);
   glDrawElements(GL_TRIANGLES, m_numSurfaceForEdge, GL_UNSIGNED_SHORT, (const GLvoid *) m_vboOffsetSurfaceForEdge);
   glDisableClientState(GL_VERTEX_ARRAY);
   glBindBuffer(GL_ARRAY_BUFFER, 0);
   glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
   glEnable(GL_CULL_FACE);
}

/* PMDModel::renderForPick: render for pick */
void PMDModel::renderForPick2()
{
   unsigned int j;
   btVector3 *vertexList;
   btVector3 v1, v2;

   if (!m_vertexList) return;
   if (!m_showFlag) return;

   /* prepare vertex */
   vertexList = new btVector3[m_numVertex];
   for (j = 0; j < m_numVertex; j++) {
      if (m_boneWeight1[j] >= 1.0f - PMDMODEL_MINBONEWEIGHT) {
         /* bone 1 */
         vertexList[j] = m_boneSkinningTrans[m_bone1List[j]] * m_vertexList[j];
      } else if (m_boneWeight1[j] <= PMDMODEL_MINBONEWEIGHT) {
         /* bone 2 */
         vertexList[j] = m_boneSkinningTrans[m_bone2List[j]] * m_vertexList[j];
      } else {
         /* lerp */
         v1 = m_boneSkinningTrans[m_bone1List[j]] * m_vertexList[j];
         v2 = m_boneSkinningTrans[m_bone2List[j]] * m_vertexList[j];
         vertexList[j] = v2.lerp(v1, btScalar(m_boneWeight1[j]));
      }
   }

   /* plain drawing of all surfaces without VBO */
   glDisable(GL_CULL_FACE);
   glEnableClientState(GL_VERTEX_ARRAY);
   glVertexPointer(3, GL_FLOAT, sizeof(btVector3), vertexList);
   glDrawElements(GL_TRIANGLES, m_numSurface, GL_UNSIGNED_SHORT, m_surfaceList);
   glDisableClientState(GL_VERTEX_ARRAY);
   glEnable(GL_CULL_FACE);

   delete [] vertexList;
}

/* PMDModel::renderDebug: render for debug view */
void PMDModel::renderDebug2()
{
   unsigned short i;

   if (!m_vertexList) return;

   glDisable(GL_DEPTH_TEST);
   glDisable(GL_LIGHTING);
   glDisable(GL_TEXTURE_2D);

   /* draw bones */
   for (i = 0; i < m_numBone; i++)
      m_boneList[i].renderDebug();

   glEnable(GL_DEPTH_TEST);
   glEnable(GL_LIGHTING);
}
