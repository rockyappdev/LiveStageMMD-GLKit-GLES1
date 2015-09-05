/*
 *  GlTrans.cpp
 *  MMD_View
 *
 */

#include "GlTrans.h"

////////////////////////////////////////////////////////
void GlTrans::glBegin(GLenum mode)
{
	_mode = mode;
	normals = NULL;
	texs = NULL;
	vertices = new std::list<float>();
}

////////////////////////////////////////////////////////
void GlTrans::glVertex3f(float x, float y, float z)
{
	vertices->push_back( x);
	vertices->push_back( y);
	vertices->push_back( z);
	
	//
	if (normals != NULL){
		while (normals->size() < vertices->size()){
			normals->push_back( _nx);
			normals->push_back( _ny);
			normals->push_back( _nz);
		}
	}
}

////////////////////////////////////////////////////////
void GlTrans::glVertex2f(float x, float y)
{
	vertices->push_back( x);
	vertices->push_back( y);
	vertices->push_back( 0.0f);
	
	//
	if (normals != NULL){
		while (normals->size() < vertices->size()){
			normals->push_back( _nx);
			normals->push_back( _ny);
			normals->push_back( _nz);
		}
	}
}


////////////////////////////////////////////////////////
void GlTrans::glNormal3f(float nx, float ny, float nz)
{
	if (vertices != NULL)
	{
		if (normals == NULL) normals = new std::list<float>();
	}
	normals->push_back( _nx = nx);
	normals->push_back( _ny = ny);
	normals->push_back( _nz = nz);
	
}

////////////////////////////////////////////////////////
void GlTrans::glTexCoord2f(float u, float v){
	if(vertices != NULL){
		if( texs == NULL) texs = new std::list<float>();
	}
	texs->push_back( u);
	texs->push_back( v);
}

/////////////////////////////////////////////////////////
float* GlTrans::verticesToFloat(){
	int count = 0;
	
	if(vertices != NULL){
		float *temp = new float[ vertices->size()];
		
		std::list<float>::iterator it = vertices->begin(); // イテレータ
		while( it != vertices->end() )  // listの末尾まで
		{
			temp[count] = *it;
			++it;  // イテレータを１つ進める
			count++;
		}
		
		
		return temp;
	}
	return NULL;
}

/////////////////////////////////////////////////////////
float* GlTrans::normalsToFloat(){
	int count = 0;
	
	if(normals != NULL){
		float *temp = new float[ normals->size()];
		
		std::list<float>::iterator it = normals->begin(); // イテレータ
		while( it != normals->end() )  // listの末尾まで
		{
			temp[count] = *it;
			++it;  // イテレータを１つ進める
			count++;
		}
		
		
		return temp;
	}
	return NULL;
}

/////////////////////////////////////////////////////////////
float* GlTrans::texsToFloat(){
	int count = 0;
	
	if(texs != NULL){
		float *temp = new float[ texs->size()];
		
		std::list<float>::iterator it = texs->begin(); // イテレータ
		while( it != texs->end() )  // listの末尾まで
		{
			temp[count] = *it;
			++it;  // イテレータを１つ進める
			count++;
		}
		
		
		return temp;
	}
	return NULL;
	
}


/////////////////////////////////////////////////////////
void GlTrans::QuadToTriangle(float *sou, int sourceIndex, float *dest, int destIndex)
{
	memcpy( dest+destIndex, sou + sourceIndex, 9*sizeof(float));
	memcpy( dest+9+destIndex,  sou + sourceIndex, 3*sizeof(float));
	memcpy( dest+12+destIndex, sou+6 +sourceIndex, 6*sizeof(float));
}

/////////////////////////////////////////////////////////
void GlTrans::QuadToTriangle2(float *sou, int sourceIndex, float *dest, int destIndex)
{
	memcpy( dest+destIndex, sou + sourceIndex, 6*sizeof(float));
	memcpy( dest+6+destIndex,  sou + sourceIndex, 2*sizeof(float));
	memcpy( dest+8+destIndex, sou+4 +sourceIndex, 4*sizeof(float));
}


//////////////////////////////////////////////////////////
void GlTrans::glEnd()
{
	float *vs=NULL, *ns = NULL, *tx = NULL;
	int vs_size=0;
	
	if (_mode == NGL_QUADS)
	{
		_mode = GL_TRIANGLES;
		float *vsrc = verticesToFloat();
		
		vs = new float[vertices->size() * 3 / 2];
		vs_size = vertices->size()*3/2;
		for (int i = 0, j = 0; i < vertices->size(); i += 12, j += 18)
			QuadToTriangle(vsrc, i, vs, j);
		if (normals != NULL)
		{
			float *nsrc = normalsToFloat();
			ns = new float[normals->size()* 3 / 2];
			for (int i = 0, j = 0; i < normals->size(); i += 12, j += 18)
				QuadToTriangle(nsrc, i, ns, j);
		}
		if(texs != NULL)
		{
			float *txrc = texsToFloat();
			tx = new float[texs->size()* 3 / 2]; 
			for (int i = 0, j = 0; i < texs->size(); i += 8, j += 12)
				QuadToTriangle2(txrc, i, tx, j);
		}
	}
	else
	{
		vs = verticesToFloat();
		vs_size = vertices->size();
		if (normals != NULL) ns = normalsToFloat();
		if( texs != NULL) tx = texsToFloat();
		if (_mode == GL_QUAD_STRIP) _mode = GL_TRIANGLE_STRIP;
	}
	

	
	if(normals != NULL){
		delete normals;
		normals = NULL;
	}
	if(vertices != NULL){
		delete vertices;
		vertices = NULL;
	}
	if(texs != NULL){
		delete texs;
		texs = NULL;
	}
	glVertexPointer(3, GL_FLOAT, 0, vs);
	if (ns != NULL) glNormalPointer(GL_FLOAT, 0, ns);
	if( tx != NULL) glTexCoordPointer(2, GL_FLOAT, 0, tx);
	glEnableClientState(GL_VERTEX_ARRAY);
	if (ns != NULL) glEnableClientState(GL_NORMAL_ARRAY);
	if( tx != NULL) glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glDrawArrays(_mode, 0, vs_size / 3);
	glDisableClientState(GL_VERTEX_ARRAY);
	if (ns != NULL)
	{
		glDisableClientState(GL_NORMAL_ARRAY);
	}
	if(tx != NULL){
		glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	}
	
	delete [] vs;
	if(ns != NULL){
		delete [] ns;
	}
	if(tx != NULL){
		delete [] tx;
	}
	
}

//////////////////////////////////////////////////////////////////////////
void GlTrans::glFrustum(
		double left, double right, double bottom, double top, double near_val, double far_val)
{
	float *m = new float[16];
	m[0] = (float)((2 * near_val) / (right - left));
	m[5] = (float)((2 * near_val) / (top - bottom));
	m[8] = (float)((right + left) / (right - left));
	m[9] = (float)((top + bottom) / (top - bottom));
	m[10] = (float)(-(far_val + near_val) / (far_val - near_val));
	m[11] = -1;
	m[14] = (float)(-(2 * far_val * near_val) / (far_val - near_val));
	glMultMatrixf(m);
	
	//
	delete [] m;
}





