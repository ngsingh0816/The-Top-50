//
//  Music Player.m
//  The Top 50
//
//  Created by MILAP on 2/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Music Player.h"

@interface MusicPlayer (InternalMethods)
- (void) sliderMoved: (id) sender;
- (void) sound: (NSSound*)sounds didFinishPlaying:(BOOL)did;
@end

@implementation MusicPlayer

+ (id) musicPlayer
{
	return [ [ [ MusicPlayer alloc ] init ] autorelease ];
}

+ (id) musicPlayerWithFrame: (MDRect)rect background: (NSColor*)bkg
{
	return [ [ [ MusicPlayer alloc ] initWithFrame:rect background:bkg ] autorelease ];
}

- (id) init
{
	if ((self = [ super init ]))
	{
		sound = nil;
		visible = NO;
		stopCounter = FALSE;
	}
	return self;
}

- (id) initWithFrame:(MDRect) rect background:(NSColor*)bkg
{
	if ((self = [ super initWithFrame:rect background:bkg ]))
	{
		sound = nil;
		visible = NO;
		buttons[0] = [ [ MDButton alloc ] initWithFrame:MakeRect(frame.x + (frame.width / 25),
			frame.y + (frame.height / 25), frame.height / 4, frame.height / 4) background:
					[ NSColor colorWithCalibratedRed:0.7 green:0.7 blue:0.7 alpha:1 ] ];
		[ buttons[0] setText:@"<<" ];
		[ buttons[0] setIdentity:@"Rewind" ];
		[ buttons[0] setTarget:self ];
		[ buttons[0] setAction:@selector(rewind) ];
		[ buttons[0] setContinuous:YES ];
		[ buttons[0] setVisible:NO ];
		
		buttons[1] = [ [ MDButton alloc ] initWithFrame:MakeRect(frame.width + frame.x -
			(frame.width / 25) - (frame.height / 4), frame.y + (frame.height / 25),
			frame.height / 4, frame.height / 4) background:[ NSColor colorWithCalibratedRed:
											0.7 green:0.7 blue:0.7 alpha:1 ] ];
		[ buttons[1] setText:@">>" ];
		[ buttons[1] setIdentity:@"Fast Forward" ];
		[ buttons[1] setTarget:self ];
		[ buttons[1] setAction:@selector(fastForward) ];
		[ buttons[1] setContinuous:YES ];
		[ buttons[1] setVisible:NO ];
		
		buttons[2] = [ [ MDButton alloc ] initWithFrame:MakeRect((frame.width / 2) + frame.x
			- (frame.width / 25) - (frame.height / 8), frame.y + (frame.height / 25),
			frame.height / 4, frame.height / 4) background:[ NSColor colorWithCalibratedRed:
									0.7 green:0.7 blue:0.7 alpha:1 ] ];
		[ buttons[2] setText:@"▶" ];
		[ buttons[2] setIdentity:@"Play" ];
		[ buttons[2] setTarget:self ];
		[ buttons[2] setAction:@selector(play) ];
		[ buttons[2] setVisible:NO ];
		
		buttons[3] = [ [ MDButton alloc ] initWithFrame:MakeRect((frame.width / 2) + frame.x
			+ (frame.width / 25) - (frame.height / 8), frame.y + (frame.height / 25),
			frame.height / 4, frame.height / 4) background:[ NSColor colorWithCalibratedRed:
									0.7 green:0.7 blue:0.7 alpha:1 ] ];
		[ buttons[3] setText:@"◼" ];
		[ buttons[3] setIdentity:@"Stop" ];
		[ buttons[3] setTarget:self ];
		[ buttons[3] setAction:@selector(stop) ];
		[ buttons[3] setVisible:NO ];
        
        buttons[4] = [ [ MDButton alloc ] initWithFrame:MakeRect(frame.x + frame.width - (frame.height / 4), frame.y + frame.height - (frame.height / 4) - (frame.height / 25), frame.height / 4, frame.height / 4) background:[ NSColor colorWithCalibratedRed:0.7 green:0.7 blue:0.7 alpha:1 ] ];
		[ buttons[4] setText:@"♫" ];
		[ buttons[4] setIdentity:@"Songs" ];
		[ buttons[4] setTarget:self ];
		[ buttons[4] setAction:@selector(viewSongs) ];
		[ buttons[4] setVisible:NO ];
		
		progress = [ [ MDSlider alloc ] initWithFrame:MakeRect(frame.x + (frame.width / 25),
			frame.y + frame.height / 2, frame.width * (23 / 25.0), 30) background:
				[ NSColor colorWithCalibratedRed:0.2 green:0.5 blue:1.0 alpha:1.0 ] ];
		[ progress setContinuous:YES ];
		[ progress setTarget:self ];
		[ progress setAction:@selector(sliderMoved:) ];
		[ progress setVisible:NO ];
		stopCounter = FALSE;
		
		for (int z = 0; z < 5; z++)
		{
			MDRect rect = [ buttons[z] frame ];
			[ views removeObject:buttons[z] ];
			rect.y -= frame.height;
			[ buttons[z] setFrame:rect ];
		}
		MDRect rect = [ progress frame ];
		[ views removeObject:progress ];
		rect.y -= frame.height;
		[ progress setFrame:rect ];
		
	}
	return self;
}

