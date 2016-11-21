//
//  WeatherViewController.h
//  WeatherApp
//
//  Created by Vishal Deep on 19/08/16.
//  Copyright © 2016 Training. All rights reserved.
//

#import "LocationViewController.h"
#import "Reachability.h"


@interface WeatherViewController : UIViewController < UITableViewDelegate, UITableViewDataSource ,UICollectionViewDelegate , UICollectionViewDataSource ,  NSFileManagerDelegate>

{
    NSMutableDictionary *json;
    
    NSMutableArray *minTemperatures;
    NSMutableArray *maxTemperatures;
    NSMutableArray *dayClimateImageArray;
    NSMutableArray *hourlyClimateImageArray;
    NSMutableArray *hourlyTempArray;
    NSMutableArray *timeArray;
    NSMutableArray *dayArray;
    
    NSString *CurrentTimeWithFormat;
    NSString *backgroundImage;
    NSString *dayClimateImage;
    NSString *hourClimateImage;
    NSString *tempInfehrenheit;
    NSString *hourlyTime;
    NSString * urlStr;
    
    Reachability *reachability;
    
    NSData *myData;
    NSManagedObject *newDataForEntity;
    NSOperationQueue *operationQueue;
//    NSManagedObject *dataFromCoreData;
    
}
@property (nonatomic, readwrite) NSInteger internetWorking;
@property (nonatomic, strong) Reachability *reachability;

@property (strong, nonatomic) IBOutlet UITableView *table;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UILabel *cityName;
@property (strong, nonatomic) IBOutlet UILabel *currentTemperature;
@property (strong, nonatomic) IBOutlet UIImageView *weatherImage;



@end
