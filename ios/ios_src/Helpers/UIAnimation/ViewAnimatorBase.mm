// Copyright eeGeo Ltd (2012-2015), All Rights Reserved

#include "ViewAnimatorBase.h"

#include "Types.h"

namespace ExampleApp
{
    namespace Helpers
    {
        namespace UIAnimation
        {
            ViewAnimatorBase::ViewAnimatorBase(UIView* view,
                                               double animationPeriodSeconds,
                                               double startDelaySeconds)
            : m_isActive(false)
            , m_isPlayingForward(true)
            , m_view(view)
            , m_animationPeriodSeconds(animationPeriodSeconds)
            , m_startDelaySeconds(startDelaySeconds)
            {
                Eegeo_ASSERT(m_view != NULL, "Can't initialise ViewAnimator with NULL view");
            }
            
            ViewAnimatorBase::~ViewAnimatorBase()
            {
                
            }
            
            void ViewAnimatorBase::Play(bool isPlayingForward, bool playFromCurrent)
            {
                m_isPlayingForward = isPlayingForward;
                m_isActive = true;
                
                OnPlay(playFromCurrent);
            }
            
            void ViewAnimatorBase::Update(double timerSeconds)
            {
                timerSeconds = fmin(timerSeconds, m_animationPeriodSeconds + m_startDelaySeconds);
                
                if(timerSeconds < m_startDelaySeconds)
                {
                    timerSeconds = m_startDelaySeconds;
                }
                
                OnUpdate(timerSeconds - m_startDelaySeconds);
                
                if(m_isPlayingForward && timerSeconds == m_animationPeriodSeconds + m_startDelaySeconds)
                {
                    m_isActive = false;
                }
                else if(!m_isPlayingForward && timerSeconds == m_startDelaySeconds)
                {
                    m_isActive = false;
                }
            }
            
            bool ViewAnimatorBase::IsActive() const
            {
                return m_isActive;
            }
            
            double ViewAnimatorBase::DurationSeconds() const
            {
                return m_animationPeriodSeconds + m_startDelaySeconds;
            }
            
            UIView* ViewAnimatorBase::GetView() const
            {
                return m_view;
            }
        }
    }
}
