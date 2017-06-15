//
//  DBManager.m
//  MyChat
//
//  Created by Rahul Mane on 07/12/15.
//  Copyright © 2015 Rahul Mane. All rights reserved.
//

#import "DBManager.h"
static DBManager *sharedInstance = nil;
static sqlite3 *database = nil;
static sqlite3_stmt *statement = nil;

@implementation DBManager

+(DBManager*)getSharedInstance{
    if (!sharedInstance) {
        sharedInstance = [[super allocWithZone:NULL]init];
        [sharedInstance createDB];
    }
    return sharedInstance;
}

-(BOOL)createDB{
    NSString *docsDir;
    NSArray *dirPaths;
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    // Build the path to the database file
    databasePath = [[NSString alloc] initWithString:
                    [docsDir stringByAppendingPathComponent: @"messages.db"]];
    BOOL isSuccess = YES;
    NSFileManager *filemgr = [NSFileManager defaultManager];
    if ([filemgr fileExistsAtPath: databasePath ] == NO)
    {
        const char *dbpath = [databasePath UTF8String];
        if (sqlite3_open(dbpath, &database) == SQLITE_OK)
        {
            char *errMsg;
            const char *sql_stmt ="create table if not exists messages (msgno integer primary key, msg text, msgDate text, msgFrom text, isSent text)";
            if (sqlite3_exec(database, sql_stmt, NULL, NULL, &errMsg)
                != SQLITE_OK)
            {
                isSuccess = NO;
                NSLog(@"Failed to create table");
            }
            sqlite3_close(database);
            return  isSuccess;
        }
        else {
            isSuccess = NO;
            NSLog(@"Failed to open/create database");
        }
    }
    return isSuccess;
}



- (BOOL) saveMessage:(MessageModel *)msgModel
{
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *insertSQL = [NSString stringWithFormat:@"insert into messages (msg,msgDate, msgFrom,isSent) values  (\"%@\", \"%@\", \"%@\",\"%d\")",msgModel.msg,msgModel.msgDate,msgModel.msgFrom,msgModel.isSent];
        
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            return YES;
        }
        else {
            return NO;
        }
        sqlite3_reset(statement);
    }
    return NO;
}



- (NSArray*) getMessagesWithPageNo:(int)pageNo andLimit:(int)limit
{
    NSMutableArray *resultArray = [[NSMutableArray alloc]init];

    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:
                              @"select * from messages order by msgno desc LIMIT %d OFFSET %d",limit,(pageNo*limit)];
        const char *query_stmt = [querySQL UTF8String];
        char *errMsg;

        if (sqlite3_prepare_v2(database,
                               query_stmt, -1, &statement, &errMsg) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                MessageModel *msgModel=[[MessageModel alloc]init];
                
                msgModel.msg = [[NSString alloc] initWithUTF8String:
                                  (const char *) sqlite3_column_text(statement, 1)];
                msgModel.msgDate = [[NSString alloc] initWithUTF8String:
                                        (const char *) sqlite3_column_text(statement, 2)];
                msgModel.msgFrom = [[NSString alloc]initWithUTF8String:
                                  (const char *) sqlite3_column_text(statement, 3)];
                
                NSString *isSent= [[NSString alloc]initWithUTF8String:
                                    (const char *) sqlite3_column_text(statement, 4)];
                
                if([isSent isEqualToString:@"1"]){
                    msgModel.isSent = 1;
                }
                else{
                    msgModel.isSent = 0;
                }

                [resultArray addObject:msgModel];
                
            }
           
            sqlite3_reset(statement);
        }
        else{
            NSLog(@"Error while creating update statement. '%s'", sqlite3_errmsg(database));

        }
    }
    return resultArray;
}

@end