- (void) mouseDown:(NSEvent *)event
{
	for (int z = 0; z < 5; z++)
		[ buttons[z] mouseDown:event ];
	[ progress mouseDown:event ];
	[ super mouseDown:event ];
}

- (void) mouseUp:(NSEvent *)event
{
	for (int z = 0; z < 5; z++)
		[ buttons[z] mouseUp:event ];
	[ progress mouseUp:event ];
	[ super mouseUp:event ];
}

- (void) mouseDragged:(NSEvent*)event
{
	for (int z = 0; z < 5; z++)
		[ buttons[z] mouseDragged:event ];
	[ progress mouseDragged:event ];
	[ super mouseDragged:event ];
}

- (void) mouseMoved:(NSEvent*)event
{
	if ([ self mouseDown ])
		return;
	
	NSPoint point = [ event locationInWindow ];
	if (point.x >= frame.x && point.x <= frame.x + frame.width &&
		point.y >= frame.y && point.y <= frame.y + 15)
		stopCounter = TRUE;
	else if (!(point.x >= frame.x && point.x <= frame.x + frame.width &&
			 point.y >= frame.y && point.y <= frame.y + frame.height))
		stopCounter = FALSE;
	
	if (stopCounter != lastCheck)
		counter = 0;
	lastCheck = stopCounter;
	
	for (int z = 0; z < 5; z++)
		[ buttons[z] mouseMoved:event ];
	[ progress mouseMoved:event ];
	[ super mouseMoved:event ];
}

- (void) setChanged:(int)changed
{
	if (change != 0)
		return;
	if (changed == 1)
	{
		originalRect = frame;
		if (!visible)
		{
			[ self setVisible:YES ];
			for (int z = 0; z < 5; z++)
			{
				//MDRect rect = [ buttons[z] frame ];
				//rect.y -= frame.height;
				//[ buttons[z] setFrame:rect ];
				[ buttons[z] setVisible:YES ];
			}
			//MDRect rect = [ progress frame ];
			[ progress setVisible:YES ];
			//rect.y -= frame.height;
			//[ progress setFrame:rect ];
		}
		frame.height = 0;
		change = 1;
	}
	else if (changed == -1)
	{
		originalRect = frame;
		frame.height = 0;
		change = 1;
		if (!visible)
			[ self setChanged:1 ];
	}
	else
		change = changed;
}

- (void) loadSound: (NSString*)str
{
	if (sound)
	{
		[ sound stop ];
		[ sound release ];
	}
	NSString* realStr = [ [ NSString alloc ] initWithString:str ];
	if (![ str hasPrefix:@"/" ])
	{
		[ realStr release ];
		realStr = [ [ NSString alloc ] initWithFormat:@"%@/Music/%@",
				   [ [ NSBundle mainBundle ] resourcePath ], str ];
	}
	sound = [ [ NSSound alloc ] initWithContentsOfFile:realStr byReference:YES ];
	[ sound setDelegate:(id)self ];
	if (savedString)
		[ savedString release ];
	savedString = [ [ NSString alloc ] initWithString:realStr ];
	[ progress setMaxValue:[ sound duration ] ];
	[ progress setValue:0 ];
	
	if (glStr)
		[ glStr release ];
	glStr = LoadString([ [ str lastPathComponent ] substringToIndex:[ str length ] - 4 ],
					   [ NSColor blackColor ], [ NSFont systemFontOfSize:14 ]);
	
	[ realStr release ];
	realStr = nil;
}

