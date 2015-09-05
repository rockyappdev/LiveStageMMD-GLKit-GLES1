//
//  SZGLTextureLoader.h
//  Texture Loading Sample
//
//  Created by numata on 09/08/16.
//  Copyright 2009 Satoshi Numata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

GLuint SZGLLoadTexture(NSData *data, CGSize *imageSize, CGSize *textureSize);

