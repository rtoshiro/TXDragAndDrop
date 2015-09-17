//
//  UIView+DragAndDrop.m
//  Pods
//
//  Created by Toshiro Sugii on 9/15/15.
//
//

#import <objc/runtime.h>
#import "NSObject+Swizzling.h"
#import "UIView+DragAndDrop.h"

static const int kdragAndDropPropertiesKey;

@interface TXDragAndDropProperties : NSObject

@property (nonatomic, assign) BOOL draggingEnabled;
@property (nonatomic, assign) UIEdgeInsets edgeInsets;

@property (nonatomic, assign) CGPoint currentPoint;
@property (nonatomic, assign) CGRect boundingBox;

@property (nonatomic, strong) NSString *originalName;
@property (nonatomic, strong) NSString *subclassName;

@end

@implementation TXDragAndDropProperties

@end


@implementation UIView (DragAndDrop)

- (TXDragAndDropProperties *)dragAndDropProperties
{
  TXDragAndDropProperties *properties = objc_getAssociatedObject(self, &kdragAndDropPropertiesKey);
  if ( !properties ) {
    properties = [[TXDragAndDropProperties alloc] init];
    properties.edgeInsets = UIEdgeInsetsMake(-CGFLOAT_MAX, -CGFLOAT_MAX, -CGFLOAT_MAX, -CGFLOAT_MAX);
    
    objc_setAssociatedObject(self, &kdragAndDropPropertiesKey, properties, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
#if !__has_feature(objc_arc)
    [properties release];
#endif
  }
  return properties;
}

- (void)setDraggingEnabled:(BOOL)draggingEnabled {
  [self dragAndDropProperties].draggingEnabled = draggingEnabled;
  if (draggingEnabled)
  {
    [self swizzleSelector:@selector(touchesBegan:withEvent:) to:@selector(txTouchesBegan:withEvent:)];
    [self swizzleSelector:@selector(touchesMoved:withEvent:) to:@selector(txTouchesMoved:withEvent:)];
    [self swizzleSelector:@selector(touchesEnded:withEvent:) to:@selector(txTouchesEnded:withEvent:)];
    [self swizzleSelector:@selector(touchesCancelled:withEvent:) to:@selector(txTouchesCancelled:withEvent:)];
  }
}

- (BOOL)isDraggingEnabled {
  return [self dragAndDropProperties].draggingEnabled;
}

- (void)setDraggingEdgeInsets:(UIEdgeInsets)edgeInsets {
  [self dragAndDropProperties].edgeInsets = edgeInsets;
}

- (UIEdgeInsets)draggingEdgeInsets {
  return [self dragAndDropProperties].edgeInsets;
}

- (void)txTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
  NSLog(@"txTouchesBegan");
  [super touchesBegan:touches withEvent:event];

  
  if ([self dragAndDropProperties].draggingEnabled)
  {
    UITouch *aTouch = [touches anyObject];
    CGPoint location = [aTouch locationInView:self.superview];
    [self dragAndDropProperties].currentPoint = location;
    
    if (CGRectIsEmpty([self dragAndDropProperties].boundingBox))
    {
      [self dragAndDropProperties].boundingBox = UIEdgeInsetsInsetRect(self.frame, [self dragAndDropProperties].edgeInsets);
    }
  }
}

- (void)txTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
  [super touchesMoved:touches withEvent:event];
  
  if ([self dragAndDropProperties].draggingEnabled)
  {
    if ([self dragAndDropProperties].currentPoint.x > 0 && [self dragAndDropProperties].currentPoint.y > 0)
    {
      // Anima a cor
      self.alpha = ((1.f * (self.frame.origin.x + self.frame.size.width)) / self.frame.size.width) + 0.2f;
      
      UITouch *aTouch = [touches anyObject];
      CGPoint location = [aTouch locationInView:self.superview];
      CGPoint diff = CGPointMake(location.x - [self dragAndDropProperties].currentPoint.x, location.y - [self dragAndDropProperties].currentPoint.y);
      
      CGRect frame = self.frame;
      if (frame.origin.x + diff.x <= [self dragAndDropProperties].boundingBox.origin.x)
        frame.origin.x = [self dragAndDropProperties].boundingBox.origin.x;
      else if (frame.origin.x + diff.x + self.frame.size.width >= ([self dragAndDropProperties].boundingBox.origin.x + [self dragAndDropProperties].boundingBox.size.width))
        frame.origin.x = ([self dragAndDropProperties].boundingBox.origin.x + [self dragAndDropProperties].boundingBox.size.width) - self.frame.size.width;
      else
        frame.origin.x += diff.x;
      
      if (frame.origin.y + diff.y <= [self dragAndDropProperties].boundingBox.origin.y)
        frame.origin.y = [self dragAndDropProperties].boundingBox.origin.y;
      else if (frame.origin.y + diff.y + self.frame.size.height >= ([self dragAndDropProperties].boundingBox.origin.y + [self dragAndDropProperties].boundingBox.size.height))
        frame.origin.y = ([self dragAndDropProperties].boundingBox.origin.y + [self dragAndDropProperties].boundingBox.size.height) - self.frame.size.height;
      else
        frame.origin.y += diff.y;
      
      [UIView beginAnimations:@"animations" context:nil];
      self.frame = frame;
      [UIView commitAnimations];
      
      [self dragAndDropProperties].currentPoint = location;
    }
  }
}

