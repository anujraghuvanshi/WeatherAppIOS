//
//  GlobalViewController.h
//  WeatherApp
//
//  Created by Vishal on 19/09/16.
//  Copyright © 2016 Training. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface GlobalViewController : NSObject{
    NSMutableArray *submittedDataArray;
    NSManagedObject *newLocationForEntity;
}

- (NSManagedObjectContext *)managedObjectContext;
-(void)fetchDataFromEntity;
@end
