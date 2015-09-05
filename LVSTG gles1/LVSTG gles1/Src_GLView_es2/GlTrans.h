/*
 *  GlTrans.h
 *  MMD_View
 *
 *
 */


#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#include <list>

#define NGL_QUADS 7

class GlTrans{
    static const int GL_QUAD_STRIP = 8;
	float _nx, _ny, _nz;
	GLenum _mode;
    std::list<float> *vertices, *normals, *texs;
	float* verticesToFloat();
	float* normalsToFloat();
	float* texsToFloat();
	void QuadToTriangle(float *sou, int souIndex, float *dest, int destIndex);
	void QuadToTriangle2(float *sou, int souIndex, float *dest, int destIndex);
	
	
public:
	void glBegin(GLenum mode);
	void glVertex3f(float x, float y, float z);
	void glVertex2f(float x, float y);
	void glNormal3f(float nx, float ny, float nz);
	void glTexCoord2f(float u, float v);
	void glEnd();
	void glFrustum(
			double left, double right, double bottom, double top, double near_val, double far_val);
};