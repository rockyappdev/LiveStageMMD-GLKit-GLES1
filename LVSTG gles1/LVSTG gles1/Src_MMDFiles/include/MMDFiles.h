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

#ifndef __mmdfiles_h__
#define __mmdfiles_h__

// not supported in iOS
#define MMDFILES_DONTUSEGLMAPBUFFER

/* convert model coordinates from left-handed to right-handed */
#define MMDFILES_CONVERTCOORDINATESYSTEM

/* convert from/to radian */
#define MMDFILES_RAD(a) (a * (3.1415926f / 180.0f))
#define MMDFILES_DEG(a) (a * (180.0f / 3.1415926f))

#define MMDFILES_MAXBUFLEN 2048

#ifdef _WIN32
#define MMDFILES_DIRSEPARATOR '\\'
#else
#define MMDFILES_DIRSEPARATOR '/'
#endif /* _WIN32 */

// added for xcode ios build
#include <OpenGLES/ES1/gl.h>
#include <OpenGLES/ES1/glext.h>
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>

#include "btBulletDynamicsCommon.h"

//#include "GLee.h"

#include "MMDFiles_utils.h"

#include "BulletPhysics.h"

#include "PMDFile.h"
#include "VMDFile.h"

#include "PTree.h"
#include "VMD.h"
#include "PMDBone.h"
#include "PMDFace.h"
#include "PMDTexture.h"
#include "PMDTextureLoader.h"
#include "PMDMaterial.h"
#include "PMDIK.h"
#include "PMDRigidBody.h"
#include "PMDConstraint.h"
#include "SystemTexture.h"
#include "PMDModel.h"

#include "MotionController.h"
#include "MotionManager.h"

#include "CameraController.h"

#endif /* __mmdfiles_h__ */
