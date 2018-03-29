// Copyright eeGeo Ltd (2012-2015), All Rights Reserved

#include "NavRoutingServiceController.h"

#include "IRoutingWebservice.h"
#include "RoutingQueryResponse.h"

namespace ExampleApp
{
    namespace NavRouting
    {
        namespace SdkModel
        {
            NavRoutingServiceController::NavRoutingServiceController(Eegeo::Routes::Webservice::IRoutingWebservice& routingWebservice)
            : m_routingWebservice(routingWebservice)
            , m_routingQueryCompleted(this, &NavRoutingServiceController::OnRoutingQueryCompleted)
            {
                m_routingQueryId = 0;
                
                m_routingWebservice.RegisterQueryCompletedCallback(m_routingQueryCompleted);
            }

            NavRoutingServiceController::~NavRoutingServiceController()
            {
                m_routingWebservice.UnregisterQueryCompletedCallback(m_routingQueryCompleted);
            }
            
            void NavRoutingServiceController::MakeRoutingQuery(const Eegeo::Routes::Webservice::RoutingQueryOptions& options)
            {
                if (m_routingQueryId!=0)
                {
                    m_routingWebservice.CancelQuery(m_routingQueryId);
                }
                
                m_routingQueryId = m_routingWebservice.BeginRoutingQuery(options);
            }
            
            void NavRoutingServiceController::OnRoutingQueryCompleted(const Eegeo::Routes::Webservice::RoutingQueryResponse& results)
            {
                if (results.Id == m_routingQueryId)
                {
                    if (results.Succeeded && results.Results.size()>0)
                    {
                        m_routingQueryCompletedCallbacks.ExecuteCallbacks(results.Results);
                    }
                    
                    m_routingQueryId = 0;
                }
            }
            
            void NavRoutingServiceController::RegisterQueryCompletedCallback(RoutesReceivedCallback& callback)
            {
                m_routingQueryCompletedCallbacks.AddCallback(callback);
            }
            
            void NavRoutingServiceController::UnregisterQueryCompletedCallback(RoutesReceivedCallback& callback)
            {
                m_routingQueryCompletedCallbacks.RemoveCallback(callback);
            }
        }
    }
}
