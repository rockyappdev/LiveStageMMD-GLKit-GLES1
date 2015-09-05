//**********************
// テクスチャリスト管理
//**********************

#include	<stdio.h>
#include	<string.h>
#include <OpenGLES/EAGL.h>
#include <OpenGLES/ES1/gl.h>
#include <OpenGLES/ES1/glext.h>

#import <GLKit/GLKTextureLoader.h>
#include "SZGLTextureLoader.h"

#include "TextureList.h"
#include "GlTrans.h"
#include <string.h>

#import "ScenarioData.h"

cTextureList	g_clsTextureList;

NSString *default_toonNames[] = {
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

unsigned int default_toonIDs[] = {
    0xFFFFFFFF,
    0xFFFFFFFF,
    0xFFFFFFFF,
    0xFFFFFFFF,
    0xFFFFFFFF,
    0xFFFFFFFF,
    0xFFFFFFFF,
    0xFFFFFFFF,
    0xFFFFFFFF,
    0xFFFFFFFF,
    0xFFFFFFFF,
};

#define MAX_DEFAULT_TOONS   11

//================
// コンストラクタ
//================
cTextureList::cTextureList( void ) : m_pTextureList( NULL )
{

}

//==============
// デストラクタ
//==============
cTextureList::~cTextureList( void )
{
	TextureData	*pTemp = m_pTextureList,
				*pNextTemp;

	while( pTemp )
	{
		pNextTemp = pTemp->pNext;

		glDeleteTextures( 1, &pTemp->uiTexID );
		delete pTemp;

		pTemp = pNextTemp;
	}

	m_pTextureList = NULL;
}

unsigned int cTextureList::getTexture(int ui)
{
    NSString *dirpath = nil;
    unsigned int	uiTexID = -1;

	if (ui > MAX_DEFAULT_TOONS) {
        return uiTexID;
    }
    
    if (default_toonIDs[ui] != 0xFFFFFFFF) {
        uiTexID = default_toonIDs[ui];
        return uiTexID;
    }
    
    if (dirpath == nil) {
        dirpath = [[[NSBundle mainBundle] pathForResource:@"toon00" ofType:@"bmp" inDirectory:@"Res_mmd"] stringByDeletingLastPathComponent];
    }

    if (dirpath != nil) {
        NSString *filePath = [NSString stringWithFormat:@"%@/%@", dirpath, default_toonNames[ui]];
        uiTexID = getTexture(filePath);
        default_toonIDs[ui] = uiTexID;
        return uiTexID;
    } else {
        NSLog(@"xxx cTextureList::getTexture dirpath = [nil]");
    }

    return uiTexID;
    
}

unsigned int cTextureList::getTextureSystem(NSString *fileName)
{
    NSString *dirpath = nil;
    
    NSLog(@"... cTextureList::getTextureSystem fileName=[%@]", fileName);
    
    if (dirpath == nil) {
        dirpath = [[[NSBundle mainBundle] pathForResource:@"toon00" ofType:@"bmp" inDirectory:@"Res_mmd"] stringByDeletingLastPathComponent];
    }
    
    NSString *filePath = [dirpath stringByAppendingPathComponent:fileName];
	
    return getTexture(filePath);
    
}


unsigned int cTextureList::getTexture(NSString *filePath )
{
	unsigned int	uiTexID = -1;
	
    NSLog(@"... cTextureList::getTexture filePath=[%@]", filePath);

	// まずはすでに読み込まれているかどうか検索
	if( findTexture( filePath, &uiTexID ) )
	{
        
        //NSLog(@"... found the texture[%u]", uiTexID);
		return uiTexID;
	}
    
	if( createTexture( filePath, &uiTexID ) )
	{

		TextureData	*pNew = new TextureData;

        pNew->name = [filePath copy];
		pNew->uiTexID = uiTexID;
		pNew->uiRefCount = 1;

		pNew->pNext = m_pTextureList;
		m_pTextureList = pNew;

        NSLog(@"... cTextureList::getTexture created the uiTexID[%i]", uiTexID);
		return uiTexID;
	}

    NSLog(@"... cTextureList::getTexture failed to create texture[%@]", filePath);

	return -1;
}

unsigned int cTextureList::getTexture(NSData *nsData, NSString *filePath, int textureLib )
{
    unsigned int	uiTexID = -1;
	
	//char tempPath[100];
	//strcpy(tempPath, szFileName+8);
	
	//fprintf(stderr,"Debug: Tex file is %s¥n", tempPath);
    
	if( findTexture( filePath, &uiTexID ) )
	{
		return uiTexID;
	}
    
	if( createTexture(nsData, filePath, &uiTexID, textureLib ) )
	{
		TextureData	*pNew = new TextureData;
        
		pNew->name = [filePath copy];
		pNew->uiTexID = uiTexID;
		pNew->uiRefCount = 1;
        
		pNew->pNext = m_pTextureList;
		m_pTextureList = pNew;
        
		return uiTexID;
        
    } else {
        NSString *fileName = [filePath lastPathComponent];
        
        uiTexID = getTextureSystem(fileName);
        
	}
    
	return -1;	// テクスチャ読み込みか作成失敗
}

//----------------------------------
// 読み込み済みのテクスチャから検索
//----------------------------------
bool cTextureList::findTexture( NSString *filepath, unsigned int *puiTexID )
{
	TextureData	*pTemp = m_pTextureList;

    NSLog(@"xxx cTextureList::findTexture filepath=[%@]", filepath);
    
	while( pTemp )
	{
        if( [pTemp->name isEqualToString:filepath])
		{
			*puiTexID = pTemp->uiTexID;
			pTemp->uiRefCount++;

			return true;
		}

		pTemp = pTemp->pNext;
	}

	return false;
}

bool cTextureList::createTexture( NSString *filePath, unsigned int *puiTexID )
{
	unsigned char   *pData;

    GLuint      mTextureName;
    CGSize      mImageSize;
    CGSize      mTextureSize;

    NSLog(@"... cTextureList::createTexture(%@)", filePath);
    
    if (filePath == NULL)
    {
        NSLog(@"... cTextureList::createTexture filePath is NULL");
        return false;
    }

    NSFileManager *fm = [[NSFileManager alloc] init];
    NSData *nsData = [fm contentsAtPath:filePath];
    
	if( nsData == nil )
    {
        NSLog(@"*** cTextureList::createTexture Failed fopen(%@)", filePath);
        return false;
    }
    
    mTextureName = SZGLLoadTexture(nsData, &mImageSize, &mTextureSize);
    if (mTextureName != -1) {
        *puiTexID = mTextureName;

        NSLog(@"... cTextureList::createTexture created: texure[%u]=[%@]", mTextureName, filePath);
        return true;
    }
    
    
    /*********

	// メモリ確保
	pData = (unsigned char *)malloc( (size_t)nsData.length );
    
    if (pData == NULL) {
        return false;
    }
    
	// 読み込み

	[nsData getBytes:pData];
     ********/
    
    pData = (unsigned char*) [nsData bytes];
    
	bool	bRet = false;
    
    NSString *fileExt = filePath.pathExtension.lowercaseString;
    
    if ([fileExt isEqualToString:@"bmp"]
        || [fileExt isEqualToString:@"spa"] || [fileExt isEqualToString:@"sph"] ) {
        //NSLog(@"... loading BMP=[%s]", filePath.UTF8String);
		bRet = createFromBMP( pData, puiTexID );
	} else if([fileExt isEqualToString:@"tga"] ) {
        //NSLog(@"... loading TGA=[%s]", filePath.UTF8String);
		bRet = createFromTGA( pData, puiTexID );
	} else {
        NSLog(@"*** cTextureList::createTexture unrecognized fileExt = [%@]", fileExt);
    }

	return bRet;
}

bool cTextureList::createTexture(NSData *nsData, NSString *filePath, unsigned int *puiTexID, int textureLib)
{
	unsigned char   *pData;
    GLuint      mTextureName;
    CGSize      mImageSize;
    CGSize      mTextureSize;
    bool        bRet = false;
    GLKTextureInfo *texInfo;
    NSError *nsError;

    NSLog(@"... cTextureList::createTexture: filePath=[%@]", filePath);
    
	if( nsData != nil ) {
        
#ifdef USE_MALLOC_FOR_NSDATA
        fpos_t	fposFileSize;
        fposFileSize = nsData.length;
        pData = (unsigned char *)malloc( (size_t)fposFileSize );
        if (pData == NULL) {
            NSLog(@"***** could not allocate pData for malloc(%lld)", fposFileSize);
            return false;
        }
        [nsData getBytes:pData];
#else
        pData = (unsigned char*) [nsData bytes];
#endif
        NSString *fileExt = filePath.pathExtension.lowercaseString;
        
        bRet = false;
        
        if (textureLib) {
            // this option to support 銀獅式モデル目, but does not work for Alice and 東北ずん子目
            if (bRet == false) {
                // use GLKit to create a texture
                texInfo  = [GLKTextureLoader textureWithContentsOfData:nsData options:nil error:&nsError];
                if (texInfo != nil) {
                    NSLog(@"... GLKTexuteLoader loaded texture from filePath=[%@]", filePath);
                    *puiTexID = texInfo.name;
                    bRet = true;
                }
            }
            
        }

        if(bRet == false && ([fileExt isEqualToString:@"tga"]
                             || [fileExt isEqualToString:@"spa"] || [fileExt isEqualToString:@"sph"]) ) {
            NSLog(@"... loading TGA=[%@]", filePath);
            bRet = createFromTGA( pData, puiTexID );
        }
        
        if (bRet == false) {
            // use GLKit to create a texture
            texInfo  = [GLKTextureLoader textureWithContentsOfData:nsData options:nil error:&nsError];
            if (texInfo != nil) {
                NSLog(@"... GLKTexuteLoader loaded texture from filePath=[%@]", filePath);
                *puiTexID = texInfo.name;
                bRet = true;
            }
        }
        
        if (bRet == false && ([fileExt isEqualToString:@"bmp"]
                              || [fileExt isEqualToString:@"spa"] || [fileExt isEqualToString:@"sph"]) ) {
            NSLog(@"... loading BMP=[%@]", filePath);
            bRet = createFromBMP( pData, puiTexID );
            
        }
        
        if (bRet == false) {
            NSLog(@"... loading imagefile=[%@]", filePath);
            mTextureName = SZGLLoadTexture(nsData, &mImageSize, &mTextureSize);
            *puiTexID = mTextureName;
            if (mTextureName != GL_INVALID_VALUE) {
                bRet = true;
            }
        }
        
        
#ifdef USE_MALLOC_FOR_NSDATA
        free( pData );
#endif
        
    }
    
	return bRet;
}



//-------------------------------
// BMPファイルからテクスチャ作成
//-------------------------------
bool cTextureList::createFromBMP( const unsigned char *pData, unsigned int *puiTexID )
{
    NSLog(@"... cTextureList::createFromBMP entered");
    
#pragma pack( push, 1 )
	// BMPファイルヘッダ構造体
	struct BMPFileHeader
	{
		unsigned short	bfType;			// ファイルタイプ
		unsigned int	bfSize;			// ファイルサイズ
		unsigned short	bfReserved1;
		unsigned short	bfReserved2;
		unsigned int	bfOffBits;		// ファイル先頭から画像データまでのオフセット
	};

	// BMP情報ヘッダ構造体
	struct BMPInfoHeader
	{
		unsigned int	biSize;			// 情報ヘッダーのサイズ
		int				biWidth;		// 幅
		int				biHeight;		// 高さ(正ならば下から上、負ならば上から下)
		unsigned short	biPlanes;		// プレーン数(常に1)
		unsigned short	biBitCount;		// 1画素あたりのビット数
		unsigned int	biCompression;
		unsigned int	biSizeImage;
		int				biXPelsPerMeter;
		int				biYPelsPerMeter;
		unsigned int	biClrUsed;		// パレットの色数
		unsigned int	biClrImportant;
	};

	// パレットデータ
	struct RGBQuad
	{
		unsigned char	rgbBlue;
		unsigned char	rgbGreen;
		unsigned char	rgbRed;
		unsigned char	rgbReserved;
	};
#pragma pack( pop )

	// BMPファイルヘッダ
	BMPFileHeader	*pBMPFileHeader = (BMPFileHeader *)pData;

	if( pBMPFileHeader->bfType != ('B' | ('M' << 8)) )
	{
		return false;	// ファイルタイプが違う
	}

	// BMP情報ヘッダ
	BMPInfoHeader	*pBMPInfoHeader = (BMPInfoHeader *)(pData + sizeof(BMPFileHeader));

	if( pBMPInfoHeader->biBitCount == 1 || pBMPInfoHeader->biCompression != 0 )
	{
		return false;	// 1ビットカラーと圧縮形式には未対応
	}

	// カラーパレット
	RGBQuad			*pPalette = NULL;

	if( pBMPInfoHeader->biBitCount < 24 )
	{
		pPalette = (RGBQuad *)(pData + sizeof(BMPFileHeader) + sizeof(BMPInfoHeader));
	}

	// 画像データの先頭へ
	pData += pBMPFileHeader->bfOffBits;

	// 画像データの1ラインのバイト数
	unsigned int	uiLineByte = ((pBMPInfoHeader->biWidth * pBMPInfoHeader->biBitCount + 0x1F) & (~0x1F)) / 8;

	// テクスチャイメージの作成
	unsigned char	*pTexelData = (unsigned char *)malloc( pBMPInfoHeader->biWidth * pBMPInfoHeader->biHeight * 4 ),
					*pTexelDataTemp = pTexelData;
	
	NSLog(@"... color=[%d]", pBMPInfoHeader->biBitCount);

	if( pBMPInfoHeader->biBitCount == 4 )
	{
		// 4Bitカラー
		for( int h = pBMPInfoHeader->biHeight - 1 ; h >= 0 ; h-- )
		{
			const unsigned char *pLineTop = &pData[uiLineByte * h];

			for( int w = 0 ; w < (pBMPInfoHeader->biWidth >> 1) ; w++ )
			{
				*pTexelDataTemp = pPalette[(pLineTop[w] >> 4) & 0x0F].rgbRed;	pTexelDataTemp++;
				*pTexelDataTemp = pPalette[(pLineTop[w] >> 4) & 0x0F].rgbGreen;	pTexelDataTemp++;
				*pTexelDataTemp = pPalette[(pLineTop[w] >> 4) & 0x0F].rgbBlue;	pTexelDataTemp++;
				*pTexelDataTemp = 255;											pTexelDataTemp++;

				*pTexelDataTemp = pPalette[(pLineTop[w]     ) & 0x0F].rgbRed;	pTexelDataTemp++;
				*pTexelDataTemp = pPalette[(pLineTop[w]     ) & 0x0F].rgbGreen;	pTexelDataTemp++;
				*pTexelDataTemp = pPalette[(pLineTop[w]     ) & 0x0F].rgbBlue;	pTexelDataTemp++;
				*pTexelDataTemp = 255;											pTexelDataTemp++;
			}
		}
	}
	else if( pBMPInfoHeader->biBitCount == 8 )
	{
		// 8Bitカラー
		for( int h = pBMPInfoHeader->biHeight - 1 ; h >= 0 ; h-- )
		{
			const unsigned char *pLineTop = &pData[uiLineByte * h];

			for( int w = 0 ; w < pBMPInfoHeader->biWidth ; w++ )
			{
				*pTexelDataTemp = pPalette[pLineTop[w]].rgbRed;		pTexelDataTemp++;
				*pTexelDataTemp = pPalette[pLineTop[w]].rgbGreen;	pTexelDataTemp++;
				*pTexelDataTemp = pPalette[pLineTop[w]].rgbBlue;	pTexelDataTemp++;
				*pTexelDataTemp = 255;								pTexelDataTemp++;
			}
		}
	}
	else if( pBMPInfoHeader->biBitCount == 24 )
	{
		// 24Bitカラー
		for( int h = pBMPInfoHeader->biHeight - 1 ; h >= 0 ; h-- )
		{
			const unsigned char *pLineTop = &pData[uiLineByte * h];

			for( int w = 0 ; w < pBMPInfoHeader->biWidth ; w++ )
			{
				*pTexelDataTemp = pLineTop[w * 3 + 2];	pTexelDataTemp++;
				*pTexelDataTemp = pLineTop[w * 3 + 1];	pTexelDataTemp++;
				*pTexelDataTemp = pLineTop[w * 3    ];	pTexelDataTemp++;
				*pTexelDataTemp = 255;					pTexelDataTemp++;
			}
		}
	}
	else if( pBMPInfoHeader->biBitCount == 32 )
	{
		// 32Bitカラー
		for( int h = pBMPInfoHeader->biHeight - 1 ; h >= 0 ; h-- )
		{
			const unsigned char *pLineTop = &pData[uiLineByte * h];

			for( int w = 0 ; w < pBMPInfoHeader->biWidth ; w++ )
			{
				*pTexelDataTemp = pLineTop[w * 4 + 2];	pTexelDataTemp++;
				*pTexelDataTemp = pLineTop[w * 4 + 1];	pTexelDataTemp++;
				*pTexelDataTemp = pLineTop[w * 4    ];	pTexelDataTemp++;
				*pTexelDataTemp = pLineTop[w * 4 + 3];	pTexelDataTemp++;
			}
		}
	}

	// テクスチャの作成
	glGenTextures( 1, puiTexID );

	glBindTexture( GL_TEXTURE_2D, *puiTexID );
	glPixelStorei( GL_UNPACK_ALIGNMENT, 4 );

	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT );
	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT );

	glTexImage2D(	GL_TEXTURE_2D, 0, GL_RGBA, 
					pBMPInfoHeader->biWidth, pBMPInfoHeader->biHeight,
					0, GL_RGBA, GL_UNSIGNED_BYTE,
					pTexelData );

    //NSLog(@"... puiTexID = [%u]", *puiTexID);
	//float	fPrioritie = 1.0f;
	//glPrioritizeTextures( 1, puiTexID, &fPrioritie );

	free( pTexelData );

	return true;
}

