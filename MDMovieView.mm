//
//  MDMovieView.mm
//  MovieDraw
//
//  Created by MILAP on 2/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MDMovieView.h"

@implementation MDQTView

- (void) dragImage:(NSImage *)anImage at:(NSPoint)viewLocation offset:(NSSize)initialOffset
			 event:(NSEvent *)event pasteboard:(NSPasteboard *)pboard source:(id)sourceObj
		 slideBack:(BOOL)slideFlag
{
}

- (BOOL) dragFile:(NSString *)filename fromRect:(NSRect)rect slideBack:(BOOL)aFlag
			event:(NSEvent *)event
{
	return NO;
}

- (void) mouseDown:(NSEvent *)theEvent
{
}

- (void) rightMouseDown:(NSEvent *)theEvent
{
}

- (void) keyDown:(NSEvent *)theEvent
{
}

@end

@interface MDMovieView (InternalMethods)
- (void) sliderMoved: (id) sender;
@end

@implementation MDMovieView

+ (id) mdMovieView
{
	return [ [ [ MDMovieView alloc ] init ] autorelease ];
}

+ (id) mdMovieViewWithFrame: (MDRect)rect background:(NSColor*)bkg
{
	return [ [ [ MDMovieView alloc ] initWithFrame:rect background:bkg ] autorelease ];
}

- (id) init
{
	if ((self = [ super init ]))
	{
		isPlaying = FALSE;
	}
	return self;
}

- (id) initWithFrame:(MDRect)rect background:(NSColor *)bkg
{
	if ((self = [ super initWithFrame:rect background:bkg ]))
	{
		buttons[0] = [ [ MDButton alloc ] initWithFrame:MakeRect(frame.x, frame.y, 20, 20)
			background:[ NSColor colorWithCalibratedRed:0.5 green:0.5 blue:0.5 alpha:1 ] ];
		[ buttons[0] setText:@"▶" ];
		[ buttons[0] setIdentity:@"Play" ];
		[ buttons[0] setTarget:self ];
		[ buttons[0] setAction:@selector(play:) ];
		[ buttons[0] setButtonType:MDButtonTypeSquare ];
		
		buttons[1] = [ [ MDButton alloc ] initWithFrame:MakeRect(frame.x + 21, frame.y,20, 20)
			background:[ NSColor colorWithCalibratedRed:0.5 green:0.5 blue:0.5 alpha:1 ] ];
		[ buttons[1] setText:@"◼" ];
		[ buttons[1] setIdentity:@"Stop" ];
		[ buttons[1] setTarget:self ];
		[ buttons[1] setAction:@selector(stop:) ];
		[ buttons[1] setButtonType:MDButtonTypeSquare ];
		
		buttons[2] = [ [ MDButton alloc ] initWithFrame:MakeRect(frame.x + 42, frame.y,20, 20)
			background:[ NSColor colorWithCalibratedRed:0.5 green:0.5 blue:0.5 alpha:1 ] ];
		[ buttons[2] setText:@"<" ];
		[ buttons[2] setIdentity:@"Rewind" ];
		[ buttons[2] setTarget:self ];
		[ buttons[2] setAction:@selector(rewind:) ];
		[ buttons[2] setContinuous:NO ];
		[ buttons[2] setButtonType:MDButtonTypeSquare ];
		
		buttons[3] = [ [ MDButton alloc ] initWithFrame:MakeRect(frame.x + 63, frame.y,20, 20)
			background:[ NSColor colorWithCalibratedRed:0.5 green:0.5 blue:0.5 alpha:1 ] ];
		[ buttons[3] setText:@">" ];
		[ buttons[3] setIdentity:@"Fast Forward" ];
		[ buttons[3] setTarget:self ];
		[ buttons[3] setAction:@selector(fastForward:) ];
		[ buttons[3] setContinuous:NO ];
		[ buttons[3] setButtonType:MDButtonTypeSquare ];
		
		slider = [ [ MDSlider alloc ] initWithFrame:MakeRect(frame.x + 94, frame.y + 1,
			frame.width - 104, 18) background:[ NSColor colorWithCalibratedRed:0.2 green:0.5
																blue:1.0 alpha:1.0 ] ];
		[ slider setContinuous:YES ];
		[ slider setContinuousCount:1 ];
		[ slider setTarget:self ];
		[ slider setAction:@selector(sliderMoved:) ];
		
		progress = [ [ MDProgressBar alloc ] initWithFrame:MakeRect(frame.x + 
			(frame.width / 10), frame.y + 20 + (frame.height / 10), frame.width * 0.8,
			(frame.height - 20) * 0.8) background:[ NSColor colorWithCalibratedRed:0.7
													green:0.7 blue:0.7 alpha:1 ] ];
		[ progress setType:MD_PROGRESSBAR_NORMAL ];
		
		isPlaying = FALSE;
	}
	return self;	
}

