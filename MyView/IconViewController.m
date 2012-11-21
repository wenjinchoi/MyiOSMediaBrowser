//
//  IconViewController.m
//  MyView
//
//  Created by wenjinchoi on 10/17/12.
//  Copyright (c) 2012 com.wenjinchoi. All rights reserved.
//

#import "IconViewController.h"

// key value for the icon view dictionary
NSString *KEY_NAME = @"name";
NSString *KEY_ICON = @"icon";

@implementation IconViewBox

-(NSView *)hitTest:(NSPoint)aPoint
{
    return nil;
}

@end


@interface IconViewController ()

// @property (readwrite, retain) NSArrayController *iconArrayController;
@property (readwrite, retain) NSMutableArray *icons;

@end

@implementation IconViewController

@synthesize icons, url;
// @synthesize iconArrayController

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
    // [collectionView addObserver:self forKeyPath:@"selectionIndexes" options:NSKeyValueObservingOptionNew context:nil];
    self.url = [NSURL URLWithString:@"/Users/wenjinchoi/Pictures/test"];
    
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
    
    NSMutableArray *contentsArray = [[NSMutableArray alloc] init];
    
    NSArray *fileurls = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:self.url
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
    NSIndexSet *indexSet = [collectionView selectionIndexes];
    
    NSUInteger index = [indexSet firstIndex];
    for (NSUInteger i = 0; i < [indexSet count]; i++) {
        NSLog(@"%@", [[icons objectAtIndex:index] valueForKey:KEY_NAME]);
        index = [indexSet indexGreaterThanIndex:index];
    }
    
    NSSavePanel *panel = [NSSavePanel savePanel];
    
    [panel setCanSelectHiddenExtension:NO];
    [panel setNameFieldStringValue:@"ExportFolder"];
    
    [panel beginSheetModalForWindow:self.view.window completionHandler:^(NSInteger result){
        if (result == NSOKButton) {
            NSURL *saveURL = [panel URL];
            
            NSFileManager *fileManager = [NSFileManager defaultManager];
            [fileManager createDirectoryAtURL:saveURL withIntermediateDirectories:YES attributes:nil error:nil];
            
            NSString *fileName = [[icons objectAtIndex:[indexSet firstIndex]] valueForKey:KEY_NAME];
            NSURL *srcURL = [url URLByAppendingPathComponent:fileName];
            NSURL *dstURL = [saveURL URLByAppendingPathComponent:fileName];
            
            NSError *err;
            [fileManager copyItemAtURL:srcURL toURL:dstURL error:&err];
            
            NSLog(@"Write to %@", [saveURL description]);
        }
    }];

}

@end
