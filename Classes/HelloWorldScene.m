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

#define TOUCH_THRESHOLD 20
#define DIFFERENCE_THRESHOLD 100
#define SLIDE_UP    1
#define SLIDE_RIGHT 2
#define SLIDE_DOWN  3
#define SLIDE_LEFT  4
#define NO_TOUCH    0

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

-(void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	// Choose one of the touches to work with
	UITouch *touch = [touches anyObject];
	CGPoint location = [touch locationInView:[touch view]];
	startTouch = [[CCDirector sharedDirector] convertToGL:location];
}

-(void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	if (!canMove) {
		return;
	}

	// Choose one of the touches to work with
	UITouch *touch = [touches anyObject];
	CGPoint location = [touch locationInView:[touch view]];
	CGPoint endTouch = [[CCDirector sharedDirector] convertToGL:location];
	
	int touchDirection = [self getTouchDirectionFrom:startTouch to:endTouch];
	
	if (touchDirection == NO_TOUCH) {
		return;
	}
	
	SpriteTile *sprite = [self getSpriteToMoveInDirection:touchDirection];
	
	if (sprite != nil) {
		[self performTileMovementSequence:sprite];
	}
}

-(void) performTileMovementSequence:(SpriteTile *)sprite {
	if (sprite == nil) {
		return;
	}
	
	if ([self canSpriteOccupyOpenSquare:sprite]) {
		[self moveTileToOpenSquare:sprite duration:0.12];
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

-(SpriteTile *) getSpriteToMoveInDirection:(int)touchDirection {	
	int position = 0;
	int i = 0;
	int j = 0;
	
	switch (touchDirection) {
		case SLIDE_UP:
			position = openSquare + 1;
			CCLOG(@"position: %d", position);
			if (position != 4 && position != 8 && position != 12 && 0 <= position && position <= 15) {
				i = [(NSNumber *)[is objectAtIndex:position] intValue];
				j = [(NSNumber *)[js objectAtIndex:position] intValue];
				
				CGPoint point = [SpriteTile calculatePosition:i j:j];
				return [self wasSpriteTouched:point];
			}
			break;
		case SLIDE_RIGHT:
			position = openSquare - 4;
			CCLOG(@"position: %d", position);
			if (0 <= position && position <= 15 ) {
				i = [(NSNumber *)[is objectAtIndex:position] intValue];
				j = [(NSNumber *)[js objectAtIndex:position] intValue];
				
				CGPoint point = [SpriteTile calculatePosition:i j:j];
				return [self wasSpriteTouched:point];				
			}
			break;
		case SLIDE_DOWN:
			position = openSquare - 1;
			CCLOG(@"position: %d", position);
			if (position != 3 && position != 7 && position != 11 && 0 <= position && position <= 15) {
				i = [(NSNumber *)[is objectAtIndex:position] intValue];
				j = [(NSNumber *)[js objectAtIndex:position] intValue];
				
				CGPoint point = [SpriteTile calculatePosition:i j:j];
				return [self wasSpriteTouched:point];
			}
			break;
		case SLIDE_LEFT:
			position = openSquare + 4;
			CCLOG(@"position: %d", position);
			if (0 <= position && position <= 15) {
				i = [(NSNumber *)[is objectAtIndex:position] intValue];
				j = [(NSNumber *)[js objectAtIndex:position] intValue];
				
				CGPoint point = [SpriteTile calculatePosition:i j:j];
				return [self wasSpriteTouched:point];
			}
			break;
	}
	
	return nil;
}

-(int) getTouchDirectionFrom:(CGPoint)start to:(CGPoint)end {
	int leftToRight = start.x - end.x;
	int bottomToTop = start.y - end.y;
	
	if (abs(leftToRight) > DIFFERENCE_THRESHOLD && abs(bottomToTop) > DIFFERENCE_THRESHOLD) {
		return NO_TOUCH;
	}
	
	if (abs(leftToRight) > abs(bottomToTop)) {
		if (abs(leftToRight) < TOUCH_THRESHOLD) {
			return NO_TOUCH;
		}
		
		// Take left to right motion
		if (leftToRight > 0) {
			return SLIDE_LEFT;
		} else {
			return SLIDE_RIGHT;
		}
	} else {
		if (abs(bottomToTop) < TOUCH_THRESHOLD) {
			return NO_TOUCH;
		}
		
		// Take bottom to top motion
		if (bottomToTop > 0) {
			return SLIDE_DOWN;
		} else {
			return SLIDE_UP;
		}		
	}
}

-(BOOL) wasOpenSquareTouched:(CGPoint) location {
	int i = [(NSNumber *)[is objectAtIndex:openSquare] intValue];
	int j = [(NSNumber *)[js objectAtIndex:openSquare] intValue];
	
	CGPoint point = [SpriteTile calculatePosition:i j:j];
	return [SpriteTile isLocationTouching:location tile:point];
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
