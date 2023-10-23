#include "flutter_window.h"

#include <optional>

#include "flutter/generated_plugin_registrant.h"
#include <iostream>
#include "flutter/method_channel.h"
#include "flutter/standard_method_codec.h"

FlutterWindow::FlutterWindow(const flutter::DartProject& project)
    : project_(project) {}

FlutterWindow::~FlutterWindow() {}

bool FlutterWindow::OnCreate() {
  if (!Win32Window::OnCreate()) {
    return false;
  }

  RECT frame = GetClientArea();

  // The size here must match the window dimensions to avoid unnecessary surface
  // creation / destruction in the startup path.
  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      frame.right - frame.left, frame.bottom - frame.top, project_);
  // Ensure that basic setup of the controller was successful.
  if (!flutter_controller_->engine() || !flutter_controller_->view()) {
    return false;
  }
  RegisterPlugins(flutter_controller_->engine());

  initMethodChannel(flutter_controller_->engine());//添加dart方法注册

  SetChildContent(flutter_controller_->view()->GetNativeWindow());

  return true;
}

void FlutterWindow::OnDestroy() {
  if (flutter_controller_) {
    flutter_controller_ = nullptr;
  }

  Win32Window::OnDestroy();
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept {
  // Give Flutter, including plugins, an opportunity to handle window messages.
  if (flutter_controller_) {
    std::optional<LRESULT> result =
        flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam,
                                                      lparam);
    if (result) {
      return *result;
    }
  }
  

  switch (message) {
    case WM_FONTCHANGE:
      flutter_controller_->engine()->ReloadSystemFonts();
      break;
  }
        
  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}


void FlutterWindow::initMethodChannel(flutter::FlutterEngine *flutter_instance){
  static const std::string CHANNEL_NAME = "dearim_channel";

  auto methodChannel = std::make_unique<flutter::MethodChannel<>>(flutter_instance->messenger() , CHANNEL_NAME , &flutter::StandardMethodCodec::GetInstance());

  methodChannel->SetMethodCallHandler([this](const flutter::MethodCall<flutter::EncodableValue>& call , std::unique_ptr<flutter::MethodResult<>> result){
    std::string method = call.method_name();
    std::cout << "method : " << method << std::endl;

    if(method == "onReceivedImmessage"){
      std::cout << "native recieived im message " << std::endl;
      onReceivedIMMessage();
      // FlashWindow(GetHandle() , true);      
    }
    
    return result->Success();
  });
}

void FlutterWindow::onReceivedIMMessage(){
  std::cout << "FlutterWindow recieived im message " << std::endl;
  FlashWindow(GetHandle() , true);  
}
