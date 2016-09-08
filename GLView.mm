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

/* GLView.m */

#import "GLView.h"
#import <OpenGL/OpenGL.h>
#import <OpenGL/gl.h>
#import <OpenGL/glu.h>
#import "Controller.h"

NSMutableArray* keys = nil;
void UpdateKeys(id sender)
{
    WorldKeyDown();
	for (int z = 0; z < [ keys count ]; z++)
	{
		int key = [ [ keys objectAtIndex:z ] intValue ];
		switch (key)
		{
			case ' ':
			{
				//if (something)
				//	break;
			}
            case NSCarriageReturnCharacter:
            case NSNewlineCharacter:
            case NSEnterCharacter:
            {
                if (textBox && waitForKeyText)
                {
                    [ textBox release ];
                    textBox = nil;
                    waitForKeyText = FALSE;
					if (reserveMessage && [ reserveMessage length ] != 0)
						[ sender textBox:reserveMessage target:textTarget action:textAction ];
					else
					{
						if (textTarget && textAction && [ textTarget respondsToSelector:textAction ])
							[ textTarget performSelector:textAction ];
						if (textTarget)
							textTarget = nil;
						if (textAction)
							textAction = nil;
						canMove = TRUE;
						if (reserveMessage)
						{
							[ reserveMessage release ];
							reserveMessage = nil;
						}
					}
                    [ keys removeAllObjects ];
                }
                break;
            }
			default:
				break;
		}
	}
}

NSMutableArray* strings = nil;
NSMutableArray* textures = nil;

unsigned int countFPS = 0;
unsigned int realFPS = 60;

unsigned int textPointer = 0;
NSMutableArray* textBox = nil;
NSMutableString* reserveMessage = nil;
BOOL waitForKeyText = FALSE;
id textTarget = nil;
SEL textAction = nil;
std::vector<double> regs;

BOOL isDrawing = FALSE, waitForDraw = FALSE;

@interface GLView (InternalMethods)
- (NSOpenGLPixelFormat *) createPixelFormat:(NSRect)frame;
- (BOOL) initGL;
@end

@implementation GLView

- (id) initWithFrame:(NSRect)frame colorBits:(int)numColorBits
		   depthBits:(int)numDepthBits fullscreen:(BOOL)runFullScreen
{
	NSOpenGLPixelFormat *pixelFormat;
	
	colorBits = numColorBits;
	depthBits = numDepthBits;
	pixelFormat = [ self createPixelFormat:frame ];
	if( pixelFormat != nil )
	{
		self = [ super initWithFrame:frame pixelFormat:pixelFormat ];
		[ pixelFormat release ];
		if( self )
		{
			[ [ self openGLContext ] makeCurrentContext ];
			[ self reshape ];
			if( ![ self initGL ] )
			{
				[ self clearGLContext ];
				self = nil;
			}
			keys = [ [ NSMutableArray alloc ] init ];
			strings = [ [ NSMutableArray alloc ] init ];
			textures = [ [ NSMutableArray alloc ] init ];
			srand(0);
			resolution = [ self bounds ].size;
		}
	}
	else
		self = nil;
	
	return self;
}