- (void) play
{
	if (sound)
	{
		if (![ sound resume ])
			[ sound play ];
	}
	else if (savedString)
	{
		[ self loadSound:[ NSString stringWithString:savedString ] ];
		if (sound)
			[ sound play ];
	}
	[ buttons[2] setText:@"❚❚" ];
	[ buttons[2] setAction:@selector(pause) ];
}

- (void) pause
{
	if (sound)
		[ sound pause ];
	[ buttons[2] setText:@"▶" ];
	[ buttons[2] setAction:@selector(play) ];
}

- (void) fastForward
{
	if (sound)
	{
		BOOL playing = [ sound isPlaying ];
		if (playing)
			[ sound pause ];
        if ([ sound currentTime ] + 1 < [ sound duration ])
            [ sound setCurrentTime:[ sound currentTime ] + 1 ];
        else
            [ sound setCurrentTime:[ sound duration ] ];
		[ self update ];
		if (playing)
			[ sound resume ];
	}
}

- (void) rewind
{
	if (sound)
	{
		BOOL playing = [ sound isPlaying ];
		if (playing)
			[ sound pause ];
        if ([ sound currentTime ] - 1 > 0)
            [ sound setCurrentTime:[ sound currentTime ] - 1 ];
        else
            [ sound setCurrentTime:0 ];
		[ self update ];
		if (playing)
			[ sound resume ];
	}
}

- (void) stop
{
	if (sound)
	{
		[ sound stop ];
		[ self update ];
	}
	[ buttons[2] setText:@"▶" ];
	[ buttons[2] setAction:@selector(play) ];
}

- (void) sound: (NSSound*)sounds didFinishPlaying:(BOOL)did
{
	[ self stop ];
}

- (void) sliderMoved: (id) sender
{
	if (sound)
	{
		[ sound pause ];
		[ sound setCurrentTime:[ progress value ] ];
		[ sound resume ];
	}
}

- (void) playTable
{
    [ self loadSound:[ [ table objectAtRow:[ table selectedRow ] ] objectForKey:@"Name" ] ];
    [ self play ];
    [ window close:self ];
}

- (void) viewSongs
{
    window = [ [ MDWindow alloc ] initWithFrame:MakeRect(resolution.width / 4, resolution.height / 4, resolution.width / 2, resolution.height / 2) background:[ NSColor colorWithCalibratedRed:0.7 green:0.7 blue:0.7 alpha:1 ] ];
    table = [ [ MDTableView alloc ] initWithFrame:MakeRect(0, 0, resolution.width / 2, resolution.height / 2) background:[ NSColor colorWithCalibratedRed:1 green:1 blue:1 alpha:1 ] ];
    [ table addHeader:@"Name" ];
    [ window addSubView:table ];
    NSArray* array = [ [ [ NSFileManager defaultManager ] enumeratorAtPath:[ NSString stringWithFormat:@"%@/Music/", [ [ NSBundle mainBundle ] resourcePath ] ] ] allObjects ];
    for (int z = 0; z < [ array count ]; z++)
    {
        [ table addRow:[ NSDictionary dictionaryWithObject:[ [ array objectAtIndex:z ] lastPathComponent ] forKey:@"Name" ] ];
    }
    [ table setClickTarget:self ];
    [ table setDoubleClickAction:@selector(playTable) ];
    array = nil;
}

- (void) setPosition:(double) position
{
	if (sound)
	{
		[ sound pause ];
		[ sound setCurrentTime:position ];
		[ self update ];
		[ sound resume ];
	}
}

- (double) position
{
	if (sound)
		return [ sound currentTime ];
	return 0;
}

- (NSSound*) sound
{
	return sound;
}

- (void) update
{
	if (!sound)
	{
		[ progress setValue:0 ];
		return;
	}
	if (![ progress mouseDown ])
	{
		[ progress setTarget:nil ];
		[ progress setValue:[ sound currentTime ] ];
		[ progress setTarget:self ];
	}
}

