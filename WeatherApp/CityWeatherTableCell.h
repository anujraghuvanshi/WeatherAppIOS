//
//  CityWeatherTableCell.h
//  WeatherApp
//
//  Created by Vishal Deep on 03/09/16.
//  Copyright © 2016 Training. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CityWeatherTableCell : UITableViewCell


@property (strong, nonatomic) IBOutlet UILabel *cityTemperatureLbl;
@property (strong, nonatomic) IBOutlet UILabel *cityTimeLbl;
@property (strong, nonatomic) IBOutlet UILabel *cityNameLbl;

@end
