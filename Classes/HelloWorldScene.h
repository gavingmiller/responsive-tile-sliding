//
//  HelloWorldScene.h
//  responsive-touch
//
//  Created by Gavin Miller on 11-02-18.
//  Copyright RANDOMType 2011. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "SpriteTile.h"

// HelloWorld Layer
@interface HelloWorld : CCLayer
{
	NSMutableArray *tiles;
	NSMutableArray *is;
	NSMutableArray *js;
	
	CCLabelTTF *time;
	CCLabelTTF *moves;
	int numMoves;
	int minutes;
	int seconds;
	
	int openSquare;
	
	BOOL hasWon;
	BOOL isFinishOverlayVisible;
	BOOL canMove;
	
}

-(void) setBackground;
-(void) setGameTiles;
-(void) scrambleGameTiles;
-(void) setCanMove;

-(SpriteTile *) getSpriteAtPosition:(int) position;
-(SpriteTile *) wasSpriteTouched:(CGPoint) location;

-(BOOL) canSpriteOccupyOpenSquare:(SpriteTile *) sprite;
-(void) moveTileToOpenSquare:(SpriteTile *)tile duration:(ccTime)duration;

+(id) scene;

@end
