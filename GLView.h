/*
 * Original Windows comment:
 * "This code was created by Jeff Molofee 2000
 * A HUGE thanks to Fredric Echols for cleaning up
 * and optimizing the base code, making it more flexible!
 * If you've found this code useful, please let me know.
 * Visit my site at nehe.gamedev.net"
 * 
 * Cocoa port by Bryan Blackburn 2002; www.withay.com
 */

/* GLView.h */

#import <Cocoa/Cocoa.h>
#import "GLString.h"
#import "MDGUI.h"
#import <vector>
#import "World.h"

extern NSMutableArray* keys;
void UpdateKeys(id sender);

extern NSMutableArray* strings;
extern NSMutableArray* textures;

extern unsigned int countFPS;
extern unsigned int realFPS;

extern BOOL isDrawing, waitForDraw;

extern NSMutableArray* textBox;
extern NSMutableString* reserveMessage;
extern unsigned int textPointer;
extern BOOL waitForKeyText;
extern id textTarget;
extern SEL textAction;
extern std::vector<double> regs;

@interface GLView : NSOpenGLView
{
	int colorBits, depthBits;
	BOOL fullscreen;
	unsigned int timerFps;
	unsigned int effect;
	double seconds;
	id target;
	SEL action;
	NSRect lastFrame;
}

- (id) initWithFrame:(NSRect)frame colorBits:(int)numColorBits
		   depthBits:(int)numDepthBits fullscreen:(BOOL)runFullScreen;
- (void) reshape;
- (void) drawRect:(NSRect)rect;
- (GLString*) loadString:(NSString *)str textColor:(NSColor *)text withSize:(double)dsize
			withFontName:(NSString *)fontName;
- (void) drawString:(GLString *)string atLocation:(NSPoint)location 
		   rotation:(float)rot alignment:(NSTextAlignment)align;
- (void) writeString: (NSString*) str textColor: (NSColor*) text 
			boxColor: (NSColor*) box borderColor: (NSColor*) border
		  atLocation: (NSPoint) location withSize: (double) dsize 
		withFontName: (NSString*) fontName rotation:(float) rot
		   alignment: (NSTextAlignment)align;
- (void) textBox: (NSString*) text target:(id)tar action:(SEL)done;
- (BOOL) loadBitmap:(NSString *)file;
- (BOOL) loadBitmapFromData:(NSData *)file;
- (void) clearTextures;
- (void) releaseImage:(unsigned int)val;
- (void) setFullScreen:(BOOL)full;
- (BOOL) fullscreen;
- (void) goBack;
- (void) goLeft;
- (void) goRight;
- (void) dealloc;

@end
