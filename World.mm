 //
//  World.mm
//  The Top 50
//
//  Created by MILAP on 3/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "World.h"
#import <OpenGL/OpenGL.h>
#import <OpenGL/gl.h>
#import <OpenGL/glu.h>
#import "Controller.h"

double xpos = 0, ypos = 0.2, zpos = 0, xrot = 15, yrot = 0,
    angle = 0, cRadius = 10.0;
BOOL jumping = FALSE;
BOOL checkLast = TRUE, resetCamera = FALSE;
float getTo = 5;
std::vector<Object>blocks;
std::vector<Person> people;
typedef struct
{
    float x1, x2;
    float y1, y2;
    float z1, z2;
    BOOL up;
} LevelPoint;
std::vector<LevelPoint> levelPoints;
unsigned int currentLevel = 1;
unsigned int command = 0;
std::vector<double> rregs;
BOOL canMove = TRUE;
BOOL canFall = TRUE;
float lastX = 0, lastY = 0.2, lastZ = 0;

BOOL CheckNextLevel()
{
    BOOL ret = FALSE;
    for (int z = 0; z < levelPoints.size(); z++)
    {
        LevelPoint p = levelPoints[z];
        if ((xpos >= p.x1 - BodyWidth && xpos <= p.x2 + BodyWidth) ||
            (xpos >= p.x2 - BodyWidth && xpos <= p.x1 + BodyWidth))
        {
            if ((ypos >= p.y1 - BodyHeight && ypos <= p.y2 + BodyHeight) ||
                (ypos >= p.y2 - BodyHeight && ypos <= p.y1 + BodyHeight))
            {
                if ((zpos >= p.z1 - BodyDepth && zpos <= p.z2 + BodyDepth) ||
                    (zpos >= p.z2 - BodyDepth && zpos <= p.z1 + BodyDepth))
                {
                    if (p.up)
                    {
                        ret = TRUE;
                        command = 1;
                        rregs.clear();
                        rregs.push_back(0);
                        canMove = FALSE;
                        lastX = 0;
                        lastY = 0.2;
                        lastZ = 0;
                        checkLast = FALSE;
                        resetCamera = TRUE;
                    }
                    else
                    {
                        ret = TRUE;
                        command = 4;
                        rregs.clear();
                        rregs.push_back(0);
                        canMove = FALSE;
                        lastX = 0;
                        lastY = 0.2;
                        lastZ = 0;
                        checkLast = FALSE;
                        resetCamera = TRUE;
                    }
                    break;
                }
            }
        }
    }
    return ret;
}

void CheckPerson(unsigned int z)
{
    if ((blocks[z].texture <= 51 && blocks[z].texture != 0) ||
        (blocks[z].texture == 55 && z != 0 && blocks[z-1].texture <= 51))
    {
        command = 3;
        canMove = FALSE;
        rregs.push_back(0);
        rregs.push_back(z);
    }
}

void LoadPeople()
{
	for (int z = 0; z < 51; z++)
	{
		Person per;
		memset(&per, 0, sizeof(per));
		
		FILE* file = fopen([ [ NSString stringWithFormat:@"%@/People/%i.txt", [ [ NSBundle mainBundle ] resourcePath ], z + 1 ] UTF8String ], "r");
		if (!file)
			break;
		
		fseek(file, 0, SEEK_END);
		unsigned long size = ftell(file);
		rewind(file);
		char* buffer = (char*)malloc(size);
		fread(buffer, 1, size, file);
		
		unsigned long offset = 0;
		NSMutableString* name = [ NSMutableString string ];
		char cmd = 0;
		while (cmd != '\n')
		{
			cmd = buffer[offset++];
			[ name appendFormat:@"%c", cmd ];
		}
		[ name deleteCharactersInRange:NSMakeRange([ name length ] - 1, 1) ];
		per.name = [ [ NSString alloc ] initWithString:name ];
		cmd = 0;
		
		NSMutableString* desc = [ NSMutableString string ];
		while (cmd != '\n')
		{
			cmd = buffer[offset++];
			[ desc appendFormat:@"%c", cmd ];
		}
		[ desc deleteCharactersInRange:NSMakeRange([ desc length ] - 1, 1) ];
		per.desc = [ [ NSString alloc ] initWithString:desc ];
		cmd = 0;
		
		free(buffer);
		buffer = NULL;
		fseek(file, offset, SEEK_SET);
		
		unsigned int images = 0;
		fscanf(file, "%i\n", &images);
		for (int q = 0; q < images; q++)
		{
			NSMutableString* str = [ NSMutableString string ];
			do
			{
				fscanf(file, "%c", &cmd);
				[ str appendFormat:@"%c", cmd ];
				
			}
			while (cmd != '\n');
			[ str deleteCharactersInRange:NSMakeRange([ str length ] - 1, 1) ];
			cmd = 0;
			per.images.push_back([ [ NSString alloc ] initWithString:str ]);
		}
		unsigned int music = 0;
		fscanf(file, "%i\n", &music);
		for (int q = 0; q < music; q++)
		{
			NSMutableString* str = [ NSMutableString string ];
			do
			{
				fscanf(file, "%c", &cmd);
				[ str appendFormat:@"%c", cmd ];
				
			}
			while (cmd != '\n');
			[ str deleteCharactersInRange:NSMakeRange([ str length ] - 1, 1) ];
			cmd = 0;
			per.images.push_back([ [ NSString alloc ] initWithString:str ]);
		}
		unsigned int movie = 0;
		fscanf(file, "%i\n", &movie);
		for (int q = 0; q < movie; q++)
		{
			NSMutableString* str = [ NSMutableString string ];
			do
			{
				fscanf(file, "%c", &cmd);
				[ str appendFormat:@"%c", cmd ];
				
			}
			while (cmd != '\n');
			[ str deleteCharactersInRange:NSMakeRange([ str length ] - 1, 1) ];
			cmd = 0;
			per.images.push_back([ [ NSString alloc ] initWithString:str ]);
		}
		
		people.push_back(per);
	}
}

