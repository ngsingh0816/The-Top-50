//
//  World.h
//  The Top 50
//
//  Created by MILAP on 3/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include <vector>

#define BodyWidth	0.5
#define BodyHeight	0.5
#define BodyDepth	0.5
#define YSTART	1.9

typedef struct
{
    float x;
    float y;
    float z;
    unsigned int frames;
} Path;

typedef struct
{
	std::vector<float> verts;
	unsigned int verticies;
	long texture;
	std::vector<float> colors;
    std::vector<Path> paths;
    unsigned int pathPtr;
    unsigned int frameCounter;
} Object;

typedef struct
{
	NSString* name;
	NSString* desc;
	std::vector<NSString*> images;
	std::vector<NSString*> music;
	std::vector<NSString*> movies;
} Person;

extern std::vector<Person> people;
extern double xpos, ypos, zpos, xrot, yrot, angle, cRadius;
extern float lastX, lastY, lastZ;
extern BOOL jumping;
extern BOOL checkLast, resetCamera;
extern float getTo;
extern BOOL canMove;
extern BOOL canFall;
extern std::vector<Object> blocks;
extern unsigned int currentLevel;
extern unsigned int command;
extern std::vector<double> rregs;
void LoadPeople();
void LoadLevel(unsigned int level);
void WorldKeyDown();
void DrawWorld();
