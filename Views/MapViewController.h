//
//  ViewController.h
//  WildFireApp
//
//  Created by Sherif Mohammed Mostafa on 12/22/14.
//  Copyright (c) 2014 Sherif Mohammed Mostafa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CartoDBClient.h"
#import "MaplyViewController.h"
#import "WhirlyGlobeViewController.h"

@interface MapViewController : UIViewController<WhirlyGlobeViewControllerDelegate,MaplyViewControllerDelegate, UITableViewDataSource, UITableViewDelegate>




- (void) loadFire;
- (void) addAnnotation:(NSString *)title withSubtitle:(NSString *)subtitle at: (MaplyCoordinate)coord;

@end

