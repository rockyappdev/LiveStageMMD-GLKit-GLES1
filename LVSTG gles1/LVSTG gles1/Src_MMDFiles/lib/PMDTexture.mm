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
#include "png.h"
#include "jpeglib.h"

#pragma pack(push, 1)

/* BMPPallete: pallete for BMP */
typedef struct _BMPPallete {
   unsigned char rgbBlue;
   unsigned char rgbGreen;
   unsigned char rgbRed;
   unsigned char rgbReserved;
} BMPPallete;

/* BMPHeader: header for BMP */
typedef struct _BMPHeader {
   unsigned short bfType;
   unsigned int bfSize;
   unsigned short bfReserved1;
   unsigned short bfReserved2;
   unsigned int bfOffBits;
} BMPHeader;

/* BMPInfo: info for BMP */
typedef struct _BMPInfo {
   unsigned int biSize;
   int biWidth;
   int biHeight;
   unsigned short biPlanes;
   unsigned short biBitCount;
   unsigned int biCompression;
   unsigned int biSizeImage;
   int biXPelsPerMeter;
   int biYPelsPerMeter;
   unsigned int biClrUsed;
   unsigned int biClrImportant;
} BMPInfo;

#pragma pack(pop)

unsigned char *pngbuf;
size_t pngbuflen;
void png_read_data_fn(png_structrp png_ptr, png_bytep data, png_size_t length)
{
    png_size_t check = 0;
    
    if (png_ptr == NULL)
        return;
    
    if (length <= pngbuflen) {
        memcpy(data, pngbuf, length);
        pngbuf += length;
        pngbuflen -= length;
        check = length;
    }
    
    if (check != length)
        png_error(png_ptr, "Read Error");
}

/* PMDTexture::loadBMP: load BMP texture */
bool PMDTexture::loadBMP(unsigned char *cp)
{
   unsigned char *data = cp;

   unsigned short bit;
   BMPPallete *palette = NULL;
   unsigned char *head;
   unsigned char *body;
   bool reversed = false;
   BMPHeader *fh;
   unsigned int len;
   BMPInfo *ih;
   unsigned int lineByte;

   unsigned char *t;
   int h, w;

   unsigned char *tl;
   unsigned char ci;
   unsigned char mod;
   unsigned char bitmask;

   m_isTransparent = false;

   /* parse header */
   head = data;
   if (head[0] != 'B' || head[1] != 'M') {
      return false;
   }
   fh = (BMPHeader *) head;
   body = data + fh->bfOffBits;
   head += sizeof(BMPHeader);
   len = *((unsigned int *) head);
   if (len == 12) {
      return false;
   }
   ih = (BMPInfo *) head;
   m_width = ih->biWidth;
   if (ih->biHeight < 0) {
      m_height = -ih->biHeight;
      reversed = true;
   } else {
      m_height = ih->biHeight;
      reversed = false;
   }

   bit = ih->biBitCount;
   if (ih->biCompression != 0) {
      return false;
   }
   if (bit <= 8) {
      palette = (BMPPallete *) (head + sizeof(BMPInfo));
   }

   m_components = 4;

   /* prepare texture data area */
   m_textureData = (unsigned char *) malloc (m_width * m_height * 4);

   lineByte = (m_width * bit) / 8;
   if ((lineByte % 4) != 0)
      lineByte = ((lineByte / 4) + 1) * 4; /* force 4-byte alignment */

   /* read body into textureData */
   t = m_textureData;
   for (h = 0; h < m_height; h++) {
      if (reversed) {
         tl = body + h * lineByte;
      } else {
         tl = body + (m_height - h - 1) * lineByte;
      }
      for (w = 0; w < m_width; w++) {
         switch (bit) {
         case 1: {
            ci = tl[w / 8];
            mod = w % 8;
            bitmask = (mod == 0) ? 0x80 : (0x80 >> mod);
            ci = (ci & bitmask) ? 1 : 0;
            *t = palette[ci].rgbRed;
            t++;
            *t = palette[ci].rgbGreen;
            t++;
            *t = palette[ci].rgbBlue;
            t++;
            *t = 255;
            t++;
         }
         break;
         case 4: {
            ci = tl[w / 2];
            if (w % 2 == 0) ci = (ci >> 4) & 0x0f;
            else ci = ci & 0x0f;
            *t = palette[ci].rgbRed;
            t++;
            *t = palette[ci].rgbGreen;
            t++;
            *t = palette[ci].rgbBlue;
            t++;
            *t = 255;
            t++;
         }
         break;
         case 8: {
            ci = tl[w];
            *t = palette[ci].rgbRed;
            t++;
            *t = palette[ci].rgbGreen;
            t++;
            *t = palette[ci].rgbBlue;
            t++;
            *t = 255;
            t++;
         }
         break;
         case 24:
            /* BGR -> RGB */
            *t = tl[w * 3 + 2];
            t++;
            *t = tl[w * 3 + 1];
            t++;
            *t = tl[w * 3 ];
            t++;
            *t = 255;
            t++;
            break;
         case 32:
            /* BGR0/BGRA -> RGB/RGBA */
            *t = tl[w * 4 + 2];
            t++;
            *t = tl[w * 4 + 1];
            t++;
            *t = tl[w * 4 ];
            t++;
            *t = tl[w * 4 + 3];
            if (*t != 0)
               m_isTransparent = true;
            t++;
            break;
         }
      }
   }

   if (bit == 32 && m_isTransparent == false) {
      /* rewrite 0 (reserved) to 255 */
      t = m_textureData + 3;
      for (h = 0; h < m_height; h++) {
         for (w = 0; w < m_width; w++) {
            *t = 255;
            t += 4;
         }
      }
   }

   return true;
}

