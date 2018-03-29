// Copyright eeGeo Ltd (2012-2015), All Rights Reserved

#pragma once

#include "Types.h"
#include "Routes.h"
#include "RouteService.h"
#include "RouteData.h"
#include "IdentityRouteThicknessPolicy.h"

namespace ExampleApp
{
    namespace NavRouting
    {
        namespace SdkModel
        {
            class NavRouteDrawingController : private Eegeo::NonCopyable
            {
            public:
                NavRouteDrawingController(Eegeo::Routes::RouteService& routeService);

                ~NavRouteDrawingController();
                
                void DrawRoute(const Eegeo::Routes::Webservice::RouteData& routeData);
                
                void ClearRoute();
                
                void SetCurrentStep(int stepIndex);
                
            private:
                Eegeo::Routes::RouteService& m_routeService;
                Eegeo::Routes::Route* m_pRoute;
                Eegeo::Routes::Style::Thickness::IdentityRouteThicknessPolicy m_routeThicknessPolicy;
            };
        }
    }
}
