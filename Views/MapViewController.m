//
//  ViewController.m
//  WildFireApp
//
//  Created by Sherif Mohammed Mostafa on 12/22/14.
//  Copyright (c) 2014 Sherif Mohammed Mostafa. All rights reserved.
//

#import "MapViewController.h"
#import "CartoDBCredentials.h"
#import "CartoDBCredentialsApiKey.h"
#import "CartoDBDataProvider.h"
#import "CartoDBDataProviderHTTP.h"
#import "CartoDBClient.h"
#import "MaplyComponent.h"
#import "WhirlyGlobeViewController.h"
#import "CartoDBLayer.h"
#import "AFHTTPRequestOperation.h"
#import "CustomIOS7AlertView.h"
#import "MBProgressHUD.h"
#import "Utils.h"

#define ARRAY_LEN(x)  (sizeof(x)/sizeof(x[0]))

@interface MapViewController ()

@end

//static NSString* const kUser = @"devsherif";
//static NSString* const kAPIKey = nil;
//static NSString* const kTableWithData = @"egypt_area";

static NSString* const kUser = @"silverleaf";
//static NSString* const kAPIKey = @"db64adf2e1050fec3253ae0f325e27123a74a0fc";
static NSString* const kAPIKey = nil;
static NSString* const kTableWithData = @"active_perimeters_dd83";


@implementation MapViewController
{
    int page;
    NSString *selectedFireName;
    CustomIOS7AlertView* alert;
    WhirlyGlobeViewController *theViewC;
    NSDictionary *vectorDict, *labelsDict;
        WhirlyGlobeViewController *globeViewC;
    NSArray *fireNamesArray;
    float labelAdded;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addMapView];
    [self addUIControllers];
    
    vectorDict = @{
                   kMaplyColor: [UIColor redColor],
                   kMaplySelectable: @(true),
                   kMaplyVecWidth: @(4.0)};
    
    labelsDict = @{
                   kMaplyTextColor: [UIColor whiteColor],
                   kMaplySelectable: @(true),
                   kMaplyVecWidth: @(4.0)};
}

-(void) viewWillAppear:(BOOL)animated
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES].labelText=@"Loading WildFire";
    labelAdded=false;
    fireNamesArray = [NSMutableArray new];
    selectedFireName = [Utils getUserDefaultValueForKey:@"selectedFireName"];
    if (selectedFireName) {
        [self loadFire];
    }else{
        [self getFireNames];
    }

}



