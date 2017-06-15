//
//  ChatTableView.h
//  ChatTableView
//
//  Created by Rahul N. Mane on 10/7/13.
//  Copyright (c) 2013 Rahul N. Mane. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatBubbleData.h"
#import "ChatBubbletableViewCell.h"
#import "ChatBubbleTableViewDataSourceDelegate.h"

typedef enum chatBubbleTypingType
{
    ChatBubbleTypingTypeNobody = 0,
    ChatBubbleTypingTypeMe = 1,
    ChatBubbleTypingTypeSomebody = 2
} ChatBubbleTypingType;

@interface ChatTableView : UITableView<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) NSCache *imageCache;
@property (nonatomic, strong) NSOperationQueue *imageOperationQueue;

@property (nonatomic) ChatBubbleTypingType typingBubble;
@property (nonatomic, retain) NSMutableArray *bubbleSection;

@property (nonatomic, assign) IBOutlet id<ChatBubbleTableViewDataSourceDelegate> bubbleDataSource;

@property (nonatomic) NSTimeInterval snapInterval;
@property (nonatomic) BOOL showAvatars;

- (void)setPriorityForVisibleCells;

-(void)cancelImageOperations;

@end
