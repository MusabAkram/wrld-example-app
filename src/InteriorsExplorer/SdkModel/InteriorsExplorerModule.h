// Copyright eeGeo Ltd (2012-2015), All Rights Reserved

#pragma once

#include "InteriorsExplorer.h"
#include "Interiors.h"
#include "Types.h"
#include "IInteriorsExplorerModule.h"
#include "ScreenControlViewModelIncludes.h"
#include "IIdentity.h"
#include "BidirectionalBus.h"
#include "MapMode.h"
#include "GlobeCamera.h"

namespace ExampleApp
{
    namespace InteriorsExplorer
    {
        namespace SdkModel
        {
            class InteriorsExplorerModule : public IInteriorsExplorerModule, private Eegeo::NonCopyable
            {
            public:
                InteriorsExplorerModule(Eegeo::Resources::Interiors::InteriorsController& interiorsController,
                                        Eegeo::Resources::Interiors::Camera::InteriorsCameraController& interiorsCameraController,
                                        Eegeo::Resources::Interiors::InteriorSelectionModel& interiorSelectionModel,
                                        Eegeo::Camera::GlobeCamera::GpsGlobeCameraController& globeCameraController,
                                        Eegeo::Helpers::IIdentityProvider& identityProvider,
                                        MapMode::SdkModel::IMapModeModel& mapModeModel,
                                        ExampleAppMessaging::TMessageBus& messageBus);
                ~InteriorsExplorerModule();
                
                View::InteriorsExplorerViewModel& GetInteriorsExplorerViewModel() const;
                
                ScreenControl::View::IScreenControlViewModel& GetScreenControlViewModel() const;
                
            private:
                
                InteriorsExplorerModel* m_pModel;
                View::InteriorsExplorerViewModel* m_pViewModel;
                InteriorsControllerExitObserver* m_pInteriorsControllerExitObserver;
            };
        }
    }
}