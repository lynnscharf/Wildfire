//
//  CartoDBLayer.h
//  WildFireApp
//
//  Created by Sherif Mohammed Mostafa on 12/25/14.
//  Copyright (c) 2014 Sherif Mohammed Mostafa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WhirlyGlobeComponent.h>

@interface CartoDBLayer : NSObject<MaplyPagingDelegate>
{
    NSString *search;
    NSOperationQueue *opQueue;
}

@property (nonatomic,assign) int minZoom,maxZoom;

// Create with the search string we'll use
- (id)initWithSearch:(NSString *)search;
@end
