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

/* Controller.m */

#import "Controller.h"

GLView *glView = nil;
MusicPlayer* player = nil;

@implementation MDNewWindow

- (BOOL) canBecomeKeyWindow
{
	return YES;
}

- (void) keyDown:(NSEvent *)theEvent
{
	[ glView keyDown:theEvent ];
}

- (void) keyUp:(NSEvent *)theEvent
{
	[ glView keyUp:theEvent ];
}

@end


@interface Controller (InternalMethods)
- (void) setupRenderTimer;
- (void) updateGLView:(NSTimer *)timer;
- (void) createFailed;
@end

@implementation Controller

- (void) awakeFromNib
{  
	[ NSApp setDelegate:self ];   // We want delegate notifications
	renderTimer = nil;
	[ glWindow makeFirstResponder:self ];
	glView = [ [ GLView alloc ] initWithFrame:[ glWindow frame ]
									colorBits:16 depthBits:16 fullscreen:FALSE ];
	if( glView != nil )
	{
		[ glWindow setContentView:glView ];
		[ glWindow setAcceptsMouseMovedEvents:YES ];
		[ glView setFullScreen:YES ];
		[ glWindow makeKeyAndOrderFront:self ];
		[ self setupRenderTimer ];
	}
	else
		[ self createFailed ];
	
	player = [ [ MusicPlayer alloc ] initWithFrame:MakeRect(0, 0, resolution.width, resolution.height * 0.2) background:[ NSColor colorWithCalibratedRed:0.7 green:0.7 blue:0.7 alpha:0.7 ] ];
	
	LoadPeople();
	LoadLevel(1);
}

- (void) updateFPS: (NSTimer*) timer
{
	if (!renderTimer)
	{
		[ timer invalidate ];
		timer = nil;
	}
	realFPS = countFPS;
	countFPS = 0;
}

/*
 * Setup timer to update the OpenGL view.
 */
- (void) setupRenderTimer
{
	NSTimeInterval timeInterval = 1 / 60.0;
	
	renderTimer = [ [ NSTimer scheduledTimerWithTimeInterval:timeInterval
													  target:self
													selector:@selector( updateGLView: )
													userInfo:nil repeats:YES ] retain ];
	[ [ NSRunLoop currentRunLoop ] addTimer:renderTimer
									forMode:NSEventTrackingRunLoopMode ];
	[ [ NSRunLoop currentRunLoop ] addTimer:renderTimer
									forMode:NSModalPanelRunLoopMode ];
	[ NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateFPS:)
									  userInfo:nil repeats:YES ];
}


/*
 * Called by the rendering timer.
 */
- (void) updateGLView:(NSTimer *)timer
{
	if( glView != nil )
		[ glView drawRect:[ glView frame ] ];
	UpdateKeys(glView);
}  


/*
 * Handle key presses
 */
- (void) keyDown:(NSEvent *)theEvent
{
	[ glView keyDown:theEvent ];
}

- (void) keyUp:(NSEvent *)theEvent
{
	[ glView keyUp:theEvent ];
}

- (void) mouseDown:(NSEvent *)theEvent
{
	[ glView mouseDown:theEvent ];
}

- (void) mouseUp:(NSEvent *)theEvent
{
	[ glView mouseUp:theEvent ];
}

- (void) mouseDragged:(NSEvent *)theEvent
{
	[ glView mouseDragged:theEvent ];
}

- (void) mouseMoved:(NSEvent *)theEvent
{
	[ glView mouseMoved:theEvent ];
}


/*
 * Called if we fail to create a valid OpenGL view
 */
- (void) createFailed
{
	NSWindow *infoWindow;
	
	infoWindow = NSGetCriticalAlertPanel( @"Initialization failed",
                                         @"Failed to initialize OpenGL",
                                         @"OK", nil, nil );
	[ NSApp runModalForWindow:infoWindow ];
	[ infoWindow close ];
	[ NSApp terminate:self ];
}


/* 
 * Cleanup
 */
- (void) dealloc
{
	if (glWindow)
	{
		[ glWindow release ]; 
		glWindow = nil;
	}
	if (glView)
	{
		[ glView release ];
		glView = nil;
	}
	if( renderTimer != nil && [ renderTimer isValid ] )
	{
		[ renderTimer invalidate ];
		renderTimer = nil;
	}
	for (int z = 0; z < people.size(); z++)
	{
		[ people[z].name release ];
		[ people[z].desc release ];
		for (int q = 0; q < people[z].images.size(); q++)
			[ people[z].images[q] release ];
		for (int q = 0; q < people[z].music.size(); q++)
			[ people[z].music[q] release ];
		for (int q = 0; q < people[z].movies.size(); q++)
			[ people[z].movies[q] release ];
	}
	people.clear();
	[ player release ];
	[ super dealloc ];
}

@end
