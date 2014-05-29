//
//  TDSynchronousChannel.h
//  Thread Utils
//
//  Created by Todd Ditchendorf on 5/19/14.
//
//

#import <Foundation/Foundation.h>

@interface TDSynchronousChannel : NSObject

+ (instancetype)synchronousChannel;

- (void)put:(id)obj;
- (id)take;
@end