- (BOOL) loadMovie: (NSString*)path
{
	if (movieName)
		[ movieName release ];
	movieName = [ [ NSString alloc ] initWithString:path ];
	if (![ movieName hasPrefix:@"/" ])
	{
		[ movieName release ];
		movieName = [ [ NSString alloc ] initWithFormat:@"%@/%@",
					 [ [ NSBundle mainBundle ] resourcePath ], path ];
	}
	if ([ [ NSFileManager defaultManager ] fileExistsAtPath:movieName ])
	{
		[ progress setVisible:YES ];
		movieView = [ [ MDQTView alloc ] initWithFrame:
					 NSMakeRect(frame.x, frame.y + 20, frame.width, frame.height - 20) ];
		[ movieView setMovie:[ QTMovie movieWithFile:movieName error:nil ] ];
		[ movieView setEditable:NO ];
		[ movieView setControllerVisible:NO ];
		[ movieView setBackButtonVisible:NO ];
		[ movieView setCustomButtonVisible:NO ];
		[ movieView setCustomButtonVisible:NO ];
		[ movieView setHotSpotButtonVisible:NO ];
		[ movieView setStepButtonsVisible:NO ];
		[ movieView setTranslateButtonVisible:NO ];
		[ movieView setVolumeButtonVisible:NO ];
		[ movieView setZoomButtonsVisible:NO ];
		
		NSTimeInterval time = 0;
		QTGetTimeInterval([ [ movieView movie ] duration ], &time);
		[ slider setMaxValue:time ];
		[ progress setVisible:NO ];
		return YES;
	}
	else
	{
		[ movieName release ];
		movieName = nil;
	}
	return NO;
}

- (NSString*) loadedMovie
{
	return movieName;
}

- (void) setView:(NSView*)view
{
	[ view addSubview:movieView ];
}

- (MDQTView*) movieView
{
	return movieView;
}

- (void) setFrame:(MDRect)rect
{
	if (movieView)
		[ movieView setFrame:NSMakeRect(rect.x, rect.y + 20, rect.width, rect.height - 20) ];
	[ super setFrame:rect ];
	for (int z = 0; z < 4; z++)
		[ buttons[z] setFrame:MakeRect(frame.x + (z * 21), frame.y, 20, 20) ];
	[ slider setFrame:MakeRect(frame.x + 94, frame.y + 1, frame.width - 104, 18) ];
	[ progress setFrame:MakeRect(frame.x + (frame.width / 10), frame.y + 20 +
				(frame.height / 10), frame.width * 0.8, (frame.height - 20) * 0.8) ];
}

- (void) sliderMoved: (id) sender
{
	if (!(movieView && [ movieView movie ]))
		return;
	[ [ movieView movie ] setCurrentTime:QTMakeTimeWithTimeInterval([ slider value ]) ];
}

- (void) drawView
{
	float square1[8];
	square1[0] = frame.x;
	square1[1] = frame.y + 20;
	square1[2] = frame.x + frame.width;
	square1[3] = frame.y + 20;
	square1[4] = frame.x;
	square1[5] = frame.y + frame.height;
	square1[6] = frame.x + frame.width;
	square1[7] = frame.y + frame.height;
	
	float colors1[16];
	for (int z = 0; z < 4; z++)
	{
		colors1[z * 4] = 0;
		colors1[(z * 4) + 1] = 0;
		colors1[(z * 4) + 2] = 0;
		colors1[(z * 4) + 3] = 1.0;
	}
	
	glLoadIdentity();
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_COLOR_ARRAY);
	glVertexPointer(2, GL_FLOAT, 0, square1);
	glColorPointer(4, GL_FLOAT, 0, colors1);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	glDisableClientState(GL_COLOR_ARRAY);
	glDisableClientState(GL_VERTEX_ARRAY);
	glLoadIdentity();
	
	float square[8];
	square[0] = frame.x;
	square[1] = frame.y;
	square[2] = frame.x + frame.width;
	square[3] = frame.y;
	square[4] = frame.x;
	square[5] = frame.y + 20;
	square[6] = frame.x + frame.width;
	square[7] = frame.y + 20;
	
	float colors[16];
	for (int z = 0; z < 4; z++)
	{
		colors[z * 4] = 0.7;
		colors[(z * 4) + 1] = 0.7;
		colors[(z * 4) + 2] = 0.7;
		colors[(z * 4) + 3] = 1.0;
	}
	
	glLoadIdentity();
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_COLOR_ARRAY);
	glVertexPointer(2, GL_FLOAT, 0, square);
	glColorPointer(4, GL_FLOAT, 0, colors);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	glDisableClientState(GL_COLOR_ARRAY);
	glDisableClientState(GL_VERTEX_ARRAY);
	glLoadIdentity();
	
	[ self update ];
}

