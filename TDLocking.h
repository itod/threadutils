//
//  TDLocking.h
//  Panthro
//
//  Created by Todd Ditchendorf on 5/19/14.
//
//

#import <Foundation/Foundation.h>

@protocol TDLocking <NSObject>

- (void)acquire;
- (void)relinquish;
@end

