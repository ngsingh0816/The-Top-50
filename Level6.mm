//
//  Level6.m
//  The Top 50
//
//  Created by MILAP on 3/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Level6.h"
#import "Controller.h"

#define NUM_MESSAGES    5
#define NUM_MESSAGES1   3

unsigned int indexPtr = 0;
NSString* messages[NUM_MESSAGES] = {
    @"Unknown: I have been waiting for you for a long time now.",
    @"Unknown: You may be wondering who I am.",
    @"Unknown: Well, to find out, you must defeat me in battle.",
    @"Unknown: Tell me, can a red box like youself experience fear?",
    @"Unknown: RAAAAAAAAAAAHHHHHHHH!!!!!!!",
};
NSString* messages1[NUM_MESSAGES1] = {
    @"You: What brother?",
    @"Brother: That's right. You've been on top for too long. It's time you lost.",
    @"You: Fine. If that's the way you want it.",
};
int messagePtr = 0;
MDProgressBar* pHealth = nil, *oHealth = nil;
int tMenu = 0;
int selMenu = 0;

BOOL KeyLevel6()
{
    for (int z = 0; z < [ keys count ]; z++)
    {
        unsigned int key = [ [ keys objectAtIndex:z ] unsignedIntValue ];
        switch (key)
        {
        }
    }
    return NO;
}

void Setup()
{
    pHealth = [ [ MDProgressBar alloc ] initWithFrame:MakeRect(resolution.width, resolution.height * 0.3, resolution.width * 0.5, resolution.height * 0.1) background:[ NSColor colorWithCalibratedRed:0.7 green:0.7 blue:0.7 alpha:1.0 ] ];
    [ pHealth setCurrentValue:100 ];
    
    oHealth = [ [ MDProgressBar alloc ] initWithFrame:MakeRect(-resolution.width / 2, resolution.height * 0.8, resolution.width * 0.5, resolution.height * 0.1) background:[ NSColor colorWithCalibratedRed:0.7 green:0.7 blue:0.7 alpha:1.0 ] ];
    [ oHealth setCurrentValue:100 ];
}

void DrawNewWorld()
{
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
    glColor4d(1.0, 0.7, 0.0, 1.0);
    glBegin(GL_QUADS);
    {
        glVertex2d(0, 0);
        glVertex2d(resolution.width, 0);
        glVertex2d(resolution.width, resolution.height);
        glVertex2d(0, resolution.height);
    }
    glEnd();
    
    glLoadIdentity();
    glColor4d(0.8, 0.8, 0.5, 1.0);
    glBegin(GL_QUADS);
    {
        glVertex2d(0, 0);
        glVertex2d(resolution.width, 0);
        glVertex2d(resolution.width, resolution.height * 0.1);
        glVertex2d(0, resolution.height * 0.1);
    }
    glEnd();
    
    if (tMenu == 0)
    {
        [ glView writeString:@"Fight" textColor:[ NSColor whiteColor ] boxColor:[ NSColor clearColor ] borderColor:[ NSColor clearColor ] atLocation:NSMakePoint(resolution.width * 0.05, resolution.height * 0.95) withSize:20 withFontName:@"Helvetica" rotation:0 alignment:NSCenterTextAlignment ];
        glLoadIdentity();
        glColor4d(1, 0, 0, 1.0);
        glBegin(GL_QUADS);
        {
            glVertex2d(resolution.width * 0.02, resolution.height * 0.045);
            glVertex2d(resolution.width * 0.03, resolution.height * 0.045);
            glVertex2d(resolution.width * 0.03, resolution.height * 0.055);
            glVertex2d(resolution.width * 0.02, resolution.height * 0.055);
        }
        glEnd();
    }
    
    glPopMatrix(); // GL_MODELVIEW
	glMatrixMode (GL_PROJECTION);
    glPopMatrix();
    glMatrixMode (s);
}

BOOL DrawLevel6()
{
    BOOL ret = NO;
    if (!textBox && indexPtr < NUM_MESSAGES && messagePtr == 0)
    {
        [ glView textBox:messages[indexPtr++] target:nil action:nil ];
        canMove = FALSE;
        ret = YES;
    }
    else if (!textBox && indexPtr >= NUM_MESSAGES && messagePtr == 0)
    {
        [ player loadSound:@"Battle Theme.mp3" ];
        [ player setRepeats:YES ];
        [ player play ];
        Setup();
        ret = NO;
        messagePtr = -1;
        //messagePtr++;
        indexPtr = 0;
    }
    else if (messagePtr == -1)
    {
        MDRect frame = [ pHealth frame ];
        frame.x -= resolution.width / 120;
        [ pHealth setFrame:frame ];
        
        MDRect oframe = [ oHealth frame ];
        oframe.x += resolution.width / 120;
        [ oHealth setFrame:oframe ];
        
        if (frame.x >= (resolution.width / 2) - 1 && frame.x <= (resolution.width / 2) + 1)
        {
            messagePtr = 1;
            [ pHealth setVisible:NO ];
            [ oHealth setVisible:NO ];
        }
        DrawNewWorld();
    }
    if (!textBox && indexPtr < NUM_MESSAGES1 && messagePtr == 1)
    {
        [ glView textBox:messages1[indexPtr++] target:nil action:nil ];
        canMove = FALSE;
    }
    else if (!textBox && indexPtr >= NUM_MESSAGES1 && messagePtr == 1)
    {
        canMove = FALSE;
        [ pHealth setVisible:YES ];
        [ oHealth setVisible:YES ];
        indexPtr = 0;
        messagePtr = 2;
    }
    
    if (messagePtr == 1 || messagePtr == 2)
    {
        DrawNewWorld();
    }

    return ret;
}