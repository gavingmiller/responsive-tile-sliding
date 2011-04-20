//
//  HelloWorldScene.m
//  responsive-touch
//
//  Created by Gavin Miller on 11-02-18.
//  Copyright RANDOMType 2011. All rights reserved.
//

#import "HelloWorldScene.h"

// Game board active
#define BACKGROUND_LAYER -3
#define FOREGROUND_LAYER -2
#define BUTTON_LAYER     -1

// Finished state
#define SHADOW_LAYER 4
#define CAT_LAYER    5
#define LABEL_LAYER  6

@implementation HelloWorld

+(id) scene {
	CCScene *scene = [CCScene node];
	HelloWorld *layer = [HelloWorld node];
	[scene addChild: layer];
	return scene;
}

-(id) init {
	if( (self=[super init] )) {
		canMove = NO;
		
		self.isTouchEnabled = YES;
		
		[self setBackground];
		[self setGameTiles];
		[self scrambleGameTiles];
		
		[self performSelector:@selector(setCanMove) withObject:nil afterDelay:1.0];
	}
	return self;
}

-(void) setCanMove {
	canMove = YES;
}

-(void) setBackground {
	CGSize winSize = [CCDirector sharedDirector].winSize;
	
	CCSprite *background = [CCSprite spriteWithFile:@"background.png"];
	background.position = ccp(winSize.width/2, winSize.height/2);
	[self addChild:background z:BACKGROUND_LAYER]; 
	
	CCSprite *shadow = [CCSprite spriteWithFile:@"puzzle-image-bg.png"];
	shadow.position = ccp(winSize.width/2 - 6, winSize.height/2);
	[self addChild:shadow z:FOREGROUND_LAYER];
}

-(void) setGameTiles {	
	tiles = [[NSMutableArray alloc] init];
	is = [[NSMutableArray alloc] init];
	js = [[NSMutableArray alloc] init];
	
	int numberOfRows = 4;
	int tileCount = 0;
	
	for (int i = 0; i < numberOfRows; i++) {
		for (int j = 0; j < numberOfRows; j++) {
			if (tileCount != 15) {
				CGRect rect = CGRectMake((SPRITE_TILE_SIZE * i), (SPRITE_TILE_SIZE * j), SPRITE_TILE_SIZE, SPRITE_TILE_SIZE);
				CGPoint point = [SpriteTile calculatePosition:i j:j];
				
				SpriteTile *st = [[[SpriteTile alloc] initWithFile:@"slider.png"
															  rect:rect 
														  position:point 
												   currentPosition:tileCount 
													 finalPosition:tileCount] autorelease];
				
				[self addChild:st];
				[tiles addObject:st];
			} else {
				openSquare = tileCount;
			}
			
			[is addObject:[NSNumber numberWithInt:i]];
			[js addObject:[NSNumber numberWithInt:j]];
			
			tileCount++;
		}
	}
}

-(void) scrambleGameTiles {
#ifdef DEBUG
	int mixfactor = 15;
#else
	int mixfactor = 500;
#endif
	for (int i = 0; i < mixfactor; i++) {		
		int index = arc4random() % 4;
		
		int result = 0;
		switch (index) {
			case 0: //up
				result = openSquare - 1;
				break;
			case 1: //right
				result = openSquare + 4;
				break;
			case 2: //down
				result = openSquare + 1;
				break;
			case 3: //left
				result = openSquare - 4;
				break;
		}
		
		if (0 <= result && result < 15 ) {
			SpriteTile *tile = [self getSpriteAtPosition:result];
			if ([self canSpriteOccupyOpenSquare:tile]) {
				[self moveTileToOpenSquare:tile duration:1.0];
			}
		}
	}
}

-(void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	if (!canMove) {
		return;
	}
	
	// Choose one of the touches to work with
	UITouch *touch = [touches anyObject];
	CGPoint location = [touch locationInView:[touch view]];
	location = [[CCDirector sharedDirector] convertToGL:location];
	
	// Detect which SpriteTile was touched
	SpriteTile *sprite = nil;
	if ( (sprite = [self wasSpriteTouched:location]) != nil) {
		if ([self canSpriteOccupyOpenSquare:sprite]) {
			[self moveTileToOpenSquare:sprite duration:0.12];
		}
	}
}

-(SpriteTile *) getSpriteAtPosition:(int) position {
	for (SpriteTile *tile in tiles) {
		if (tile.currentPosition == position) {
			return tile;
		}
	}
	
	CCLOG(@"This state should be unreachable. :D");
	abort();
}

-(SpriteTile *) wasSpriteTouched:(CGPoint) location {
	for (SpriteTile *tile in tiles) {
		if ([tile isTouching:location]) {
			return tile;
		}
	}
	
	return nil;
}

-(BOOL) canSpriteOccupyOpenSquare:(SpriteTile *) sprite {
	int position = sprite.currentPosition;
	
	// Is open above the x-axis
	if (openSquare == position - 1) {
		// No wrapping around to the bottom
		if (position != 4 && position != 8 && position != 12) {
			return YES;
		}
	}
	
	// Is open below the x-axis
	if (openSquare == position + 1) {
		// No wrapping around to the top
		if (position != 3 && position != 7 && position != 11) {
			return YES;
		}
	}	
	
	// Is open on the y-axis
	if (openSquare == position - 4 || openSquare == position + 4) {
		return YES;
	}
	
	return NO;
}

-(void) moveTileToOpenSquare:(SpriteTile *)tile duration:(ccTime)duration {
	int i = [(NSNumber *)[is objectAtIndex:openSquare] intValue];
	int j = [(NSNumber *)[js objectAtIndex:openSquare] intValue];
	
	// Swap the position of the current sprite with the openSqaure
	CC_SWAP(openSquare, tile.currentPosition);
	
	// Move sprite to that position
	id actionMove = [CCMoveTo actionWithDuration:duration
										position:[SpriteTile calculatePosition:i j:j]];
	[tile runAction:[CCSequence actions:actionMove, nil]];
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	[tiles release];
	tiles = nil;
	
	[js release];
	js = nil;
	
	[is release];
	is = nil;
	
	// don't forget to call "super dealloc"
	[super dealloc];
}
@end
