

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface Database : NSObject {
	
	
}
+(NSString* )getDatabasePath;
+(NSMutableArray *)executeQuery:(NSString*)str;
+(NSString*)encodedString:(const unsigned char *)ch;
+(BOOL)executeScalarQuery:(NSString*)str;


@end
