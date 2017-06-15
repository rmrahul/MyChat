//
//  ChatViewController.m
//  MyChat
//
//  Created by Rahul Mane on 07/12/15.
//  Copyright © 2015 Rahul Mane. All rights reserved.
//

#import "ChatViewController.h"
#import "ChatTableView.h"
#import "DBManager.h"
#import "ChatBubbleData.h"
#import "NSMutableArray+Reverse.h"
#import "MBProgressHUD.h"

#define kMessageLimit 5
#define channelname @"asedasasax"


@interface ChatViewController ()<ChatBubbleTableViewDataSourceDelegate,UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *txtSendMessage;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbarMessage;

@property (weak, nonatomic) IBOutlet ChatTableView *chatTableView;

@end

@implementation ChatViewController{
    NSMutableArray *arrayOfChatMessages;
    UIRefreshControl *refreshControl;
    int previousPageMessageCount;
    int currentPageNumber;
    BOOL keyboardVissible;
    
    UITapGestureRecognizer *tapGesture;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUp];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [self subscribeChannel];

}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}


-(void)subscribeChannel{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES withText:@"Connecting.."];
    [PubNub subscribeOnChannel:[PNChannel channelWithName: channelname] withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *arr, PNError *error) {
        
        if(state == PNSubscriptionProcessSubscribedState){
            self.navigationItem.title = @"Online";
        }
        else{
            self.navigationItem.title = @"Offline";
        }
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        [self getMissedMessagesIfAny];
    }];
}


-(void)getMissedMessagesIfAny{

    NSMutableArray *arrayFromDB = [[[DBManager getSharedInstance]getMessagesWithPageNo:0 andLimit:1] mutableCopy];

    if(arrayFromDB.count){
        [MBProgressHUD showHUDAddedTo:self.view animated:YES withText:@"Loading previous messages..."];

        MessageModel *msgModel = [arrayFromDB objectAtIndex:0];

        NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"yyyy/MM/dd hh:mm:ss aa"];

        PNDate *pndate = [PNDate dateWithDate:[formatter dateFromString:msgModel.msgDate]];
        
        
        [PubNub requestHistoryForChannel:[PNChannel channelWithName:channelname] from:pndate withCompletionBlock:^(NSArray *array, PNChannel *channel, PNDate *from, PNDate *to, PNError *error) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];

            if(error){
                
            }
            else{
                NSLog(@"asdasdasd");
                
                for (int k=0; k<array.count; k++) {
                    PNMessage *message=[array objectAtIndex:k];
                    PNDate *date=message.receiveDate;

                    MessageModel *model=[[MessageModel alloc]init];
                    model.msg = [message.message valueForKey:@"message"];
                    model.msgFrom = [message.message valueForKey:@"from"];
                    model.msgDate = [formatter stringFromDate:date.date];
                    model.isSent = NO;
                    
                    
                    if([model.msgFrom isEqualToString:[UIDevice currentDevice].name]){
                        return;
                    }
                    else{
                        [[DBManager getSharedInstance]saveMessage:model];
                    }
                }
                

                dispatch_async(dispatch_get_main_queue(), ^{
                    [self getMessagesFromDB:0];
                });
        
            }
        }];
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


-(void)setUp{
    arrayOfChatMessages= [[NSMutableArray alloc]init];
    [self setChatTbaleviewContentView];
    [self setUpPullDownToRefresh];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshChats:) name:@"chatMessageRecived" object:nil];
    [self getMessagesFromDB:0];
    [self setUpTextFields];
}

-(void)addTapGesture{
    if(tapGesture){
        [self.view removeGestureRecognizer:tapGesture];
        tapGesture=nil;
    }
    tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGestureClicked:)];
    [self.view addGestureRecognizer:tapGesture];
}



-(void)getMessagesFromDB:(int)tag{
    if(tag==0){  // that means we are loading events freshly
        previousPageMessageCount=0;
        currentPageNumber=0;
        [arrayOfChatMessages removeAllObjects];
        arrayOfChatMessages=[[NSMutableArray alloc]init];
        [self getChats];

    }
    else{ // that means we are loading more events
        currentPageNumber++;
        previousPageMessageCount=(int)arrayOfChatMessages.count;

        [self getChats];
        
        [refreshControl endRefreshing];
    }
   
}

