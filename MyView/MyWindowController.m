//
//  MyWindowController.m
//  MyView
//
//  Created by wenjinchoi on 10/13/12.
//  Copyright (c) 2012 com.wenjinchoi. All rights reserved.
//

#import "MyWindowController.h"
#import "ImageAndTextCell.h"
#import "SeparatorCell.h"
#import "ChildNode.h"

#define COLUMN_NAME             @"NameColumn"

#define UNTITLED_NAME			@"Untitled"		// default name for added folders and leafs

#define HTTP_PREFIX				@"http://"

#define MY_PLACE_NAME           @"My Place"
#define MY_PLACE_CHILDPATH_1    @"/Volumes/TEST-FAT/Movies"
#define MY_PLACE_CHILDPATH_2    @"/Volumes/TEST-FAT/TV Shows"
#define MY_PLACE_CHILDPATH_3    @"/Volumes/TEST-FAT/Videos"

#define kMinOutlineViewSplit	120.0f

#pragma mark -

// -------------------------------------------------------------------------------
//	TreeAdditionObj
//
//	This object is used for passing data between the main and secondary thread
//	which populates the outline view.
// -------------------------------------------------------------------------------
@interface TreeAdditionObj : NSObject
{
	NSIndexPath *indexPath;
	NSString	*nodeURL;
	NSString	*nodeName;
	BOOL		selectItsParent;
}

@property (readonly) NSIndexPath *indexPath;
@property (readonly) NSString *nodeURL;
@property (readonly) NSString *nodeName;
@property (readonly) BOOL selectItsParent;

@end


#pragma mark -

@implementation TreeAdditionObj

@synthesize indexPath, nodeURL, nodeName, selectItsParent;

// -------------------------------------------------------------------------------
//  initWithURL:url:name:select
// -------------------------------------------------------------------------------
- (id)initWithURL:(NSString *)url withName:(NSString *)name selectItsParent:(BOOL)select
{
	self = [super init];
	
	nodeName = name;
	nodeURL = url;
	selectItsParent = select;
	
	return self;
}
@end

@interface MyWindowController ()

@end

@implementation MyWindowController
@synthesize contents;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
        contents = [[NSMutableArray alloc] init];
    }
    
    return self;
}

-(void)dealloc
{
    [contents release];
    
    [super dealloc];
}

-(void)awakeFromNib
{
    
    NSTableColumn *tablecolumn = [myOutlineView tableColumnWithIdentifier:COLUMN_NAME];
    ImageAndTextCell *imageandTextCell = [[[ImageAndTextCell alloc] init] autorelease];
    [imageandTextCell setEditable:YES];
    [imageandTextCell setMenu:outlineViewRigthClickMenu];
    [tablecolumn setDataCell:imageandTextCell];
    
    separatorCell = [[SeparatorCell alloc] init];
    [separatorCell setEditable:YES];
    
    [NSThread detachNewThreadSelector:@selector(populateOutlineView:) toTarget:self withObject:nil];
    
    [[[myOutlineView enclosingScrollView] verticalScroller] setFloatValue:0.0];
    [[[myOutlineView enclosingScrollView] contentView] scrollToPoint:NSMakePoint(0, 0)];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}



#pragma mark - Actions

// -------------------------------------------------------------------------------
//	selectParentFromSelection
//
//	Take the currently selected node and select its parent.
// -------------------------------------------------------------------------------
- (void)selectParentFromSelection
{
    if ([[treeController selectedNodes] count] > 0) {
        NSTreeNode *firstSelectedNode = [[treeController selectedNodes] objectAtIndex:0];
        NSTreeNode *parentNode = [firstSelectedNode parentNode];
        if (parentNode) {
            // select the parent
            NSIndexPath *parentIndex = [parentNode indexPath];
            [treeController setSelectionIndexPath:parentIndex];
        } else {
            // no parent exists (we are at the top of tree), so make no selection in our outline
            NSArray *selectionIndexPaths = [treeController selectionIndexPaths];
            [treeController removeSelectionIndexPaths:selectionIndexPaths];
        }
    }

}

// -------------------------------------------------------------------------------
//	performAddFolder:treeAddition
// -------------------------------------------------------------------------------
- (void)performAddFolder:(TreeAdditionObj *)treeAddition
{
	// NSTreeController inserts objects using NSIndexPath, so we need to calculate this
	NSIndexPath *indexPath = nil;
	
	// if there is no selection, we will add a new group to the end of the contents array
	if ([[treeController selectedObjects] count] == 0)
	{
		// there's no selection so add the folder to the top-level and at the end
		indexPath = [NSIndexPath indexPathWithIndex:[contents count]];
	}
	else
	{
		// get the index of the currently selected node, then add the number its children to the path -
		// this will give us an index which will allow us to add a node to the end of the currently selected node's children array.
		//
		indexPath = [treeController selectionIndexPath];
		if ([[[treeController selectedObjects] objectAtIndex:0] isLeaf])
		{
			// user is trying to add a folder on a selected child,
			// so deselect child and select its parent for addition
			[self selectParentFromSelection];
		}
		else
		{
			indexPath = [indexPath indexPathByAddingIndex:[[[[treeController selectedObjects] objectAtIndex:0] children] count]];
		}
	}
	
	ChildNode *node = [[ChildNode alloc] init];
    node.nodeTitle = [treeAddition nodeName];
	
	// the user is adding a child node, tell the controller directly
	[treeController insertObject:node atArrangedObjectIndexPath:indexPath];
	
	[node release];
}

