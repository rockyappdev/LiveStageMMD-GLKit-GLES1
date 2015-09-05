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

#include <stdarg.h>
#include "MMDAgent.h"

/* LogText::initialize: initialize logger */
void LogText::initialize()
{
   m_textRenderer = NULL;

   m_textWidth = 0;
   m_textHeight = 0;
   m_textX = 0.0;
   m_textY = 0.0;
   m_textZ = 0.0;
   m_textScale = 0.0;

   m_textList = NULL;
   m_displayList = NULL;
   m_lengthList = NULL;

   m_textIndex = 0;
   m_viewIndex = 0;
}

/* LogText::clear: free logger */
void LogText::clear()
{
   int i;

   if (m_textList) {
      for (i = 0; i < LOGTEXT_MAXNLINES; i++)
         free(m_textList[i]);
      free(m_textList);
   }
   if (m_displayList) {
      for (i = 0; i < LOGTEXT_MAXNLINES; i++)
         free(m_displayList[i]);
      free(m_displayList);
   }
   if (m_lengthList)
      free(m_lengthList);

   initialize();
}

/* LogText::LogText: constructor */
LogText::LogText()
{
   initialize();
}

/* LogText::~LogText: destructor */
LogText::~LogText()
{
   clear();
}

/* LogText::setup: initialize and setup logger with args */
void LogText::setup(TextRenderer *text, const int *size, const float *position, float scale)
{
   int i;

   if (text == NULL || size[0] <= 0 || size[1] <= 0 || scale <= 0.0) return;

   clear();

   m_textRenderer = text;

   m_textWidth = size[0];
   m_textHeight = size[1];
   m_textX = position[0];
   m_textY = position[1];
   m_textZ = position[2];
   m_textScale = scale;

   m_textList = (char **) malloc(sizeof(char *) * LOGTEXT_MAXNLINES);
   for (i = 0; i < LOGTEXT_MAXNLINES; i++) {
      m_textList[i] = (char *) malloc(sizeof(char) * m_textWidth);
      strcpy(m_textList[i], "");
   }

   m_displayList = (unsigned int **) malloc(sizeof(unsigned int *) * LOGTEXT_MAXNLINES);
   for (i = 0; i < LOGTEXT_MAXNLINES; i++)
      m_displayList[i] = (unsigned int *) malloc(sizeof(unsigned int) * m_textWidth);

   m_lengthList = (int *) malloc(sizeof(int) * LOGTEXT_MAXNLINES);
   for (i = 0; i < LOGTEXT_MAXNLINES; i++)
      m_lengthList[i] = 0;
}

/* LogText::log: store log text */
void LogText::log(const char *format, ...)
{
   char *p, *save;
   char buff[LOGTEXT_MAXBUFLEN];
   va_list args;

   if (m_textList == NULL) return;

   va_start(args, format);
   vsprintf(buff, format, args);
   for (p = MMDAgent_strtok(buff, "\n", &save); p; p = MMDAgent_strtok(NULL, "\n", &save)) {
      strncpy(m_textList[m_textIndex], p, m_textWidth - 1);
      m_textList[m_textIndex][m_textWidth - 1] = '\0';
      m_lengthList[m_textIndex] = -1;
      m_textIndex++;
      if (m_textIndex >= LOGTEXT_MAXNLINES)
         m_textIndex = 0;
      if(m_viewIndex != 0)
         scroll(1);
   }
   va_end(args);
}

/* LogText::scroll: scroll text area */
void LogText::scroll(int shift)
{
   if(LOGTEXT_MAXNLINES <= m_textHeight)
      return;

   m_viewIndex += shift;

   if(m_viewIndex < 0)
      m_viewIndex = 0;
   else if(m_viewIndex >= LOGTEXT_MAXNLINES - m_textHeight)
      m_viewIndex = LOGTEXT_MAXNLINES - m_textHeight;
}

/* LogText::render: render log text */
void LogText::render()
{
#ifndef MMDAGENT_DONTRENDERDEBUG
   int i, j, size;
   float w, h, rate;

   if (m_textList == NULL) return;

   w = 0.5f * (float) (m_textWidth) * 0.85f + 1.0f;
   h = 1.0f * (float) (m_textHeight) * 0.85f + 1.0f;

   glPushMatrix();
   glDisable(GL_CULL_FACE);
   glDisable(GL_LIGHTING);
   glScalef(m_textScale, m_textScale, m_textScale);
   glNormal3f(0.0f, 1.0f, 0.0f);

   /* background */
   glColor4f(LOGTEXT_BGCOLOR);
    /******
   glBegin(GL_QUADS);
   glVertex3f(m_textX, m_textY, m_textZ);
   glVertex3f(m_textX + w, m_textY, m_textZ);
   glVertex3f(m_textX + w, m_textY + h, m_textZ);
   glVertex3f(m_textX, m_textY + h, m_textZ);
   glEnd();
     ******/
    
   /* scroll bar */
   if(m_textHeight < LOGTEXT_MAXNLINES) {
      glColor4f(LOGTEXT_COLOR);
       /********
      glBegin(GL_LINE_LOOP);
      glVertex3f(m_textX + w, m_textY, m_textZ + 0.05f);
      glVertex3f(m_textX + w + LOGTEXT_SCROLLBARWIDTH, m_textY, m_textZ + 0.05f);
      glVertex3f(m_textX + w + LOGTEXT_SCROLLBARWIDTH, m_textY + h, m_textZ + 0.05f);
      glVertex3f(m_textX + w, m_textY + h, m_textZ + 0.05f);
      glEnd();
      rate = (float) m_viewIndex / LOGTEXT_MAXNLINES;
      glBegin(GL_QUADS);
      glVertex3f(m_textX + w, m_textY + h * rate, m_textZ + 0.05f);
      glVertex3f(m_textX + w + LOGTEXT_SCROLLBARWIDTH, m_textY + h * rate, m_textZ + 0.05f);
      rate = (float) (m_viewIndex + m_textHeight) / LOGTEXT_MAXNLINES;
      glVertex3f(m_textX + w + LOGTEXT_SCROLLBARWIDTH, m_textY + h * rate, m_textZ + 0.05f);
      glVertex3f(m_textX + w, m_textY + h * rate, m_textZ + 0.05f);
      glEnd();
        *********/
   }

   /* text */
   glColor4f(LOGTEXT_COLOR);
   glTranslatef(m_textX + 0.5f, m_textY - 0.2f, m_textZ + 0.05f);
   size = LOGTEXT_MAXNLINES < m_textHeight ? LOGTEXT_MAXNLINES : m_textHeight;
   for(i = 0, j = m_textIndex - 1 - m_viewIndex; i < size; i++) {
      if(j < 0)
         j += LOGTEXT_MAXNLINES;
      glTranslatef(0.0f, 0.85f, 0.0f);
      if (MMDAgent_strlen(m_textList[j]) > 0) {
         if (m_lengthList[j] < 0)
            m_lengthList[j] = m_textRenderer->getDisplayListArrayOfString(m_textList[j], m_displayList[j], m_textWidth);
         if (m_lengthList[j] > 0) {
            glPushMatrix();
            m_textRenderer->renderDisplayListArrayOfString(m_displayList[j], m_lengthList[j]);
            glPopMatrix();
         }
      }
      j--;
   }

   glEnable(GL_LIGHTING);
   glEnable(GL_CULL_FACE);
   glPopMatrix();
#endif /* !MMDAGENT_DONTRENDERDEBUG */
}
