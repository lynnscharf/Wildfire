//
//  SettingsViewController.h
//  WildFireApp
//
//  Created by Sherif Mohammed Mostafa on 1/5/15.
//  Copyright (c) 2015 Sherif Mohammed Mostafa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) IBOutlet UILabel* selectedFireNameLabel;


-(IBAction)changeFireName:(id)sender;

@end
