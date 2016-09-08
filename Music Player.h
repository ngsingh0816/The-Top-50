//
//  Music Player.h
//  The Top 50
//
//  Created by MILAP on 2/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MDControl.h"
#import "MDButton.h"
#import "MDSlider.h"
#import "MDWindow.h"
#import "MDTableView.h"

@interface MusicPlayer : MDControl {
	NSSound* sound;
	NSString* savedString;
	MDButton* buttons[5];
	MDSlider* progress;
    MDWindow* window;
    MDTableView* table;
	float counter;
	BOOL stopCounter;
	int change;
	MDRect originalRect;
	BOOL lastCheck;
}

+ (id) musicPlayer;
+ (id) musicPlayerWithFrame: (MDRect)rect background: (NSColor*)bkg;
- (void) loadSound: (NSString*)str;
- (void) play;
- (void) pause;
- (void) stop;
- (void) fastForward;
- (void) rewind;
- (void) viewSongs;
- (void) setPosition:(double) position;
- (double) position;
- (NSSound*) sound;
- (void) update;
- (void) setChanged:(int)changed;
- (void) setRepeats: (BOOL) repeat;

@end
