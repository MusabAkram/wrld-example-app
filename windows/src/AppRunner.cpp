// Copyright eeGeo Ltd (2012-2015), All Rights Reserved

#include "AppRunner.h"
#include "Graphics.h"
#include "WindowsThreadHelper.h"
#include "WindowsAppThreadAssertionMacros.h"
#include "ImagePathHelpers.h"
#include "WindowsImagePathHelpers.h"
#include "MouseInputEvent.h"
#include "GLHelpers.h"

using namespace Eegeo::Helpers::GLHelpers;

AppRunner::AppRunner
(
    WindowsNativeState* pNativeState
)
    : m_pNativeState(pNativeState)
    , m_pAppHost(NULL)
    , m_updatingNative(true)
    , m_isPaused(false)
    , m_appRunning(true)
{
    ASSERT_NATIVE_THREAD

    Eegeo::Helpers::ThreadHelpers::SetThisThreadAsMainThread();
}

AppRunner::~AppRunner()
{
    ASSERT_NATIVE_THREAD

    bool destroyEGL = true;
    
    {
        LockGL contextLock;
        m_displayService.ReleaseDisplay(destroyEGL);
    }
    

    if(m_pAppHost != NULL)
    {
        Eegeo_DELETE(m_pAppHost);
    }
}

void AppRunner::CreateAppHost()
{
    ASSERT_NATIVE_THREAD

    if(m_pAppHost == NULL && m_displayService.IsDisplayAvailable())
    {
        ExampleApp::Helpers::ImageHelpers::SetDeviceDensity(160);
        const Eegeo::Rendering::ScreenProperties& screenProperties = Eegeo::Rendering::ScreenProperties::Make(
                    static_cast<float>(m_displayService.GetDisplayWidth()),
                    static_cast<float>(m_displayService.GetDisplayHeight()),
                    ExampleApp::Helpers::ImageHelpers::GetPixelScale(),
                    m_pNativeState->deviceDpi);
        m_pAppHost = Eegeo_NEW(AppHost)
                     (
                         *m_pNativeState,
                         screenProperties,
                         m_displayService.GetDisplay(),
                         m_displayService.GetSharedSurface(),
                         m_displayService.GetResourceBuildSharedContext()
                     );
    }
}

void AppRunner::Pause()
{
    ASSERT_NATIVE_THREAD

    if(m_pAppHost != NULL && !m_isPaused)
    {
        m_pAppHost->OnPause();
        m_isPaused = true;
    }

    ReleaseDisplay();
}

void AppRunner::Resume()
{
    ASSERT_NATIVE_THREAD

    if(m_pAppHost != NULL && m_isPaused)
    {
        m_pAppHost->OnResume();
    }

    m_isPaused = false;
}

bool AppRunner::ActivateSurface()
{
    ASSERT_NATIVE_THREAD

    Pause();
    bool displayBound = TryBindDisplay();
    Eegeo_ASSERT(displayBound, "Failed to bind display");
    CreateAppHost();
    Resume();

    return displayBound;
}

void AppRunner::HandleMouseEvent(const Eegeo::Windows::Input::MouseInputEvent& event)
{
    ASSERT_NATIVE_THREAD

    if (m_pAppHost != NULL)
    {
        m_pAppHost->HandleMouseInputEvent(event);
    }
}


void AppRunner::HandleKeyboardDownEvent(char keyCode)
{
    if (m_pAppHost)
    {
        Eegeo::Windows::Input::KeyboardInputEvent keyEvent;

        keyEvent.keyCode = keyCode;
        keyEvent.keyDownEvent = true;

        m_pAppHost->HandleKeyboardInputEvent(keyEvent);
    }
}

void AppRunner::HandleKeyboardUpEvent(char keyCode)
{
    if (m_pAppHost)
    {
        Eegeo::Windows::Input::KeyboardInputEvent keyEvent;

        keyEvent.keyCode = keyCode;
        keyEvent.keyDownEvent = false;

        m_pAppHost->HandleKeyboardInputEvent(keyEvent);
    }
}