- (void) textBox: (NSString*) text target:(id)tar action:(SEL)done
{
    textPointer = 0;
    canMove = FALSE;
    NSMutableString* realString = [ [ NSMutableString alloc ] initWithFormat:@" %@", text ];
	[ realString replaceOccurrencesOfString:@"\n" withString:@"\n " options:0 range:
	 NSMakeRange(0, [ realString length ]) ];
	[ realString replaceOccurrencesOfString:@"\t" withString:@"     " options:0 range:
	 NSMakeRange(0, [ realString length ]) ];
	
	if (reserveMessage)
	{
		[ reserveMessage release ];
		reserveMessage = nil;
	}
    if (textBox)
        [ textBox release ];
    textBox = [ [ NSMutableArray alloc ] init ];
	float realWidth = resolution.width * 0.75;
	float realHeight = resolution.height * 0.26;
	unsigned int lastSpace = 0;
	unsigned int lastLine = 0;
	float height = 0;
	for (int z = 0; z < [ realString length ]; z++)
	{
		if ([ realString characterAtIndex:z ] == ' ' ||
			[ realString characterAtIndex:z ] == '-' ||
			[ realString characterAtIndex:z ] == '\n' ||
			[ realString characterAtIndex:z ] == '\t')
			lastSpace = z;
        GLString* temp = [ self loadString:[ realString substringWithRange:NSMakeRange(lastLine, z + 1 - lastLine) ] textColor:[ NSColor whiteColor ] withSize:40 withFontName:@"Helvetica" ];
		
		if ([ temp frameSize ].width >= realWidth || 
			[ realString characterAtIndex:z ] == '\n')
		{
			height += [ temp frameSize ].height;
			if (height >= realHeight)
			{
				height -= [ temp frameSize ].height;
				[ temp release ];
				temp = nil;
				if (reserveMessage)
					[ reserveMessage release ];
				reserveMessage = [ [ NSMutableString alloc ] initWithString:[ realString substringFromIndex:lastLine ] ];
				break;
			}
			
			[ textBox addObject:[ self loadString:[ realString substringWithRange:NSMakeRange(lastLine, lastSpace - lastLine) ] textColor:[ NSColor whiteColor ] withSize:40 withFontName:@"Helvetica" ] ];
			lastLine += lastSpace - lastLine;
			if ([ realString characterAtIndex:z ] == '\n')
				lastLine++;
		}
		
		[ temp release ];
		temp = nil;
	}
	
	GLString* temp = [ self loadString:[ realString substringFromIndex:lastLine ] textColor:[ NSColor whiteColor ] 
							  withSize:40 withFontName:@"Helvetica" ];
	height += [ temp frameSize ].height;
	if (height >= realHeight)
	{
		height -= [ temp frameSize ].height;
		[ temp release ];
		temp = nil;
		if (reserveMessage)
			[ reserveMessage release ];
		reserveMessage = [ [ NSMutableString alloc ] initWithString:[ realString substringFromIndex:lastLine ] ];
		[ temp release ];
		temp = nil;
	}
	else
		[ textBox addObject:temp ];
    [ realString release ];
	realString = nil;
    
    for (int z = 0; z < [ textBox count ]; z++)
    {
        [ [ textBox objectAtIndex:z ] realSize ];
        [ [ textBox objectAtIndex:z ] useStaticFrame:NSMakeSize(0, 0) ];
    }
}


/*
 * Create a pixel format and possible switch to full screen mode
 */
- (NSOpenGLPixelFormat *) createPixelFormat:(NSRect)frame
{
	NSOpenGLPixelFormatAttribute pixelAttribs[ 16 ];
	int pixNum = 0;
	NSOpenGLPixelFormat *pixelFormat;
	
	pixelAttribs[ pixNum++ ] = NSOpenGLPFADoubleBuffer;
	pixelAttribs[ pixNum++ ] = NSOpenGLPFAAccelerated;
	pixelAttribs[ pixNum++ ] = NSOpenGLPFAColorSize;
	pixelAttribs[ pixNum++ ] = colorBits;
	pixelAttribs[ pixNum++ ] = NSOpenGLPFADepthSize;
	pixelAttribs[ pixNum++ ] = depthBits;
	
	pixelAttribs[ pixNum ] = 0;
	pixelFormat = [ [ NSOpenGLPixelFormat alloc ]
                   initWithAttributes:pixelAttribs ];
	
	return pixelFormat;
}

/*
 * Initial OpenGL setup
 */
- (BOOL) initGL
{ 
	glShadeModel( GL_SMOOTH );                // Enable smooth shading
	glClearColor( 0.0f, 0.0f, 0.0f, 0.5f );   // Black background
	glClearDepth( 1.0f );                     // Depth buffer setup
	glEnable( GL_DEPTH_TEST );                // Enable depth testing
	glDepthFunc( GL_LEQUAL );                 // Type of depth test to do
	// Really nice perspective calculations
	glHint( GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST );
	
	return TRUE;
}


/*
 * Resize ourself
 */