- (void)txTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
  [super touchesEnded:touches withEvent:event];
}

- (void)txTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
  [super touchesCancelled:touches withEvent:event];
}
//
//+ (void)swizzleSelector:(SEL)originalSelector to:(SEL)newSelector {
//  Method originalMethod = class_getInstanceMethod(self, originalSelector);
//  Method newMethod = class_getInstanceMethod(self, newSelector);
//  
//  BOOL methodAdded = class_addMethod([self class],
//                                     originalSelector,
//                                     method_getImplementation(newMethod),
//                                     method_getTypeEncoding(newMethod));
//  
//  if (methodAdded) {
//    class_replaceMethod([self class],
//                        newSelector,
//                        method_getImplementation(originalMethod),
//                        method_getTypeEncoding(originalMethod));
//  } else {
//    method_exchangeImplementations(originalMethod, newMethod);
//  }
//}
//
//- (void)swizzleSelector:(SEL)originalSelector to:(SEL)newSelector {
//  Class currentClass = [self class];
//  NSString *currentClassName = NSStringFromClass(currentClass);
//  
//  // Create a new subclass
//  if (![self dragAndDropProperties].subclassName)
//  {
//    [self dragAndDropProperties].originalName = currentClassName;
//    [self dragAndDropProperties].subclassName = [currentClassName stringByAppendingString:[[NSUUID UUID] UUIDString]];
//    Class newClass = objc_allocateClassPair(currentClass, [self dragAndDropProperties].subclassName.UTF8String, 0);
//    objc_registerClassPair(newClass);
//  }
//  
//  Class newClass = NSClassFromString([self dragAndDropProperties].subclassName);
//  Class origClass = NSClassFromString([self dragAndDropProperties].originalName);
//  Method origMethod = class_getInstanceMethod(origClass, newSelector);
//  
//  
//  Method originalMethod = class_getInstanceMethod(origClass, originalSelector);
//  Method newMethod = class_getInstanceMethod(origClass, newSelector);
//  
////  class_replaceMethod(newClass,
////                  originalSelector,
////                  method_getImplementation(newMethod),
////                  method_getTypeEncoding(newMethod));
////  
////
//  BOOL methodAdded = class_addMethod(newClass,
//                                     originalSelector,
//                                     method_getImplementation(newMethod),
//                                     method_getTypeEncoding(newMethod));
//  NSLog(@"%d", methodAdded);
////  class_replaceMethod(newClass,
////                      newSelector,
////                      method_getImplementation(originalMethod),
////                      method_getTypeEncoding(originalMethod));
////  
////  NSLog(@"%d", methodAdded);
////  if (!class_addMethod(newClass, newSelector, method_getImplementation(origMethod), method_getTypeEncoding(origMethod))) {
////    method_setImplementation(origMethod, method_getImplementation(origMethod));
////  }
////
////  [newClass swizzleSelector:originalSelector to:newSelector];
////
////  if (!class_addMethod(newClass, method_getName(origMethod), method_getImplementation(origMethod), method_getTypeEncoding(origMethod))) {
////    method_setImplementation(method, newImp);
////  }
//  
////  NSLog(@"changing %@", newClass);
////  method_exchangeImplementations(class_getInstanceMethod(newClass, originalSelector), class_getInstanceMethod(newClass, newSelector));
////
////  
//  if (![currentClassName isEqualToString:[self dragAndDropProperties].subclassName])
//    object_setClass(self, newClass);
//}

@end