void AppRunner::ActivateSharedSurface()
{
    if (m_pAppHost != NULL)
    {
        LockGL contextLock;
        
        m_pAppHost->SetSharedSurface(m_displayService.GetSharedSurface());
        const Eegeo::Rendering::ScreenProperties& screenProperties = Eegeo::Rendering::ScreenProperties::Make(
            static_cast<float>(m_displayService.GetDisplayWidth()),
            static_cast<float>(m_displayService.GetDisplayHeight()),
            1.f,
            m_pNativeState->deviceDpi);
        m_pAppHost->NotifyScreenPropertiesChanged(screenProperties);
        m_pAppHost->SetViewportOffset(0, 0);
    }
}

bool AppRunner::IsRunning()
{
    return m_appRunning;
}

void AppRunner::Exit()
{
    m_appRunning = false;
}

void AppRunner::SetAllInputEventsToPointerUp(int x, int y)
{
    if (m_pAppHost)
    {
        m_pAppHost->SetAllInputEventsToPointerUp(x, y);
    }
}

void AppRunner::ReleaseDisplay()
{
    ASSERT_NATIVE_THREAD

    LockGL contextLock;

    if(m_displayService.IsDisplayAvailable())
    {
        const bool teardownEGL = false;
        m_displayService.ReleaseDisplay(teardownEGL);
    }

}

bool AppRunner::TryBindDisplay()
{
    ASSERT_NATIVE_THREAD

    LockGL contextLock;

    if(m_displayService.TryBindDisplay(*m_pNativeState))
    {
        if(m_pAppHost != NULL)
        {
            m_pAppHost->SetSharedSurface(m_displayService.GetSharedSurface());
            const Eegeo::Rendering::ScreenProperties& screenProperties = Eegeo::Rendering::ScreenProperties::Make(
                        static_cast<float>(m_displayService.GetDisplayWidth()),
                        static_cast<float>(m_displayService.GetDisplayHeight()),
                        ExampleApp::Helpers::ImageHelpers::GetPixelScale(),
                        m_pNativeState->deviceDpi);
            m_pAppHost->NotifyScreenPropertiesChanged(screenProperties);
            m_pAppHost->SetViewportOffset(0, 0);
        }
        return true;
    }
    return false;
}

void AppRunner::UpdateNative(float deltaSeconds)
{
    ASSERT_NATIVE_THREAD

    if(m_updatingNative && m_pAppHost != NULL && m_displayService.IsDisplayAvailable())
    {
        
        m_pAppHost->Update(deltaSeconds);

        LockGL contextLock;

        if (m_pNativeState->requiresPBuffer)
        { 
            glFinish();
        }

        if (!m_pNativeState->requiresPBuffer)
        {
            Eegeo_GL(eglSwapBuffers(m_displayService.GetDisplay(), m_displayService.GetSurface()));
        }
        
        Eegeo::Helpers::GLHelpers::ClearBuffers();

        m_pAppHost->Draw(deltaSeconds);
    }
}

void AppRunner::UpdateUiViews(float deltaSeconds)
{
    ASSERT_UI_THREAD

    LockGL contextLock;

    if(m_pAppHost != NULL)
    {
        m_pAppHost->UpdateUiViewsFromUiThread(deltaSeconds);
    }
}

void AppRunner::StopUpdatingNativeBeforeTeardown()
{
    ASSERT_NATIVE_THREAD

    Eegeo_ASSERT(m_updatingNative, "Should only call StopUpdatingNativeBeforeTeardown once, before teardown.\n");
    m_updatingNative = false;
}

void AppRunner::DestroyApplicationUi()
{
    ASSERT_UI_THREAD

    if(m_pAppHost != NULL)
    {
        m_pAppHost->DestroyUiFromUiThread();
    }
}

void AppRunner::RespondToResize()
{
    if (m_displayService.IsDisplayAvailable())
    {
        m_displayService.ReleaseMainRenderSurface();
    }

    if (!m_isPaused)
    {
        TryBindDisplay();
    }

}

void AppRunner::RespondToSize(int width, int height)
{
    LockGL contextLock;

    m_pNativeState->screenWidth = width;
    m_pNativeState->screenHeight = height;
    
    if (m_displayService.IsDisplayAvailable())
    {
        m_displayService.ReleaseMainRenderSurface();
    }

    if (!m_isPaused)
    {
        TryBindDisplay();
    }
}

void* AppRunner::GetMainRenderSurfaceSharePointer()
{
    return m_displayService.GetMainRenderSurfaceSharePointer();
}
