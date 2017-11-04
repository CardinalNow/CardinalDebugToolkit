//
//  NSUserDefaultsHelper.m
//  CardinalDebugToolkit
//
//  Created by Robin Kunde on 11/3/17.
//

#import <CardinalDebugToolkit/CardinalDebugToolkit-Swift.h>
#import <Foundation/Foundation.h>

NSArray<NSString*>* persistentUserDefaultsDomains() {
    return NSUserDefaults.standardUserDefaults.persistentDomainNames;
}

NSArray<NSString*>* volatileUserDefaultsDomains() {
    return NSUserDefaults.standardUserDefaults.volatileDomainNames;
}
