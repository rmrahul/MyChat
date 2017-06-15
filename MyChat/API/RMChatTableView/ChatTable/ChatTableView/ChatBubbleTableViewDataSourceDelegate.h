//
//  ChatBubbleTableViewDataSourceDelegate.h
//  ChatTableView
//
//  Created by Rahul N. Mane on 10/7/13.
//  Copyright (c) 2013 Rahul N. Mane. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ChatTableView;
@class ChatBubbleData;

@protocol ChatBubbleTableViewDataSourceDelegate <NSObject>

@optional

@required

- (NSInteger)rowsForBubbleTable:(ChatTableView *)tableView;
- (ChatBubbleData *)bubbleTableView:(ChatTableView *)tableView dataForRow:(NSInteger)row;



@end