- (NSSize) setUseRealSize:(BOOL)use
{
	[ movieView setPreservesAspectRatio:use ];
	return [ movieView frame ].size;
}

- (void) setVolume:(float)volume
{
	if (!movieView)
		return;
	[ [ movieView movie ] setVolume:volume ];
}

- (float) volume
{
	if (!movieView)
		return 0;
	return [ [ movieView movie ] volume ];
}

- (void) setFinishTarget: (id) tar
{
	target = tar;
}

- (id) finishTarget
{
	return target;
}

- (void) setFinishAction: (SEL) act
{
	finishAct = act;
}

- (SEL) finishAction
{
	return finishAct;
}

- (void) play: (id) sender
{
	if (!movieView)
		return;
	[ movieView play:self ];
	[ buttons[0] setAction:@selector(pause:) ];
	[ buttons[0] setText:@"❚❚" ];
	isPlaying = TRUE;
}

- (void) pause:(id)sender
{
	if (!movieView)
		return;
	[ movieView pause:self ];
	[ buttons[0] setAction:@selector(play:) ];
	[ buttons[0] setText:@"▶" ];
	isPlaying = FALSE;
}

- (void) stop: (id) sender
{
	if (!movieView)
		return;
	[ movieView pause:self ];
	[ movieView gotoBeginning:self ];
	[ buttons[0] setAction:@selector(play:) ];
	[ buttons[0] setText:@"▶" ];
	isPlaying = FALSE;
	[ self update ];
}

- (void) rewind: (id) sender
{
	if (!movieView)
		return;
	NSTimeInterval time = 0;
	QTGetTimeInterval([ [ movieView movie ] currentTime ], &time);
	[ [ movieView movie ] setCurrentTime:QTMakeTimeWithTimeInterval(time - 1) ];
	if (isPlaying)
		[ movieView play:self ];
	[ self update ];
}

- (void) fastForward: (id) sender
{
	if (!movieView)
		return;
	NSTimeInterval time = 0;
	QTGetTimeInterval([ [ movieView movie ] currentTime ], &time);
	[ [ movieView movie ] setCurrentTime:QTMakeTimeWithTimeInterval(time + 1) ];
	if (isPlaying)
		[ movieView play:self ];
	[ self update ];
}

- (void) update
{
	if (!(movieView && [ movieView movie ]))
	{
		[ slider setValue:0 ];
		return;
	}
	NSTimeInterval time = 0;
	QTGetTimeInterval([ [ movieView movie ] currentTime ], &time);
	[ slider setValue:time ];
	if ((float)time >= [ slider maxValue ])
	{
		if (finish && [ finish respondsToSelector:finishAct ])
			[ finish performSelector:finishAct ];
		[ self stop:self ];
	}
}

- (void) dealloc
{
	for (int z = 0; z < 4; z++)
	{
		if (buttons[z])
			[ views removeObject:buttons[z] ];
		if (buttons[z])
		{
			[ buttons[z] release ];
			buttons[z] = nil;
		}
	}
	if (slider)
	{
		[ views removeObject:slider ];
		if (slider)
		{
			[ slider release ];
			slider = nil;
		}
	}
	if (progress)
	{
		[ views removeObject:progress ];
		if (progress)
		{
			[ progress release ];
			progress = nil;
		}
	}
	if (movieName)
	{
		[ movieName release ];
		movieName = nil;
	}
	if (movieView)
	{
		[ movieView removeFromSuperview ];
		[ movieView release ];
		movieName = nil;
	}
	[ super dealloc ];
}

@end
