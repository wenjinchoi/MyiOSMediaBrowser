//
//  AppDelegate.h
//  MyView
//
//  Created by wenjinchoi on 10/13/12.
//  Copyright (c) 2012 com.wenjinchoi. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class MyWindowController;

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    MyWindowController *myWindowController;
}

//@property (assign) IBOutlet NSWindow *window;

@end