- (void) reshape
{ 
	NSRect sceneBounds;
	
	[ [ self openGLContext ] update ];
	sceneBounds = [ self bounds ];
	// Reset current viewport
	glViewport( 0, 0, sceneBounds.size.width, sceneBounds.size.height );
	glMatrixMode( GL_PROJECTION );   // Select the projection matrix
	glLoadIdentity();                // and reset it
	// Calculate the aspect ratio of the view
	gluPerspective( 45.0f, 1,
                   0.1f, 100.0f );
	glMatrixMode( GL_MODELVIEW );    // Select the modelview matrix
	glLoadIdentity();                // and reset it
	
	NSSize newSize = [ self bounds ].size;
	double xRatio = resolution.width / newSize.width;
	double yRatio = resolution.height / newSize.height;
	for (int z = 0; z < [ views count ]; z++)
	{
		MDRect rect = [ (MDControlView*)[ views objectAtIndex:z ] frame ];
		[ (MDControlView*)[ views objectAtIndex:z ] setFrame:MakeRect(rect.x / xRatio,
						rect.y / yRatio, rect.width / xRatio, rect.height / yRatio) ];
	}
	resolution = [ self bounds ].size;
}

- (GLString*) loadString: (NSString*) str textColor: (NSColor*) text 
				withSize: (double) dsize withFontName: (NSString*) fontName
{
	if (str == nil)
		return nil;
	// Init string and font
	NSFont* font = [ NSFont fontWithName:fontName size:dsize ];
	if (font == nil)
		return nil;
	
	GLString* gstr = [ [ GLString alloc ] initWithString:str withAttributes:[ NSDictionary
			dictionaryWithObjectsAndKeys:text, NSForegroundColorAttributeName, font,
			NSFontAttributeName, nil ] withTextColor: text withBoxColor:
					  [ NSColor clearColor ] withBorderColor:[ NSColor clearColor ] ];
	return gstr;
}

- (void) drawString: (GLString*) string atLocation: (NSPoint)location
		   rotation:(float) rot alignment:(NSTextAlignment)align
{
	if (!string)
		return;
	// Get ready to draw
	int s = 0;
	glGetIntegerv (GL_MATRIX_MODE, &s);
	glMatrixMode (GL_PROJECTION);
	glPushMatrix();
	glLoadIdentity ();
	glMatrixMode (GL_MODELVIEW);
	glPushMatrix();
	
	// Draw
	NSSize internalRes = [ self bounds ].size;
	glLoadIdentity();    // Reset the current modelview matrix
	glScaled(2.0 / internalRes.width, -2.0 / internalRes.height, 1.0);
	glTranslated(-internalRes.width / 2.0, -internalRes.height / 2.0, 0.0);
	glColor4f(1.0f, 1.0f, 1.0f, 1.0f);	// Make right color
	
	NSSize frameSize = [ string frameSize ];
	glTranslated(location.x + (frameSize.width / 2),
				 location.y + (frameSize.height / 2), 0);
	glRotated(rot, 0, 0, 1);
	glTranslated(-(location.x + (frameSize.width / 2)),
				 -(location.y + (frameSize.height / 2)), 0);
	
	NSPoint realLoc = location;
	if (align == NSCenterTextAlignment)
	{
		realLoc.x -= (frameSize.width / 2);
		realLoc.y -= (frameSize.height / 2);
	}
	else if (align == NSRightTextAlignment)
	{
		realLoc.x += (frameSize.width / 2);
		realLoc.y += (frameSize.height / 2);
	}
	
	[ string drawAtPoint:realLoc ];
	
	// Reset things
	glPopMatrix(); // GL_MODELVIEW
	glMatrixMode (GL_PROJECTION);
    glPopMatrix();
    glMatrixMode (s);
}