-(void) addUIControllers
{
    int buttonWidth = self.view.frame.size.height/14;
    UIButton* zoomInButton = [UIButton buttonWithType:UIButtonTypeCustom];
    zoomInButton.frame = CGRectMake(10, 50, buttonWidth, buttonWidth);
    [zoomInButton setImage:[UIImage imageNamed:@"zoom_in_icon"] forState:UIControlStateNormal];
    [zoomInButton setTitle:@"Zoom In" forState:UIControlStateNormal];
    [zoomInButton setTag:1];
    [zoomInButton addTarget:self action:@selector(zoomButtonsAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:zoomInButton];
    
    UIButton* zoomOutButton = [UIButton buttonWithType:UIButtonTypeCustom];
    zoomOutButton.frame = CGRectMake(10, 50+10+buttonWidth, buttonWidth, buttonWidth);
    [zoomOutButton setTag:2];
    [zoomOutButton addTarget:self action:@selector(zoomButtonsAction:) forControlEvents:UIControlEventTouchUpInside];
    [zoomOutButton setImage:[UIImage imageNamed:@"zoom_out_icon"] forState:UIControlStateNormal];
    [self.view addSubview:zoomOutButton];
}

-(IBAction)zoomButtonsAction:(id)sender
{
    if([sender tag] ==1){
        globeViewC.height = globeViewC.height/2;
    }else if([sender tag] ==2){
        globeViewC.height = globeViewC.height*2;
    }
}


-(void) addMapView
{
    
    theViewC = [[WhirlyGlobeViewController alloc] init];
    [self.view addSubview:theViewC.view];
    theViewC.view.frame = self.view.bounds;
    [self addChildViewController:theViewC];
    

    MaplyViewController *mapViewC = nil;
    if ([theViewC isKindOfClass:[WhirlyGlobeViewController class]])
        globeViewC = (WhirlyGlobeViewController *)theViewC;
    else
        mapViewC = (MaplyViewController *)theViewC;
    
    // we want a black background for a globe, a white background for a map.
    theViewC.clearColor = (globeViewC != nil) ? [UIColor blackColor] : [UIColor whiteColor];
    
    // and thirty fps if we can get it ­ change this to 3 if you find your app is struggling
    theViewC.frameInterval = 2;
    
    // add the capability to use the local tiles or remote tiles
    bool useLocalTiles = false;
    
    // we'll need this layer in a second
    MaplyQuadImageTilesLayer *layer;
    
    if (useLocalTiles)
    {
        MaplyMBTileSource *tileSource =
        [[MaplyMBTileSource alloc] initWithMBTiles:@"geography­-class_medres"];
        layer = [[MaplyQuadImageTilesLayer alloc]
                 initWithCoordSystem:tileSource.coordSys tileSource:tileSource];
    } else {
        // Because this is a remote tile set, we'll want a cache directory
        NSString *baseCacheDir =
        [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)
         objectAtIndex:0];
        NSString *aerialTilesCacheDir = [NSString stringWithFormat:@"%@/osmtiles/",
                                         baseCacheDir];
        int maxZoom = 100;
        
        // MapQuest Open Aerial Tiles, Courtesy Of Mapquest
        // Portions Courtesy NASA/JPL­Caltech and U.S. Depart. of Agriculture, Farm Service Agency
        MaplyRemoteTileSource *tileSource =
        [[MaplyRemoteTileSource alloc]
         initWithBaseURL:@"http://otile1.mqcdn.com/tiles/1.0.0/sat/"
         ext:@"png" minZoom:0 maxZoom:maxZoom];
        tileSource.cacheDir = aerialTilesCacheDir;
        layer = [[MaplyQuadImageTilesLayer alloc]
                 initWithCoordSystem:tileSource.coordSys tileSource:tileSource];
    }
    
    layer.handleEdges = (globeViewC != nil);
    layer.coverPoles = (globeViewC != nil);
    layer.requireElev = false;
    layer.waitLoad = false;
    layer.drawPriority = 0;
    layer.singleLevelLoading = false;
    [theViewC addLayer:layer];
    
    // start up over Colorado
    if (globeViewC != nil)
    {
        globeViewC.height = 0.5;
        [globeViewC animateToPosition:MaplyCoordinateMakeWithDegrees(-95.665,37.6)
                                 time:1.0];
    } else {
        mapViewC.height = 0.5;
        [mapViewC animateToPosition:MaplyCoordinateMakeWithDegrees(-95.665,37.6)
                               time:1.0];
    }
    globeViewC.heading=180;
    // start up over New York
//    if (globeViewC != nil)
//    {
//        globeViewC.height = 0.0002;
//        [globeViewC animateToPosition:MaplyCoordinateMakeWithDegrees(-73.99,40.75)
//                                 time:1.0];
//    } else {
//        globeViewC.height = 0.0002;
//        [mapViewC animateToPosition:MaplyCoordinateMakeWithDegrees(-73.99,40.75)
//                               time:1.0];
//    }
    
    // If you're doing a globe
    if (globeViewC != nil)
        globeViewC.delegate = self;
    
    // If you're doing a map
    if (mapViewC != nil)
        mapViewC.delegate = self;
    
}

