//
//  MDRotationBox.mm
//  MovieDraw
//
//  Created by Neil on 5/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MDRotationBox.h" 

MDRect ToTwoD(MDRect threeD);
MDRect ToTwoD(MDRect threeD, double xrot, double yrot, double zrot);

MDRect ToTwoD(MDRect threeD)
{
	double totalX = CONSTANT(resolution.width / 2) * -threeD.z;
	double realX = (threeD.x + (totalX / 2)) / totalX * resolution.width;
	double realW = (threeD.width / totalX) * resolution.width;
	double totalY = CONSTANT(resolution.height / 2) * -threeD.z;
	double realY = (threeD.y + (totalY / 2)) / totalY * resolution.height;
	double realH = (threeD.height / totalY) * resolution.height;
	MDRect rect = MakeRect(realX + 1, realY - 2, realW, realH);
	return rect;
	
	/*
	 threeD.x = realx / resolution.width * totalX - (totalX / 2)
	 */
}

MDRect ToTwoD(MDRect threeD, double xrot, double yrot, double zrot)
{
	double rotX = fabs(yrot);
	while (rotX > 90)
		rotX -= 90;
	if (rotX > 45)
		rotX = 90 - rotX;
	double rotY = fabs(xrot);
	while (rotY > 90)
		rotY -= 90;
	if (rotY > 45)
		rotY = 90 - rotY;

	
	double totalX = CONSTANT(resolution.width / 2) * -threeD.z;
	double realX = ((threeD.x - ((sin(rotX * pi / 180) * threeD.width / 3.312))) + (totalX / 2)) / totalX * resolution.width;
	double realW = ((threeD.width + ((sin(rotX * pi / 180) * threeD.width / 1.656))) / totalX) * resolution.width;
	double totalY = CONSTANT(resolution.height / 2) * -threeD.z;
	double realY = ((threeD.y - ((sin(rotY * pi / 180) * threeD.height / 3.312))) + (totalY / 2)) / totalY * resolution.height;
	double realH = ((threeD.height + ((sin(rotY * pi / 180) * threeD.height / 1.656))) / totalY) * resolution.height;
	MDRect rect = MakeRect(realX + 1, realY - 2, realW, realH);
	return rect;
}

@implementation MDRotationBox

+ (id) mdRotationBox
{
	MDRotationBox* view = [ [ [ MDRotationBox alloc ] init ] autorelease ];
	return view;
}

+ (id) mdRotationBoxWithFrame: (MDRect)rect background: (NSColor*)bkg
{
	MDRotationBox* view = [ [ [ MDRotationBox alloc ] initWithFrame:rect background:bkg ] autorelease ];
	return view;
}

- (BOOL) uses3D
{
	return YES;
}

- (id)init
{
    self = [super init];
    if (self) {
        rotationX = 0;
		rotationY = 0;
		rotationZ = 0;
		fadealpha = 0.7;
		side = -1;
		
		sides.push_back([ MDText create2DText:[ [ [ NSAttributedString alloc ] initWithString:@" Front " attributes:[ NSDictionary dictionaryWithObject:[ NSFont systemFontOfSize:100 ] forKey:NSFontAttributeName ] ] autorelease ] ]);
		sides.push_back([ MDText create2DText:[ [ [ NSAttributedString alloc ] initWithString:@" Right " attributes:[ NSDictionary dictionaryWithObject:[ NSFont systemFontOfSize:100 ] forKey:NSFontAttributeName ] ] autorelease ] ]);
		sides.push_back([ MDText create2DText:[ [ [ NSAttributedString alloc ] initWithString:@" Back " attributes:[ NSDictionary dictionaryWithObject:[ NSFont systemFontOfSize:100 ] forKey:NSFontAttributeName ] ] autorelease ] ]);
		sides.push_back([ MDText create2DText:[ [ [ NSAttributedString alloc ] initWithString:@" Left " attributes:[ NSDictionary dictionaryWithObject:[ NSFont systemFontOfSize:100 ] forKey:NSFontAttributeName ] ] autorelease ] ]);
		sides.push_back([ MDText create2DText:[ [ [ NSAttributedString alloc ] initWithString:@" Bottom " attributes:[ NSDictionary dictionaryWithObject:[ NSFont systemFontOfSize:100 ] forKey:NSFontAttributeName ] ] autorelease ] ]);
		sides.push_back([ MDText create2DText:[ [ [ NSAttributedString alloc ] initWithString:@" Top " attributes:[ NSDictionary dictionaryWithObject:[ NSFont systemFontOfSize:100 ] forKey:NSFontAttributeName ] ] autorelease ] ]);
		
		pressure = 0;
		for (int z = 1; z < 31; z++)
			pressure += (pow(z, 2) / 3600);
		pressure *= 2;
		
		[ self setContinuous:YES ];
    }
    
    return self;
}

