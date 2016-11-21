//
//  CityWeatherVC.h
//  WeatherApp
//
//  Created by Vishal Deep on 31/08/16.
//  Copyright © 2016 Training. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GlobalViewController.h"

@interface CityWeatherVC : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    NSMutableDictionary *savedValue;
    NSArray *keys;
    GlobalViewController *fetchManageObjectContext;
}


@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

-(IBAction) TempFormatsegmentedControl:(id) sender;
@end
