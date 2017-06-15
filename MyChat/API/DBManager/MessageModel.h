//
//  MessageModel.h
//  MyChat
//
//  Created by Rahul Mane on 07/12/15.
//  Copyright © 2015 Rahul Mane. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MessageModel : NSObject
@property (nonatomic,strong) NSString *msgID;
@property (nonatomic,strong) NSString *msg;
@property (nonatomic,strong) NSString *msgDate;
@property (nonatomic,strong) NSString *msgFrom;
@property (nonatomic,readwrite) BOOL isSent;

@end
