//
//  SettingsViewController.m
//  WildFireApp
//
//  Created by Sherif Mohammed Mostafa on 1/5/15.
//  Copyright (c) 2015 Sherif Mohammed Mostafa. All rights reserved.
//

#import "SettingsViewController.h"
#import "Utils.h"
#import "AFHTTPRequestOperation.h"
#import "CustomIOS7AlertView.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

NSString* selectedFireName;
NSArray* fireNamesArray;
CustomIOS7AlertView* alert;


- (void)viewDidLoad {
    [super viewDidLoad];
    fireNamesArray = [NSArray new];
    selectedFireName = [Utils getUserDefaultValueForKey:@"selectedFireName"];
    _selectedFireNameLabel.text=selectedFireName;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(IBAction)changeFireName:(id)sender
{
    [self getFireNames];
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
    alertTitleLabel.textAlignment=UITextAlignmentCenter;
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
    _selectedFireNameLabel.text=selectedFireName;
    [Utils saveUserDefaultForKey:@"selectedFireName" value:selectedFireName];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
