//
//  IconViewController.m
//  MyView
//
//  Created by wenjinchoi on 10/17/12.
//  Copyright (c) 2012 com.wenjinchoi. All rights reserved.
//

#import "IconViewController.h"

// key value for the icon view dictionary
NSString const *KEY_NAME = @"name";
NSString const *KEY_ICON = @"icon";

@implementation IconViewBox

-(NSView *)hitTest:(NSPoint)aPoint
{
    return nil;
}

@end


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

- (void)awakeFromNib
{
    [NSThread detachNewThreadSelector:@selector(gatherContents:) toTarget:self withObject:nil];
}

- (void)updateIcons:(id)iconArray
{
    self.icons = iconArray;
}

// 收集内容和icon花销比较大
// 使用单独的线程调用此方法，避免对界面造成阻塞
- (void)gatherContents:(id)inObject
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    // for test
    url = [NSURL URLWithString:@"/Users/wenjinchoi/Pictures/test"];
    
    NSMutableArray *contentsArray = [[NSMutableArray alloc] init];
    
    NSArray *fileurls = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:url
                                                      includingPropertiesForKeys:[NSArray array]
                                                                         options:0
                                                                           error:nil];
    
    if (fileurls) {
        for (NSURL *elment in fileurls) {
            NSString *elmentNameStr = nil;
            NSImage *elmentImage = [[NSImage alloc] initWithContentsOfURL:elment];
            
            // 只允许不隐藏的文件
            NSNumber *hiddenFlag = nil;
            if ([elment getResourceValue:&hiddenFlag forKey:NSURLIsHiddenKey error:nil]) {
                if (![hiddenFlag boolValue]) {
                    if ([elment getResourceValue:&elmentNameStr forKey:NSURLNameKey error:nil]) {
                        [contentsArray addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                  elmentImage, KEY_ICON,
                                                  elmentNameStr, KEY_NAME,
                                                  nil]];
                    }
                    
                }
            }
            
            [elmentImage release];
        }
    }
    
    // 回调主线程在 View 中更新 icons
    [self performSelectorOnMainThread:@selector(updateIcons:) withObject:contentsArray waitUntilDone:YES];
    
    [contentsArray release];
    
    [pool release];

}

#pragma mark - Menu Action

- (IBAction)exportByMenu:(id)sender {

}

@end
