/*
 *  GlutTrans.h
 *  glTest
 *
 *
 */

#include <OpenGLES/ES1/gl.h>
#include <OpenGLES/ES1/glext.h>

#import "GlTrans.h"

class GlutTrans {
	public:
	static void glutWireCube( GLfloat dSize);
	static void glutSolidCube( GLfloat dSize);
	static void gluOrtho2D(	GLfloat left , GLfloat right , GLfloat bottom , GLfloat top );

	
};
