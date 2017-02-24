//
//  ZFPayAlertView.m
//  ZFAlertView
//
//  Created by zhaofei on 2017/2/24.
//  Copyright © 2017年 zhaofei. All rights reserved.
//

#import "ZFPayAlertView.h"
#import "Masonry.h"

#define container_left_right_margin 40
#define container_top_margin 64
#define inputView_container_margin 20

#define dotSize 12
#define passwordLength 6
#define cancelBtnSize 30

#define lineWidth 1 / [UIScreen mainScreen].scale
#define separatorLineColor [UIColor colorWithRed:.9 green:.9 blue:.9 alpha:1.]

@interface ZFPayAlertView() <UITextFieldDelegate>
@property (nonatomic, strong, readwrite) UIView *containerView;
@property (nonatomic, strong, readwrite) UIButton *cancelBtn;
@property (nonatomic, strong, readwrite) UIView *lineView;
@property (nonatomic, strong, readwrite) UIView *inputView;
@property (nonatomic, strong, readwrite) UITextField *textField;

@property (nonatomic, strong, readwrite) NSMutableArray *dotLabels;
@end

@implementation ZFPayAlertView

#pragma mark - layout subviews
- (void)configureSubviews {
    [super configureSubviews];
    NSLog(@"ZFPayAlertView - configureSubviews");
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self).offset(- container_top_margin * [UIScreen mainScreen].scale);
        make.leading.equalTo(self).offset(container_left_right_margin);
        make.trailing.equalTo(self).offset(-container_left_right_margin);
        make.bottom.equalTo(self.inputView.mas_bottom).offset(8);
    }];
    
    [self.cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.containerView);
        make.top.equalTo(self.containerView);
        make.height.equalTo(@(cancelBtnSize));
        make.width.equalTo(@(cancelBtnSize));
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.containerView);
        make.centerY.equalTo(self.cancelBtn);
    }];

    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.containerView);
        make.top.equalTo(self.cancelBtn.mas_bottom).offset(1);
        make.height.equalTo(@(1 / [UIScreen mainScreen].scale));
        make.width.equalTo(self.containerView);
    }];
    
    [self.subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.containerView);
        make.top.equalTo(self.lineView.mas_bottom).offset(8);
    }];
    
    [self.amountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.containerView);
        make.top.equalTo(self.subTitleLabel.mas_bottom).offset(8);
    }];
    
    [self.inputView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.containerView).offset(inputView_container_margin);
        make.trailing.equalTo(self.containerView).offset(-inputView_container_margin);
        make.top.equalTo(self.amountLabel.mas_bottom).offset(12);
        make.height.equalTo(@44);
    }];
    
    // 添加点
    for (int i = 0; i < passwordLength; i++) {
        
        CGFloat bgWidth = (ScreenWidth - container_left_right_margin * 2 - inputView_container_margin * 2) / passwordLength;
        
        UIView *bgView = [[UIView alloc] init];
        [self addSubview: bgView];
        
        [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.inputView).offset(i * bgWidth);
            make.top.equalTo(self.inputView);
            make.bottom.equalTo(self.inputView);
            make.width.equalTo(@(bgWidth));
        }];
        
        if (i != passwordLength - 1) {
            UIView *separatorLine = [[UIView alloc] init];
            separatorLine.backgroundColor = separatorLineColor;
            [bgView addSubview: separatorLine];
            [bgView bringSubviewToFront: separatorLine];
            
            
            [separatorLine mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(bgView);
                make.bottom.equalTo(bgView);
                make.width.equalTo(@(lineWidth));
                make.leading.equalTo(bgView.mas_trailing).offset(lineWidth * 0.5);
            }];
        }
        
        
        UILabel *dotLabel = [[UILabel alloc] init];
        dotLabel.backgroundColor = [UIColor blackColor];
        dotLabel.layer.cornerRadius = dotSize * 0.5;
        dotLabel.layer.masksToBounds = YES;
        dotLabel.hidden = YES;
        [bgView addSubview: dotLabel];
        
        [self.dotLabels addObject: dotLabel];
        
        [dotLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(bgView);
            make.width.equalTo(@(dotSize));
            make.height.equalTo(@(dotSize));
        }];
    }
    
    self.textField.frame = self.frame;
}

