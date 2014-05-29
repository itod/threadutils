//
//  TDSync.h
//  Thread Utils
//
//  Created by Todd Ditchendorf on 5/19/14.
//
//

#import <Foundation/Foundation.h>

@protocol TDSync <NSObject>

- (void)acquire;
- (void)relinquish;
@end