// -------------------------------------------------------------------------------
//	addFolder:folderName
// -------------------------------------------------------------------------------
- (void)addFolder:(NSString *)folderName
{
	TreeAdditionObj *treeObjInfo = [[TreeAdditionObj alloc] initWithURL:nil withName:folderName selectItsParent:NO];
	
	if (buildingOutlineView)
	{
		// add the folder to the tree controller, but on the main thread to avoid lock ups
		[self performSelectorOnMainThread:@selector(performAddFolder:) withObject:treeObjInfo waitUntilDone:YES];
	}
	else
	{
		[self performAddFolder:treeObjInfo];
	}
	
	[treeObjInfo release];
}

// -------------------------------------------------------------------------------
//	performAddChild:treeAddition
// -------------------------------------------------------------------------------
- (void)performAddChild:(TreeAdditionObj *)treeAddition
{
	if ([[treeController selectedObjects] count] > 0)
	{
		// we have a selection
		if ([[[treeController selectedObjects] objectAtIndex:0] isLeaf])
		{
			// trying to add a child to a selected leaf node, so select its parent for add
			[self selectParentFromSelection];
		}
	}
	
	// find the selection to insert our node
	NSIndexPath *indexPath;
	if ([[treeController selectedObjects] count] > 0)
	{
		// we have a selection, insert at the end of the selection
		indexPath = [treeController selectionIndexPath];
		indexPath = [indexPath indexPathByAddingIndex:[[[[treeController selectedObjects] objectAtIndex:0] children] count]];
	}
	else
	{
		// no selection, just add the child to the end of the tree
		indexPath = [NSIndexPath indexPathWithIndex:[contents count]];
	}
	
	// create a leaf node
	ChildNode *node = [[ChildNode alloc] initLeaf];
	node.urlString = [treeAddition nodeURL];
    
	if ([treeAddition nodeURL])
	{
		if ([[treeAddition nodeURL] length] > 0)
		{
			// the child to insert has a valid URL, use its display name as the node title
			if ([treeAddition nodeName])
                node.nodeTitle = [treeAddition nodeName];
			else
                node.nodeTitle = [[NSFileManager defaultManager] displayNameAtPath:[node urlString]];
		}
		else
		{
			// the child to insert will be an empty URL
            node.nodeTitle = UNTITLED_NAME;
            node.urlString = HTTP_PREFIX;
		}
	}
	
	// the user is adding a child node, tell the controller directly
	[treeController insertObject:node atArrangedObjectIndexPath:indexPath];
    
	[node release];
	
	// adding a child automatically becomes selected by NSOutlineView, so keep its parent selected
	if ([treeAddition selectItsParent])
		[self selectParentFromSelection];
}

// -------------------------------------------------------------------------------
//	addChild:url:withName:selectParent
// -------------------------------------------------------------------------------
- (void)addChild:(NSString *)url withName:(NSString *)nameStr selectParent:(BOOL)select
{
	TreeAdditionObj *treeObjInfo = [[TreeAdditionObj alloc] initWithURL:url
                                                               withName:nameStr
                                                        selectItsParent:select];
	
	if (buildingOutlineView)
	{
		// add the child node to the tree controller, but on the main thread to avoid lock ups
		[self performSelectorOnMainThread:@selector(performAddChild:)
                               withObject:treeObjInfo
                            waitUntilDone:YES];
	}
	else
	{
		[self performAddChild:treeObjInfo];
	}
	
	[treeObjInfo release];
}


- (void)populateOutlineView:(id)inObject
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    buildingOutlineView = YES;
    
    [myOutlineView setHidden:YES];
    
    [self addMyPlace];
    
    buildingOutlineView = NO;
    
    [myOutlineView setHidden:NO];
    
    [pool release];
}

- (void)addMyPlace
{
    [self addFolder:MY_PLACE_NAME];
    
    [self addChild:MY_PLACE_CHILDPATH_1 withName:nil selectParent:YES];
    [self addChild:MY_PLACE_CHILDPATH_2 withName:nil selectParent:YES];
    [self addChild:MY_PLACE_CHILDPATH_3 withName:nil selectParent:YES];
    
    [self selectParentFromSelection];
    
}


#pragma mark - Split View Delegate

// -------------------------------------------------------------------------------
//	splitView:constrainMinCoordinate:
//
//	What you really have to do to set the minimum size of both subviews to kMinOutlineViewSplit points.
// -------------------------------------------------------------------------------
- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedCoordinate ofSubviewAt:(int)index
{
	return proposedCoordinate + kMinOutlineViewSplit;
}

// -------------------------------------------------------------------------------
//	splitView:constrainMaxCoordinate:
// -------------------------------------------------------------------------------
- (CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedCoordinate ofSubviewAt:(int)index
{
	return proposedCoordinate - kMinOutlineViewSplit;
}

@end
