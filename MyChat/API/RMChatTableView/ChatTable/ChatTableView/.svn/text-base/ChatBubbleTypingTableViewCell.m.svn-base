//
//  ChatBubbleTypingTableViewCell.m
//  ChatTableView
//
//  Created by Rahul N. Mane on 10/7/13.
//  Copyright (c) 2013 Rahul N. Mane. All rights reserved.
//

#import "ChatBubbleTypingTableViewCell.h"
#import "ImageConstants.h"

@interface ChatBubbleTypingTableViewCell ()

@property (nonatomic, retain) UIImageView *typingImageView;

@end


@implementation ChatBubbleTypingTableViewCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (CGFloat)height
{
    return 40.0;
}

- (void)setType:(ChatBubbleTypingType)value
{
    if (!self.typingImageView)
    {
        self.typingImageView = [[UIImageView alloc] init];
        [self addSubview:self.typingImageView];
    }
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UIImage *bubbleImage = nil;
    CGFloat x = 0;
    
    if (value == ChatBubbleTypingTypeMe)
    {
        bubbleImage = [UIImage imageNamed:typingMine];
        x = self.frame.size.width - bubbleImage.size.width;
    }
    else
    {
        bubbleImage = [UIImage imageNamed:typingSomeone];
        x = 0;
    }
    
    self.typingImageView.image = bubbleImage;
    self.typingImageView.frame = CGRectMake(x, 4, 73, 31);
}




@end
