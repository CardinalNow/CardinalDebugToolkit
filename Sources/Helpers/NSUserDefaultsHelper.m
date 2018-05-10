//
//  NSUserDefaultsHelper.m
//  CardinalDebugToolkit
//
//  Created by Robin Kunde on 11/3/17.
//

#import "NSUserDefaultsHelper.h"

NSArray<NSString*>* _Nonnull persistentUserDefaultsDomains(void) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    return NSUserDefaults.standardUserDefaults.persistentDomainNames;
#pragma clang diagnostic pop
}

NSArray<NSString*>* _Nonnull volatileUserDefaultsDomains(void) {
    return NSUserDefaults.standardUserDefaults.volatileDomainNames;
}
