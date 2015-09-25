
#import "Database.h"
#import <sqlite3.h>

static sqlite3 *database = nil;


@implementation Database
+(NSString* )getDatabasePath{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"ChatDB.sqlite"];
	return writableDBPath;
	
}

+(NSMutableArray *)executeQuery:(NSString*)str{

	sqlite3_stmt *statement= nil;
	sqlite3 *database;
	NSString *strPath = [self getDatabasePath];
	NSMutableArray *allDataArray = [[NSMutableArray alloc] init];
	if (sqlite3_open([strPath UTF8String],&database) == SQLITE_OK) {
		if (sqlite3_prepare_v2(database, [str UTF8String], -1, &statement, NULL) == SQLITE_OK) {
			

			while (sqlite3_step(statement) == SQLITE_ROW) {
							NSInteger i = 0;
				NSInteger iColumnCount = sqlite3_column_count(statement);
				NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
				while (i< iColumnCount) {
					NSString *str = [self encodedString:(const unsigned char*)sqlite3_column_text(statement, i)];
					
					
				NSString *strFieldName = [self encodedString:(const unsigned char*)sqlite3_column_name(statement, i)];
					
					[dict setObject:str forKey:strFieldName];
					i++;
				}
				
				[allDataArray addObject:dict];
			}
		}

		sqlite3_finalize(statement);
	} 
	sqlite3_close(database);
	return allDataArray;
}

+(NSString*)encodedString:(const unsigned char *)ch
{
	NSString *retStr;
	if(ch == nil)
		retStr = @"";
	else
		retStr = [NSString stringWithCString:(char*)ch encoding:NSUTF8StringEncoding];
	return retStr;
}

+(BOOL)executeScalarQuery:(NSString*)str{
	sqlite3_stmt *statement= nil;
	sqlite3 *database;
	BOOL fRet = NO;
	NSString *strPath = [self getDatabasePath];
	if (sqlite3_open([strPath UTF8String],&database) == SQLITE_OK) {
		if (sqlite3_prepare_v2(database, [str UTF8String], -1, &statement, NULL) == SQLITE_OK) {
			if (sqlite3_step(statement) == SQLITE_DONE)
				fRet =YES;
		}
		
		sqlite3_finalize(statement);
	} 
	sqlite3_close(database);
	return fRet;
}

@end