- (NSMutableArray *)dotLabels {
    if (!_dotLabels) {
        _dotLabels = [[NSMutableArray alloc] init];
    }
    return _dotLabels;
}

- (UIView *)containerView {
    if (!_containerView) {
        _containerView = [[UIView alloc] init];
        _containerView.backgroundColor = [UIColor whiteColor];
        _containerView.layer.cornerRadius = 6;
        _containerView.layer.masksToBounds = YES;
        [self addSubview:_containerView];
    }
    return _containerView;
}

- (UIButton *)cancelBtn {
    if (!_cancelBtn) {
        _cancelBtn = [[UIButton alloc] init];
        [_cancelBtn setTitle:@"╳" forState:UIControlStateNormal];
        [_cancelBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        _cancelBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
        [_cancelBtn addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview: _cancelBtn];
    }
    return _cancelBtn;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = [UIColor blackColor];
        [self addSubview:_lineView];
    }
    return _lineView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = @"Title";
        _titleLabel.textColor = [UIColor blackColor];
        [self addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UILabel *)subTitleLabel {
    if (!_subTitleLabel) {
        _subTitleLabel = [[UILabel alloc] init];
        _subTitleLabel.text = @"Subtitle";
        _subTitleLabel.font = [UIFont boldSystemFontOfSize:15];
        _subTitleLabel.textColor = [UIColor blackColor];
        [self addSubview:_subTitleLabel];
    }
    return _subTitleLabel;
}


- (UILabel *)amountLabel {
    if (!_amountLabel) {
        _amountLabel = [[UILabel alloc] init];
//        _amountLabel.text = @"Amount: $10";
        _amountLabel.textColor = [UIColor blackColor];
        _amountLabel.font = [UIFont boldSystemFontOfSize:16];
        [self addSubview:_amountLabel];
    }
    return _amountLabel;
}

- (UIView *)inputView {
    if (!_inputView) {
        _inputView = [[UIView alloc] init];
        _inputView.backgroundColor = [UIColor whiteColor];
        _inputView.layer.borderWidth = 1.f;
        _inputView.layer.borderColor = [UIColor colorWithRed:.9 green:.9 blue:.9 alpha:1.].CGColor;
        [self addSubview:_inputView];
    }
    return _inputView;
}

- (UITextField *)textField {
    if (!_textField) {
        _textField = [[UITextField alloc] init];
        _textField.hidden = YES;
        _textField.keyboardType = UIKeyboardTypeNumberPad;
        [_textField addTarget:self action:@selector(checkTextLength:) forControlEvents:UIControlEventEditingChanged];
        _textField.delegate = self;
        [self addSubview:_textField];
    }
    return _textField;
}

#pragma mark - text field delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.text.length >= passwordLength && string.length) {
        return NO;
    }
    
    // 只容许输入数字
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",@"^[0-9]*$"];
    return [predicate evaluateWithObject:string];
}

- (void)checkTextLength: (UITextField *)textField {
    if (textField.text.length == passwordLength) {
        [self dismiss];
        
        // call back
        if (self.completeHander) {
            self.completeHander(textField.text);
        }
        return;
    }
    
    for (UILabel *dot in self.dotLabels) {
        dot.hidden = YES;
    }
    
    for (int i = 0; i< textField.text.length; i++) {
        UILabel *label = [self.dotLabels objectAtIndex:i];
        label.hidden = NO;
    }
}

#pragma mark - override
- (void)show {
    [super show];
    
    self.containerView.transform = CGAffineTransformMakeScale(1.21f, 1.21f);
    self.containerView.alpha = 0;
    
    [UIView animateWithDuration:0.7f delay:0.f usingSpringWithDamping:0.7f initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self.textField becomeFirstResponder];
        self.containerView.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
        self.containerView.alpha = 1.0;
    } completion:nil];
}

- (void)dismiss {
    [self.textField resignFirstResponder];
    [self.window removeFromSuperview];
    [self.window resignKeyWindow];
    self.window = nil;
}

@end
