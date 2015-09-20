//
//  UIView+DragAndDrop.m
//  Pods
//
//  Created by Toshiro Sugii on 9/15/15.
//
//

#import <objc/runtime.h>
#import "UIView+DragAndDrop.h"
#import "NSObject+Swizzling.h"

static const int kdragAndDropPropertiesKey;

@interface TXDragAndDropProperties : NSObject

@property (nonatomic, assign) BOOL draggingEnabled;
@property (nonatomic, assign) UIEdgeInsets edgeInsets;

@property (nonatomic, assign) CGPoint currentPoint;
@property (nonatomic, assign) CGRect boundingBox;

@property (nonatomic, strong) NSString *originalName;
@property (nonatomic, strong) NSString *subclassName;

@property (nonatomic, assign) BOOL alreadySubclassed;


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
  if (draggingEnabled && ![self dragAndDropProperties].alreadySubclassed)
  {
    [self dragAndDropProperties].alreadySubclassed = YES;
    [self subclassSwizzlingSelector:@selector(touchesBegan:withEvent:) to:@selector(txTouchesBegan:withEvent:)];
    [self subclassSwizzlingSelector:@selector(touchesMoved:withEvent:) to:@selector(txTouchesMoved:withEvent:)];
    [self subclassSwizzlingSelector:@selector(touchesEnded:withEvent:) to:@selector(txTouchesEnded:withEvent:)];
    [self subclassSwizzlingSelector:@selector(touchesCancelled:withEvent:) to:@selector(txTouchesCancelled:withEvent:)];
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
  [self dragAndDropProperties].currentPoint = CGPointZero;
}

- (void)txTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
  [super touchesCancelled:touches withEvent:event];
  [self dragAndDropProperties].currentPoint = CGPointZero;
}

@end
