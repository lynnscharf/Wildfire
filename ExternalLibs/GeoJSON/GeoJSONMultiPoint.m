//
//  GeoJSONMultiPoint.m
//  geojson-parser
//
//  Created by JM on 03/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GeoJSONMultiPoint.h"
#import "GeoJSONPoint.h"

@implementation GeoJSONMultiPoint

@synthesize count;

- (id) initWithGeoJSONCoordinates:(NSArray*)coords
{
    if (self = [super init]) {
        NSMutableArray *tmp = [[NSMutableArray alloc] initWithCapacity:coords.count];
        
        for (NSArray* point in coords) {
            GeoJSONPoint *geoPoint = [[GeoJSONPoint alloc] initWithGeoJSONCoordinates:point];
            if (geoPoint) {
                [tmp addObject:geoPoint];
            }
        }
        
        _points = [[NSArray alloc] initWithArray:tmp];
    }
    return self;
}


- (GeoJSONPoint*) pointAt:(int)index
{
    return index < _points.count ? [_points objectAtIndex:index] : nil;
}

- (int) count
{
    return _points ? _points.count : -1;
}


+ (bool) isType:(NSString*)type
{
    return [@"MultiPoint" isEqualToString:type] || [@"LineString" isEqualToString:type];
}


- (NSString*) description
{
    NSMutableString *str = [[NSMutableString alloc] initWithCapacity:256];
    [str appendFormat:@"MultiPoint(count=%d)[", self.count, nil];
    int i = 0;
    for (GeoJSONPoint *p in _points) {
        [str appendFormat:@"\n\tPoint %d: %@", i++, [p description]];
    }
    [str appendFormat:@"\n]"];
    return [NSString stringWithString:str];
}

@end
