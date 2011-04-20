//
//  responsive_touchAppDelegate.h
//  responsive-touch
//
//  Created by Gavin Miller on 11-04-19.
//  Copyright RANDOMType 2011. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;

@interface responsive_touchAppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;
}

@property (nonatomic, retain) UIWindow *window;

@end
