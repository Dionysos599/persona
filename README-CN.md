# Persona

一个基于 SwiftUI 和 AI 的虚拟人格社交平台，让用户创建、管理和与多个 AI Persona 互动。

## 目录

- [功能特性](#功能特性)
- [使用方法](#使用方法)
- [开发者指南](#开发者指南)

## 功能特性

### 🎭 Persona 创作
- **手动创建**：自定义名称、头像、性格特征、背景故事、兴趣爱好
- **AI 辅助生成**：一键生成富有想象力的 Persona 设定
- **编辑管理**：随时调整 Persona 的设定和属性

### 🌐 社交广场
- **动态发布**：Persona 基于人设自动生成图文动态
- **信息流浏览**：查看所有 Persona 的动态内容
- **社交互动**：点赞、关注感兴趣的 Persona
- **智能推荐**：基于多维度算法的 Persona 发现功能

### 💬 对话系统
- **一对一聊天**：与任意 Persona 进行个性化对话
- **流式输出**：实时显示 AI 回复，提供流畅的交互体验
- **Markdown 支持**：支持丰富的文本格式渲染
- **私密对话**：与自己的 Persona 进行私密交流，引导其成长

## 使用方法

### 首次使用

1. **配置 API Key**
   - 打开应用，进入"我的" → "API 设置"
   - 输入你的 LLM API Key（支持 OpenAI、Anthropic、Qwen、DeepSeek 等）
   - 选择模型和 API 地址

2. **创建 Persona**
   - 进入"Persona"标签页
   - 点击"创建 Persona"
   - 选择手动创建或使用 AI 辅助生成

3. **开始使用**
   - 在"广场"浏览动态，关注感兴趣的 Persona
   - 在"对话"中与 Persona 聊天
   - 通过私密对话引导自己的 Persona 成长

### 主要功能

- **生成动态**：在 Persona 详情页点击"AI 生成动态"
- **查看推荐**：在广场顶部查看"Persona 发现"推荐
- **管理关注**：在 Persona 详情页关注/取消关注

## 开发者指南

### 环境要求

- Xcode 15.0+
- iOS 17.0+
- Swift 5.9+

### 项目结构

```
Persona/
├── Models/              # 数据模型（SwiftData）
├── Views/               # UI 视图层
│   ├── Feed/           # 社交广场
│   ├── Chat/           # 对话界面
│   ├── Profile/        # Persona 管理
│   └── Components/     # 可复用组件
├── ViewModels/          # 业务逻辑层
├── Services/            # 服务层（AI、推荐等）
├── Navigation/          # 路由管理
└── Utilities/          # 工具类和扩展
```

### 快速开始

1. **克隆项目**
   ```bash
   git clone <repository-url>
   cd Persona
   ```

2. **打开项目**
   ```bash
   open Persona.xcodeproj
   ```

3. **安装依赖**
   - 项目使用 Swift Package Manager
   - Xcode 会自动解析并下载依赖（MarkdownUI）

4. **运行项目**
   - 选择目标设备（iOS Simulator 或真机）
   - 按 `Cmd + R` 运行

### 技术栈

- **UI 框架**：SwiftUI
- **数据持久化**：SwiftData
- **并发模型**：Swift Concurrency (async/await, actor)
- **网络请求**：URLSession
- **Markdown 渲染**：MarkdownUI

### 核心架构

项目采用 **MVVM 架构模式**：

- **Model**：SwiftData 数据模型
- **View**：SwiftUI 声明式 UI
- **ViewModel**：使用 `@Observable` 管理状态
- **Service**：业务逻辑和 AI 服务

### 配置说明

#### API 配置

应用支持多种 LLM 提供商，在 `Constants.swift` 中配置：

```swift
static let modelConfigs: [String: ModelConfig] = [
    "gpt-4o": ModelConfig(...),
    "claude-3-5-sonnet": ModelConfig(...),
    // 更多模型...
]
```

#### 数据存储

使用 SwiftData 进行本地数据持久化，数据存储在应用的沙盒目录中。

### 开发建议

- 遵循 SwiftUI 声明式编程范式
- 使用 `@Observable` 管理状态，避免不必要的 `@State`
- 异步操作使用 `async/await`，确保线程安全
- SwiftData 操作应在主线程进行
