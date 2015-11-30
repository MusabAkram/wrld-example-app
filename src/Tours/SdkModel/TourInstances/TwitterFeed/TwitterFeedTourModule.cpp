// Copyright eeGeo Ltd (2012-2015), All Rights Reserved

#include "TwitterFeedTourModule.h"
#include "TwitterFeedTourObserver.h"
#include "LatLongAltitude.h"

namespace ExampleApp
{
    namespace Tours
    {
        namespace SdkModel
        {
            namespace TourInstances
            {
                namespace TwitterFeed
                {
                    TwitterFeedTourModule::TwitterFeedTourModule(Camera::IToursCameraTransitionController& toursCameraTransitionController,
                                                                 Camera::IToursCameraController& toursCameraController,
                                                                 ITourService& tourService,
                                                                 WorldPins::SdkModel::IWorldPinsService& worldPinsService,
                                                                 Eegeo::Resources::Interiors::InteriorController& interiorController,
                                                                 InteriorsExplorer::SdkModel::InteriorVisibilityUpdater& interiorVisibilityUpdater,
                                                                 const Eegeo::Resources::Interiors::InteriorSelectionModel& interiorSelectionModel,
                                                                 ITourRepository& tourRepository,
                                                                 Social::TwitterFeed::ITwitterFeedService& twitterFeedService,
                                                                 Metrics::IMetricsService& metricsService,
                                                                 ExampleAppMessaging::TMessageBus& messageBus)
                    {
                        
                        m_tweetStateDataMap["Dev4Recce"] = TweetStateData(Eegeo::Space::LatLongAltitude::FromDegrees(37.619988, -122.366472, 600).ToECEF(),
                                                                          Eegeo::Space::LatLongAltitude::FromDegrees(37.617398, -122.376256, 20).ToECEF());
                        m_pTwitterFeedTourObserver = Eegeo_NEW(TwitterFeedTourObserver)(toursCameraTransitionController,
                                                                                        toursCameraController,
                                                                                        tourService,
                                                                                        worldPinsService,
                                                                                        interiorController,
                                                                                        interiorVisibilityUpdater,
                                                                                        interiorSelectionModel,
                                                                                        tourRepository,
                                                                                        twitterFeedService,
                                                                                        m_tweetStateDataMap,
                                                                                        metricsService,
                                                                                        messageBus);
                    }
                    
                    TwitterFeedTourModule::~TwitterFeedTourModule()
                    {
                        Eegeo_DELETE m_pTwitterFeedTourObserver;
                        
                        m_tweetStateDataMap.clear();
                    }
                    
                    const std::map<std::string, TweetStateData>& TwitterFeedTourModule::GetTweetStateDataMap() const
                    {
                        return m_tweetStateDataMap;
                    }
                }
            }
        }
    }
}