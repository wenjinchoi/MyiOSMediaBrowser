//
//  AppDelegate.m
//  MyView
//
//  Created by wenjinchoi on 10/13/12.
//  Copyright (c) 2012 com.wenjinchoi. All rights reserved.
//

#import "AppDelegate.h"
#import "MyWindowController.h"

@interface AppDelegate ()

@property (strong) MyWindowController *myWindowController;

@end


@implementation AppDelegate

@synthesize myWindowController;

- (void)dealloc
{
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    myWindowController = [[MyWindowController alloc] initWithWindowNibName:@"MyWindowController"];
    [myWindowController showWindow:self];
}

@end