// Write text to screen
- (void) writeString: (NSString*) str textColor: (NSColor*) text 
			boxColor: (NSColor*) box borderColor: (NSColor*) border
		  atLocation: (NSPoint) location withSize: (double) dsize 
		withFontName: (NSString*) fontName rotation:(float) rot
		   alignment: (NSTextAlignment)align
{
	// Init string and font
	NSFont* font = [ NSFont fontWithName:fontName size:dsize ];
	if (font == nil)
		return;
	
	GLString* string = [ [ GLString alloc ] initWithString:str withAttributes:[ NSDictionary
				dictionaryWithObjectsAndKeys:text, NSForegroundColorAttributeName, font,
			NSFontAttributeName, nil ] withTextColor: text withBoxColor: box 
										   withBorderColor: border ];
	
	// Get ready to draw
	int s = 0;
	glGetIntegerv (GL_MATRIX_MODE, &s);
	glMatrixMode (GL_PROJECTION);
	glPushMatrix();
	glLoadIdentity ();
	glMatrixMode (GL_MODELVIEW);
	glPushMatrix();
	
	// Draw
	NSSize internalRes = [ self bounds ].size;
	glLoadIdentity();    // Reset the current modelview matrix
	glScaled(2.0 / internalRes.width, -2.0 / internalRes.height, 1.0);
	glTranslated(-internalRes.width / 2.0, -internalRes.height / 2.0, 0.0);
	glColor4f(1.0f, 1.0f, 1.0f, 1.0f);	// Make right color
	
	NSSize frameSize = [ string frameSize ];
	glTranslated(location.x + (frameSize.width / 2),
				 location.y + (frameSize.height / 2), 0);
	glRotated(rot, 0, 0, 1);
	glTranslated(-(location.x + (frameSize.width / 2)),
				 -(location.y + (frameSize.height / 2)), 0);
	
	NSPoint realLoc = location;
	if (align == NSCenterTextAlignment)
	{
		realLoc.x -= (frameSize.width / 2);
		realLoc.y -= (frameSize.height / 2);
	}
	else if (align == NSRightTextAlignment)
	{
		realLoc.x += (frameSize.width / 2);
		realLoc.y += (frameSize.height / 2);
	}
	
	[ string drawAtPoint:realLoc ];
	
	// Reset things
	glPopMatrix(); // GL_MODELVIEW
	glMatrixMode (GL_PROJECTION);
    glPopMatrix();
    glMatrixMode (s);
	
	// Cleanup
	[ string release ];
}

- (void) setFullScreen:(BOOL)full
{
	if (fullscreen == full)
		return;
	
	fullscreen = full;
	if (full)
	{
		[ [ self window ] setStyleMask:NSBorderlessWindowMask ];
		lastFrame = [ [ self window ] frame ];
		NSSize size = [ [ NSScreen mainScreen ] frame ].size;
		[ [ self window ] setBackingType:NSBackingStoreBuffered ];
		[ [ self window ] setLevel:NSMainMenuWindowLevel + 1 ];
		[ [ self window ] setOpaque:YES ];
		[ [ self window ] setHidesOnDeactivate:YES ];
		[ [ self window ] setFrame:NSMakeRect(0, 0, size.width, size.height) display:YES ];
	}
	else
	{
		[ [ self window ] setFrame:lastFrame display:YES ];
		[ [ self window ] setStyleMask:NSTitledWindowMask | NSClosableWindowMask ];
		[ [ self window ] setBackingType:NSBackingStoreBuffered ];
		[ [ self window ] setLevel:NSNormalWindowLevel ];
		[ [ self window ] setOpaque:YES ];
		[ [ self window ] setHidesOnDeactivate:NO ];
	}
	[ self reshape ];
	[ [ self window ] makeFirstResponder:self ];
}

- (BOOL) fullscreen
{
	return fullscreen;
}

- (void) goBack
{
	while ([ views count ] != 0)
		[ views removeObjectAtIndex:0 ];
	command = 2;
	canMove = TRUE;
}

- (void) goLeft
{
	Person per;
	if (blocks[rregs[1]].texture == 55)
		per = people[blocks[rregs[1] - 1].texture - 1];
	else
		per = people[blocks[rregs[1]].texture - 1];
	MDImageView* view = ViewForIdentity(@"Image");
	unsigned int z = -1;
	for (int q = 0; q < per.images.size(); q++)
	{
		if ([ [ view image ] hasSuffix:per.images[q] ])
		{
			z = q;
			break;
		}
	}
	if (z == -1)
		return;
	z--;
	if (z == -1)
		z = per.images.size() - 1;
	[ view setImage:[ NSMutableString stringWithFormat:@"%@/Images/%@", [ [ NSBundle mainBundle ] resourcePath ], per.images[z] ] onThread:NO ];
}