/* PMDTexture::loadTGA: load TGA texture */
bool PMDTexture::loadTGA(unsigned char *cp)
{
   unsigned char *data = cp;

   unsigned char idField;
   unsigned char type;
   unsigned char bit;
   unsigned char attrib;
   int stride;
   unsigned char *body;
   unsigned char *uncompressed;
   unsigned int datalen;
   unsigned char *src;
   unsigned char *dst;
   short i, len;

   unsigned char *ptmp;
   unsigned char *pLine;
   unsigned int idx;
   int h, w;

   /* parse TGA */
   /* support only Full-color images */
   idField = *((unsigned char *) data);
   type = *((unsigned char *) (data + 2));
   if (type != 2 /* full color */ && type != 10 /* full color + RLE */) {
      return false;
   }
   m_width = *((short *) (data + 12));
   m_height = *((short *) (data + 14));
   bit = *((unsigned char *) (data + 16)); /* 24 or 32 */
   attrib = *((unsigned char *) (data + 17));
   stride = bit / 8;
   body = data + 18 + idField;

   /* if RLE compressed, uncompress it */
   uncompressed = NULL;
   if (type == 10) {
      datalen = m_width * m_height * stride;
      uncompressed = (unsigned char *)malloc(datalen);
      src = body;
      dst = uncompressed;
      while ((unsigned long) dst - (unsigned long) uncompressed < datalen) {
         len = (*src & 0x7f) + 1;
         if (*src & 0x80) {
            src++;
            for (i = 0; i < len; i++) {
               memcpy(dst, src, stride);
               dst += stride;
            }
            src += stride;
         } else {
            src++;
            memcpy(dst, src, stride * len);
            dst += stride * len;
            src += stride * len;
         }
      }
      /* will load from uncompressed data */
      body = uncompressed;
   }

   /* prepare texture data area */
   m_textureData = (unsigned char *) malloc(m_width * m_height * 4);
   ptmp = m_textureData;

   m_isTransparent = false;

   for (h = 0; h < m_height; h++) {
      if (attrib & 0x20) { /* from up to bottom */
         pLine = body + h * m_width * stride;
      } else { /* from bottom to up */
         pLine = body + (m_height - 1 - h) * m_width * stride;
      }
      for (w = 0; w < m_width; w++) {
         if (attrib & 0x10) { /* from right to left */
            idx = (m_width - 1 - w) * stride;
         } else { /* from left to right */
            idx = w * stride;
         }
         /* BGR or BGRA -> RGBA */
         *(ptmp++) = pLine[idx + 2];
         *(ptmp++) = pLine[idx + 1];
         *(ptmp++) = pLine[idx ];
         *(ptmp++) = (bit == 32) ? pLine[idx + 3] : 255;
         if ( (bit == 32) && pLine[idx + 3] != 255)
            m_isTransparent = true;
      }
   }

   m_components = 4;
   if (uncompressed) free(uncompressed);

   return true;
}

