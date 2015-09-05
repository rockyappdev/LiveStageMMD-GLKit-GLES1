//**********************
// テクスチャリスト管理
//**********************

#ifndef	_TEXTURELIST_H_
#define	_TEXTURELIST_H_

@class ScenarioData;
@class NSString, NSData;

class cTextureList
{
	private :

    struct TextureData
    {
        unsigned int	uiTexID;
        unsigned int	uiRefCount;
        
        TextureData		*pNext;
        
        NSString        *name;
    };
    
    TextureData		*m_pTextureList;
    
    bool findTexture( NSString *name, unsigned int *puiTexID );
    bool createTexture( NSString *filePath, unsigned int *puiTexID );
    bool createFromBMP( const unsigned char *pData, unsigned int *puiTexID );
    bool createFromTGA( const unsigned char *pData, unsigned int *puiTexID );

    public :

    cTextureList( void );
    ~cTextureList( void );
    
    unsigned int getTextureSystem(NSString *fileName);
    unsigned int getTexture(int id);
    unsigned int getTexture(NSString *filePath );
    unsigned int getTexture(NSData *nsData, NSString *filePath, int textureLib );
    bool createTexture( NSData *nsData, NSString *filePath, unsigned int *puiTexID, int textureLib );
    
    void debugDraw( void );
    
    void releaseTexture( unsigned int uiTexID );
    void releaseAllTextures( void );

};

#endif	// _TEXTURELIST_H_