- (id) initWithFrame:(MDRect)rect background:(NSColor *)bkg
{
	self = [ super initWithFrame:rect background:bkg ];
    if (self) {
		rotationX = 0;
		rotationY = 0;
		rotationZ = 0;
		fadealpha = 0.7;
		side = -1;
		
		sides.push_back([ MDText create2DText:[ [ [ NSAttributedString alloc ] initWithString:@" Front " attributes:[ NSDictionary dictionaryWithObject:[ NSFont systemFontOfSize:100 ] forKey:NSFontAttributeName ] ] autorelease ] ]);
		sides.push_back([ MDText create2DText:[ [ [ NSAttributedString alloc ] initWithString:@" Right " attributes:[ NSDictionary dictionaryWithObject:[ NSFont systemFontOfSize:100 ] forKey:NSFontAttributeName ] ] autorelease ] ]);
		sides.push_back([ MDText create2DText:[ [ [ NSAttributedString alloc ] initWithString:@" Back " attributes:[ NSDictionary dictionaryWithObject:[ NSFont systemFontOfSize:100 ] forKey:NSFontAttributeName ] ] autorelease ] ]);
		sides.push_back([ MDText create2DText:[ [ [ NSAttributedString alloc ] initWithString:@" Left " attributes:[ NSDictionary dictionaryWithObject:[ NSFont systemFontOfSize:100 ] forKey:NSFontAttributeName ] ] autorelease ] ]);
		sides.push_back([ MDText create2DText:[ [ [ NSAttributedString alloc ] initWithString:@" Bottom " attributes:[ NSDictionary dictionaryWithObject:[ NSFont systemFontOfSize:100 ] forKey:NSFontAttributeName ] ] autorelease ] ]);
		sides.push_back([ MDText create2DText:[ [ [ NSAttributedString alloc ] initWithString:@" Top " attributes:[ NSDictionary dictionaryWithObject:[ NSFont systemFontOfSize:100 ] forKey:NSFontAttributeName ] ] autorelease ] ]);
		
		pressure = 0;
		for (int z = 1; z < 31; z++)
			pressure += (pow(z, 2) / 3600);
		pressure *= 2;
		
		[ self setContinuous:YES ];
    }
    
    return self;
}

- (int) pick: (NSPoint) point
{
	picking = TRUE;
	side = -1;
	unsigned int buffer[512];
	int viewport[4];
	glGetIntegerv(GL_VIEWPORT, viewport);
	glSelectBuffer(512, buffer);
	glRenderMode(GL_SELECT);
	glInitNames();
	glPushName(0);
	glMatrixMode(GL_PROJECTION);
	glPushMatrix();
	glLoadIdentity();
	gluPickMatrix(point.x, point.y, 1, 1, viewport);
	gluPerspective(45, windowSize.width / windowSize.height, 0.1, 100);
	glMatrixMode(GL_MODELVIEW);
	[ self drawView ];
	glMatrixMode(GL_PROJECTION);
	glPopMatrix();
	glMatrixMode(GL_MODELVIEW);
	unsigned int hits = glRenderMode(GL_RENDER);
	if (hits != 0)
	{
		int choose = buffer[3];	// name
		int depth = buffer[1]; // minimum z;
		for (int z = 1; z < hits; z++)
		{
			// If anything is closer, take that
			if (buffer[(z * 4) + 1] < (unsigned int)depth)
			{
				choose = buffer[(z * 4) + 3];
				depth = buffer[(z * 4) + 1];
			}
		}
		side = choose;
	}
	picking = FALSE;
	return hits;
}

