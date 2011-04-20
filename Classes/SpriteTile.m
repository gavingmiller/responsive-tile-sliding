//
//  SpriteTile.m
//  responsive-touch
//
//  Created by Gavin Miller on 11-02-18.
//  Copyright 2011 RANDOMType. All rights reserved.
//

#import "SpriteTile.h"

#define X_OFFSET 85
#define Y_OFFSET 10

@implementation SpriteTile

@synthesize currentPosition, finalPosition;

- (id)initWithFile:(NSString *)filename rect:(CGRect)rect position:(CGPoint)position currentPosition:(int)cp finalPosition:(int)fp {
	if ( (self = [super initWithFile:filename rect:rect]) ) {
		self.position = [SpriteTile convertPoint:position];
		self.currentPosition = cp;
		self.finalPosition = fp;
	}
	
	return self;
}

- (BOOL)isTouching:(CGPoint)location {
	return [SpriteTile isLocationTouching:location tile:self.position];
}

+ (BOOL)isLocationTouching:(CGPoint)location tile:(CGPoint)tile {
	if (tile.x - SPRITE_TILE_RADIUS < location.x && location.x < tile.x + SPRITE_TILE_RADIUS) {
		if (tile.y - SPRITE_TILE_RADIUS < location.y && location.y < tile.y + SPRITE_TILE_RADIUS) {
			return YES;
		}
	}
	
	return NO;
}

+ (CGPoint)convertPoint:(CGPoint)point {    
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		return ccp(32 + point.x*2, 64 + point.y*2);
	} else {
		return point;
	}    
}

+ (CGPoint)calculatePosition:(int)i j:(int)j {
	return ccp(X_OFFSET + SPRITE_TILE_RADIUS + (SPRITE_TILE_SIZE * i), 
			   Y_OFFSET + SPRITE_TILE_RADIUS + (SPRITE_TILE_SIZE * (3 - j)));
}

@end
