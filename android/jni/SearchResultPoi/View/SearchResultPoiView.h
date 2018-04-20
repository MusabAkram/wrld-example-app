// Copyright eeGeo Ltd (2012-2015), All Rights Reserved

#pragma once

#include <string>
#include <SearchTags.h>
#include "Types.h"
#include "ISearchResultPoiView.h"
#include "AndroidNativeState.h"
#include "CallbackCollection.h"


namespace ExampleApp
{
    namespace SearchResultPoi
    {
        namespace View
        {
            class SearchResultPoiView : public ISearchResultPoiView, Eegeo::NonCopyable
            {
            private:
                AndroidNativeState& m_nativeState;
                Eegeo::Helpers::CallbackCollection0 m_closedCallbacks;
                Eegeo::Helpers::CallbackCollection1<Search::SdkModel::SearchResultModel> m_togglePinClickedCallbacks;
                Eegeo::Helpers::CallbackCollection2<const Search::SdkModel::SearchResultModel&, const std::string&> m_availabilityChangedCallbacks;

                jclass m_uiViewClass;
                jobject m_uiView;
                Search::SdkModel::SearchResultModel m_model;

            public:
                SearchResultPoiView(AndroidNativeState& nativeState, const ExampleApp::Search::SdkModel::SearchTags& swallowSearchTags);

                ~SearchResultPoiView();

                void Show(const Search::SdkModel::SearchResultModel& model, bool isPinned);

                void Hide();

                void UpdateImage(const std::string& url, bool hasImage, const std::vector<Byte>* pImageBytes);

                void InsertAvailabilityChangedCallback(Eegeo::Helpers::ICallback2<const Search::SdkModel::SearchResultModel&, const std::string&>& callback);

                void RemoveAvailabilityChangedCallback(Eegeo::Helpers::ICallback2<const Search::SdkModel::SearchResultModel&, const std::string&>& callback);

                void InsertClosedCallback(Eegeo::Helpers::ICallback0& callback);

                void RemoveClosedCallback(Eegeo::Helpers::ICallback0& callback);

                void HandleCloseClicked();

                void InsertTogglePinnedCallback(Eegeo::Helpers::ICallback1<Search::SdkModel::SearchResultModel>& callback);

                void RemoveTogglePinnedCallback(Eegeo::Helpers::ICallback1<Search::SdkModel::SearchResultModel>& callback);

                void HandlePinToggleClicked();

                void HandleAvailabilityChanged(std::string& availability);

            private:
                void CreateAndShowYelpPoiView(const Search::SdkModel::SearchResultModel& model);

                void CreateAndShowGeoNamesPoiView(const Search::SdkModel::SearchResultModel& model);

                void CreateAndShowEegeoPoiView(const Search::SdkModel::SearchResultModel& model);
                void CreateAndShowPersonSearchResultPoiView(const Search::SdkModel::SearchResultModel& model);

				void CreateAndShowMeetingRoomSearchResultPoiView(const Search::SdkModel::SearchResultModel& model);

				void CreateAndShowWorkingGroupSearchResultPoiView(const Search::SdkModel::SearchResultModel& model);

				void CreateAndShowFacilitySearchResultPoiView(const Search::SdkModel::SearchResultModel& model);

				void CreateAndShowDepartmentSearchResultPoiView(const Search::SdkModel::SearchResultModel& model);

                jclass CreateJavaClass(const std::string& viewClass);

                jobject CreateJavaObject(jclass uiViewClass);

                jobjectArray CreateJavaArray(const std::vector<std::string>& stringVector);
            };
        }
    }
}
