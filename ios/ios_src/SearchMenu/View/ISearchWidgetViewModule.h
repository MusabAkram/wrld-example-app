#pragma once

#include "SearchWidgetView.h"
#include "SearchWidgetController.h"
#include "SearchWidgetContainerView.h"
#include "ISearchResultsRepository.h"
namespace ExampleApp
{
    namespace SearchMenu
    {
        namespace View
        {
            class ISearchWidgetViewModule
            {
            public:
                virtual ~ISearchWidgetViewModule() { }
                
                virtual SearchWidgetContainerView& GetSearchWidgetView() const = 0;
                
                virtual SearchWidgetController& GetSearchWidgetController() const = 0;
                
                virtual ISearchResultsRepository& GetSuggestionsRepository() const = 0;
            };
        }
    }
}

