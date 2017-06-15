//
//  ChatBubbletableViewCell.m
//  ChatTableView
//
//  Created by Rahul N. Mane on 10/7/13.
//  Copyright (c) 2013 Rahul N. Mane. All rights reserved.
//

#import "ChatBubbletableViewCell.h"
#import "ImageConstants.h"

@interface ChatBubbletableViewCell ()



- (void) setup;

@end

@implementation ChatBubbletableViewCell

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

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
	[self setup];
}

- (void)setDataInternal:(ChatBubbleData *)value
{
	self.data = value;
	[self setup];
}

- (void) setup
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (!self.bubbleImage)
    {
        self.bubbleImage = [[UIImageView alloc] init];
        [self addSubview:self.bubbleImage];
    }
    
    ChatBubbleType type = self.data.type;
    
    CGFloat width = self.data.view.frame.size.width;
    CGFloat height = self.data.view.frame.size.height;
    
    CGFloat x = (type == BubbleTypeSomeoneElse) ? 0 : self.frame.size.width - width - self.data.insets.left - self.data.insets.right;
    CGFloat y = 0;
    
    // Adjusting the x coordinate for avatar
    if (self.showAvatar)
    {
        [self.avatarImage removeFromSuperview];
        
        self.avatarImage = [[UIImageView alloc] initWithImage:(self.data.avatar ? self.data.avatar : [UIImage imageNamed:missingAvatar])];
       // self.avatarImage=[[UIImageView alloc]init];
        
        self.avatarImage.layer.cornerRadius = 9.0;
        self.avatarImage.layer.masksToBounds = YES;
        self.avatarImage.layer.borderColor = [UIColor colorWithWhite:0.0 alpha:0.2].CGColor;
        self.avatarImage.layer.borderWidth = 1.0;
        
        CGFloat avatarX = (type == BubbleTypeSomeoneElse) ? 2 : self.frame.size.width - 52;
        //Rahul N Mane
      //  CGFloat avatarY = self.frame.size.height - 50;
          CGFloat avatarY = self.frame.size.height - 70;
        
        
        self.avatarImage.frame = CGRectMake(avatarX, avatarY, 50, 50);
        [self addSubview:self.avatarImage];
        
        [self.lblUserName removeFromSuperview];
        self.lblUserName=[[UILabel alloc]initWithFrame:CGRectMake(avatarX, avatarY+50, 50, 20)];
        self.lblUserName.font=[UIFont fontWithName:@"HelveticaNeue" size:11];
        self.lblUserName.textColor=[UIColor colorWithRed:114.0/255.0 green:108.0/255.0 blue:108.0/255.0 alpha:1];
        self.lblUserName.textAlignment=NSTextAlignmentCenter;
        
        
        self.lblUserName.text=(self.data.strUserName ? self.data.strUserName : @"");

        
        [self addSubview:self.lblUserName];

        
        
        CGFloat delta = self.frame.size.height - (self.data.insets.top + self.data.insets.bottom + self.data.view.frame.size.height);
        if (delta > 0) {
          y = delta;
            
            //Rahul N Mane
           // y=0;
        }
        
        if (type == BubbleTypeSomeoneElse) x += 54;
        if (type == BubbleTypeMine) x -= 54;
    }
    
    [self.customView removeFromSuperview];
    self.customView = self.data.view;
    self.customView.frame = CGRectMake(x + self.data.insets.left, y + self.data.insets.top, width, height);
    
    [self.contentView addSubview:self.customView];
    
    if (type == BubbleTypeSomeoneElse)
    {
        self.bubbleImage.image = [[UIImage imageNamed:bubbleSomeone] stretchableImageWithLeftCapWidth:21 topCapHeight:14];
        
    }
    else {
        self.bubbleImage.image = [[UIImage imageNamed:bubbleMine] stretchableImageWithLeftCapWidth:15 topCapHeight:14];
    }
    
    self.bubbleImage.frame = CGRectMake(x, y, width + self.data.insets.left + self.data.insets.right, height + self.data.insets.top + self.data.insets.bottom);
}

@end