-(void) getFireNames
{
    NSString *queryStr = [NSString stringWithFormat:
                          @"http://silverleaf.cartodb.com/api/v2/sql?format=JSON&q=SELECT distinct(fire_name) FROM active_perimeters_dd83 order by fire_name LIMIT 1000"];
    
    
    // Kick off the request with AFNetworking.  We can deal with the result in a block
    NSURLRequest *request = [NSURLRequest requestWithURL:
                             [NSURL URLWithString:[queryStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]
                                         initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation
                                               , id responseObject) {
        fireNamesArray = responseObject[@"rows"];
        [self showAlertView];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"JSON: %@",error.description);
    }];
    [operation start];
}

-(void) showAlertView
{
    alert = [[CustomIOS7AlertView alloc] init];
    
    UIView* alertContainerView = [[UIView alloc] initWithFrame:CGRectMake(5, 50, self.view.frame.size.width-10, self.view.frame.size.height-100)];
    UILabel* alertTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, -50, alertContainerView.frame.size.width-20, 50)];
    alertTitleLabel.text=@"Please select a wild fire";
    alertTitleLabel.textAlignment=NSTextAlignmentCenter;
    UITableView* fireNamesTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, alertContainerView.frame.size.width-10, alertContainerView.frame.size.height-50)];
    fireNamesTableView.delegate=self;
    fireNamesTableView.dataSource=self;
    [alertContainerView addSubview:fireNamesTableView];
    [alertContainerView addSubview:alertTitleLabel];
    [alert setContainerView:alertContainerView];
    [alert show];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width-10, 60)];
    UILabel* fireNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 200, 50)];
    fireNameLabel.text = [fireNamesArray objectAtIndex:indexPath.row][@"fire_name"];
    [cell addSubview:fireNameLabel];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return fireNamesArray.count;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    [alert dismissWithClickedButtonIndex:-1 animated:YES];
    [alert removeFromSuperview];
    selectedFireName = [fireNamesArray objectAtIndex:indexPath.row][@"fire_name"];
    NSLog(@"selected fire name = %@", selectedFireName);
    [Utils saveUserDefaultForKey:@"selectedFireName" value:selectedFireName];
    [self loadFire];
    
}


- (void)loadFire
{
    NSLog(@"loading fire name");
    NSString *queryStr = [NSString stringWithFormat:
                          @"http://silverleaf.cartodb.com/api/v2/sql?format=GeoJSON&q=SELECT the_geom, fire, fire_name FROM active_perimeters_dd83 where fire_name = '%@' LIMIT 1000",selectedFireName];

    
        // Kick off the request with AFNetworking.  We can deal with the result in a block
        NSURLRequest *request = [NSURLRequest requestWithURL:
                                 [NSURL URLWithString:[queryStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]
                                         initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation
                                               , id responseObject) {
        MaplyVectorObject*  maply = [MaplyVectorObject VectorObjectFromGeoJSONDictionary:(NSDictionary *) responseObject];
        globeViewC.height=0.008;
        [globeViewC animateToPosition:[maply center] time:1.0];
        globeViewC.heading=60;
        for (MaplyVectorObject* maply1 in maply.splitVectors){
            [self addFire:maply1];
        }
        labelAdded=false;
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
                NSLog(@"JSON: %@",error.description);
    }]; 
        [operation start];
    
}


- (void)addFire:(MaplyVectorObject *)vecs
{
    if (!vecs)
        return;

    [globeViewC addVectors:[NSArray arrayWithObject:vecs] desc:vectorDict];

    MaplyCoordinate center = [vecs center];

    NSString *name;
    if(vecs.attributes[@"fire_name"]){
    name= vecs.attributes[@"fire_name"];
    }


    if (![name isKindOfClass:[NSNull class]] && !labelAdded)
    {
        labelAdded=true;
        MaplyScreenLabel *fireNameLabel = [[MaplyScreenLabel alloc] init];
        fireNameLabel.text = name;
        fireNameLabel.loc = center;
        fireNameLabel.selectable = NO;
        fireNameLabel.layoutImportance = 1.0;
        [globeViewC addScreenLabels:@[fireNameLabel] desc:labelsDict];
    }
    
}


