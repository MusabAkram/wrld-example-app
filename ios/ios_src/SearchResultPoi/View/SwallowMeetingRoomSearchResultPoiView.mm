// Copyright eeGeo Ltd (2012-2015), All Rights Reserved

#include <string>
#include <algorithm>
#include "SearchResultPoiView.h"
#include "MathFunc.h"
#include "UIColors.h"
#include "ImageHelpers.h"
#include "IconResources.h"
#include "StringHelpers.h"
#import "UIView+TouchExclusivity.h"
#include "SwallowMeetingRoomSearchResultPoiView.h"
#include "SwallowSearchParser.h"
#include "SwallowSearchConstants.h"
#include "App.h"
#import "UIButton+DefaultStates.h"
#import "ViewController.h"

@interface SwallowMeetingRoomSearchResultPoiView()<UIGestureRecognizerDelegate>
{
}
@end

@implementation SwallowMeetingRoomSearchResultPoiView

- (id)initWithInterop:(ExampleApp::SearchResultPoi::View::SearchResultPoiViewInterop*)pInterop;
{
    self = [super init];
    
    if(self)
    {
        m_pController = [UIViewController alloc];
        [m_pController setView:self];
        
        m_pInterop = pInterop;
        self.alpha = 0.f;
        m_stateChangeAnimationTimeSeconds = 0.2f;
        
        self.pControlContainer = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)] autorelease];
        self.pControlContainer.backgroundColor = ExampleApp::Helpers::ColorPalette::UiBackgroundColor;
        [self addSubview: self.pControlContainer];
        
        self.pContentContainer = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)] autorelease];
        self.pContentContainer.backgroundColor = ExampleApp::Helpers::ColorPalette::UiBackgroundColor;
        [self.pControlContainer addSubview: self.pContentContainer];
        
        self.pLabelsContainer = [[[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)] autorelease];
        self.pLabelsContainer.backgroundColor = ExampleApp::Helpers::ColorPalette::UiBackgroundColor;
        [self.pContentContainer addSubview: self.pLabelsContainer];
        
        self.pHeadlineContainer = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)] autorelease];
        self.pHeadlineContainer.backgroundColor = ExampleApp::Helpers::ColorPalette::UiBackgroundColor;
        [self.pControlContainer addSubview: self.pHeadlineContainer];
        
        self.pCategoryIconContainer = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)] autorelease];
        self.pCategoryIconContainer.backgroundColor = ExampleApp::Helpers::ColorPalette::UiBackgroundColor;
        [self.pHeadlineContainer addSubview: self.pCategoryIconContainer];
        
        self.pTitleLabel = [self createLabel :ExampleApp::Helpers::ColorPalette::UiTextCopyColor :ExampleApp::Helpers::ColorPalette::UiBackgroundColor];
        self.pTitleLabel.textColor = ExampleApp::Helpers::ColorPalette::UiBorderColor;
        [self.pHeadlineContainer addSubview: self.pTitleLabel];
        
        self.pCloseButton = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 0, 0)] autorelease];
        self.pCloseButton.contentMode = UIViewContentModeScaleAspectFit;
        self.pCloseButton.clipsToBounds = YES;
        [self.pCloseButton setDefaultStatesWithImageNames:@"exit_blue_x_button" :@"exit_dark_blue_x_button"];
        [self.pCloseButton addTarget:self action:@selector(handleClosedButtonSelected) forControlEvents:UIControlEventTouchUpInside];
        [self.pHeadlineContainer addSubview: self.pCloseButton];
        
        self.pImageDivider = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)] autorelease];
        self.pImageDivider.backgroundColor = ExampleApp::Helpers::ColorPalette::UiBorderColor;
        [self.pLabelsContainer addSubview:self.pImageDivider];
        
        self.pPreviewImage = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)] autorelease];
        self.pPreviewImage.contentMode = UIViewContentModeScaleAspectFill;
        [self.pLabelsContainer addSubview: self.pPreviewImage];
        
        self.pPlaceholderImage = [UIImage imageNamed: @"poi_placeholder.png"];
        
        self.pPreviewImageSpinner = [[[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)] autorelease];
        self.pPreviewImageSpinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        self.pPreviewImageSpinner.center = CGPointZero;
        [self.pPreviewImage addSubview: self.pPreviewImageSpinner];
        
        self.pAvailableDivider = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)] autorelease];
        self.pAvailableDivider.backgroundColor = ExampleApp::Helpers::ColorPalette::UiBorderColor;
        [self.pLabelsContainer addSubview:self.pAvailableDivider];
        
        self.pAvailableButton = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 0, 0)] autorelease];
        [self.pAvailableButton setBackgroundImage:ExampleApp::Helpers::ImageHelpers::LoadImage(@"button_occupancy_available_off") forState:UIControlStateNormal];
        [self.pAvailableButton setBackgroundImage:ExampleApp::Helpers::ImageHelpers::LoadImage(@"button_occupancy_available_on") forState:UIControlStateSelected];
        [self.pLabelsContainer addSubview: self.pAvailableButton];
        
        self.pAvailableSoonButton = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 0, 0)] autorelease];
        [self.pAvailableSoonButton setBackgroundImage:ExampleApp::Helpers::ImageHelpers::LoadImage(@"button_occupancy_availablesoon_off") forState:UIControlStateNormal];
        [self.pAvailableSoonButton setBackgroundImage:ExampleApp::Helpers::ImageHelpers::LoadImage(@"button_occupancy_availablesoon_on") forState:UIControlStateSelected];
        [self.pLabelsContainer addSubview: self.pAvailableSoonButton];
        
        self.pOccupiedButton = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 0, 0)] autorelease];
        [self.pOccupiedButton setBackgroundImage:ExampleApp::Helpers::ImageHelpers::LoadImage(@"button_occupancy_occupied_off") forState:UIControlStateNormal];
        [self.pOccupiedButton setBackgroundImage:ExampleApp::Helpers::ImageHelpers::LoadImage(@"button_occupancy_occupied_on") forState:UIControlStateSelected];
        [self.pLabelsContainer addSubview: self.pOccupiedButton];
        
        self.pCategoriesHeaderContainer = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)] autorelease];
        self.pCategoriesHeaderContainer.backgroundColor = ExampleApp::Helpers::ColorPalette::UiBorderColor;
        [self.pLabelsContainer addSubview: self.pCategoriesHeaderContainer];
        
        self.pCategoriesHeaderLabel = [self createLabel :ExampleApp::Helpers::ColorPalette::UiTextHeaderColor :ExampleApp::Helpers::ColorPalette::UiBorderColor];
        [self.pCategoriesHeaderContainer addSubview: self.pCategoriesHeaderLabel];
        
        self.pCategoriesContent = [self createLabel :ExampleApp::Helpers::ColorPalette::UiTextCopyColor :ExampleApp::Helpers::ColorPalette::UiBackgroundColor];
        [self.pLabelsContainer addSubview: self.pCategoriesContent];
        
        [self setTouchExclusivity: self];
        
        self.alpha = 0.f;
    }
    
    return self;
}

