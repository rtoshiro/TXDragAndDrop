//
//  UIView+DragAndDrop.h
//  Pods
//
//  Created by Toshiro Sugii on 9/15/15.
//
//

#import <Foundation/Foundation.h>

@interface UIView (DragAndDrop)

- (void)setDraggingEnabled:(BOOL)draggingEnabled;
- (BOOL)isDraggingEnabled;

- (void)setDraggingEdgeInsets:(UIEdgeInsets)edgeInsets;
- (UIEdgeInsets)draggingEdgeInsets;



@end
