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
#import <Foundation/Foundation.h>


NSString *default_toons[] = {
    @"toon00.bmp",
    @"toon01.bmp",
    @"toon02.bmp",
    @"toon03.bmp",
    @"toon04.bmp",
    @"toon05.bmp",
    @"toon06.bmp",
    @"toon07.bmp",
    @"toon08.bmp",
    @"toon09.bmp",
    @"toon10.bmp",
    nil
};

/* SystemTexture::initialize: initialize SystemTexture */
void SystemTexture::initialize()
{
   int i;

   for (i = 0; i < SYSTEMTEXTURE_NUMFILES; i++)
      m_toonTextureID[i] = 0;
}

/* SystemTexture::clear: free SystemTexutre */
void SystemTexture::clear()
{
   int i;

   for (i = 0; i < SYSTEMTEXTURE_NUMFILES; i++)
      m_toonTexture[i].release();
   initialize();
}

/* SystemTexture::SystemTexutre: constructor */
SystemTexture::SystemTexture()
{
   initialize();
}

/* SystemTexture::SystemTexutre:: destructor */
SystemTexture::~SystemTexture()
{
   clear();
}

/* SystemTexture::load: load system texture from current directory */
bool SystemTexture::load( void )
{
   int i;
   bool ret = true;
    NSString *dirpath;
    NSString *path;
    NSData *nsData;
    unsigned char *pData;
    size_t imgSize;
    char *name;

    NSLog(@"... SystemTexture::load entered");
    
    dirpath = [[[NSBundle mainBundle] pathForResource:@"toon00" ofType:@"bmp" inDirectory:@"Res_mmd"] stringByDeletingLastPathComponent];
    
    NSFileManager *fm = [[NSFileManager alloc] init];
    
    if (dirpath != nil) {
        for (i = 0; i < SYSTEMTEXTURE_NUMFILES; i++) {
            path = [NSString stringWithFormat:@"%@/%@", dirpath, default_toons[i]];
            nsData = [fm contentsAtPath:path];
            imgSize = nsData.length;
            if (imgSize>0) {
                pData = (unsigned char*)malloc(imgSize);
                name = (char*)[path cStringUsingEncoding:NSUTF8StringEncoding];
                [nsData getBytes:pData];

                if (pData) {
                    if (m_toonTexture[i].load(pData,imgSize,name) == false) {
                        ret = false;
                    }
                    m_toonTextureID[i] = m_toonTexture[i].getID();
                    NSLog(@"... m_toonTextureID[%d]=texID[%d],[%@]", i, m_toonTextureID[i], default_toons[i]);
                }
            }
        }
    }

   return ret;
}

/* SystemTexture::getTextureID: get toon texture ID */
unsigned int SystemTexture::getTextureID(int i)
{
   return m_toonTextureID[i];
}

/* SystemTexture::release: free SystemTexture */
void SystemTexture::release()
{
   clear();
}
