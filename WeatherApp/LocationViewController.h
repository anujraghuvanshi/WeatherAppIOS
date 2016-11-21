//
//  ViewController.h
//  WeatherApp
//
//  Created by Vishal Deep on 17/08/16.
//  Copyright © 2016 Training. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@import CoreLocation;

@interface LocationViewController : UIViewController <UITextFieldDelegate,CLLocationManagerDelegate>
{
    NSMutableArray * arrayOfDictionary;
    NSMutableDictionary *dictionary;
    NSString * cityEnteredByUser;
    NSString * stateEnteredByUser;
    NSString * countryEnteredByUser;
    NSString * pincodeEnteredByUser;
    NSString *LattitudeFoundByUserData;
    NSString *LongitudeFoundByUserData;
    CLLocation *newLocation;
    
    NSString *currentLatitude;
    NSString *currentLongitude;
    
    UISwitch * switchCase;
    NSManagedObject *newDataForEntity;
}


@property (nonatomic, retain) CLLocationManager *locationManager;
- (IBAction)switchBtn:(id)sender;
@property (strong, nonatomic) IBOutlet UITextField *city;
@property (strong, nonatomic) IBOutlet UITextField *state;
@property (strong, nonatomic) IBOutlet UITextField *country;
@property (strong, nonatomic) IBOutlet UITextField *pinCode;
@property (strong, nonatomic) IBOutlet UIImageView *weatherImage;
@property (strong, nonatomic) IBOutlet UIButton *showBtn;
- (IBAction)showlocation:(id)sender;


@end

