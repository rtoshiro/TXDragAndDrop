# TXDragAndDrop

## Usage

Call ```setDraggingEnabled:``` to make a UIView draggable.

You can restrict the dragging area throught ```setDraggingEdgeInsets:```.

As Apple API docs said:

Positive values cause the frame to be inset (or shrunk) by the specified amount. Negative values cause the frame to be outset (or expanded) by the specified amount.

So, if you want to make UIView draggable to the left, restricting top and bottom, you can set your UIEdgeInsets as:

```
[self.myview setDraggingEdgeInsets:UIEdgeInsetsMake(0.f, -self.myview.frame.size.width, 0.f, 0.f)];

```

## API

```
- (void)setDraggingEnabled:(BOOL)draggingEnabled;
- (BOOL)isDraggingEnabled;

- (void)setDraggingEdgeInsets:(UIEdgeInsets)edgeInsets;
- (UIEdgeInsets)draggingEdgeInsets;
```

## Installation

TXDragAndDrop is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "TXDragAndDrop"
```

## License

Copyright (c) 2015 Toshiro Sugii

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
