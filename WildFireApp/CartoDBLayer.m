//
//  CartoDBLayer.m
//  WildFireApp
//
//  Created by Sherif Mohammed Mostafa on 12/25/14.
//  Copyright (c) 2014 Sherif Mohammed Mostafa. All rights reserved.
//

#import "CartoDBLayer.h"

@implementation CartoDBLayer



- (id)initWithSearch:(NSString *)inSearch
{
    self = [super init];
    search = inSearch;
    opQueue = [[NSOperationQueue alloc] init];
             NSLog(@"insearch called");    
    return self;
}


- (void)startFetchForTile:(MaplyTileID)tileID forLayer:(MaplyQuadPagingLayer *)layer
{
    
             NSLog(@"startFetchForTile called");
    // bounding box for tile
    MaplyBoundingBox bbox;
    [layer geoBoundsforTile:tileID ll:&bbox.ll ur:&bbox.ur];
    
    
    NSURLRequest *urlReq = [self constructRequest:bbox];
    
    // kick off the query asychronously
    [NSURLConnection
     sendAsynchronousRequest:urlReq
     queue:opQueue
     completionHandler:
     ^(NSURLResponse *response, NSData *data, NSError *connectionError)
     {
NSLog(@"response = %@", response.description);
         // parse the resulting GeoJSON
         MaplyVectorObject *vecObj = [MaplyVectorObject VectorObjectFromGeoJSON:data];
         if (vecObj)
         {
             // display a transparent filled polygon
             MaplyComponentObject *filledObj =
             [layer.viewC
              addVectors:@[vecObj]
              desc:@{kMaplyColor: [UIColor colorWithRed:0.25
                                                  green:0.0 blue:0.0 alpha:0.15],
                     kMaplyEnable: @(NO)
                     }
              mode:MaplyThreadCurrent];
             
             // display a line around the lot
             MaplyComponentObject *outlineObj =
             [layer.viewC
              addVectors:@[vecObj]
              desc:@{kMaplyColor: [UIColor redColor],
                     kMaplyFilled: @(NO),
                     kMaplyEnable: @(NO)
                     }
              mode:MaplyThreadCurrent];
             
             NSLog(@"fire_name value = %@",vecObj.attributes[@"fire_name"]);
             NSString* fire_name = vecObj.attributes[@"fire_name"];
             if(fire_name){
                 // We'll create a 2D (screen) label at that point and the layout engine will control it
                 MaplyScreenLabel *fireNameLabel = [[MaplyScreenLabel alloc] init];
                 fireNameLabel.text = fire_name;
                 fireNameLabel.loc = vecObj.center;
                 fireNameLabel.selectable = NO;
                 fireNameLabel.layoutImportance = 1.0;
                 [layer.viewC addScreenLabels:@[fireNameLabel] desc:
                  @{kMaplyColor: [UIColor whiteColor],kMaplyFont: [UIFont boldSystemFontOfSize:10.0],kMaplyShadowColor: [UIColor blackColor], kMaplyShadowSize: @(1.0), kMaplyFade: @(1.0)}];
             
             // keep track of it in the layer
             [layer addData:@[filledObj,outlineObj] forTile:tileID];
             }
         }
         
         // let the layer know the tile is done
         [layer tileDidLoad:tileID];
     }];
}


- (NSURLRequest *)constructRequest:(MaplyBoundingBox)bbox
{
                 NSLog(@"construct request called");
    double toDeg = 180/M_PI;
    NSString *query = [NSString stringWithFormat:search,bbox.ll.x*toDeg,bbox.ll.y*toDeg,bbox.ur.x*toDeg,bbox.ur.y*toDeg];
    NSString *encodeQuery = [query stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    encodeQuery = [encodeQuery stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];
    NSString *fullUrl = [NSString stringWithFormat:@"https://silverleaf.cartodb.com/api/v2/sql?format=GeoJSON&q=%@",encodeQuery];
//    NSString *fullUrl = [NSString stringWithFormat:@"https://pluto.cartodb.com/api/v2/sql?format=GeoJSON&q=%@",encodeQuery];
    NSURLRequest *urlReq = [NSURLRequest requestWithURL:[NSURL URLWithString:fullUrl]];
    
    return urlReq;
}

@end