void LoadLevel(unsigned int level)
{
	FILE* file = fopen([ [ NSString stringWithFormat:@"%@/Levels/Level%i/%i.lvl", [ [ NSBundle 
                mainBundle ] resourcePath ], level, level ] UTF8String ], "rb");
	if (!file)
		return;
    lastX = 0;
    lastY = 0.2;
    lastZ = 0;
    currentLevel = level;
    [ glView clearTextures ];
    
   // ypos = 0.2;
    jumping = FALSE;
    getTo = 5;
    
    float transx = 0, transy = 0, transz = 0;
    
	// First load all 51 people textures
	for (int z = 0; z < people.size(); z++)
		[ glView loadBitmap:[ NSString stringWithFormat:@"%@", people[z].images[0] ] ];
	
	unsigned int numImages = 0;
    fscanf(file, "%i\n", &numImages);
    for (int z = 0; z < numImages; z++)
    {
        NSMutableString* str = [ [ NSMutableString alloc ] init ];
        unsigned char cmd = 0;
		fread(&cmd, 1, 1, file);
		while (cmd != '\n')
		{
			[ str appendFormat:@"%c", cmd ];
			fread(&cmd, 1, 1, file);
		}
        [ glView loadBitmap:[ NSString stringWithFormat:@"%@/Levels/%@", [ [ NSBundle 
                    mainBundle ] resourcePath ], str ] ];
        [ str release ];
        str = nil;
    }
    
    unsigned int lvlPoints = 0;
    fscanf(file, "%i\n", &lvlPoints);
    for (int z = 0; z < lvlPoints; z++)
    {
        float x1 = 0, y1 = 0, z1 = 0, x2 = 0, y2 = 0, z2 = 0;
        unsigned int checkUp = 0;
        fscanf(file, "%f, %f, %f, %f, %f, %f, %i\n", &x1, &y1, &z1, &x2, &y2, &z2, &checkUp);
        LevelPoint p = { x1, x2, y1, y2, z1, z2, checkUp };
        levelPoints.push_back(p);
    }
    
	blocks.clear();
	unsigned int num = 0;
	fscanf(file, "%i\n\n", &num);
	blocks.resize(num);
	for (int z = 0; z < num; z++)
	{
		float vert = 0;
        int img = 0;
		fscanf(file, "%f, %i\n", &vert, &img);
        int amtPaths = round((vert - (int)vert) * 100);
        blocks[z].paths.resize(amtPaths);
        vert = (int)vert;
		blocks[z].verticies = vert;
		blocks[z].verts.clear();
		blocks[z].verts.resize(vert * 3);
		for (int q = 0; q < vert * 3; q += 3)
		{
			float x = 0, y = 0, zr = 0;
			fscanf(file, "%f, %f, %f, ", &x, &y, &zr);
			blocks[z].verts[q] = x + transx;
			blocks[z].verts[q + 1] = y - 2.2 + transy;
			blocks[z].verts[q + 2] = zr + transz;
		}
		fscanf(file, "\n");
		blocks[z].colors.clear();
		blocks[z].colors.resize(vert * 4);
		for (int q = 0; q < vert * 4; q += 4)
		{
			float red = 0, green = 0, blue = 0, alpha = 0;
			fscanf(file, "%f, %f, %f, %f, ", &red, &green, &blue, &alpha);
			blocks[z].colors[q] = red;
			blocks[z].colors[q + 1] = green;
			blocks[z].colors[q + 2] = blue;
			blocks[z].colors[q + 3] = alpha;
		}
        fscanf(file, "\n");
		if (img < 0)
			img = -img;
		else if (img > 0)
			img += people.size();
		blocks[z].texture = img;
        for (int q = 0; q < blocks[z].paths.size(); q++)
        {
            Path p;
            memset(&p, 0, sizeof(p));
            float x1 = 0, y1 = 0, z1 = 0;
            unsigned int frames = 0;
            fscanf(file, "%f, %f, %f, %i\n", &x1, &y1, &z1, &frames);
            p.x = x1;
            p.y = y1;
            p.z = z1;
            p.frames = frames;
            blocks[z].paths[q] = p;
        }
        blocks[z].pathPtr = 0;
        blocks[z].frameCounter = 0;
        
        if (blocks[z].verticies == 1)
        {
            transx += blocks[z].verts[0];
            transy += blocks[z].verts[1] + 2.2;
            transz += blocks[z].verts[2];
            blocks.erase(blocks.begin() + z);
            z--;
            num--;
        }
        
		fscanf(file, "\n");
	}
	
	fclose(file);
}

