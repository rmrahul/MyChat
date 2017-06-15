//
//  ChatBubbleData.h
//  ChatTableView
//
//  Created by Rahul N. Mane on 10/7/13.
//  Copyright (c) 2013 Rahul N. Mane. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum chatBubbleType
{
    BubbleTypeMine = 0,
    BubbleTypeSomeoneElse = 1
}ChatBubbleType;

@interface ChatBubbleData : NSObject

@property (readonly, nonatomic, strong) NSDate *date;
@property (readonly, nonatomic) ChatBubbleType type;
@property (readonly, nonatomic, strong) UIView *view;
@property (readonly, nonatomic) UIEdgeInsets insets;
@property (nonatomic, strong) UIImage *avatar;
//Rahul N Mane
@property (nonatomic, strong) NSString *strUserName;
@property (nonatomic, strong) NSString *strImageURL;

- (id)initWithText:(NSString *)text date:(NSDate *)date type:(ChatBubbleType)type;
+ (id)dataWithText:(NSString *)text date:(NSDate *)date type:(ChatBubbleType)type;
- (id)initWithImage:(UIImage *)image date:(NSDate *)date type:(ChatBubbleType)type;
+ (id)dataWithImage:(UIImage *)image date:(NSDate *)date type:(ChatBubbleType)type;
- (id)initWithView:(UIView *)view date:(NSDate *)date type:(ChatBubbleType)type insets:(UIEdgeInsets)insets;
+ (id)dataWithView:(UIView *)view date:(NSDate *)date type:(ChatBubbleType)type insets:(UIEdgeInsets)insets;


@end