- (void) drawView
{
	if (!visible)
		return;
	
	glEnable(GL_LIGHTING);
	glEnable(GL_LIGHT0);
	glEnable(GL_COLOR_MATERIAL);
	
	for (int z = 0; z < 6; z++)
	{
		glLoadIdentity();
		glLoadName(z);
		glTranslated(frame.x, frame.y, frame.z - (frame.depth / 2));
		glRotated(rotationX , 1, 0, 0);
		glRotated(rotationY, 0, 1, 0);
		glRotated(rotationZ, 0, 0, 1);
		if (z < 4)
			glRotated(z * 90, 0, 1, 0);
		else
		{
			glRotated((z == 4) ? 90 : -90, 0, 1, 0);
			glRotated((z == 4) ? 90 : -90, 1, 0, 0);
			glRotated(90, 0, 0, 1);
		}
		glColor4d(0.5, 0.5, 0.5, fabs(fadealpha));
		if (side == z)
			glColor4d(0.7, 0.7, 0.2, fabs(fadealpha));
		for (int q = 0; q < 2; q++)
		{
			if (q == 1)
			{
				glEnable(GL_TEXTURE_2D);
				glBindTexture(GL_TEXTURE_2D, [ sides[z] unsignedIntValue ]);
			}
			glBegin(GL_QUADS);
			{
				glNormal3d(0, 0, 1);
				glTexCoord2f(0, 0);
				glVertex3d(-frame.width / 2, -frame.height / 2, frame.depth / 2);
				glTexCoord2f(1, 0);
				glVertex3d(frame.width / 2, -frame.height / 2, frame.depth / 2);
				glTexCoord2f(1, 1);
				glVertex3d(frame.width / 2, frame.height / 2, frame.depth / 2);
				glTexCoord2f(0, 1);
				glVertex3d(-frame.width / 2, frame.height / 2, frame.depth / 2);
			}
			glEnd();
			if (q == 1)
			{
				glBindTexture(GL_TEXTURE_2D, 0);
				glDisable(GL_TEXTURE_2D);
			}
		}
	}
	glDisable(GL_TEXTURE_2D);
	glDisable(GL_COLOR_MATERIAL);
	glDisable(GL_LIGHT0);
	glDisable(GL_LIGHTING);
	
	if (picking)
		return;
	
	if (fadealpha < -0.3)
	{
		fadealpha += 0.05;
		if (fadealpha > -0.3)
			fadealpha = -0.3;
	}
	else if (fadealpha > 0.2)
	{
		fadealpha += 0.05;
		if (fadealpha > 0.8)
			fadealpha = 0.8;
	}
	
	if (setX || setY || setZ)
		[ self pick:lastMouse ];
	if (setX)
	{
		float value = framesX;
		if (value > 30)
			value = 60 - value;
		rotationX += ((toX - startX) * 21 / 20 * (pow(value, 2) / 3600)) / pressure;
		framesX++;
		if (framesX == 60)
		{
			setX = FALSE;
			rotationX = toX;
			while (rotationX >= 360)
				rotationX -= 360;
		}
	}
	if (setY)
	{
		float value = framesY;
		if (value > 30)
			value = 60 - value;
		rotationY += ((toY - startY) * 21 / 20 * (pow(value, 2) / 3600)) / pressure;
		framesY++;
		if (framesY == 60)
		{
			setY = FALSE;
			rotationY = toY;
			while (rotationY >= 360)
				rotationY -= 360;
		}
	}
	if (setZ)
	{
		float value = framesZ;
		if (value > 30)
			value = 60 - value;
		rotationZ += ((toZ - startZ) * 21 / 20 * (pow(value, 2) / 3600)) / pressure;
		framesZ++;
		if (framesZ == 60)
		{
			setZ = FALSE;
			rotationZ = toZ;
			while (rotationZ >= 360)
				rotationZ -= 360;
		}
	}
}

- (BOOL) isShowing
{
	if (setX || setY || setZ)
		return YES;
	return NO;
}

- (double) showPercent
{
	return framesX / 60.0;
}

- (BOOL) isSpecial
{
	return isSpecial;
}

- (void) mouseDown:(NSEvent *)event
{
	NSPoint point = [ event locationInWindow ];
	point.x -= origin.x;
	point.y -= origin.y;
	point.x *= resolution.width / windowSize.width;
	point.y *= resolution.height / windowSize.height;
	lastMouse = point;
	downPoint = point;
	
	if ([ self pick:point ] != 0)
	{
		up = FALSE;
		down = TRUE;
		realDown = TRUE;
		//fadealpha = 0.2;
	}
	if (target && continuous && [ target respondsToSelector:action ])
		[ target performSelector:action withObject:self ];
	
	setX = FALSE;
	setY = FALSE;
}

