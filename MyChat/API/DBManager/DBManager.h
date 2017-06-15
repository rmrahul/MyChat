//
//  DBManager.h
//  MyChat
//
//  Created by Rahul Mane on 07/12/15.
//  Copyright © 2015 Rahul Mane. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "MessageModel.h"


@interface DBManager : NSObject
{
    NSString *databasePath;
}

+(DBManager*)getSharedInstance;
-(BOOL)createDB;
- (BOOL) saveMessage:(MessageModel *)msgModel;
- (NSArray*) getMessagesWithPageNo:(int)pageNo andLimit:(int)limit;

@end