-(void)setUpTextFields{
    
}
-(void)getChats{
    
    NSMutableArray *arrayFromDB = [[[DBManager getSharedInstance]getMessagesWithPageNo:currentPageNumber andLimit:kMessageLimit] mutableCopy];
    [arrayFromDB reverse];
    
    for (int k=0; k<arrayFromDB.count; k++) {
        MessageModel *model=[arrayFromDB objectAtIndex:k];
        
        NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"yyyy/MM/dd hh:mm:ss aa"];
        
        if(model.isSent){
            ChatBubbleData *bubble = [ChatBubbleData dataWithText:model.msg date:[formatter dateFromString:model.msgDate] type:BubbleTypeMine];
            [arrayOfChatMessages addObject:bubble];
        }
        else{
            
            ChatBubbleData *bubble = [ChatBubbleData dataWithText:model.msg date:[formatter dateFromString:model.msgDate] type:BubbleTypeSomeoneElse];
            [arrayOfChatMessages addObject:bubble];
        }
    }
    
    [self.chatTableView reloadData];
}

-(void)setUpPullDownToRefresh{
    UITableViewController *tableViewController = [[UITableViewController alloc] init];
    tableViewController.tableView = self.chatTableView;
    
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor grayColor];
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@""];
    [refreshControl addTarget:self action:@selector(refreshPreviousChatFired:) forControlEvents:UIControlEventValueChanged];
    tableViewController.refreshControl = refreshControl;
}



-(void)setChatTbaleviewContentView{
    self.chatTableView.bubbleDataSource=self;
    self.chatTableView.snapInterval = 86400 ;

    
}




#pragma mark - Chat tableview

- (NSInteger)rowsForBubbleTable:(ChatTableView *)tableView
{
    return [arrayOfChatMessages count];
}

- (ChatBubbleData *)bubbleTableView:(ChatTableView *)tableView dataForRow:(NSInteger)row
{
    return [arrayOfChatMessages objectAtIndex:row];
}

-(void)refreshChats:(id)sender{
    if (self.isViewLoaded && self.view.window) {
        [self getMessagesFromDB:0];
    }
}

#pragma mark - Textfield delegates

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    return YES;
}

#pragma mark - Pull down to refresh delegates
#pragma mark -

-(void)refreshPreviousChatFired:(id)sender{
    [self getMessagesFromDB:1];
}

#pragma mark - Keyboard 
- (void) keyboardWillHide:(NSNotification *)aNotification{
    if(!keyboardVissible){
        return;
    }
    NSDictionary* info = [aNotification userInfo];
    NSTimeInterval duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    NSValue* aValue = [info objectForKey:UIKeyboardFrameBeginUserInfoKey];
    CGFloat keyboardHeight = [aValue CGRectValue].size.height;
    
    keyboardVissible = NO;
    
    [UIView animateWithDuration:duration animations:^{
        
        CGRect frame = self.view.frame;
        frame.size.height += keyboardHeight;
        self.view.frame = frame;
    }];

}


- (void) keyboardWillShow:(NSNotification *)aNotification{

    if(keyboardVissible){
        return;
    }
    NSDictionary* info = [aNotification userInfo];
    NSTimeInterval duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    NSValue* aValue = [info objectForKey:UIKeyboardFrameBeginUserInfoKey];
    CGFloat keyboardHeight = [aValue CGRectValue].size.height;
    
    keyboardVissible = YES;
    
    [self addTapGesture];
    [UIView animateWithDuration:duration animations:^{
        
        CGRect frame = self.view.frame;
        frame.size.height -= keyboardHeight;
        self.view.frame = frame;
    }];
}

#pragma mark - Tap gesture

-(void)tapGestureClicked:(UITapGestureRecognizer *)tap{
    [self.view removeGestureRecognizer:tapGesture];
    tapGesture=nil;
    [self.view endEditing:YES];
}

#pragma mark - Send chat


- (IBAction)btnSendClicked:(id)sender {
    NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy/MM/dd hh:mm:ss aa"];

    
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    [dict setValue:self.txtSendMessage.text forKey:@"message"];
    [dict setValue:[UIDevice currentDevice].name forKey:@"from"];
    
    [PubNub sendMessage:dict toChannel:[PNChannel channelWithName:@"asedasasax"] withCompletionBlock:^(PNMessageState state, id sender) {
        if(state == PNMessageSendingError){
            [self showErrorMessage:@"Message not able to sent"];
        }
        else if(state == PNMessageSending){
           // [self showErrorMessage:@"Message not able to sent"];
        }
        else
        {
           MessageModel *model=[[MessageModel alloc]init];
           model.msg = self.txtSendMessage.text;
           model.msgDate = [formatter stringFromDate:[NSDate date]];
           model.msgFrom = [UIDevice currentDevice].name;
           model.isSent = YES;
        
           self.txtSendMessage.text = @"";

           [[DBManager getSharedInstance]saveMessage:model];
               [self getMessagesFromDB:0];
           }
    }];
}


-(void)showErrorMessage:(NSString *)msg{
    [[UIAlertView alloc]initWithTitle:@"MyChat" message:msg delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
    
}
@end