- (void) goRight
{
	Person per;
	if (blocks[rregs[1]].texture == 55)
		per = people[blocks[rregs[1] - 1].texture - 1];
	else
		per = people[blocks[rregs[1]].texture - 1];
	MDImageView* view = ViewForIdentity(@"Image");
	unsigned int z = -1;
	for (int q = 0; q < per.images.size(); q++)
	{
		if ([ [ view image ] hasSuffix:per.images[q] ])
		{
			z = q;
			break;
		}
	}
	if (z == -1)
		return;
	z++;
	if (z == per.images.size())
		z = 0;
	[ view setImage:[ NSMutableString stringWithFormat:@"%@/Images/%@", [ [ NSBundle mainBundle ] resourcePath ], per.images[z] ] onThread:NO ];
}

- (void) mouseMoved:(NSEvent *)theEvent
{
	for (int z = 0; z < [ views count ]; z++)
	{
		[ [ views objectAtIndex:z ] mouseMoved:theEvent ];
	}
}

- (void) mouseDown:(NSEvent *)theEvent
{
	BOOL down = FALSE;
	for (int z = (int)[ views count ] - 1; z >= 0; z--)
	{
		MDControlView* view = [ views objectAtIndex:z ];
		if (down)
			[ view mouseNotDown ];
		else
		{
			unsigned long prevViews = [ views count ];
			[ view mouseDown:theEvent ];
			if (prevViews != [ views count ])
				break;
			if ([ view mouseDown ])
			{
				for (int q = 0; q < [ [ view subViews ] count ]; q++)
				{
					if (![ [ [ view subViews ] objectAtIndex:q ] mouseDown ])
					{
						[ [ [ view subViews ]
						   objectAtIndex:q ] mouseDown:theEvent ];
					}
				}
				if ([ view parentView ] &&
					![ [ view parentView ] mouseDown ])
					[ [ view parentView ] mouseDown:theEvent ];
				down = TRUE;
			}
		}
	}
	if (down)
		return;
}

- (void) mouseDragged:(NSEvent *)theEvent
{
	for (int z = 0; z < [ views count ]; z++)
		[ [ views objectAtIndex:z ] mouseDragged:theEvent ];
}

- (void) mouseUp:(NSEvent *)theEvent
{
	for (int z = 0; z < [ views count ]; z++)
		[ (MDControlView*)[ views objectAtIndex:z ] mouseUp:theEvent ];
}

- (void) scrollWheel:(NSEvent *)theEvent
{
	for (int z = (int)[ views count ] - 1; z >= 0; z--)
	{
		[ [ views objectAtIndex:z ] scrollWheel:theEvent ];
		if ([ [ views objectAtIndex:z ] scrolled ])
			break;
	}
}

- (void) keyDown:(NSEvent *)theEvent
{
    if ([ theEvent modifierFlags ] & NSCommandKeyMask)
    {
        [ keys removeAllObjects ];
        return;
    }
	unichar unicodeKey = [ [ theEvent characters ] characterAtIndex:0 ];
    BOOL shouldAdd = TRUE;
	switch (unicodeKey)
	{
		/*case 27:	// Escape
		{
			if ([ theEvent isARepeat ])
				break;
			[ glView setFullScreen:![ glView fullscreen ] ];
			break;
		}*/
		case NSUpArrowFunctionKey:
		{
			break;
		}
		case NSDownArrowFunctionKey:
		{
			break;
		}
        case NSNewlineCharacter:
        case NSCarriageReturnCharacter:
        case NSEnterCharacter:
        {
            if (textBox && !waitForKeyText)
            {
                waitForKeyText = TRUE;
                for (int z = 0; z < [ textBox count ]; z++)
                {
                    [ [ textBox objectAtIndex:z ] useStaticFrame:[ [ textBox objectAtIndex:z ] realSize ] ];
                }
                shouldAdd = FALSE;
            }
        }
        case ' ':
        {
            if (textBox && !waitForKeyText)
            {
                waitForKeyText = TRUE;
                for (int z = 0; z < [ textBox count ]; z++)
                {
                    [ [ textBox objectAtIndex:z ] useStaticFrame:[ [ textBox objectAtIndex:z ] realSize ] ];
                }
                shouldAdd = FALSE;
            }
            break;
        }
	}
	for (int z = 0; z < [ views count ]; z++)
		[ [ views objectAtIndex:z ] keyDown:theEvent ];
	if ([ theEvent isARepeat ] || !shouldAdd)
		return;
	[ keys addObject:[ NSNumber numberWithInt:unicodeKey ] ];
}