void DrawCube(float width, float height, float depth)
{
	glBegin(GL_QUADS);
	{
		glVertex3d(-width, -height, depth);
		glVertex3d(-width, height, depth);
		glVertex3d(width, height, depth);
		glVertex3d(width, -height, depth);
		
		glVertex3d(-width, -height, -depth);
		glVertex3d(-width, height, -depth);
		glVertex3d(width, height, -depth);
		glVertex3d(width, -height, -depth);
		
		glVertex3d(-width, -height, depth);
		glVertex3d(-width, height, depth);
		glVertex3d(width, height, depth);
		glVertex3d(width, -height, depth);
		
		glVertex3d(-width, -height, -depth);
		glVertex3d(-width, -height, depth);
		glVertex3d(-width, height, depth);
		glVertex3d(-width, height, -depth);
		
		glVertex3d(width, -height, -depth);
		glVertex3d(width, -height, depth);
		glVertex3d(width, height, depth);
		glVertex3d(width, height, -depth);
		
		glVertex3d(-width, height, -depth);
		glVertex3d(-width, height, depth);
		glVertex3d(width, height, depth);
		glVertex3d(width, height, -depth);
		
		glVertex3d(-width, -height, -depth);
		glVertex3d(-width, -height, depth);
		glVertex3d(width, -height, depth);
		glVertex3d(width, -height, -depth);
	}
	glEnd();
}