//-------------------------------
// TGAファイルからテクスチャ作成
//-------------------------------
bool cTextureList::createFromTGA( const unsigned char *pData, unsigned int *puiTexID )
{
#pragma pack( push, 1 )
	struct TGAFileHeader
	{
		unsigned char	tfIdFieldLength;
		unsigned char	tfColorMapType;
		unsigned char	tfImageType;
		unsigned short	tfColorMapIndex;
		unsigned short	tfColorMapLength;
		unsigned char	tfColorMapSize;
		unsigned short	tfImageOriginX;
		unsigned short	tfImageOriginY;
		unsigned short	tfImageWidth;
		unsigned short	tfImageHeight;
        unsigned char	tfBitPerPixel;
        unsigned char	tfDiscripter;
	};
#pragma pack( pop )

	TGAFileHeader	*pTgaFileHeader = (TGAFileHeader *)pData;

/*
0	イメージなし
1	インデックスカラー（256色）
2	フルカラー
3	白黒
9	インデックスカラー。RLE圧縮
A	フルカラー。RLE圧縮
B	白黒。RLE圧縮
*/
	if( pTgaFileHeader->tfImageType != 0x02 && pTgaFileHeader->tfImageType != 0x0A )
	{
		// 非対応フォーマット
		return false;
	}

	pData += sizeof( TGAFileHeader );

	unsigned char	*pTexelData = (unsigned char *)malloc( pTgaFileHeader->tfImageWidth * pTgaFileHeader->tfImageHeight * 4 ),
					*pTexelDataTemp = pTexelData;

	if( pTgaFileHeader->tfImageType == 0x02 && pTgaFileHeader->tfBitPerPixel == 24 )
	{
		// 非圧縮24Bitカラー
		if( pTgaFileHeader->tfDiscripter & 0x20 )
		{
			// 上から下へ
			for( int h = 0 ; h < pTgaFileHeader->tfImageHeight ; h++ )
			{
				const unsigned char *pLineTop = &pData[(pTgaFileHeader->tfImageWidth * 3) * h];

				for( int w = 0 ; w < pTgaFileHeader->tfImageWidth ; w++ )
				{
					*pTexelDataTemp = pLineTop[w * 3 + 2];	pTexelDataTemp++;
					*pTexelDataTemp = pLineTop[w * 3 + 1];	pTexelDataTemp++;
					*pTexelDataTemp = pLineTop[w * 3    ];	pTexelDataTemp++;
					*pTexelDataTemp = 255;					pTexelDataTemp++;
				}
			}
		}
		else
		{
			// 下から上へ
			for( int h = pTgaFileHeader->tfImageHeight - 1 ; h >= 0 ; h-- )
			{
				const unsigned char *pLineTop = &pData[(pTgaFileHeader->tfImageWidth * 3) * h];

				for( int w = 0 ; w < pTgaFileHeader->tfImageWidth ; w++ )
				{
					*pTexelDataTemp = pLineTop[w * 3 + 2];	pTexelDataTemp++;
					*pTexelDataTemp = pLineTop[w * 3 + 1];	pTexelDataTemp++;
					*pTexelDataTemp = pLineTop[w * 3    ];	pTexelDataTemp++;
					*pTexelDataTemp = 255;					pTexelDataTemp++;
				}
			}
		}
	}
	else if( pTgaFileHeader->tfImageType == 0x02 && pTgaFileHeader->tfBitPerPixel == 32 )
	{
		// 非圧縮32Bitカラー
		if( pTgaFileHeader->tfDiscripter & 0x20 )
		{
			// 上から下へ
			for( int h = 0 ; h < pTgaFileHeader->tfImageHeight ; h++ )
			{
				const unsigned char *pLineTop = &pData[(pTgaFileHeader->tfImageWidth * 4) * h];

				for( int w = 0 ; w < pTgaFileHeader->tfImageWidth ; w++ )
				{
					*pTexelDataTemp = pLineTop[w * 4 + 2];	pTexelDataTemp++;
					*pTexelDataTemp = pLineTop[w * 4 + 1];	pTexelDataTemp++;
					*pTexelDataTemp = pLineTop[w * 4    ];	pTexelDataTemp++;
					*pTexelDataTemp = pLineTop[w * 4 + 3];	pTexelDataTemp++;
				}
			}
		}
		else
		{
			// 下から上へ
			for( int h = pTgaFileHeader->tfImageHeight - 1 ; h >= 0 ; h-- )
			{
				const unsigned char *pLineTop = &pData[(pTgaFileHeader->tfImageWidth * 4) * h];

				for( int w = 0 ; w < pTgaFileHeader->tfImageWidth ; w++ )
				{
					*pTexelDataTemp = pLineTop[w * 4 + 2];	pTexelDataTemp++;
					*pTexelDataTemp = pLineTop[w * 4 + 1];	pTexelDataTemp++;
					*pTexelDataTemp = pLineTop[w * 4    ];	pTexelDataTemp++;
					*pTexelDataTemp = pLineTop[w * 4 + 3];	pTexelDataTemp++;
				}
			}
		}
	}
	else if( pTgaFileHeader->tfImageType == 0x0A )
	{
		// 圧縮24/32Bitカラー
		if( pTgaFileHeader->tfDiscripter & 0x20 )
		{
			// 上から下へ
			short	nPosX = 0,
					nPosY = 0;

            while( nPosY < pTgaFileHeader->tfImageHeight )
            {
                bool	bCompress =	((*pData) & 0x80) == 0x80;
                short	nLength = ((*pData) & 0x7F) + 1;

				pData++;

                if( bCompress )
                {
                    for( short i = 0 ; i < nLength ; i++ )
                    {
						*pTexelDataTemp = pData[2];	pTexelDataTemp++;
						*pTexelDataTemp = pData[1];	pTexelDataTemp++;
						*pTexelDataTemp = pData[0];	pTexelDataTemp++;

						if( pTgaFileHeader->tfBitPerPixel == 32 )	*pTexelDataTemp = pData[3];
						else										*pTexelDataTemp = 255;
						pTexelDataTemp++;

						nPosX++;
						if( pTgaFileHeader->tfImageWidth <= nPosX )
						{
							nPosX = 0;
							nPosY++;
						}
                    }

					if( pTgaFileHeader->tfBitPerPixel == 32 )	pData += 4;
					else										pData += 3;
                }
                else
                {
                    for( short i = 0 ; i < nLength ; i++ )
                    {
						*pTexelDataTemp = pData[2];	pTexelDataTemp++;
						*pTexelDataTemp = pData[1];	pTexelDataTemp++;
						*pTexelDataTemp = pData[0];	pTexelDataTemp++;

						if( pTgaFileHeader->tfBitPerPixel == 32 )	*pTexelDataTemp = pData[3];
						else										*pTexelDataTemp = 255;
						pTexelDataTemp++;

						if( pTgaFileHeader->tfBitPerPixel == 32 )	pData += 4;
						else										pData += 3;

                        nPosX++;
                        if( pTgaFileHeader->tfImageWidth <= nPosX )
                        {
                            nPosX = 0;
                            nPosY++;
                        }
                    }
                }
            }
		}
		else
		{
			// 下から上へ
			short	nPosX = 0,
					nPosY = pTgaFileHeader->tfImageHeight - 1;

            while( 0 <= nPosY )
            {
                bool	bCompress =	((*pData) & 0x80) == 0x80;
                short	nLength = ((*pData) & 0x7F) + 1;

				pData++;

                if( bCompress )
                {
                    for( short i = 0 ; i < nLength ; i++ )
                    {
						pTexelDataTemp = &pTexelData[(nPosX + nPosY * pTgaFileHeader->tfImageWidth) * 4];

						*pTexelDataTemp = pData[2];	pTexelDataTemp++;
						*pTexelDataTemp = pData[1];	pTexelDataTemp++;
						*pTexelDataTemp = pData[0];	pTexelDataTemp++;

						if( pTgaFileHeader->tfBitPerPixel == 32 )	*pTexelDataTemp = pData[3];
						else										*pTexelDataTemp = 255;

						nPosX++;
						if( pTgaFileHeader->tfImageWidth <= nPosX )
						{
							nPosX = 0;
							nPosY--;
						}
                    }

					if( pTgaFileHeader->tfBitPerPixel == 32 )	pData += 4;
					else										pData += 3;
                }
                else
                {
                    for( short i = 0 ; i < nLength ; i++ )
                    {
						pTexelDataTemp = &pTexelData[(nPosX + nPosY * pTgaFileHeader->tfImageWidth) * 4];

						*pTexelDataTemp = pData[2];	pTexelDataTemp++;
						*pTexelDataTemp = pData[1];	pTexelDataTemp++;
						*pTexelDataTemp = pData[0];	pTexelDataTemp++;

						if( pTgaFileHeader->tfBitPerPixel == 32 )	*pTexelDataTemp = pData[3];
						else										*pTexelDataTemp = 255;

						if( pTgaFileHeader->tfBitPerPixel == 32 )	pData += 4;
						else										pData += 3;

                        nPosX++;
                        if( pTgaFileHeader->tfImageWidth <= nPosX )
                        {
                            nPosX = 0;
                            nPosY--;
                        }
                    }
                }
            }
		}
	}

	// テクスチャの作成
	glGenTextures( 1, puiTexID );

	glBindTexture( GL_TEXTURE_2D, *puiTexID );
	glPixelStorei( GL_UNPACK_ALIGNMENT, 4 );

	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT );
	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT );

	glTexImage2D(	GL_TEXTURE_2D, 0, GL_RGBA, 
					pTgaFileHeader->tfImageWidth, pTgaFileHeader->tfImageHeight,
					0, GL_RGBA, GL_UNSIGNED_BYTE,
					pTexelData );

	//float	fPrioritie = 1.0f;
	//glPrioritizeTextures( 1, puiTexID, &fPrioritie );

	free( pTexelData );

	return true;
}

