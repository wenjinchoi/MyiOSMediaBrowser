//
//  IconViewController.h
//  MyView
//
//  Created by wenjinchoi on 10/17/12.
//  Copyright (c) 2012 com.wenjinchoi. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface IconViewBox : NSBox
@end

@interface IconViewController : NSViewController {
    IBOutlet NSCollectionView *collectionView;
    // NSArrayController *iconArrayController;
    NSURL *url;
    NSMutableArray *icons;
}

@property (readwrite, retain) NSURL *url;

- (IBAction)exportSelectedItem:(id)sender;


@end
