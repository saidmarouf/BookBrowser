//
//  BookCellCollectionViewCell.m
//  BookBrowser
//
//  Created by Said Marouf on 9/18/14.
//
//

#import "BookCell.h"
#import "Book.h"
#import "Helpers.h"

@interface BookCell()

@property (nonatomic, strong) UILabel *bookTitleLabel;
@property (nonatomic, strong) UILabel *bookAuthorLabel;

- (void) addCellConstraints;

@end



@implementation BookCell

- (instancetype) initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        
        [self setBackgroundColor:[UIColor colorWithWhite:0.95 alpha:1.0]];
        
        _bookTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), 20)];
        [_bookTitleLabel setLineBreakMode:NSLineBreakByTruncatingTail];
        [_bookTitleLabel setTextAlignment:NSTextAlignmentCenter];
        [_bookTitleLabel setNumberOfLines:2];
        [_bookTitleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:15]];
        [_bookTitleLabel setPreferredMaxLayoutWidth:CGRectGetWidth(frame)-20];
        [_bookTitleLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addSubview:_bookTitleLabel];
        
        _bookAuthorLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), 24)];
        [_bookAuthorLabel setTextAlignment:NSTextAlignmentCenter];
        [_bookAuthorLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14]];
        [_bookAuthorLabel setPreferredMaxLayoutWidth:CGRectGetWidth(frame)-20];
        [_bookAuthorLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addSubview:_bookAuthorLabel];
        
        [self addCellConstraints];
    }
    
    return self;
}

- (void) setBook:(Book *)book {
    
    _book = book;
    [self layoutSubviews];
}

- (void) layoutSubviews {
    [super layoutSubviews];
    
    //Simple stuff here, but could do more complex things with our data and update the layout.
    //reset for cases where empty authors occur
    [_bookTitleLabel setText:@""];
    [_bookAuthorLabel setText:@""];

    if(_book) {
        if(_book.bookTitle)
            [_bookTitleLabel setText:_book.bookTitle];
        if(_book.bookUnifiedAuthor)
            [_bookAuthorLabel setText:_book.bookUnifiedAuthor];
    }
}

- (void) addCellConstraints {
    
    NSUInteger titleHeight = CGRectGetHeight(_bookTitleLabel.frame); //shold be based on title content
    
    NSInteger titleAdjustment_Y = -1 * ceil(titleHeight/2.0);
    
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:_bookTitleLabel
                         attribute:NSLayoutAttributeCenterY
                         relatedBy:NSLayoutRelationEqual
                         toItem:self
                         attribute:NSLayoutAttributeCenterY
                         multiplier:1.0
                         constant:titleAdjustment_Y]];
    
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:_bookTitleLabel
                         attribute:NSLayoutAttributeCenterX
                         relatedBy:NSLayoutRelationEqual
                         toItem:self
                         attribute:NSLayoutAttributeCenterX
                         multiplier:1.0
                         constant:0]];
    
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:_bookTitleLabel
                         attribute:NSLayoutAttributeWidth
                         relatedBy:NSLayoutRelationEqual
                         toItem:self
                         attribute:NSLayoutAttributeWidth
                         multiplier:1.0
                         constant:-20]];
    
    
    /*
     Should add more extensive helper methods for adding constraints...
     */
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:_bookAuthorLabel
                         attribute:NSLayoutAttributeTop
                         relatedBy:NSLayoutRelationEqual
                         toItem:_bookTitleLabel
                         attribute:NSLayoutAttributeBottom
                         multiplier:1.0
                         constant:4]];
    
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:_bookAuthorLabel
                         attribute:NSLayoutAttributeCenterX
                         relatedBy:NSLayoutRelationEqual
                         toItem:_bookTitleLabel
                         attribute:NSLayoutAttributeCenterX
                         multiplier:1.0
                         constant:0]];
    
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:_bookAuthorLabel
                         attribute:NSLayoutAttributeWidth
                         relatedBy:NSLayoutRelationEqual
                         toItem:self
                         attribute:NSLayoutAttributeWidth
                         multiplier:1.0
                         constant:-20]];
}

@end