- (void)addAnnotation:(NSString *)title withSubtitle:(NSString *)subtitle at:(MaplyCoordinate)coord
{
    [theViewC clearAnnotations];
    
    MaplyAnnotation *annotation = [[MaplyAnnotation alloc] init];
    annotation.title = title;
    annotation.subTitle = subtitle;
    [theViewC addAnnotation:annotation forPoint:coord offset:CGPointZero];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)globeViewController:(WhirlyGlobeViewController *)viewC
                   didTapAt:(MaplyCoordinate)coord
{
    NSString *title = @"Tap Location:";
    NSString *subtitle = [NSString stringWithFormat:@"(%.2fN, %.2fE)",
                          coord.y*57.296,coord.x*57.296];
    [self addAnnotation:title withSubtitle:subtitle at:coord];
}

- (void)maplyViewController:(MaplyViewController *)viewC
                   didTapAt:(MaplyCoordinate)coord
{
    NSString *title = @"Tap Location:";
    NSString *subtitle = [NSString stringWithFormat:@"(%.2fN, %.2fE)",
                          coord.y*57.296,coord.x*57.296];
    [self addAnnotation:title withSubtitle:subtitle at:coord];
}


// Unified method to handle the selection
- (void) handleSelection:(MaplyBaseViewController *)viewC
                selected:(NSObject *)selectedObj
{
    NSLog(@"selected object is: %@",selectedObj);
    
    if ([selectedObj isKindOfClass:[CartoDBLayer class]]){
        
        NSLog(@"CartoDBLayer Object selected");
    }
    else if ([selectedObj isKindOfClass:[MaplyVectorObject class]])
    {
        MaplyVectorObject *theVector = (MaplyVectorObject *)selectedObj;

            NSString *title = [NSString stringWithFormat:@"Fire Name: %@",(NSString *)theVector.attributes[@"fire_name"]];
//        globeViewC.heading=0;
        MaplyCoordinate coordinate = [theVector center];
//        coordinate.x += globeViewC.height-globeViewC.height/2;
//        [globeViewC setPosition:coordinate];
        [globeViewC animateToPosition:coordinate
                                 time:1.0];

        float latitude =[theVector center].x;
        float longitude =[theVector center].y;
        NSString *subtitle =[NSString stringWithFormat:@"Latitude: %f, Longitude: %f", latitude, longitude];
        [self addAnnotation:title withSubtitle:subtitle at:[theVector center]];
        
    } else if ([selectedObj isKindOfClass:[MaplyScreenMarker class]])
    {
        MaplyScreenMarker *theMarker = (MaplyScreenMarker *)selectedObj;
        
        NSString *title = @"Selected:";
        NSString *subtitle = @"Screen Marker";
        [self addAnnotation:title withSubtitle:subtitle at:theMarker.loc];
        
    }
}

// This is the version for a globe
- (void) globeViewController:(WhirlyGlobeViewController *)viewC
                   didSelect:(NSObject *)selectedObj
{
    [self handleSelection:viewC selected:selectedObj];
}

// This is the version for a map
- (void) maplyViewController:(MaplyViewController *)viewC
                   didSelect:(NSObject *)selectedObj
{
    [self handleSelection:viewC selected:selectedObj];
}


- (void)addBuildings
{
    NSString *search = @"SELECT the_geom, fire_name FROM active_perimeters_dd83 where the_geom && ST_SetSRID(ST_MakeBox2D(ST_Point(%f, %f), ST_Point(%f, %f)), 4326) LIMIT 2000;";
    CartoDBLayer *cartoLayer = [[CartoDBLayer alloc] initWithSearch:search];
    cartoLayer.minZoom = 8;
    cartoLayer.maxZoom = 15;
    MaplySphericalMercator *coordSys = [[MaplySphericalMercator alloc] initWebStandard];
    MaplyQuadPagingLayer *quadLayer =
    [[MaplyQuadPagingLayer alloc] initWithCoordSystem:coordSys delegate:cartoLayer];
    [globeViewC addLayer:quadLayer];
}


@end
