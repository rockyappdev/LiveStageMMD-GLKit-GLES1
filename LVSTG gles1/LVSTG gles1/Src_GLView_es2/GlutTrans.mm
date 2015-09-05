/*
 *  GlutTrans.mm
 *  glTest
 *
 *
 */

#include "GlutTrans.h"

//////////////////////////////////////////////////////////////////////////////////////
void GlutTrans::glutWireCube( GLfloat dSize){
    double size = dSize * 0.5;
	
#   define V(a,b,c) te.glVertex3f( a size, b size, c size );
#   define N(a,b,c) te.glNormal3f( a, b, c );
	
    /*
     * PWO: I dared to convert the code to use macros..
     */
	GlTrans te;
    te.glBegin( GL_LINE_LOOP ); N( 1.0, 0.0, 0.0); V(+,-,+); V(+,-,-); V(+,+,-); V(+,+,+); te.glEnd();
    te.glBegin( GL_LINE_LOOP ); N( 0.0, 1.0, 0.0); V(+,+,+); V(+,+,-); V(-,+,-); V(-,+,+); te.glEnd();
    te.glBegin( GL_LINE_LOOP ); N( 0.0, 0.0, 1.0); V(+,+,+); V(-,+,+); V(-,-,+); V(+,-,+); te.glEnd();
    te.glBegin( GL_LINE_LOOP ); N(-1.0, 0.0, 0.0); V(-,-,+); V(-,+,+); V(-,+,-); V(-,-,-); te.glEnd();
    te.glBegin( GL_LINE_LOOP ); N( 0.0,-1.0, 0.0); V(-,-,+); V(-,-,-); V(+,-,-); V(+,-,+); te.glEnd();
    te.glBegin( GL_LINE_LOOP ); N( 0.0, 0.0,-1.0); V(-,-,-); V(-,+,-); V(+,+,-); V(+,-,-); te.glEnd();
	
#   undef V
#   undef N
}

/////////////////////////////////////////////////////////////////////////////////////
void GlutTrans::glutSolidCube( GLfloat dSize )
{
    double size = dSize * 0.5;
#   define V(a,b,c) te.glVertex3f( a size, b size, c size );
#   define N(a,b,c) te.glNormal3f( a, b, c );
	
    /*
     * PWO: Again, I dared to convert the code to use macros...
     */
	GlTrans te;
    te.glBegin( NGL_QUADS );
	N( 1.0, 0.0, 0.0); V(+,-,+); V(+,-,-); V(+,+,-); V(+,+,+);
	N( 0.0, 1.0, 0.0); V(+,+,+); V(+,+,-); V(-,+,-); V(-,+,+);
	N( 0.0, 0.0, 1.0); V(+,+,+); V(-,+,+); V(-,-,+); V(+,-,+);
	N(-1.0, 0.0, 0.0); V(-,-,+); V(-,+,+); V(-,+,-); V(-,-,-);
	N( 0.0,-1.0, 0.0); V(-,-,+); V(-,-,-); V(+,-,-); V(+,-,+);
	N( 0.0, 0.0,-1.0); V(-,-,-); V(-,+,-); V(+,+,-); V(+,-,-);
    te.glEnd();
#   undef V
#   undef N
}

///////////////////////////////////////////////////////////////////////////////////////
void GlutTrans::gluOrtho2D(GLfloat left, GLfloat right, GLfloat bottom, GLfloat top)
{
	glOrthof(left, right, bottom, top, 1.0, -1.0);
}
