//
//  GlobalViewController.m
//  WeatherApp
//
//  Created by Vishal on 19/09/16.
//  Copyright © 2016 Training. All rights reserved.
//

#import "GlobalViewController.h"
#import "LocationViewController.h"

@implementation GlobalViewController



- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}


-(void)fetchDataFromEntity {
//    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSManagedObjectContext *context = [self managedObjectContext]; 
    newLocationForEntity = [NSEntityDescription insertNewObjectForEntityForName:@"WeatherRecord" inManagedObjectContext:context];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"WeatherRecord"];
    self->submittedDataArray = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];

}



@end
