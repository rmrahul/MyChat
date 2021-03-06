//
//  ChatTableView.m
//  ChatTableView
//
//  Created by Rahul N. Mane on 10/7/13.
//  Copyright (c) 2013 Rahul N. Mane. All rights reserved.
//

#import "ChatTableView.h"
#import "ChatBubbleData.h"
#import "ChatBubbleHeaderTableViewCell.h"
#import "ChatBubbleTypingTableViewCell.h"
//#import "BlockOperationWithIdentifier.h"

@implementation ChatTableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) [self setUpView];
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self=[super initWithCoder:aDecoder];
    if(self){
        [self setUpView];
    }
    return self;

}
- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:UITableViewStylePlain];
    if (self) [self setUpView];
    return self;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark - SetUp views

-(void)setUpView
{
       // UITableView properties
        
        self.backgroundColor = [UIColor clearColor];
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        assert(self.style == UITableViewStylePlain);
        
        self.delegate = self;
        self.dataSource = self;
        
        // ChatTableView default properties
//        self.snapInterval = 120;
        self.typingBubble = ChatBubbleTypingTypeNobody;
    
    self.imageCache=[[NSCache alloc]init];
    self.imageOperationQueue = [[NSOperationQueue alloc]init];
    self.imageOperationQueue.maxConcurrentOperationCount = 2;
    
}

#pragma mark - Override

- (void)reloadData
{
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    
    // Cleaning up
	self.bubbleSection = nil;
    
    // Loading new data
    int count = 0;

    self.bubbleSection = [[NSMutableArray alloc] init];

    
    if (self.bubbleDataSource && (count = [self.bubbleDataSource rowsForBubbleTable:self]) > 0)
    {
       NSMutableArray *bubbleData = [[NSMutableArray alloc] initWithCapacity:count];
        
        for (int i = 0; i < count; i++)
        {
            NSObject *object = [self.bubbleDataSource bubbleTableView:self dataForRow:i];
            assert([object isKindOfClass:[ChatBubbleData class]]);
            [bubbleData addObject:object];
        }
        
        //Rahul N Mane.
        // currently not required sorting..
        /*
        [bubbleData sortUsingComparator:^NSComparisonResult(id obj1, id obj2)
         {
             ChatBubbleData *bubbleData1 = (ChatBubbleData *)obj1;
             ChatBubbleData *bubbleData2 = (ChatBubbleData *)obj2;
             
             return [bubbleData1.date compare:bubbleData2.date];
         }];
         */
        
        NSDate *last = [NSDate dateWithTimeIntervalSince1970:0];
        NSMutableArray *currentSection = nil;
        
        for (int i = 0; i < count; i++)
        {
            ChatBubbleData *data = (ChatBubbleData *)[bubbleData objectAtIndex:i];
            
          //  NSLog(@"Time :%f %f",[data.date timeIntervalSinceDate:last],self.snapInterval);
            
            if ([data.date timeIntervalSinceDate:last] > self.snapInterval)
            {

                currentSection = [[NSMutableArray alloc] init];

                [self.bubbleSection addObject:currentSection];
            }
            
            [currentSection addObject:data];
            last = data.date;
        }
    }
    
    
    [super reloadData];
  
}



#pragma mark - UITableViewDelegate implementation

