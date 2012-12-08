//
//  MyWindowController.h
//  MyView
//
//  Created by wenjinchoi on 10/13/12.
//  Copyright (c) 2012 com.wenjinchoi. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class SeparatorCell;
@class IconViewController;

@interface MyWindowController : NSWindowController <NSMenuDelegate> {
    IBOutlet NSSplitView       *mySplitView;
    IBOutlet NSView            *placeHolderView;
    IBOutlet NSOutlineView     *myOutlineView;
    
    IBOutlet NSButton          *exportButton;
    
    IBOutlet NSTreeController  *treeController;
   
    
    NSView *currentView;
    IconViewController *iconViewController;
    
    //IBOutlet NSCollectionView  *myCollectionView;
    
    IBOutlet NSMenu            *outlineViewRigthClickMenu;
    
    NSMutableArray             *contents;
    
    SeparatorCell              *separatorCell;
    
    BOOL                       buildingOutlineView;
}
@property (readwrite, retain) NSMutableArray *contents;

@end
