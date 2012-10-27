//
//  IconViewController.m
//  MyView
//
//  Created by wenjinchoi on 10/17/12.
//  Copyright (c) 2012 com.wenjinchoi. All rights reserved.
//

#import "IconViewController.h"

@interface IconViewController ()

@property (readwrite, retain) NSArrayController *iconArrayController;
@property (readwrite, retain) NSMutableArray *icons;

@end

@implementation IconViewController

@synthesize iconArrayController, icons, url;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}


// 收集内容和icon花销比较大
// 使用单独的线程调用此方法，避免对界面造成阻塞
- (void)gatherContents:(id)inObjec
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSMutableArray *contentsArray = [[NSMutableArray alloc] init];
    
    
    
    
}
@end