void WorldKeyDown()
{
    if (!canMove)
        return;
    
    double newXpos = xpos;
	double newZpos = zpos;
	for (int z = 0; z < [ keys count ]; z++)
	{
		unichar unicodeKey = [ [ keys objectAtIndex:z ] intValue ];
		switch( unicodeKey )
		{
			case 'q':
			case 'Q':
			{
				xrot += 2;
				if (xrot > 90)
					xrot = 90;
				break;
			}
			case 'a':
			case 'A':
			{
				xrot -= 2;
                if (xrot < 0)
					xrot = 0;
				break;
			}
			case 'w':
			case 'W':
			{
				cRadius -= 0.4;
				if (cRadius < 0)
					cRadius = 0;
				break;
			}
			case 's':
			case 'S':
			{
				cRadius += 0.4;
				if (cRadius > 15)
					cRadius = 15;
				break;
			}
			case NSUpArrowFunctionKey:
			{
				float xrotrad, yrotrad;
				yrotrad = (yrot / 180 * 3.141592654f);
				xrotrad = (0 / 180 * 3.141592654f); 
				newXpos += sin(yrotrad) / 2.0;
				newZpos -= cos(yrotrad) / 2.0;
				ypos -= sin(xrotrad) / 2.0;
				break;
			}
			case NSDownArrowFunctionKey:
			{
				float xrotrad, yrotrad;
				yrotrad = (yrot / 180 * 3.141592654f);
				xrotrad = (0 / 180 * 3.141592654f); 
				newXpos -= sin(yrotrad) / 2.0;
				newZpos += cos(yrotrad) / 2.0;
				ypos += sin(xrotrad) / 2.0;
				break;
			}
			case NSRightArrowFunctionKey:
			{
				yrot += 4;
				if (yrot > 360)
					yrot -= 360;
				break;
			}
			case NSLeftArrowFunctionKey:
			{
				yrot -= 4;
				if (yrot < -360)
					yrot += 360;
				break;
			}
			case ' ':
			{
				if (jumping == 0)
				{
					jumping = 1;  
					getTo = 5 + ypos;
				}
				break;
			}
			case 'r':
			{
				ypos += 0.4;
				break;
			}
		}
	}
	
    int yCollision = -1;
	if (ypos > 0 && jumping != 1)
	{
		BOOL realDoes = FALSE;
		float prev = ypos;
		ypos -= 0.1;
		for (int z = 0; z < blocks.size(); z++)
		{
			std::vector<float> block = blocks[z].verts;
			double xcoord[4] = { block[0], block[3], block[6], block[9] };
			double ycoord[4] = { block[1], block[4], block[7], block[10] };
			double zcoord[4] = { block[2], block[5], block[8], block[11] };
			
			BOOL does = TRUE;
			double highestX = -100;
			double lowestX = 100;
			for (int q = 0; q < 4; q++)
			{
				if (xcoord[q] > highestX)
					highestX = xcoord[q];
				if (lowestX > xcoord[q])
					lowestX = xcoord[q];
			}
			double highestY = -100;
			double lowestY = 100;
			for (int q = 0; q < 4; q++)
			{
				if (ycoord[q] > highestY)
					highestY = ycoord[q];
				if (lowestY > ycoord[q])
					lowestY = ycoord[q];
			}
			double highestZ = -100;
			double lowestZ = 100;
			for (int q = 0; q < 4; q++)
			{
				if (zcoord[q] > highestZ)
					highestZ = zcoord[q];
				if (lowestZ > zcoord[q])
					lowestZ = zcoord[q];
			}
			if (!(xpos >= lowestX - BodyWidth && xpos < highestX + BodyWidth))
			{
				does = FALSE;
				jumping = 2;
				continue;
			}
			if (!(zpos >= lowestZ - BodyDepth && zpos < highestZ + BodyDepth))
			{
				does = FALSE;
				jumping = 2;
				continue;
			}
			if (!(prev - YSTART > lowestY && !(ypos - YSTART > lowestY + BodyHeight)))
			{
				does = FALSE;
				jumping = 2;
				continue;
			}
			if (does)
			{
				realDoes = TRUE;
				prev = lowestY + YSTART + BodyHeight + 0.00001;
                CheckPerson(z);
                yCollision = z;
				break;
			}
		}
        if (CheckNextLevel())
            return;
		if (realDoes)
		{
			ypos = prev;
			jumping = 0;
            if (blocks[yCollision].paths.size() == 0 && checkLast)
            {
                lastX = xpos;
                lastY = ypos;
                lastZ = zpos;
            }
		}
	}
    if (ypos < 0.2)
    {
        canMove = FALSE;
        command = 1;
        rregs.push_back(0);
        currentLevel--;
    }
    
    if (!canFall)
        return;
    
    for (int z = 0; z < blocks.size(); z++)
    {
        if (blocks[z].paths.size() != 0)
        {
            if (blocks[z].pathPtr >= blocks[z].paths.size())
                blocks[z].pathPtr = 0;
            Path p = blocks[z].paths[blocks[z].pathPtr];
            if (p.frames == 0)
                continue;
            if (z == yCollision)
            {
                newXpos += p.x / (double)p.frames;
                newZpos += p.z / (double)p.frames;
            }
        }
    }
	
    int xCollision = -1;
    float prevX = xpos;
	do
	{
		BOOL realDoes = FALSE;
		for (int z = 0; z < blocks.size(); z++)
		{
			std::vector<float> block = blocks[z].verts;
			double xcoord[4] = { block[0], block[3], block[6], block[9] };
			double ycoord[4] = { block[1], block[4], block[7], block[10] };
			double zcoord[4] = { block[2], block[5], block[8], block[11] };
			
			BOOL does = TRUE;
			double highestX = -100;
			double lowestX = 100;
			for (int q = 0; q < 4; q++)
			{
				if (xcoord[q] > highestX)
					highestX = xcoord[q];
				if (lowestX > xcoord[q])
					lowestX = xcoord[q];
			}
			double highestY = -100;
			double lowestY = 100;
			for (int q = 0; q < 4; q++)
			{
				if (ycoord[q] > highestY)
					highestY = ycoord[q];
				if (lowestY > ycoord[q])
					lowestY = ycoord[q];
			}
			double highestZ = -100;
			double lowestZ = 100;
			for (int q = 0; q < 4; q++)
			{
				if (zcoord[q] > highestZ)
					highestZ = zcoord[q];
				if (lowestZ > zcoord[q])
					lowestZ = zcoord[q];
			}
			if (!((ypos - YSTART) > lowestY/* - BodyHeight*/ && (ypos - YSTART) <
				  highestY + BodyHeight))
				continue;
			float avgZ = 0, avgX = 0;
			avgZ = ((zpos - lowestZ) / (highestZ - lowestZ));
			if (avgZ > 1.0 + (BodyDepth / (highestZ - lowestZ))  || avgZ <= 
				-(BodyDepth / (highestZ - lowestZ)))
				continue;
			if (fabs(lowestX) > fabs(highestX))
			{
				float bLowestX = lowestX;
				lowestX = highestX;
				highestX = bLowestX;
			}
			avgX = highestX * avgZ;
			avgX += lowestX * (1 - avgZ);
			if (!(xpos >= avgX - BodyWidth && xpos <= avgX + BodyWidth))
				does = FALSE;
			if (does)
			{
				realDoes = TRUE;
                CheckPerson(z);
                xCollision = z;
				break;
			}
		}
        if (CheckNextLevel())
            return;
		if (realDoes)
		{
			if (xpos < newXpos)
				xpos -= BodyWidth / 2;
			else
				xpos += BodyWidth / 2;
			break;
		}
		if (xpos < newXpos)
			xpos += 0.01;
		else
			xpos -= 0.01;
        if (!(xpos < newXpos - 0.01 || xpos > newXpos + 0.01))
            xpos = newXpos;
	}
    while (xpos < newXpos - 0.01 || xpos > newXpos + 0.01);
    
    for (int z = 0; z < blocks.size(); z++)
    {
        if (blocks[z].paths.size() != 0)
        {
            if (blocks[z].pathPtr >= blocks[z].paths.size())
                blocks[z].pathPtr = 0;
            Path p = blocks[z].paths[blocks[z].pathPtr];
            if (p.frames == 0)
                continue;
            if (z == xCollision)
            {
                std::vector<float> block = blocks[z].verts;
                double xcoord[4] = { block[0], block[3], block[6], block[9] };
                double highestX = -100;
                double lowestX = 100;
                for (int q = 0; q < 4; q++)
                {
                    if (xcoord[q] > highestX)
                        highestX = xcoord[q];
                    if (lowestX > xcoord[q])
                        lowestX = xcoord[q];
                }
                double avgX = (highestX + lowestX) / 2.0;
                xpos = prevX;
                xpos += p.x / (double)p.frames;
                if (xpos > avgX)
                    xpos += 0.01;
                else
                    xpos -= 0.01;
                break;
            }
        }
    }
	
    int zCollision = -1;
    float prevZ = zpos;
	do
	{
		BOOL realDoes = FALSE;
		for (int z = 0; z < blocks.size(); z++)
		{
			std::vector<float> block = blocks[z].verts;
			double xcoord[4] = { block[0], block[3], block[6], block[9] };
			double ycoord[4] = { block[1], block[4], block[7], block[10] };
			double zcoord[4] = { block[2], block[5], block[8], block[11] };
			
			double highestX = -100;
			double lowestX = 100;
			for (int q = 0; q < 4; q++)
			{
				if (xcoord[q] > highestX)
					highestX = xcoord[q];
				if (lowestX > xcoord[q])
					lowestX = xcoord[q];
			}
			double highestY = -100;
			double lowestY = 100;
			for (int q = 0; q < 4; q++)
			{
				if (ycoord[q] > highestY)
					highestY = ycoord[q];
				if (lowestY > ycoord[q])
					lowestY = ycoord[q];
			}
			double highestZ = -100;
			double lowestZ = 100;
			for (int q = 0; q < 4; q++)
			{
				if (zcoord[q] > highestZ)
					highestZ = zcoord[q];
				if (lowestZ > zcoord[q])
					lowestZ = zcoord[q];
			}
			BOOL does = TRUE;
			if (!((ypos - YSTART) > lowestY/* - BodyHeight*/ && (ypos - YSTART)
				  < highestY + BodyHeight))
				continue;
			float avgZ = 0, avgX = 0;
			avgX = ((xpos - lowestX) / (highestX - lowestX));
			if (avgX > 1.0 + (BodyWidth / (highestX - lowestX))  || avgX <= 
				-(BodyWidth / (highestX - lowestX)))
				continue;
			if (fabs(lowestZ) > fabs(highestZ))
			{
				float bLowestZ = lowestZ;
				lowestZ = highestZ;
				highestZ = bLowestZ;
			}
			avgZ = highestZ * avgX;
			avgZ += lowestZ * (1 - avgX);
			if (!(zpos >= avgZ - BodyDepth && zpos <= avgZ + BodyDepth))
				does = FALSE;
			if (does)
			{
				realDoes = TRUE;
                CheckPerson(z);
                zCollision = z;
				break;
			}
		}
        if (CheckNextLevel())
            return;
		if (realDoes)
		{
			if (zpos < newZpos)
				zpos -= BodyDepth / 2;
			else
				zpos += BodyDepth / 2;
			break;
		}
		if (zpos < newZpos)
			zpos += 0.01;
		else
			zpos -= 0.01;
        if (!(zpos < newZpos - 0.01 || zpos > newZpos + 0.01))
            zpos = newZpos;
	}
    while (zpos < newZpos - 0.01 || zpos > newZpos + 0.01);
    
    for (int z = 0; z < blocks.size(); z++)
    {
        if (blocks[z].paths.size() != 0)
        {
            if (blocks[z].pathPtr >= blocks[z].paths.size())
                blocks[z].pathPtr = 0;
            Path p = blocks[z].paths[blocks[z].pathPtr];
            if (p.frames == 0)
                continue;
            if (z == zCollision)
            {
                std::vector<float> block = blocks[z].verts;
                double zcoord[4] = { block[2], block[5], block[8], block[11] };
                double highestZ = -100;
                double lowestZ = 100;
                for (int q = 0; q < 4; q++)
                {
                    if (zcoord[q] > highestZ)
                        highestZ = zcoord[q];
                    if (lowestZ > zcoord[q])
                        lowestZ = zcoord[q];
                }
                double avgZ = (highestZ + lowestZ) / 2.0;
                zpos = prevZ;
                zpos += p.z / (double)p.frames;
                if (zpos > avgZ)
                    zpos += 0.01;
                else
                    zpos -= 0.01;
                break;
            }
        }
    }
    
    for (int z = 0; z < blocks.size(); z++)
    {
        if (blocks[z].paths.size() != 0)
        {
            if (blocks[z].pathPtr >= blocks[z].paths.size())
                blocks[z].pathPtr = 0;
            Path p = blocks[z].paths[blocks[z].pathPtr];
            if (p.frames == 0)
                continue;
            for (int q = 0; q < blocks[z].verticies; q++)
            {
                blocks[z].verts[(q * 3)] += p.x / (double)p.frames;
                blocks[z].verts[(q * 3) + 1] += p.y / (double)p.frames;
                blocks[z].verts[(q * 3) + 2] += p.z / (double)p.frames;
            }
            blocks[z].frameCounter++;
            if (blocks[z].frameCounter > p.frames)
            {
                blocks[z].frameCounter = 0;
                blocks[z].pathPtr++;
            }
        }
    }
}