- (void) keyUp:(NSEvent *)theEvent
{
    if ([ theEvent modifierFlags ] & NSCommandKeyMask)
    {
        [ keys removeAllObjects ];
        return;
    }
	for (int z = 0; z < [ views count ]; z++)
		[ [ views objectAtIndex:z ] keyUp:theEvent ];
	if ([ theEvent isARepeat ])
		return;
	unichar unicodeKey;
	
	unicodeKey = [ [ theEvent characters ] characterAtIndex:0 ];
	for (int z = 0; z < [ keys count ]; z++)
	{
		if ([ [ keys objectAtIndex:z ] intValue ] == unicodeKey)
			[ keys removeObjectAtIndex:z ];
	}
}

- (BOOL) acceptsFirstResponder
{
	return YES;
}

- (BOOL) loadBitmap: (NSString*) file
{	
	NSString* theStr = [ NSString stringWithFormat:@"%@", file ];
	if (![ theStr hasPrefix:@"/" ])
	{
		theStr = [ NSString stringWithFormat:@"%@/Images/%@", [ [ NSBundle mainBundle ]
														resourcePath ], file ];
	}
	return [ self loadBitmapFromData:[ NSData dataWithContentsOfFile:theStr ] ];
}

- (BOOL) loadBitmapFromData: (NSData*) file
{	
	BOOL success = FALSE;
	NSBitmapImageRep *theImage;
	int bitsPPixel, bytesPRow;
	int rowNum, destRowNum;
	
	theImage = [ NSBitmapImageRep imageRepWithData:file ];
	if (theImage != nil)
	{
		bitsPPixel = (int)[ theImage bitsPerPixel ];
		bytesPRow = (int)[ theImage bytesPerRow ];
		GLenum texFormat;
		if( bitsPPixel == 24 )        // No alpha channel
			texFormat = GL_RGB;
		else if( bitsPPixel == 32 )   // There is an alpha channel
			texFormat = GL_RGBA;
		NSSize texSize = NSMakeSize([ theImage pixelsWide ], [ theImage pixelsHigh ]);
		unsigned char* data = (unsigned char*)malloc(bytesPRow * texSize.height);
		
		if (data)
		{
			success = TRUE;
			destRowNum = 0;
			for( rowNum = texSize.height - 1; rowNum >= 0;
				rowNum--, destRowNum++ )
			{
				// Copy the entire row in one shot
				memcpy(data + ( destRowNum * bytesPRow ),
					   [ theImage bitmapData ] + ( rowNum * bytesPRow ),
					   bytesPRow );
			}
		}
		
		unsigned int image = 0;
		glGenTextures(1, &image);
		glBindTexture(GL_TEXTURE_2D, image);
		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, texSize.width,
					 texSize.height, 0, texFormat,
					 GL_UNSIGNED_BYTE, data);
		
		[ textures addObject:[ NSNumber numberWithUnsignedInt:image ] ];
		
		glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
		glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
		
		free(data);
		data = NULL;
	}
	
	return success;
}

- (void) clearTextures
{
	for (int z = 0; z < [ textures count ]; z++)
		[ self releaseImage:[ [ textures objectAtIndex:z ] unsignedIntValue ] ];
	[ textures removeAllObjects ];
}

- (void) releaseImage: (unsigned int)val
{
	if (glIsTexture(val))
		glDeleteTextures(1, &val);
}


/*
 * Called when the system thinks we need to draw.
 */