- (void) mouseDragged:(NSEvent *)event
{
	NSPoint point = [ event locationInWindow ];
	point.x -= origin.x;
	point.y -= origin.y;
	point.x *= resolution.width / windowSize.width;
	point.y *= resolution.height / windowSize.height;
	
	[ self pick:point ];
	if (down)
	{
		float changeX = point.x - lastMouse.x;
		float changeY = point.y - lastMouse.y;
		
		rotationX -= (TH(changeY, -frame.z) / frame.height) * 90;
		while (rotationX >= 360)
			rotationX -= 360;
		while (rotationX < 0)
			rotationX += 360;
		
		rotationY += (TW(changeX, -frame.z) / frame.width) * 90;
		while (rotationY >= 360)
			rotationY -= 360;
		while (rotationY < 0)
			rotationY += 360;
		
		lastMouse = point;
	
		if (target && continuous && [ target respondsToSelector:action ])
			[ target performSelector:action withObject:self ];
	}
}

- (void) mouseMoved:(NSEvent *)event
{
	[ super mouseMoved:event ];
	
	NSPoint point = [ event locationInWindow ];
	point.x -= origin.x;
	point.y -= origin.y;
	point.x *= resolution.width / windowSize.width;
	point.y *= resolution.height / windowSize.height;
	lastMouse = point;
	
	[ self pick:point ];
}

- (void) mouseUp:(NSEvent *)event
{
	NSPoint point = [ event locationInWindow ];
	point.x -= origin.x;
	point.y -= origin.y;
	point.x *= resolution.width / windowSize.width;
	point.y *= resolution.height / windowSize.height;
	lastMouse = point;
	
	[ self pick:point ];
	
	if (down)
	{
		//	fadealpha = -1;
		if (downPoint.x == point.x && downPoint.y == point.y && side != -1)
		{
			if (side < 4)
			{
				toX = 0;
				if (rotationX > 180)
					toX = 360;
				[ self setXRotation:toX show:YES ];
				toY = 360 - (side * 90);
				while (toY >= 360)
					toY -= 360;
				if (fabs(toY - rotationY) > fabs(360 + toY - rotationY))
					toY += 360;
				[ self setYRotation:toY show:YES ];
				[ self setZRotation:0 show:YES ];
			}
			else
			{
				toY = 0;
				if (rotationY > 180)
					toY = 360;
				[ self setYRotation:toY show:YES ];
				toX = (side == 4) ? -90 : 90;
				if (fabs(toX - rotationX) > fabs(360 + toX - rotationX))
					toX += 360;
				[ self setXRotation:toX show:YES ];
				[ self setZRotation:0 show:YES ];
			}
		}
		isSpecial = FALSE;
		if ([ event modifierFlags ] & NSAlternateKeyMask)
			isSpecial = TRUE;
	}
	
	
	lastMouse = point;
	up = TRUE;
	down = FALSE;
	realDown = FALSE;
	
	[ super mouseUp:event ];
}

- (float) xrotation
{
	return rotationX;
}

- (float) yrotation
{
	return rotationY;
}

- (float) zrotation
{
	return rotationZ;
}

- (void) setXRotation:(float)xrot
{
	[ self setXRotation:xrot show:NO ];
}

- (void) setYRotation:(float)yrot
{
	[ self setYRotation:yrot show:NO ];
}

- (void) setZRotation:(float)zrot
{
	[ self setZRotation:zrot show:NO ];
}

- (void) setXRotation: (float)xrot show:(BOOL)sh
{
	framesX = 0;
	startX = rotationX;
	toX = xrot;
	setX = sh;
	if (!sh)
	{
		rotationX = xrot;
		while (rotationX >= 360)
			rotationX -= 360;
		while (rotationX < 0)
			rotationX += 360;
	}
}

- (void) setYRotation: (float)yrot show:(BOOL)sh
{
	framesY = 0;
	startY = rotationY;
	toY = yrot;
	setY = sh;
	if (!sh)
	{	
		rotationY = yrot;
		while (rotationY >= 360)
			rotationY -= 360;
		while (rotationY < 0)
			rotationY += 360;
	}
}

- (void) setZRotation: (float)zrot show:(BOOL)sh
{
	framesZ = 0;
	startZ = rotationZ;
	toZ = zrot;
	setZ = sh;
	if (!sh)
	{
		rotationZ = zrot;
		while (rotationY >= 360)
			rotationY -= 360;
		while (rotationY < 0)
			rotationY += 360;
	}
}

- (void)dealloc
{
	for (int z = 0; z < 6; z++)
	{
		unsigned int value = [ sides[z] unsignedIntValue ];
		ReleaseImage(&value);
	}
    [super dealloc];
}

@end
