
#import "ACommon.h"
#import "AFirmware.h"

#define VFDECRYPT [[NSBundle mainBundle] pathForResource:@"vfdecrypt" ofType:@"" inDirectory:@"bin"]
#define GENPASS [[NSBundle mainBundle] pathForResource:@"genpass" ofType:@"" inDirectory:@"bin"]
#define GRABKBAG [[NSBundle mainBundle] pathForResource:@"grabkbag" ofType:@"" inDirectory:@"bin"]
#define DBHELPER [[NSBundle mainBundle] pathForResource:@"dbHelper" ofType:@"" inDirectory:@"bin"]
#define XPWNTOOL [[NSBundle mainBundle] pathForResource:@"xpwntool" ofType:@"" inDirectory:@"bin"]
#define DYLDCACHE [[NSBundle mainBundle] pathForResource:@"dyldcache" ofType:@"" inDirectory:@"bin"]
#define CDC [[NSBundle mainBundle] pathForResource:@"class-dump-cache" ofType:@"" inDirectory:@"bin"]
#define FM [NSFileManager defaultManager]
#define NULLOUT [NSFileHandle fileHandleWithNullDevice]


@interface NSString (specialAdditions)


-(NSString *)cleanedString;
-(NSString *)decryptedPath;


@end