/* PMDTexture::loadPNG: load PNG texture */
bool PMDTexture::loadPNG(unsigned char *cp, size_t len)
{
   png_uint_32 imageWidth, imageHeight;
   int depth, color;

   png_infop info_ptr;
   png_bytep *lineBuf;
   png_uint_32 i;

    
   // create and initialize handler
   png_structp png_ptr = png_create_read_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);
   if (!png_ptr) {
      return false;
   }

   // allocate memory for file information
   info_ptr = png_create_info_struct(png_ptr);
   if (! info_ptr) {
      png_destroy_read_struct(&png_ptr, NULL, NULL);
      return false;
   }

   // set error handler
   if (setjmp(png_jmpbuf(png_ptr))) {
      png_destroy_read_struct(&png_ptr, &info_ptr, NULL);
      return false;
   }

   // set up standard C I/O
   //png_init_io(png_ptr, fp);
    pngbuf = cp;
    pngbuflen = len;
    png_set_read_fn(png_ptr, cp, png_read_data_fn);

   // read image info
   png_read_info(png_ptr, info_ptr);
   png_get_IHDR(png_ptr, info_ptr, &imageWidth, &imageHeight, &depth, &color, NULL, NULL, NULL);
   m_width = imageWidth;
   m_height = imageHeight;

   // gray to rgb
   if (color == PNG_COLOR_TYPE_GRAY || color == PNG_COLOR_TYPE_GRAY_ALPHA)
      png_set_gray_to_rgb(png_ptr);

   // set up image data area
   m_textureData = (unsigned char *) malloc(png_get_rowbytes(png_ptr, info_ptr) * imageHeight);

   // read image data
   lineBuf = (png_bytep *) malloc(sizeof(png_bytep) * imageHeight);
   for (i = 0; i < imageHeight; i++)
      lineBuf[i] = &(m_textureData[png_get_rowbytes(png_ptr, info_ptr) * i]);
   png_read_image(png_ptr, lineBuf);
   free(lineBuf);

   if (color == PNG_COLOR_TYPE_PALETTE) {
      // not supported
      free(m_textureData);
      return false;
   }

   if (color & PNG_COLOR_MASK_ALPHA) {
      m_components = 4;
      m_isTransparent = true;
   } else {
      m_components = 3;
      m_isTransparent = false;
   }

   png_read_end(png_ptr, NULL);

   // clean up memory
   png_destroy_read_struct(&png_ptr, &info_ptr, NULL);
    
   return true;
}

// jpeg_dummy_mgr: dummy for jpeg_error_mgr
struct jpeg_dummy_mgr {
   struct jpeg_error_mgr err;
   jmp_buf jump;
};

// jpeg_error_catcher: error catcher for JPEG
void jpeg_error_catcher(j_common_ptr jpegDecompressor)
{
   jpeg_dummy_mgr *myerr = (jpeg_dummy_mgr *) jpegDecompressor->err;
   longjmp(myerr->jump, 1);
}

/* PMDTexture::loadJPG: load JPG texture */
bool PMDTexture::loadJPG(unsigned char *cp, size_t len)
{

   struct jpeg_decompress_struct jpegDecompressor;
   struct jpeg_dummy_mgr jpegError;

   int i;
   JSAMPROW buff;

   // for error
   jpegDecompressor.err = jpeg_std_error(&jpegError.err);
   jpegError.err.error_exit = jpeg_error_catcher;
   if (setjmp(jpegError.jump)) {
      jpeg_destroy_decompress(&jpegDecompressor);
      return false;
   }

   // initialize decompressor
   jpeg_create_decompress(&jpegDecompressor);

   // file open

    jpeg_mem_src(&jpegDecompressor, cp, len);

    // read header
   jpeg_read_header(&jpegDecompressor, true);

   // load
    jpeg_start_decompress(&jpegDecompressor);
    
   buff = (JSAMPROW) malloc(jpegDecompressor.output_width * jpegDecompressor.output_components);

   m_textureData = (unsigned char *) malloc(jpegDecompressor.output_height * jpegDecompressor.output_width * jpegDecompressor.output_components);
   for (i = 0; jpegDecompressor.output_scanline < jpegDecompressor.output_height; i++) {
      jpeg_read_scanlines(&jpegDecompressor, &buff, 1);
      memcpy(&m_textureData[i * jpegDecompressor.output_width * jpegDecompressor.output_components], buff, jpegDecompressor.output_width * jpegDecompressor.output_components);
   }
   free(buff);
   jpeg_finish_decompress(&jpegDecompressor);

   // save
   m_width = jpegDecompressor.output_width;
   m_height = jpegDecompressor.output_height;
   m_components = 3;
   m_isTransparent = false;

   // free decompressor
   jpeg_destroy_decompress(&jpegDecompressor);
    
   return true;
}

/* PMDTexture::initialize: initialize texture */
void PMDTexture::initialize()
{
   m_id = PMDTEXTURE_UNINITIALIZEDID;
   m_isTransparent = false;
   m_isSphereMap = false;
   m_isSphereMapAdd = false;
   m_width = 0;
   m_height = 0;
   m_components = 3;
   m_textureData = NULL;
}

/* PMDTexture::clear: free texture */
void PMDTexture::clear()
{
   if (m_id != PMDTEXTURE_UNINITIALIZEDID)
      glDeleteTextures(1, &m_id);
   if (m_textureData)
      free(m_textureData);
   initialize();
}

/* constructor */
PMDTexture::PMDTexture()
{
   initialize();
}

