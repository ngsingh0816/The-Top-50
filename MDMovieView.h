//
//  MDMovieView.h
//  MovieDraw
//
//  Created by MILAP on 2/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MDControl.h"
#import "MDButton.h"
#import "MDSlider.h"
#import "MDProgressBar.h"
#import <QTKit/QTKit.h>

@interface MDQTView : QTMovieView
{
}

@end


@interface MDMovieView : MDControl {
	NSString* movieName;
	unsigned int texture;
	MDQTView* movieView;
	MDButton* buttons[4];
	MDSlider* slider;
	MDProgressBar* progress;
	BOOL isPlaying;
	id finish;
	SEL finishAct;
}

+ (id) mdMovieView;
+ (id) mdMovieViewWithFrame: (MDRect)rect background:(NSColor*)bkg;
- (BOOL) loadMovie: (NSString*)path;
- (NSString*) loadedMovie;
- (void) setView:(NSView*)view;
- (MDQTView*) movieView;
- (NSSize) setUseRealSize:(BOOL)use;
- (void) setVolume:(float)volume;
- (float) volume;
- (void) setFinishTarget: (id) tar;
- (id) finishTarget;
- (void) setFinishAction: (SEL) act;
- (SEL) finishAction;

- (void) play: (id) sender;
- (void) pause: (id) sender;
- (void) stop: (id) sender;
- (void) rewind: (id) sender;
- (void) fastForward: (id) sender;
- (void) update;

@end