#pragma mark - UITableViewDataSource implementation

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    int result = [self.bubbleSection count];
    if (self.typingBubble != ChatBubbleTypingTypeNobody)
    {
      result++;
    }
    return result;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // This is for now typing bubble
	if (section >= [self.bubbleSection count])
    {
      return 1;
    }
    return [[self.bubbleSection objectAtIndex:section] count] + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Now typing
	if (indexPath.section >= [self.bubbleSection count])
    {
        return MAX([ChatBubbleTypingTableViewCell height], self.showAvatars ? 52 : 0);
    }
    
    // Header
    if (indexPath.row == 0)
    {
        return [ChatBubbleHeaderTableViewCell height];
    }
    
    ChatBubbleData *data = [[self.bubbleSection objectAtIndex:indexPath.section] objectAtIndex:indexPath.row - 1];
   // return MAX(data.insets.top + data.view.frame.size.height + data.insets.bottom, self.showAvatars ? 52 : 0);
    
    //Rahul N Mane
     return MAX(data.insets.top + data.view.frame.size.height + data.insets.bottom, self.showAvatars ? 72 : 0);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Now typing
	if (indexPath.section >= [self.bubbleSection count])
    {
        static NSString *cellId = @"tblBubbleTypingCell";
        ChatBubbleTypingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        
        if (cell == nil) cell = [[ChatBubbleTypingTableViewCell alloc] init];
        
        cell.type = self.typingBubble;
        cell.showAvatar = self.showAvatars;
        
        return cell;
    }
    
    // Header with date and time
    if (indexPath.row == 0)
    {
        static NSString *cellId = @"tblBubbleHeaderCell";
        ChatBubbleHeaderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        ChatBubbleData *data = [[self.bubbleSection objectAtIndex:indexPath.section] objectAtIndex:0];
        
        if (cell == nil) cell = [[ChatBubbleHeaderTableViewCell alloc] init];
        
        cell.date = data.date;
        cell.backgroundColor=[UIColor colorWithRed:231.0/255.0 green:231.0/255.0 blue:231.0/255.0 alpha:1];


        return cell;
    }
    
    // Standard bubble
    static NSString *cellId = @"tblBubbleCell";
    ChatBubbletableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    ChatBubbleData *data = [[self.bubbleSection objectAtIndex:indexPath.section] objectAtIndex:indexPath.row - 1];
    
    if (cell == nil) cell = [[ChatBubbletableViewCell alloc] init];
    
    cell.data = data;
    cell.showAvatar = self.showAvatars;
    
    cell.backgroundColor=[UIColor colorWithRed:231.0/255.0 green:231.0/255.0 blue:231.0/255.0 alpha:1];
  
    
    
    UIImage *imageFromCache = [self.imageCache objectForKey:[NSString stringWithFormat:@"%@",data.strUserName]];
    if (imageFromCache) {
        cell.avatarImage.image=imageFromCache;
        data.avatar=imageFromCache;
        
        CATransition *transition = [CATransition animation];
        transition.duration = 0.75f;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = kCATransitionFade;
        
        [cell.avatarImage.layer addAnimation:transition forKey:nil];
        

    }else{
        
        BOOL isFound=NO;
        
        /*
        for(BlockOperationWithIdentifier *operation in self.imageOperationQueue.operations) {
                if([operation.identifier isEqual:data.strImageURL]) {
                    isFound=YES;
                    NSLog(@"Aleardy in queue");
                }else {
                    isFound=NO;
                }
            }
         */
        
        cell.avatarImage.image = nil;//user a placeholder later
        if(!isFound){
            /*
            BlockOperationWithIdentifier *operation = [BlockOperationWithIdentifier blockOperationWithBlock:^{
                
                NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:data.strImageURL]];
                
                UIImage *img = [UIImage imageWithData:imageData];
                if (img) {
                    [self.imageCache setObject:img forKey:[NSString stringWithFormat:@"%@",data.strUserName]];
                    data.avatar=img;
                }
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    
                    if(self.imageOperationQueue!=nil){
                        [self reloadData];
                        ChatBubbletableViewCell *updateCell =(ChatBubbletableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
                        if (updateCell) {
                            updateCell.avatarImage.image = img;
                            
                            CATransition *transition = [CATransition animation];
                            transition.duration = 0.75f;
                            transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                            transition.type = kCATransitionFade;
                            
                            [updateCell.avatarImage.layer addAnimation:transition forKey:nil];
                        }
                    }
                    else{
                        NSLog(@"Solved crashess");
                    }

                }];
            }];
            operation.queuePriority = NSOperationQueuePriorityNormal;
            operation.identifier=data.strImageURL;
            [self.imageOperationQueue addOperation:operation];
*/
            
        }
        
    }

    

   // cell.backgroundColor=[UIColor yellowColor];

    return cell;
}


-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
  
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if(!decelerate)
    {
       // [self setPriorityForVisibleCells];
    }
}

/**
 @author         Rahul N. Mane
 @function       setPriorityForVisibleCells
 @discussion     It handles operation queue for image download.If user scrolls down then priority of image download changes
 @param          nil
 @result         Makes queuePriority in Operation queue for image download.
 */
/*
- (void)setPriorityForVisibleCells
{
    
    NSArray *array=[self indexPathsForVisibleRows];
    
    
    for(NSIndexPath *indexPath in [self indexPathsForVisibleRows]) {
        for(BlockOperationWithIdentifier *operation in self.imageOperationQueue.operations) {
            ChatBubbleData *data = [[self.bubbleSection objectAtIndex:indexPath.section] objectAtIndex:indexPath.row - 1];
            if([operation.identifier isEqual:data.strImageURL]) {
                operation.queuePriority = NSOperationQueuePriorityVeryHigh;
            }else {
                operation.queuePriority = NSOperationQueuePriorityVeryLow;
            }
        }
    }
}
 */



-(void)cancelImageOperations{
  //  [[NSOperationQueue mainQueue] cancelAllOperations];
    [self.imageOperationQueue cancelAllOperations];
    self.imageOperationQueue=nil;
}
@end
