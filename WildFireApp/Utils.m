//
//  Utils.m
//  WildFireApp
//
//  Created by Sherif Mohammed Mostafa on 1/18/15.
//  Copyright (c) 2015 Sherif Mohammed Mostafa. All rights reserved.
//

#import "Utils.h"

@implementation Utils



+(void) saveUserDefaultForKey:(NSString*) key value:(NSString*) value
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    [prefs setObject:value forKey:key];
    
    [prefs synchronize];
    
}

+(NSString *) getUserDefaultValueForKey:(NSString*) key
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    return [prefs stringForKey:key];
    
}

@end