//==============
// デバッグ表示
//==============
void cTextureList::debugDraw( void )
{
	glDisable( GL_DEPTH_TEST );
	glDisable( GL_LIGHTING );

	glMatrixMode( GL_PROJECTION );
	glPushMatrix();
	glLoadIdentity();
	glOrthof( 0.0f, (float)320.0, 0.0f, (float)480.0, 1.0, -1.0 );

	glMatrixMode( GL_MODELVIEW );
	glPushMatrix();
	glLoadIdentity();

	glColor4f( 1.0f, 1.0f, 1.0f, 1.0f );

	glEnable( GL_TEXTURE_2D );

	TextureData	*pTemp = m_pTextureList;
	float		fPosX = 0.0f,
				fPosY = 480.0;

	#define		DISP_SIZE	64.0f

	while( pTemp )
	{
		glBindTexture( GL_TEXTURE_2D, pTemp->uiTexID );

		GlTrans te;
		te.glBegin( GL_TRIANGLE_FAN );
			te.glTexCoord2f( 1.0f, 1.0f );	te.glVertex2f( fPosX,             fPosY - DISP_SIZE );
			te.glTexCoord2f( 1.0f, 0.0f );	te.glVertex2f( fPosX + DISP_SIZE, fPosY - DISP_SIZE );
			te.glTexCoord2f( 0.0f, 0.0f );	te.glVertex2f( fPosX + DISP_SIZE, fPosY             );
			te.glTexCoord2f( 0.0f, 1.0f );	te.glVertex2f( fPosX,             fPosY             );
		te.glEnd();

		fPosX += DISP_SIZE + 2.0f;
		if( fPosX >= 320.0f - DISP_SIZE )
		{
			fPosX  =             0.0f;
			fPosY -= DISP_SIZE + 2.0f;
		}

		pTemp = pTemp->pNext;
	}

	glMatrixMode( GL_PROJECTION );
	glPopMatrix();
	glMatrixMode( GL_MODELVIEW );
	glPopMatrix();

	glEnable( GL_DEPTH_TEST );
	glEnable( GL_LIGHTING );
}

//================
// テクスチャ解放
//================
void cTextureList::releaseTexture( unsigned int uiTexID )
{
	TextureData	*pTemp = m_pTextureList,
				*pPrevTemp = NULL;

	while( pTemp )
	{
		if( pTemp->uiTexID == uiTexID )
		{
			pTemp->uiRefCount--;
			if( pTemp->uiRefCount <= 0 )
			{
				glDeleteTextures( 1, &pTemp->uiTexID );

				if( pPrevTemp )	pPrevTemp->pNext = pTemp->pNext;
				else			m_pTextureList = pTemp->pNext;

				delete pTemp;
			}

			return;
		}

		pPrevTemp = pTemp;
		pTemp = pTemp->pNext;
	}
}

void cTextureList::releaseAllTextures( void )
{
	TextureData	*pTemp = m_pTextureList,
    *pNextTemp;
    
	while( pTemp )
	{
		pNextTemp = pTemp->pNext;
        
		glDeleteTextures( 1, &pTemp->uiTexID );
		delete pTemp;
        
		pTemp = pNextTemp;
	}
    
	m_pTextureList = NULL;
}
