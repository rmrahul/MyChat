//
//  ChatBubbleHeaderTableViewCell.h
//  ChatTableView
//
//  Created by Rahul N. Mane on 10/7/13.
//  Copyright (c) 2013 Rahul N. Mane. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatBubbleHeaderTableViewCell : UITableViewCell

+ (CGFloat)height;

@property (nonatomic, strong) NSDate *date;

@end