/* ~PMDTexture: destructor */
PMDTexture::~PMDTexture()
{
   clear();
}

/* PMDTexture::load: load from file (multi-byte character) */
bool PMDTexture::load(unsigned char *cp, size_t imgLen, char *fileName)
{
   bool ret = true;
    int len;
    
   unsigned char tmp;
   int h, w;
   unsigned char *l1, *l2;

   GLint format;
   float priority;

    printf("... PMDTexture::load: fileName=[%s]\n", fileName);
    
   clear();
   len = MMDFiles_strlen(fileName);
   if (len <= 0)
      return false;

   /* read texture bitmap from the file into textureData */
   if (MMDFiles_strtailmatch(fileName, ".sph") || MMDFiles_strtailmatch(fileName, ".SPH")) {
      if ((ret = loadTGA(cp)) || (ret = loadBMP(cp)) || (ret = loadJPG(cp,imgLen)) || (ret = loadPNG(cp,imgLen))) {
         m_isSphereMap = true;
         m_isSphereMapAdd = false;
      }
   } else if (MMDFiles_strtailmatch(fileName, ".spa") || MMDFiles_strtailmatch(fileName, ".SPA")) {
      if ((ret = loadBMP(cp)) || (ret = loadTGA(cp)) || (ret = loadJPG(cp,imgLen)) || (ret = loadPNG(cp,imgLen))) {
         m_isSphereMap = true;
         m_isSphereMapAdd = true;
      }
   } else if (MMDFiles_strtailmatch(fileName, ".bmp") || MMDFiles_strtailmatch(fileName, ".BMP")) {
      ret = loadBMP(cp);
   } else if (MMDFiles_strtailmatch(fileName, ".tga") || MMDFiles_strtailmatch(fileName, ".TGA")) {
      ret = loadTGA(cp);
   } else if (MMDFiles_strtailmatch(fileName, ".jpg") || MMDFiles_strtailmatch(fileName, ".JPG") || MMDFiles_strtailmatch(fileName, ".jpeg") || MMDFiles_strtailmatch(fileName, ".JPEG")) {
      ret = loadJPG(cp,imgLen);
   } else if (MMDFiles_strtailmatch(fileName, ".png") || MMDFiles_strtailmatch(fileName, ".PNG")) {
       ret = loadPNG(cp,imgLen);
   } else {
      /* unknown file suffix */
      ret = false;
   }

   if (ret == false) {
      /* failed to read and decode file */
       printf("*** MDTexture::load failed to load=[%s]\n", fileName);
      return false;
   }

   if (m_isSphereMap || m_isSphereMapAdd) {
      /* swap vertically */
      for (h = 0; h < m_height / 2; h++) {
         l1 = m_textureData + h * m_width * m_components;
         l2 = m_textureData + (m_height - 1 - h) * m_width * m_components;
         for (w = 0 ; w < m_width * m_components; w++) {
            tmp = l1[w];
            l1[w] = l2[w];
            l2[w] = tmp;
         }
      }

   }

   /* generate texture */
   glGenTextures(1, &m_id);
   glBindTexture(GL_TEXTURE_2D, m_id);
   glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
   glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
   glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
   glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
   if (m_components == 3) {
      format = GL_RGB;
      glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
   } else {
      format = GL_RGBA;
      glPixelStorei(GL_UNPACK_ALIGNMENT, 4);
   }
   glTexImage2D(GL_TEXTURE_2D, 0, format, m_width, m_height, 0, format, GL_UNSIGNED_BYTE, m_textureData);

   /* set highest priority to this texture to tell OpenGL to keep textures in GPU memory */
   priority = 1.0f;
   //glPrioritizeTexturesEXT(1, &m_id, &priority);

   return true;
}

/* PMDTexture::getID: get OpenGL texture ID */
GLuint PMDTexture::getID()
{
   return m_id;
}

void PMDTexture::setID(GLuint val)
{
    m_id = val;
}

/* PMDTexture::isTransparent: return true if this texture contains transparency */
bool PMDTexture::isTransparent()
{
   return m_isTransparent;
}

/* PMDTexture::isSphereMap: return true if this texture is sphere map */
bool PMDTexture::isSphereMap()
{
   return m_isSphereMap;
}

void PMDTexture::setSphereMap(bool val)
{
    m_isSphereMap = val;
}

/* PMDTexture::isSphereMapAdd: return true if this is sphere map to add */
bool PMDTexture::isSphereMapAdd()
{
   return m_isSphereMapAdd;
}

void PMDTexture::setSphereMapAdd(bool val)
{
    m_isSphereMapAdd = val;
}

/* PMDTexture::release: free texture */
void PMDTexture::release()
{
   clear();
}
