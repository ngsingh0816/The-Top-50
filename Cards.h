//
//  Cards.h
//  The Top 50
//
//  Created by MILAP on 3/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include <vector>
#include "GLString.h"

typedef enum
{
	DIAMONDS = 0,
	HEARTS,
	CLUBS,
	SPADES,
} Suit;
typedef struct
{
	unsigned int letter;
	Suit suit;
	int image;
} Card;
extern std::vector<Card> cards;

void LoadCards();
void Shuffle();
void DrawCards();
void CleanupCards();
