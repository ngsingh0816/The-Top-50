//
//  3DText.h
//  MovieDraw
//
//  Created by Neil on 6/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
//#import "MDTypes.h"

extern float percent;
extern BOOL calculating;

@interface MDText : NSObject {
}

//+ (MDObject*) createText: (NSAttributedString*) str depth: (float)dep;
+ (NSNumber*) create2DText: (NSAttributedString*) text;

@end