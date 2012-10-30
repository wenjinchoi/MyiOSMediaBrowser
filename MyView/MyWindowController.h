//
//  MyWindowController.h
//  MyView
//
//  Created by wenjinchoi on 10/13/12.
//  Copyright (c) 2012 com.wenjinchoi. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class SeparatorCell;

@interface MyWindowController : NSWindowController <NSMenuDelegate> {
    IBOutlet NSSplitView       *mySplitView;
    IBOutlet NSOutlineView     *myOutlineView;
    IBOutlet NSTreeController  *treeController;
    
    IBOutlet NSCollectionView  *myCollectionView;
    
    IBOutlet NSMenu            *outlineViewRigthClickMenu;
    
    NSMutableArray             *contents;
    
    SeparatorCell              *separatorCell;
    
    BOOL                       buildingOutlineView;
}
@property (readwrite, retain) NSMutableArray *contents;

@end
