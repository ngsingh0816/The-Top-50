//
//  Cards.mm
//  The Top 50
//
//  Created by MILAP on 3/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Cards.h"
#import <OpenGL/OpenGL.h>
#import <OpenGL/gl.h>
#import <OpenGL/glu.h>
#import "Controller.h"

const char* letters[] = { "A", "2", "3", "4", "5", "6", "7", "8", "9", "10",
	"J", "Q", "K" };
const char* suitLetters[] = { "Diamonds", "Hearts", "Clubs", "Spades" };

std::vector<Card> cards;
void LoadCards()
{
	cards.clear();
	[ glView loadBitmap:@"Cards/Back.png" ];
	for (int z = 0; z < 52; z++)
	{
		Card card;
		memset(&card, 0, sizeof(card));
		card.letter = (z / 4);
		card.suit = (Suit)(z % 4);
		card.image = z + 1;
		[ glView loadBitmap:[ NSString stringWithFormat:@"Cards/%s%s.png",
							 letters[z / 4], suitLetters[(int)card.suit] ] ];
		cards.push_back(card);
	}
}

void Shuffle()
{
}

void DrawCards()
{
	glEnable(GL_TEXTURE_2D);
	for (int z = 0; z < 1; z++)
	{
		MDRect frame = MakeRect(-10, -20, 20, 40);
		glLoadIdentity();
		glTranslated(0, 0, -50);
		glBindTexture(GL_TEXTURE_2D, [ [ textures objectAtIndex:
										cards[z].image ] intValue ]);
		glColor4d(1, 1, 1, 1);
		glBegin(GL_QUADS);
		{
			glTexCoord2d(0, 0);
			glVertex2d(frame.x, frame.y);
			glTexCoord2d(1, 0);
			glVertex2d(frame.x + frame.width, frame.y);
			glTexCoord2d(1, 1);
			glVertex2d(frame.x + frame.width, frame.y + frame.height);
			glTexCoord2d(0, 1);
			glVertex2d(frame.x, frame.y + frame.height);
		}
		glEnd();
		
		// Back
		glTranslated(0, 0, -0.01);
		glBindTexture(GL_TEXTURE_2D, [ [ textures objectAtIndex:0 ] intValue ]);
		glColor4d(1, 1, 1, 1);
		glBegin(GL_QUADS);
		{
			glTexCoord2d(0, 0);
			glVertex2d(frame.x, frame.y);
			glTexCoord2d(1, 0);
			glVertex2d(frame.x + frame.width, frame.y);
			glTexCoord2d(1, 1);
			glVertex2d(frame.x + frame.width, frame.y + frame.height);
			glTexCoord2d(0, 1);
			glVertex2d(frame.x, frame.y + frame.height);
		}
		glEnd();
	}
	glDisable(GL_TEXTURE_2D);
}

void CleanupCards()
{
	[ glView clearTextures ];
	cards.clear();
}
