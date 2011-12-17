//
//  HPTextViewInternal.m
//
//  Created by Hans Pinckaers on 29-06-10.
//
//	MIT License
//
//	Copyright (c) 2011 Hans Pinckaers
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the Software is
//	furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in
//	all copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//	THE SOFTWARE.

#import "HPTextViewInternal.h"

#define PLACEHOLDER_LABEL_TAG 999

@interface HPTextViewInternal()

@property(nonatomic,retain) UILabel* placeHolderLabel;

@end


@implementation HPTextViewInternal

@synthesize placeHolderLabel;
@synthesize placeholderColor;
@synthesize placeholder;

- (id)initWithFrame:(CGRect)frame {
	if  (self = [super initWithFrame:frame]) {
		self.placeholder = @"";
		self.placeholderColor = [UIColor colorWithRed:179/255.0 green:179/255.0 blue:179/255.0 alpha:1.0];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:nil];
	}

	return self;
}

-(void)setContentOffset:(CGPoint)s
{
	if(self.tracking || self.decelerating){
		//initiated by user...
		self.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
	} else {

		float bottomOffset = (self.contentSize.height - self.frame.size.height + self.contentInset.bottom);
		if(s.y < bottomOffset && self.scrollEnabled){
			self.contentInset = UIEdgeInsetsMake(0, 0, 8, 0); //maybe use scrollRangeToVisible?
		}
		
	}
	
	[super setContentOffset:s];
}

-(void)setContentInset:(UIEdgeInsets)s
{
	UIEdgeInsets insets = s;
	
	if(s.bottom>8) insets.bottom = 0;
	insets.top = 0;

	[super setContentInset:insets];
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];

	self.placeHolderLabel = nil;
	self.placeholderColor = nil;
	self.placeholder = nil;

	[super dealloc];
}

- (void)textChanged:(NSNotification*)notification {
	if ([self.placeholder length] == 0) return;

	if ([self.text length] == 0) {
		[[self viewWithTag:PLACEHOLDER_LABEL_TAG] setAlpha:1];
	} else {
		[[self viewWithTag:PLACEHOLDER_LABEL_TAG] setAlpha:0];
	}
}


- (void)drawRect:(CGRect)rect {
	if ([self.placeholder length] > 0 ) {
		self.placeHolderLabel.text = self.placeholder;
		[self.placeHolderLabel sizeToFit];
		[self sendSubviewToBack:self.placeHolderLabel];
	}

	if( [self.text length] == 0 && [self.placeholder length] > 0 )
	{
		[self viewWithTag:PLACEHOLDER_LABEL_TAG].alpha = 1;
	}

	[super drawRect:rect];
}

#pragma mark Accessors

- (void)setText:(NSString*)text {
	 [super setText:text];
	 [self textChanged:nil];
}


- (UILabel*)placeHolderLabel {
	if (placeHolderLabel == nil) {
		placeHolderLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 8, self.bounds.size.width - 16, 0)];
		placeHolderLabel.lineBreakMode = UILineBreakModeWordWrap;
		placeHolderLabel.numberOfLines = 0;
		placeHolderLabel.font = self.font;
		placeHolderLabel.backgroundColor = [UIColor clearColor];
		placeHolderLabel.textColor = self.placeholderColor;
		placeHolderLabel.alpha = 0;
		placeHolderLabel.tag = PLACEHOLDER_LABEL_TAG;
		[self addSubview:placeHolderLabel];
	}

	return placeHolderLabel;
}

@end
