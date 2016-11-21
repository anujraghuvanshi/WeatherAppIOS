//
//  TableViewCell.h
//  WeatherApp
//
//  Created by Vishal Deep on 20/08/16.
//  Copyright © 2016 Training. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *dayLbl;
@property (strong, nonatomic) IBOutlet UILabel *maxTempLbl;
@property (strong, nonatomic) IBOutlet UILabel *minTempLbl;
@property (strong, nonatomic) IBOutlet UIImageView *dayClimateImage;
@end