void DrawWorld()
{
    if (textBox)
        canMove = FALSE;
    
    glEnable(GL_BLEND);								
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	
	glLoadIdentity();
	
	glDisable(GL_TEXTURE_2D);
	glTranslated(0, -YSTART, -cRadius);
    glColor4d(1, 0, 0, 1);
	glRotated(xrot, 1, 0, 0);
    DrawCube(BodyWidth, BodyHeight, BodyDepth);
    glTranslated(0, YSTART, 0);
	glRotated(yrot, 0, 1, 0);
	glTranslated(-xpos, -ypos, -zpos);
	
	glEnable(GL_TEXTURE_2D);
	for (int z = 0; z < blocks.size(); z++)
	{
		if (blocks[z].texture != 0)
			glBindTexture(GL_TEXTURE_2D, [ [ textures objectAtIndex:blocks[z].texture - 1 ] intValue ]);
		else
			glBindTexture(GL_TEXTURE_2D, 0);
		float highestx = -100, highesty = -100;
		if (blocks[z].texture != 0)
		{
			for (int q = 0; q < blocks[z].verticies; q += 3)
			{
				if (highestx < blocks[z].verts[q])
					highestx = blocks[z].verts[q];
				if (highesty < blocks[z].verts[q + 1])
					highesty = blocks[z].verts[q + 1];
			}
		}
		glBegin(GL_QUADS);
		{
			for (int q = 0; q < blocks[z].verticies; q++)
			{
				std::vector<float> colors = blocks[z].colors;
				glColor4d(colors[(q * 4)], colors[(q * 4) + 1], colors[(q * 4) + 2],
						  colors[(q * 4) + 3]);
				std::vector<float> verts = blocks[z].verts;
				if (blocks[z].texture != 0)
				{
                    switch (q)
                    {
                        case 0:
                            glTexCoord2d(0, 1);
                            break;
                        case 1:
                            glTexCoord2d(1, 1);
                            break;
                        case 2:
                            glTexCoord2d(1, 0);
                            break;
                        case 3:
                            glTexCoord2d(0, 0);
                            break;
                    }
				}
				glVertex3d(verts[(q * 3)], verts[(q * 3) + 1], verts[(q * 3) + 2]);
			}
		}
		glEnd();
	}
    glDisable(GL_TEXTURE_2D);
    
    if (command == 1)
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
        glColor4d(0, 0, 0, rregs[0]);
        rregs[0] += 1 / 60.0;
        glBegin(GL_QUADS);
        {
            glVertex2d(0, 0);
            glVertex2d(resolution.width, 0);
            glVertex2d(resolution.width, resolution.height);
            glVertex2d(0, resolution.height);
        }
        glEnd();
        if (rregs[0] >= 1)
        {
            xpos = lastX;
            ypos = lastY;
            zpos = lastZ;
            if (resetCamera)
            {
                xrot = 15;
                yrot = 0;
                resetCamera = FALSE;
            }
            jumping = FALSE;
            getTo = 5;
            LoadLevel(currentLevel + 1);
            command = 2;
            canFall = FALSE;
            checkLast = TRUE;
        }
        
        glPopMatrix(); // GL_MODELVIEW
        glMatrixMode (GL_PROJECTION);
        glPopMatrix();
        glMatrixMode (s);
    }
    else if (command == 2)
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
        glColor4d(0, 0, 0, rregs[0]);
        rregs[0] -= 1 / 60.0;
        glBegin(GL_QUADS);
        {
            glVertex2d(0, 0);
            glVertex2d(resolution.width, 0);
            glVertex2d(resolution.width, resolution.height);
            glVertex2d(0, resolution.height);
        }
        glEnd();
        if (rregs[0] <= 0)
        {
            command = 0;
            rregs.clear();
            canFall = TRUE;
            canMove = TRUE;
            checkLast = TRUE;
        }
        
        glPopMatrix(); // GL_MODELVIEW
        glMatrixMode (GL_PROJECTION);
        glPopMatrix();
        glMatrixMode (s);
    }
    else if (command == 3 && rregs[1] != 0)
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
        glColor4d(0, 0, 0, rregs[0]);
        rregs[0] += 1 / 60.0;
        glBegin(GL_QUADS);
        {
            glVertex2d(0, 0);
            glVertex2d(resolution.width, 0);
            glVertex2d(resolution.width, resolution.height);
            glVertex2d(0, resolution.height);
        }
        glEnd();
        if (rregs[0] >= 1)
        {
			// Add views
			MDImageView* view = [ [ MDImageView alloc ] initWithFrame:MakeRect(200, 400, 600, 600) background:MD_IMAGEVIEW_DEFAULT_COLOR ];
			NSMutableString* string = [ NSMutableString stringWithFormat:@"%@/Images/", [ [ NSBundle mainBundle ] resourcePath ] ];
			Person per;
			if (blocks[rregs[1]].texture == 55)
			{
				[ string appendString:people[blocks[rregs[1] - 1].texture - 1].images[0] ];
				per = people[blocks[rregs[1] - 1].texture - 1];
			}
			else
			{
				[ string appendString:people[blocks[rregs[1]].texture - 1].images[0] ];
				per = people[blocks[rregs[1]].texture - 1];
			}
			[ view setImage:string onThread:NO ];
			[ view setIdentity:@"Image" ];
			[ view release ];
			
			MDTextView* text = [ [ MDTextView alloc ] initWithFrame:MakeRect(900, 800, 900, 200) background:MD_TEXTVIEW_DEFAULT_COLOR ];
			[ text setTextFont:[ NSFont systemFontOfSize:28 ] ];
			[ text setText:per.desc ];
			[ text setEditable:NO ];
			[ text release ];
			
			MDButton* back = [ [ MDButton alloc ] initWithFrame:MakeRect(20, 20, 70, 20) background:MD_BUTTON_DEFAULT_BUTTON_COLOR ];
			[ back setText:@"Back" ];
			[ back setTarget:glView ];
			[ back setAction:@selector(goBack) ];
			[ back release ];
			
			MDButton* left = [ [ MDButton alloc ] initWithFrame:MakeRect(200, 370, 70, 20) background:MD_BUTTON_DEFAULT_BUTTON_COLOR ];
			[ left setText:@"←" ];
			[ left setTarget:glView ];
			[ left setAction:@selector(goLeft) ];
			[ left release ];
			
			MDButton* right = [ [ MDButton alloc ] initWithFrame:MakeRect(730, 370, 70, 20) background:MD_BUTTON_DEFAULT_BUTTON_COLOR ];
			[ right setText:@"→" ];
			[ right setTarget:glView ];
			[ right setAction:@selector(goRight) ];
			[ right release ];
			
			command = 5;
			rregs.clear();
			canMove = FALSE;
        }
        
        glPopMatrix(); // GL_MODELVIEW
        glMatrixMode (GL_PROJECTION);
        glPopMatrix();
        glMatrixMode (s);
    }
    else if (command == 3 && rregs[1] == 0)
    {
        command = 0;
        rregs.clear();
        canMove = TRUE;
    }
    else if (command == 4)
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
        glColor4d(0, 0, 0, rregs[0]);
        rregs[0] += 1 / 60.0;
        glBegin(GL_QUADS);
        {
            glVertex2d(0, 0);
            glVertex2d(resolution.width, 0);
            glVertex2d(resolution.width, resolution.height);
            glVertex2d(0, resolution.height);
        }
        glEnd();
        if (rregs[0] >= 1)
        {
            xpos = lastX;
            ypos = lastY;
            zpos = lastZ;
            if (resetCamera)
            {
                xrot = 15;
                yrot = 0;
                resetCamera = FALSE;
            }
            jumping = FALSE;
            getTo = 5;
            LoadLevel(currentLevel - 1);
            command = 2;
            canFall = FALSE;
            checkLast = TRUE;
        }
        
        glPopMatrix(); // GL_MODELVIEW
        glMatrixMode (GL_PROJECTION);
        glPopMatrix();
        glMatrixMode (s);
    }
	else if (command == 5)
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
        glColor4d(0, 0, 0, rregs[0]);
		glBegin(GL_QUADS);
        {
            glVertex2d(0, 0);
            glVertex2d(resolution.width, 0);
            glVertex2d(resolution.width, resolution.height);
            glVertex2d(0, resolution.height);
        }
        glEnd();
		
		glPopMatrix(); // GL_MODELVIEW
        glMatrixMode (GL_PROJECTION);
        glPopMatrix();
        glMatrixMode (s);
	}
    glDisable(GL_BLEND);
	
	if (jumping == 1 && canMove)
	{
		double prev = ypos;
		ypos += 0.2;
		BOOL realDoes = FALSE;
		for (int z = 0; z < blocks.size(); z++)
		{
			std::vector<float> block = blocks[z].verts;
			double xcoord[4] = { block[0], block[3], block[6], block[9] };
			double ycoord[4] = { block[1], block[4], block[7], block[10] };
			double zcoord[4] = { block[2], block[5], block[8], block[11] };
			
			BOOL does = TRUE;
			double highestX = -100;
			double lowestX = 100;
			for (int q = 0; q < 4; q++)
			{
				if (xcoord[q] > highestX)
					highestX = xcoord[q];
				if (lowestX > xcoord[q])
					lowestX = xcoord[q];
			}
			double highestY = -100;
			double lowestY = 100;
			for (int q = 0; q < 4; q++)
			{
				if (ycoord[q] > highestY)
					highestY = ycoord[q];
				if (lowestY > ycoord[q])
					lowestY = ycoord[q];
			}
			double highestZ = -100;
			double lowestZ = 100;
			for (int q = 0; q < 4; q++)
			{
				if (zcoord[q] > highestZ)
					highestZ = zcoord[q];
				if (lowestZ > zcoord[q])
					lowestZ = zcoord[q];
			}
			if (!(xpos >= lowestX - BodyWidth && xpos < highestX + BodyWidth))
			{
				does = FALSE;
				continue;
			}
			if (!(zpos >= lowestZ - BodyDepth && zpos < highestZ + BodyDepth))
			{
				does = FALSE;
				continue;
			}
			if (!(prev - YSTART < lowestY - BodyHeight && !(ypos - YSTART <
                                                            lowestY - BodyHeight)))
			{
				does = FALSE;
				continue;
			}
			if (does)
			{
				realDoes = TRUE;
				break;
			}
		}
		if (ypos >= getTo || realDoes)
		{
			if (realDoes)
				ypos = prev;
			else
				ypos = getTo;
			jumping = 2;
		}
	}
	else if (jumping == 2 && canMove)
	{
		ypos -= 0.1;
		if (ypos <= 0.2)
		{
			ypos = 0.2;
			jumping = 0;
		}
	}
    angle++;
}


