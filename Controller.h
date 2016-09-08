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

/* Controller.h */

#import <Cocoa/Cocoa.h>
#import "GLView.h"
#import "Music Player.h"

extern MusicPlayer* player;

@interface MDNewWindow : NSWindow
{
}

@end


extern GLView *glView;
@interface Controller : NSResponder
{
	IBOutlet MDNewWindow *glWindow;
	
	NSTimer *renderTimer;
}

- (void) awakeFromNib;
- (void) dealloc;

@end
