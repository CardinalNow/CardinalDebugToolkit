//
//  NSUserDefaultsHelper.h
//  CardinalDebugToolkit
//
//  Created by Robin Kunde on 11/3/17.
//

#import <Foundation/Foundation.h>

#ifndef NSUserDefaultsHelper_h
#define NSUserDefaultsHelper_h

NSArray<NSString*>* _Nonnull persistentUserDefaultsDomains(void);
NSArray<NSString*>* _Nonnull volatileUserDefaultsDomains(void);

#endif /* NSUserDefaultsHelper_h */
