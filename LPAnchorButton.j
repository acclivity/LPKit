/*
 * LPAnchorButton.j
 * LPKit
 *
 * Created by Ludwig Pettersson on November 9, 2009.
 * 
 * The MIT License
 * 
 * Copyright (c) 2009 Ludwig Pettersson
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 * 
 */

LPAnchorButtonNoUnderline     = 0;
LPAnchorButtonNormalUnderline = 1;
LPAnchorButtonHoverUnderline  = 2;

@implementation LPAnchorButton : CPControl
{
    unsigned _underlineMask @accessors(property=underlineMask);

    CPString _title @accessors(property=title);
    CPURL _URL;
    id _DOMAnchorElement;
}

+ (CPString)defaultThemeClass
{
    return @"anchor-button";
}

+ (id)buttonWithTitle:(CPString)aTitle
{
    var button = [[self alloc] init];
    [button setTitle:aTitle];
    [button sizeToFit];
    return button;
}

- (id)init
{
    if (self = [super init])
    {
        // Set default underline mask
        _underlineMask = LPAnchorButtonNormalUnderline | LPAnchorButtonHoverUnderline;
    }
    return self;
}

- (void)setTitle:(CPString)aTitle
{
    _title = aTitle;
    [self setNeedsLayout];
}

- (void)openURLOnClick:(CPURL)aURL
{
    _URL = aURL;

    [self setNeedsLayout];
}

- (void)setTextColor:(CPColor)aColor
{
    [self setValue:aColor forThemeAttribute:@"text-color"];
}

- (void)setTextHoverColor:(CPColor)aColor
{
    [self setValue:aColor forThemeAttribute:@"text-color" inState:CPThemeStateHovered];
}

- (void)mouseDown:(CPEvent)anEvent
{
    if (![self isEnabled])
        return;

    if (_URL)
    {
        [[[self window] platformWindow] _propagateCurrentDOMEvent:YES];
    }
    else
        [super mouseDown:anEvent];
}

- (void)sizeToFit
{
    [self setFrameSize:[(_title || " ") sizeWithFont:[self currentValueForThemeAttribute:@"font"]]];
}

- (CGRect)rectForEphemeralSubviewNamed:(CPString)aName
{
    return [self bounds];
}

- (CPView)createEphemeralSubviewNamed:(CPString)aName
{
    var contentView = [[_CPImageAndTextView alloc] initWithFrame:CGRectMakeZero()];
    return contentView;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    // Set up anchor element if needed
    if (_URL)
    {
        if (!_DOMAnchorElement)
        {
            _DOMAnchorElement = document.createElement("a");
            _DOMAnchorElement.target = @"_blank";
            _DOMAnchorElement.style.position = "absolute";
            _DOMAnchorElement.style.zIndex = "100";

            self._DOMElement.appendChild(_DOMAnchorElement)
        }

        _DOMAnchorElement.href = typeof _URL == 'string' ? _URL : [_URL absoluteString];

        var bounds = [self bounds];

        _DOMAnchorElement.style.width = CGRectGetWidth(bounds) + @"px";
        _DOMAnchorElement.style.height = CGRectGetHeight(bounds) + @"px";

        _DOMAnchorElement.style.display = [self isEnabled] ? @"block" : @"none";
    }

    var shouldUnderline = NO,
        isNormalThemeState = [self hasThemeState:CPThemeStateNormal] ||
                                [self hasThemeState:CPThemeStateSelected] ||
                                [self hasThemeState:CPThemeStateHighlighted] ||
                                [self hasThemeState:CPThemeStateDisabled],
        isHoverThemeState = [self hasThemeState:CPThemeStateHovered];

    if (isNormalThemeState && _underlineMask & LPAnchorButtonNormalUnderline)
        shouldUnderline = YES;
    else if (isHoverThemeState && _underlineMask & LPAnchorButtonHoverUnderline)
        shouldUnderline = YES;

    var contentView = [self layoutEphemeralSubviewNamed:@"content-view"
                                             positioned:CPWindowAbove
                        relativeToEphemeralSubviewNamed:nil];

    if (contentView)
    {
        [contentView setText:_title];

        [contentView setTextColor:[self currentValueForThemeAttribute:@"text-color"]];
        [contentView setFont:[self currentValueForThemeAttribute:@"font"]];
        [contentView setAlignment:[self currentValueForThemeAttribute:@"alignment"]];
        [contentView setVerticalAlignment:[self currentValueForThemeAttribute:@"vertical-alignment"]];
        [contentView setLineBreakMode:[self currentValueForThemeAttribute:@"line-break-mode"]];
        [contentView setTextShadowColor:[self currentValueForThemeAttribute:@"text-shadow-color"]];
        [contentView setTextShadowOffset:[self currentValueForThemeAttribute:@"text-shadow-offset"]];

        // Force the layout to make sure the needed DOM elements are available
        [contentView layoutIfNeeded];

        if (contentView._DOMTextElement)
            contentView._DOMTextElement.style.textDecoration = shouldUnderline ? @"underline" : @"none";

        if (contentView._DOMTextShadowElement)
            contentView._DOMTextShadowElement.style.textDecoration = shouldUnderline ? @"underline" : @"none";
    }
}

@end


var LPAnchorButtonUnderlineMaskKey = @"LPAnchorButtonUnderlineMaskKey";

@implementation LPAnchorButton (CPCoding)

- (id)initWithCoder:(CPCoder)aCoder
{
    if (self = [super initWithCoder:aCoder])
    {
        _underlineMask = [aCoder decodeIntForKey:LPAnchorButtonUnderlineMaskKey];

        if (!_underlineMask)
            _underlineMask = LPAnchorButtonNormalUnderline | LPAnchorButtonHoverUnderline
    }

    return self;
}

- (void)encodeWithCoder:(CPCoder)aCoder
{
    [super encodeWithCoder:aCoder];

    if (_underlineMask !== LPAnchorButtonNoUnderline)
        [aCoder encodeInt:_underlineMask forKey:LPAnchorButtonUnderlineMaskKey];
}

@end