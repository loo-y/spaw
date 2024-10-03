## sPaw (iOS App)

**简单推送 Webhook (sPaw) - iOS 客户端**

此仓库包含 sPaw 的 iOS 客户端，sPaw 是一个简单的系统，用于通过自托管服务器向您的 iOS 设备发送推送通知。服务器公开了一个 API 端点，可以被任何 webhook 或服务触发，从而允许您接收来自几乎任何来源的推送通知。

**功能：**

* 接收从 sPaw 服务器发送的推送通知。
* 可配置的服务器地址。
* 安全地存储和管理设备的 APNs 令牌。
* 干净简洁的 SwiftUI 界面。

**要求：**

* Xcode 14 或更高版本
* iOS 15 或更高版本
* 一个 sPaw 服务器实例 (参见 [sPaw-server](https://github.com/loo-y/spaw-server))

**安装：**

1. 克隆此仓库：`git clone https://github.com/loo-y/spaw.git`
2. 在 Xcode 中打开项目。
3. 在应用程序的设置中配置您的服务器地址。
4. 在您的 iOS 设备上构建并运行应用程序。

**使用：**

1. 启动应用程序后，它会注册推送通知并获取 APNs 令牌。
2. 需要将此令牌传达给将触发 sPaw 服务器的服务。应用程序将显示令牌以便于复制。
3. 将您的 webhook 或服务配置为将消息文本和 APNs 令牌发送到 sPaw 服务器的 `/pushmessage` 端点。
4. 然后，服务器将通过 APNs 将消息转发到您的设备。

**配置：**

可以在应用程序的设置中配置服务器地址。

