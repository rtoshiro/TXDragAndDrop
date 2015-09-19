//
//  NSObject+Swizzling.m
//  Pods
//
//  Created by Toshiro Sugii on 9/15/15.
//
//

#import <objc/runtime.h>
#import "NSObject+Swizzling.h"

static const int kswizzlingPropertiesKey;

@interface TXSwizzlingProperties : NSObject

@property (nonatomic, strong) NSString *originalName;
@property (nonatomic, strong) NSString *subclassName;

@end

@implementation TXSwizzlingProperties

@end

@implementation NSObject (Swizzling)

- (TXSwizzlingProperties *)swizzlingProperties
{
  TXSwizzlingProperties *properties = objc_getAssociatedObject(self, &kswizzlingPropertiesKey);
  if ( !properties ) {
    properties = [[TXSwizzlingProperties alloc] init];
    
    objc_setAssociatedObject(self, &kswizzlingPropertiesKey, properties, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
#if !__has_feature(objc_arc)
    [properties release];
#endif
  }
  
  return properties;
}

+ (void)swizzleSelector:(SEL)originalSelector to:(SEL)newSelector {
  Method originalMethod = class_getInstanceMethod(self, originalSelector);
  Method newMethod = class_getInstanceMethod(self, newSelector);
  
  BOOL methodAdded = class_addMethod([self class],
                                     originalSelector,
                                     method_getImplementation(newMethod),
                                     method_getTypeEncoding(newMethod));
  
  if (methodAdded) {
    class_replaceMethod([self class],
                        newSelector,
                        method_getImplementation(originalMethod),
                        method_getTypeEncoding(originalMethod));
  } else {
    method_exchangeImplementations(originalMethod, newMethod);
  }
}

- (void)subclassSwizzlingSelector:(SEL)originalSelector to:(SEL)newSelector
{
  Class currentClass = object_getClass(self);
  NSString *currentClassName = NSStringFromClass(currentClass);
  
  // Creates new subclass
  if (![self swizzlingProperties].subclassName)
  {
    [self swizzlingProperties].originalName = currentClassName;
    [self swizzlingProperties].subclassName = [[self swizzlingProperties].originalName stringByAppendingString:[[NSUUID UUID] UUIDString]];
    Class newClass = objc_allocateClassPair(currentClass, [[self swizzlingProperties].subclassName cStringUsingEncoding:NSUTF8StringEncoding], 0);    
    objc_registerClassPair(newClass);
  }
//  
  Class newClass = objc_getClass([[self swizzlingProperties].subclassName cStringUsingEncoding:NSUTF8StringEncoding]);
//  Class origClass = objc_getClass([[self swizzlingProperties].originalName cStringUsingEncoding:NSUTF8StringEncoding]);

  
  
  [newClass swizzleSelector:originalSelector to:newSelector];
//  Method originalMethod = class_getInstanceMethod(origClass, originalSelector);
//  Method newMethod = class_getInstanceMethod(origClass, newSelector);
//  
//  method_exchangeImplementations(originalMethod, newMethod);

  
//
//  BOOL methodAdded = class_addMethod(newClass,
//                                     originalSelector,
//                                     method_getImplementation(newMethod),
//                                     method_getTypeEncoding(newMethod));
//  
//  if (methodAdded) {
//    class_replaceMethod(newClass,
//                        newSelector,
//                        method_getImplementation(originalMethod),
//                        method_getTypeEncoding(originalMethod));
//    NSLog(@"imp ");
//  } else {
//    method_exchangeImplementations(originalMethod, newMethod);
//  }

  
  
  
  if (![currentClassName isEqualToString:[self swizzlingProperties].subclassName])
    object_setClass(self, newClass);
}

@end