- (void)dealloc
{
    [self.pCloseButton removeFromSuperview];
    [self.pCloseButton release];
    
    [self.pControlContainer removeFromSuperview];
    [self.pControlContainer release];
    
    [self.pHeadlineContainer removeFromSuperview];
    [self.pHeadlineContainer release];
    
    [self.pLabelsContainer removeFromSuperview];
    [self.pLabelsContainer release];
    
    [self.pContentContainer removeFromSuperview];
    [self.pContentContainer release];
    
    [self.pCategoryIconContainer removeFromSuperview];
    [self.pCategoryIconContainer release];
    
    [self.pTitleLabel removeFromSuperview];
    [self.pTitleLabel release];
    
    [self.pOccupiedButton removeFromSuperview];
    [self.pOccupiedButton release];
    
    [self.pAvailableSoonButton removeFromSuperview];
    [self.pAvailableSoonButton release];
    
    [self.pAvailableButton removeFromSuperview];
    [self.pAvailableButton release];
    
    [self.pAvailableDivider removeFromSuperview];
    [self.pAvailableDivider release];
    
    [self.pCategoriesHeaderContainer removeFromSuperview];
    [self.pCategoriesHeaderContainer release];
    
    [self.pCategoriesHeaderLabel removeFromSuperview];
    [self.pCategoriesHeaderLabel release];
    
    [self.pCategoriesContent removeFromSuperview];
    [self.pCategoriesContent release];
    
    [self.pPlaceholderImage release];
    
    [self.pPreviewImage removeFromSuperview];
    [self.pPreviewImage release];
    
    [self.pPreviewImageSpinner removeFromSuperview];
    [self.pPreviewImageSpinner release];
    
    [self.pImageDivider removeFromSuperview];
    [self.pImageDivider release];
    
    [m_pController release];
    [self removeFromSuperview];
    [super dealloc];
}

