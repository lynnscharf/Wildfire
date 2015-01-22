//
//  Utils.h
//  WildFireApp
//
//  Created by Sherif Mohammed Mostafa on 1/18/15.
//  Copyright (c) 2015 Sherif Mohammed Mostafa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utils : NSObject


+(void) saveUserDefaultForKey:(NSString*) key value:(NSString*) value;
+(NSString *) getUserDefaultValueForKey:(NSString*) key;

@end
