//
//  ChatBubbleTypingTableViewCell.h
//  ChatTableView
//
//  Created by Rahul N. Mane on 10/7/13.
//  Copyright (c) 2013 Rahul N. Mane. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatTableView.h"

@interface ChatBubbleTypingTableViewCell : UITableViewCell

+ (CGFloat)height;

@property (nonatomic) ChatBubbleTypingType type;
@property (nonatomic) BOOL showAvatar;

@end