- (void) drawRect:(NSRect)rect
{
	while (waitForDraw) {}
	isDrawing = TRUE;
	resolution = windowSize = [ self bounds ].size;
	// Clear the screen and depth buffer
	glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );
	
    DrawWorld();
    
    if (textBox != nil)
    {
        glEnable(GL_BLEND);								
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        
        int s = 0;
        glGetIntegerv (GL_MATRIX_MODE, &s);
        glMatrixMode (GL_PROJECTION);
        glPushMatrix();
        glLoadIdentity ();
        glMatrixMode (GL_MODELVIEW);
        glPushMatrix();
        glViewport( 0, 0, resolution.width, resolution.height );
        glMatrixMode( GL_PROJECTION );
        glLoadIdentity();
        gluOrtho2D(0, resolution.width, 0, resolution.height);
        glMatrixMode( GL_MODELVIEW );
        glLoadIdentity();

        glLoadIdentity();
        glColor4d(0.4, 0.4, 0.4, 0.7);
        glBegin(GL_QUADS);
        {
            glVertex2d(resolution.width * 0.1, resolution.height * 0.365);
            glVertex2d(resolution.width * 0.9, resolution.height * 0.365);
            glVertex2d(resolution.width * 0.9, resolution.height * 0.1);
            glVertex2d(resolution.width * 0.1, resolution.height * 0.1);
        }
        glEnd();
        
        glPopMatrix(); // GL_MODELVIEW
        glMatrixMode (GL_PROJECTION);
        glPopMatrix();
        glMatrixMode (s);
        
        glDisable(GL_BLEND);
        
        for (int z = 0; z < textPointer + 1; z++)
        {
            GLString* str = [ textBox objectAtIndex:z ];
            float height = [ str realSize ].height + 5;
            if ([ str staticFrame ])
            {
                [ str useStaticFrame:NSMakeSize([ str frameSize ].width + 15, [ str realSize ].height) ];
                [ str setFromRight:YES ];
                if ([ str frameSize ].width + 5 > [ str realSize ].width)
                { 
                    textPointer = z + 1;
                    if (textPointer >= [ textBox count ])
                    {
                        textPointer--;
                        waitForKeyText = TRUE;
                    }
                    [ str useDynamicFrame ];
                }
            }
            [ self drawString:str atLocation:NSMakePoint([ self bounds ].size.width * 0.12, [ self bounds ].size.height * 0.64 + (height * z)) rotation:0 alignment:NSLeftTextAlignment ];
            str = nil;
        }
    }
	
	int s = 0;
	glGetIntegerv (GL_MATRIX_MODE, &s);
	glMatrixMode (GL_PROJECTION);
	glPushMatrix();
	glLoadIdentity ();
	glMatrixMode (GL_MODELVIEW);
	glPushMatrix();
	
	glViewport( 0, 0, resolution.width, resolution.height );
	glMatrixMode( GL_PROJECTION );
	glLoadIdentity();
	gluOrtho2D(0, resolution.width, 0, resolution.height);
	glMatrixMode( GL_MODELVIEW );
	glLoadIdentity();
	
	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	for (int z = 0; z < [ views count ]; z++)
		[ [ views objectAtIndex:z ] drawView ];
	glBlendFunc(GL_SRC_ALPHA, GL_ONE);
	glDisable(GL_BLEND);
	
	glPopMatrix(); // GL_MODELVIEW
	glMatrixMode (GL_PROJECTION);
    glPopMatrix();
    glMatrixMode (s);
	
//#ifdef DEBUG
	[ self writeString:[ NSString stringWithFormat:@"%i", realFPS ] textColor:
	 [ NSColor yellowColor ] boxColor:[ NSColor clearColor ] borderColor:
	 [ NSColor clearColor ] atLocation:NSMakePoint(0, 0) withSize:15 withFontName:
	 @"Helvetica" rotation:0 alignment:NSLeftTextAlignment ];
//#endif
	
	[ [ self openGLContext ] flushBuffer ];
	
	isDrawing = FALSE;
	
	for (int z = 0; z < [ views count ]; z++)
		[ [ views objectAtIndex:z ] finishDraw ];
	
	countFPS++;
	timerFps++;
	if (timerFps >= 3600)
		timerFps = 0;
}

/*
 * Cleanup
 */
- (void) dealloc
{
	[ self clearTextures ];
	if (keys)
	{
		[ keys release ];
		keys = nil;
	}
	if (strings)
	{
		[ strings release ];
		strings = nil;
	}
	if (textures)
	{
		[ textures release ];
		textures = nil;
	}
	if (views)
	{
		[ views removeAllObjects ];
		[ views release ];
		views = nil;
	}
    if (textBox)
    {
        [ textBox release ];
        textBox = nil;
    }
	if (reserveMessage)
	{
		[ reserveMessage release ];
		reserveMessage = nil;
	}
	[ super dealloc ];
}

@end
