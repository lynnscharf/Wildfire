//
//  GeoJSONPolygon.m
//  geojson-parser
//
//  Created by JM on 03/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GeoJSONPolygon.h"
#import "GeoJSONMultiPoint.h"
#import "GeoJSONPoint.h"

@implementation GeoJSONPolygon


- (id) initWithGeoJSONCoordinates:(NSArray*)coords
{
    if (self = [super init]) {
        
        _points = [[GeoJSONMultiPoint alloc] initWithGeoJSONCoordinates:[coords objectAtIndex:0]];
        
        NSMutableArray *tmp = [[NSMutableArray alloc] initWithCapacity:coords.count];
        if (coords.count > 1) {
            // holes
            for (int i = 1; i < coords.count; ++i) {
                GeoJSONMultiPoint *hole = [[GeoJSONMultiPoint alloc] initWithGeoJSONCoordinates:[coords objectAtIndex:i]];
                if (hole) {
                    [tmp addObject:hole];
                }
            }
            _holes = [[NSArray alloc] initWithArray:tmp];
        } else {
            _holes = [[NSArray alloc] init];
        }
    }
    return self;
}


- (GeoJSONPoint*) vertexAt:(int)index
{
    return index < _points.count ? [_points pointAt:index] : nil;
}

- (GeoJSONMultiPoint*) holeAt:(int)index
{
    return index < _holes.count ? [_holes objectAtIndex:index] : nil;
}

- (int) vertexCount
{
    return _points ? _points.count : -1;
}

- (int) holeCount
{
    return _holes ? _holes.count : -1;
}


+ (bool) isType:(NSString*)type
{
    return [@"MultiLineString" isEqualToString:type] || [@"Polygon" isEqualToString:type];
}


- (NSString*) description
{
    NSMutableString *str = [[NSMutableString alloc] initWithCapacity:256];
    [str appendFormat:@"Polygon(vertices=%d)[\n\tVertices:", self.vertexCount, nil];
    for (int i = 0; i < _points.count; ++i) {
        GeoJSONPoint *p = [self vertexAt:i];
        [str appendFormat:@"\n\t\tPoint %d: %@", i, [p description]];
    }
    [str appendFormat:@"\n]"];
    //TODO holes
    return [NSString stringWithString:str];
}

@end
