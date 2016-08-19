//
//  TDExchanger.h
//  TDThreadUtils
//
//  Created by Todd Ditchendorf on 5/19/14.
//
//

#import <Foundation/Foundation.h>

@interface TDExchanger : NSObject

+ (instancetype)exchanger;

- (id)exchange:(id)obj;
@end