- (void) layoutSubviews
{
    UIViewController *viewController = [UIApplication sharedApplication].delegate.window.rootViewController;
    self.frame = [viewController largePopoverFrame];
    
    CGFloat mainWindowWidth = self.frame.size.width;
    CGFloat mainWindowHeight = self.frame.size.height;
    
    CGFloat sideMargin = 15.0;
    
    self.pControlContainer.frame = CGRectMake(0.f,
                                              0.f,
                                              mainWindowWidth,
                                              mainWindowHeight);
    
    const float headlineHeight = 60.f;
    const float closeButtonSectionHeight = 36.f;
    const float contentSectionHeight = mainWindowHeight - headlineHeight;
    const float contentSectionWidth = mainWindowWidth - (2 * sideMargin);
    
    self.pHeadlineContainer.frame = CGRectMake(0.f,
                                               0.f,
                                               mainWindowWidth,
                                               headlineHeight);
    
    self.pContentContainer.frame = CGRectMake(sideMargin,
                                              headlineHeight,
                                              contentSectionWidth,
                                              contentSectionHeight);
    
    const float labelsSectionOffsetX = 0.f;
    m_labelsSectionWidth = contentSectionWidth - (2.f * labelsSectionOffsetX);
    
    self.pLabelsContainer.frame = CGRectMake(labelsSectionOffsetX,
                                             0.f,
                                             m_labelsSectionWidth,
                                             contentSectionHeight);
    
    const float closeButtonMarginTop = 12.0f;
    self.pCloseButton.frame = CGRectMake(mainWindowWidth - closeButtonSectionHeight - sideMargin,
                                         closeButtonMarginTop,
                                         closeButtonSectionHeight,
                                         closeButtonSectionHeight);
    
    self.pCategoryIconContainer.frame = CGRectMake(0.f, 0.f, headlineHeight, headlineHeight);
    
    const float titlePadding = 10.0f;
    
    const float titleHeight = headlineHeight;
    
    self.pTitleLabel.frame = CGRectMake(headlineHeight + titlePadding,
                                        0,
                                        mainWindowWidth - (headlineHeight + titlePadding) - closeButtonSectionHeight - sideMargin,
                                        titleHeight);
    self.pTitleLabel.font = [UIFont systemFontOfSize:24.0f];
    
    m_imageWidth = contentSectionWidth;
    m_imageHeight = contentSectionWidth;
    
}

- (void) performDynamicContentLayout
{
    const float labelYSpacing = 8.f;
    const float buttonSpacing = 16.0f;
    const float buttonWidth = 192.0f;
    const float buttonHeight = 40.0f;
    const float buttonX = (m_labelsSectionWidth - buttonWidth) / 2.0f;
    const float dividerHeight = 1.0f;
    
    float currentContentY = 8.f;
    
    if(!m_meetingRoomModel.GetImageUrl().empty())
    {
        currentContentY = 0.f;
        const CGFloat imagePadding = 10.0f;
        
        self.pImageDivider.frame = CGRectMake(0,
                                              currentContentY,
                                              m_labelsSectionWidth,
                                              dividerHeight);
        self.pImageDivider.hidden = false;
        
        currentContentY += dividerHeight + imagePadding;
        
        self.pPreviewImage.frame = CGRectMake(0, currentContentY, m_imageWidth, m_imageHeight);
        [self.pPreviewImage setClipsToBounds:YES];
        self.pPreviewImageSpinner.center = [self.pPreviewImage convertPoint:self.pPreviewImage.center fromView:self.pPreviewImage.superview];
        currentContentY += (m_imageHeight + imagePadding);
        self.pPreviewImage.hidden = false;
    }
    
    if(!m_availability.empty())
    {
        self.pAvailableDivider.frame = CGRectMake(0,
                                                  currentContentY,
                                                  m_labelsSectionWidth,
                                                  dividerHeight);
        self.pAvailableDivider.hidden = false;
        currentContentY += dividerHeight + buttonSpacing;
        
        self.pAvailableButton.frame = CGRectMake(buttonX, currentContentY, buttonWidth, buttonHeight);
        self.pAvailableButton.hidden = false;
        self.pAvailableButton.selected = m_availability == ExampleApp::Search::Swallow::SearchConstants::MEETING_ROOM_AVAILABLE;
        self.pAvailableButton.enabled = self.pAvailableButton.selected;
        currentContentY += buttonSpacing + self.pAvailableButton.frame.size.height;
        
        self.pAvailableSoonButton.frame = CGRectMake(buttonX, currentContentY, buttonWidth, buttonHeight);
        self.pAvailableSoonButton.hidden = false;
        self.pAvailableSoonButton.selected = m_availability == ExampleApp::Search::Swallow::SearchConstants::MEETING_ROOM_AVAILABLE_SOON;
        self.pAvailableSoonButton.enabled = self.pAvailableSoonButton.selected;
        currentContentY += buttonSpacing + self.pAvailableSoonButton.frame.size.height;
        
        self.pOccupiedButton.frame = CGRectMake(buttonX, currentContentY, buttonWidth, buttonHeight);
        self.pOccupiedButton.hidden = false;
        self.pOccupiedButton.selected = m_availability == ExampleApp::Search::Swallow::SearchConstants::MEETING_ROOM_OCCUPIED;
        self.pOccupiedButton.enabled = self.pOccupiedButton.selected;
        currentContentY += labelYSpacing + self.pOccupiedButton.frame.size.height;
    }
    
    [self.pLabelsContainer setContentSize:CGSizeMake(m_labelsSectionWidth, currentContentY)];
}

