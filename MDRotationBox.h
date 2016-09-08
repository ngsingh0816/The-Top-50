//
//  MDRotationBox.h
//  MovieDraw
//
//  Created by Neil on 5/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MDControl.h"
#import "3DText.h"

@interface MDRotationBox : MDControl {
    float rotationX;
	float toX;
	BOOL setX;
	int framesX;
	float startX;
	float rotationY;
	float toY;
	BOOL setY;
	int framesY;
	float startY;
	float toZ;
	BOOL setZ;
	int framesZ;
	float startZ;
	float rotationZ;
	float pressure;
	float viewX, viewY;
	float fadealpha;
	NSPoint lastMouse;
	NSPoint downPoint;
	BOOL isSpecial;
	
	// Strings
	std::vector<NSNumber*> sides;
	int side;
	
	BOOL picking;
}

+ (id) mdRotationBox;
+ (id) mdRotationBoxWithFrame: (MDRect)rect background: (NSColor*)bkg;
- (BOOL) uses3D;
- (float) xrotation;
- (float) yrotation;
- (float) zrotation;
- (void) setXRotation: (float)xrot;
- (void) setYRotation: (float)yrot;
- (void) setZRotation: (float)zrot;
- (void) setXRotation: (float)xrot show:(BOOL)sh;
- (void) setYRotation: (float)yrot show:(BOOL)sh;
- (void) setZRotation: (float)zrot show:(BOOL)sh;
- (BOOL) isShowing;
- (double) showPercent;
- (BOOL) isSpecial;

@end