- (void) drawView
{
	counter++;
	if (counter > 120)
	{
		counter = 0;
		if (change == 0)
		{
			originalRect = frame;
			if (!stopCounter && visible)
				change = -1;
			else if (stopCounter && !visible)
			{
				change = 1;
				[ self setVisible:YES ];
				for (int z = 0; z < 5; z++)
					[ buttons[z] setVisible:YES ];
				[ progress setVisible:YES ];
				frame.height = 0;
			}
		}
	}
	
	if (!visible)
		return;
	
	[ super drawView ];
	[ self update ];
	
	double backupH = frame.height;
	frame.height = originalRect.height;
	double backupY = frame.y;
	frame.y = backupH - originalRect.height;
	
	if (sound)
	{
		DrawString(glStr, NSMakePoint(frame.x + (frame.width / 2),
			frame.y + frame.height * 0.85), NSCenterTextAlignment, 0);
		NSMutableString* str = [ [ NSMutableString alloc ] init ];
		[ str appendFormat:@"%i", ((int)[ sound currentTime ] / 60) ];
		if (((int)[ sound currentTime ] % 60) < 10)
			[ str appendFormat:@":0%i / ", ((int)[ sound currentTime ] % 60) ];
		else
			[ str appendFormat:@":%i / ", ((int)[ sound currentTime ] % 60) ];
		[ str appendFormat:@"%i", ((int)[ sound duration ] / 60) ];
		if (((int)[ sound duration ] % 60) < 10)
			[ str appendFormat:@":0%i", ((int)[ sound duration ] % 60) ];
		else
			[ str appendFormat:@":%i", ((int)[ sound duration ] % 60) ];
		MDDrawString(str, NSMakePoint(frame.x + (frame.width / 2), frame.y +
			frame.height * 0.75), [ NSColor blackColor ], [ NSFont systemFontOfSize:14 ],
					 0, NSCenterTextAlignment);
		[ str release ];
	}
	
	frame.height = backupH;
	frame.y = backupY;
	
	if (change == -1)
	{
		frame.height -= (originalRect.height / 60.0);
		for (int z = 0; z < 5; z++)
		{
			MDRect rect = [ buttons[z] frame ];
			[ buttons[z] setFrame:MakeRect(rect.x, rect.y - (originalRect.height / 60),
										   rect.width, rect.height) ];
		}
		MDRect rect = [ progress frame ];
		[ progress setFrame:MakeRect(rect.x, rect.y - (originalRect.height / 60),
									 rect.width, rect.height) ];
		if (frame.height <= 0)
		{
			[ self setVisible:NO ];
			change = 0;
			frame.height = originalRect.height;
			for (int z = 0; z < 4; z++)
				[ buttons[z] setVisible:NO ];
			[ progress setVisible:NO ];
			counter = 0;
		}
	}
	else if (change == 1)
	{
		frame.height += (originalRect.height / 60.0);
		for (int z = 0; z < 5; z++)
		{
			MDRect rect = [ buttons[z] frame ];
			[ buttons[z] setFrame:MakeRect(rect.x, rect.y + (originalRect.height / 60),
										   rect.width, rect.height) ];
		}
		MDRect rect = [ progress frame ];
		[ progress setFrame:MakeRect(rect.x, rect.y + (originalRect.height / 60),
									 rect.width, rect.height) ];
		if (frame.height >= originalRect.height)
		{
			change = 0;
			frame.height = originalRect.height;
			counter = 0;
		}
	}
	else
	{
		originalRect = frame;
	}
	
	for (int z = 0; z < 5; z++)
		[ buttons[z] drawView ];
	[ progress drawView ];
}

- (void) setRepeats: (BOOL) repeat
{
    if (sound)
        [ sound setLoops:repeat ];
}

- (void) dealloc
{
	if (sound)
	{
		[ sound release ];
		sound = nil;
	}
	for (int z = 0; z < 5; z++)
	{
		[ buttons[z] release ];
		buttons[z] = nil;
	}
	if (progress)
	{
		[ progress release ];
		progress = nil;
	}
	if (savedString)
	{
		[ savedString release ];
		savedString = nil;
	}
    if (table)
    {
        [ table release ];
        table = nil;
    }
    if (window)
    {
        [ window release ];
        window = nil;
    }
	[ super dealloc ];
}

@end