- (void) setContent:(const ExampleApp::Search::SdkModel::SearchResultModel*)pModel
{
    Eegeo_ASSERT(pModel != NULL);
    
    m_model = *pModel;
    m_meetingRoomModel = ExampleApp::Search::Swallow::SdkModel::SearchParser::TransformToSwallowMeetingRoomResult(m_model);
    std::string availability = ExampleApp::Search::Swallow::SearchConstants::GetAvailabilityFromAvailabilityState(m_model.GetAvailability());
    
    NSString *state = [[NSUserDefaults standardUserDefaults]objectForKey:[NSString stringWithUTF8String:m_meetingRoomModel.GetName().c_str()]];
    if(state && state != NULL)
    {
        availability = std::string([state UTF8String]);
    }
    
    m_availability = availability;
    
    self.pTitleLabel.text = [NSString stringWithUTF8String:pModel->GetTitle().c_str()];
    
    [self.pCategoryIconContainer.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
    std::string tagIcon = ExampleApp::Helpers::IconResources::GetSmallIconForTag(pModel->GetIconKey());
    ExampleApp::Helpers::ImageHelpers::AddPngImageToParentView(self.pCategoryIconContainer, tagIcon, ExampleApp::Helpers::ImageHelpers::Centre);
    
    self.pAvailableDivider.hidden = true;
    self.pAvailableButton.hidden = true;
    self.pAvailableSoonButton.hidden = true;
    self.pOccupiedButton.hidden = true;
    self.pImageDivider.hidden = true;
    self.pPreviewImage.hidden = true;
    self.pCategoriesHeaderContainer.hidden = true;
    self.pCategoriesContent.hidden = true;
    
    [self performDynamicContentLayout];
    
    if(!m_meetingRoomModel.GetImageUrl().empty())
    {
        [self.pPreviewImage setImage:self.pPlaceholderImage];
        [self.pPreviewImageSpinner startAnimating];
    }
    
    [self.pLabelsContainer setContentOffset:CGPointMake(0,0) animated:NO];
}

- (void) updateImage:(const std::string&)url :(bool)success bytes:(const std::vector<Byte>*)bytes;
{
    if(url == m_meetingRoomModel.GetImageUrl())
    {
        [self.pPreviewImageSpinner stopAnimating];
        
        if(success)
        {
            NSData* imageData = [NSData dataWithBytes:&bytes->at(0) length:bytes->size()];
            UIImage* image = [UIImage imageWithData:imageData];
            [self.pPreviewImage setImage:image];
            
            [self.pPreviewImage.layer removeAllAnimations];
            self.pPreviewImage.hidden = false;
            
            [self performDynamicContentLayout];
        }
        else
        {
            
            [self performDynamicContentLayout];
        }
    }
}

- (void) setFullyActive
{
    [m_pController setView: self];
    if(self.alpha == 1.f)
    {
        return;
    }
    
    [self animateToAlpha:1.f];
}

- (void) setFullyInactive
{
    [m_pController setView: nil];
    if(self.alpha == 0.f)
    {
        return;
    }
    
    [self animateToAlpha:0.f];
}

- (void) setActiveStateToIntermediateValue:(float)openState
{
    self.alpha = openState;
}

- (ExampleApp::SearchResultPoi::View::SearchResultPoiViewInterop*)getInterop
{
    return m_pInterop;
}

- (BOOL)consumesTouch:(UITouch *)touch
{
    return self.alpha > 0.f;
}

- (void) animateToAlpha:(float)alpha
{
    [UIView animateWithDuration:m_stateChangeAnimationTimeSeconds
                     animations:^
     {
         self.alpha = alpha;
     }];
}

- (UILabel*) createLabel:(UIColor*)textColor :(UIColor*)backgroundColor
{
    UILabel* pLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)] autorelease];
    pLabel.textColor = textColor;
    pLabel.backgroundColor = backgroundColor;
    pLabel.textAlignment = NSTextAlignmentLeft;
    return pLabel;
}

- (void) handleClosedButtonSelected
{
    m_pInterop->HandleCloseClicked();
}

@end
