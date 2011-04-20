//
//  SpriteTile.h
//  responsive-touch
//
//  Created by Gavin Miller on 11-02-18.
//  Copyright 2011 RANDOMType. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface SpriteTile : CCSprite {
	int currentPosition;
	int finalPosition;
}

@property (nonatomic) int currentPosition;
@property (nonatomic) int finalPosition;

- (id)initWithFile:(NSString *)filename rect:(CGRect)rect position:(CGPoint)position currentPosition:(int)cp finalPosition:(int)fp;
- (BOOL)isTouching:(CGPoint)location;

+ (BOOL)isLocationTouching:(CGPoint)location tile:(CGPoint)tile;
+ (CGPoint)convertPoint:(CGPoint)point;
+ (CGPoint)calculatePosition:(int)i j:(int)j;

@end
