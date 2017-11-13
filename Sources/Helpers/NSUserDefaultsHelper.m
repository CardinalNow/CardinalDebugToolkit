//
//  NSUserDefaultsHelper.m
//  CardinalDebugToolkit
//
//  Created by Robin Kunde on 11/3/17.
//

#import <CardinalDebugToolkit/CardinalDebugToolkit-Swift.h>
#import <Foundation/Foundation.h>

NSArray<NSString*>* persistentUserDefaultsDomains() {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    return NSUserDefaults.standardUserDefaults.persistentDomainNames;
#pragma clang diagnostic pop
}

NSArray<NSString*>* volatileUserDefaultsDomains() {
    return NSUserDefaults.standardUserDefaults.volatileDomainNames;
}
