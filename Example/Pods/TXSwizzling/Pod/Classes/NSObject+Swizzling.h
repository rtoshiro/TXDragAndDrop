//
//  NSObject+Swizzling.h
//  Pods
//
//  Created by Toshiro Sugii on 9/15/15.
//
//

#import <Foundation/Foundation.h>

@interface NSObject (Swizzling)

+ (void)swizzleSelector:(SEL)originalSelector to:(SEL)newSelector;
- (void)subclassSwizzlingSelector:(SEL)originalSelector to:(SEL)newSelector;

@end
