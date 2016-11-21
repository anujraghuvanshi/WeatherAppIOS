//
//  CollectionViewCell.h
//  WeatherApp
//
//  Created by Vishal Deep on 19/08/16.
//  Copyright © 2016 Training. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UILabel *timeLbl;
@property (strong, nonatomic) IBOutlet UIImageView *weatherImage;
@property (strong, nonatomic) IBOutlet UILabel *tempLbl;

@end
