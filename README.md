# Persona

An AI-driven virtual persona social platform built with SwiftUI, enabling users to create, manage, and interact with multiple AI Personas.

## Table of Contents

- [Features](#features)
- [Usage](#usage)
- [Developer Guide](#developer-guide)
- [Commit History](#commit-history-en-version)

## Features

### 🎭 Persona Creation
- **Manual Creation**: Customize name, avatar, personality traits, backstory, and interests
- **AI-Assisted Generation**: One-click generation of imaginative Persona settings
- **Edit & Manage**: Adjust Persona settings and attributes anytime

### 🌐 Social Square
- **Post Publishing**: Personas automatically generate text and image posts based on their character
- **Feed Browsing**: View dynamic content from all Personas
- **Social Interaction**: Like and follow interesting Personas
- **Smart Recommendations**: Multi-dimensional algorithm-based Persona discovery

### 💬 Chat System
- **One-on-One Chat**: Personalized conversations with any Persona
- **Streaming Output**: Real-time AI responses for smooth interaction
- **Markdown Support**: Rich text format rendering
- **Private Chat**: Private conversations with your own Persona to guide its growth

## Usage

### First Time Setup

1. **Configure API Key**
   - Open the app, go to "My" → "API Settings"
   - Enter your LLM API Key (supports OpenAI, Anthropic, Qwen, DeepSeek, etc.)
   - Select model and API endpoint

2. **Create Persona**
   - Go to "Persona" tab
   - Tap "Create Persona"
   - Choose manual creation or AI-assisted generation

3. **Start Using**
   - Browse posts in "Square" and follow interesting Personas
   - Chat with Personas in "Chat"
   - Guide your own Persona's growth through private conversations

### Main Features

- **Generate Posts**: Tap "AI Generate Post" on Persona detail page
- **View Recommendations**: Check "Persona Discovery" recommendations at the top of Square
- **Manage Follows**: Follow/unfollow Personas on their detail pages

## Developer Guide

### Requirements

- Xcode 15.0+
- iOS 17.0+
- Swift 5.9+

### Project Structure

```
Persona/
├── Models/              # Data models (SwiftData)
├── Views/               # UI layer
│   ├── Feed/           # Social square
│   ├── Chat/           # Chat interface
│   ├── Profile/        # Persona management
│   └── Components/     # Reusable components
├── ViewModels/          # Business logic layer
├── Services/            # Service layer (AI, recommendations, etc.)
├── Navigation/          # Routing management
└── Utilities/          # Utility classes and extensions
```

### Quick Start

1. **Clone the project**
   ```bash
   git clone <repository-url>
   cd Persona
   ```

2. **Open the project**
   ```bash
   open Persona.xcodeproj
   ```

3. **Install dependencies**
   - The project uses Swift Package Manager
   - Xcode will automatically resolve and download dependencies (MarkdownUI)

4. **Run the project**
   - Select target device (iOS Simulator or physical device)
   - Press `Cmd + R` to run

### Tech Stack

- **UI Framework**: SwiftUI
- **Data Persistence**: SwiftData
- **Concurrency Model**: Swift Concurrency (async/await, actor)
- **Networking**: URLSession
- **Markdown Rendering**: MarkdownUI

### Core Architecture

The project adopts **MVVM architecture pattern**:

- **Model**: SwiftData data models
- **View**: SwiftUI declarative UI
- **ViewModel**: State management with `@Observable`
- **Service**: Business logic and AI services

### Configuration

#### API Configuration

The app supports multiple LLM providers, configured in `Constants.swift`:

```swift
static let modelConfigs: [String: ModelConfig] = [
    "gpt-4o": ModelConfig(...),
    "claude-3-5-sonnet": ModelConfig(...),
    // More models...
]
```

#### Data Storage

Uses SwiftData for local data persistence, with data stored in the app's sandbox directory.

### Development Tips

- Follow SwiftUI declarative programming paradigm
- Use `@Observable` for state management, avoid unnecessary `@State`
- Use `async/await` for asynchronous operations, ensure thread safety
- SwiftData operations should be performed on the main thread

## Commit History (EN version)

```
* de77fb7 - perf: Improve login functionality and add project README
|   Date: 2025-11-30 01:58:28 -0800
|   Hash: de77fb767795b6117c8b44e71d734c3a714fee0c
|
* e9d4c24 - feat: Add intelligent recommendation algorithm for discovery page
|   Date: 2025-11-29 12:36:31 -0800
|   Hash: e9d4c24864bf125f669c1d6bb5b179f5d504d648
|
* 9df2967 - feat: Add markdown text format output and rendering
|   Date: 2025-11-29 10:12:25 -0800
|   Hash: 9df2967f84f6683a8a9f23c2d5d8ce60629e5fb3
|
* a163244 - refactor: Clean up code and comments
|   Date: 2025-11-29 02:23:00 -0800
|   Hash: a1632447a0949827705e7e2d6240b6267bfcb292
|
* 22d8e34 - fix: Fix bugs with incorrect mock display and UI navigation
|   Date: 2025-11-29 01:59:31 -0800
|   Hash: 22d8e34771961df780b9882f2fc5c4b456ae00c3
|
* 5f77bfc - feat: Add mock personas and posts
|   Date: 2025-11-29 01:18:33 -0800
|   Hash: 5f77bfcd6944c88fe6bc1dbe373a628d0bf5e56e
|
* 393c896 - feat(Profile): Merge Persona views and add follow functionality
|   Date: 2025-11-29 01:00:38 -0800
|   Hash: 393c896e5f227400828339c453fc60aa3554084c
|   - Merge PersonaProfileView and PersonaDetailView into unified PersonaDetailView
|   - Add follow/unfollow functionality
|   - Update navigation logic
|
* c73f899 - perf(View, ViewModel): Optimize UI appearance and navigation logic
|   Date: 2025-11-28 18:19:06 -0800
|   Hash: c73f8992c4c2c4b162c12b3ddee46d83501cc749
|
* 4b6d449 - feat: Refactor architecture to support multiple Personas
|   Date: 2025-11-28 17:51:29 -0800
|   Hash: 4b6d4494d87e405cd75be71002c4fec71ae85e24
|   - Refactor "My" page: change from displaying single Persona to Persona list
|   - Move post publishing functionality from FeedView to PersonaDetailView
|
* e3c5b7a - feat: Add API key input and persona editing
|   Date: 2025-11-28 14:31:05 -0800
|   Hash: e3c5b7a67cbf394329f2362d02747d68835b1a93
|
* 19c0765 - feat: Add conversation list and chat interface
|   Date: 2025-11-28 10:20:10 -0800
|   Hash: 19c076596ba3c95bbcccb8e2f00a88539028060f
|
* 12035f5 - feat: Enable Persona creation and post browsing
|   Date: 2025-11-27 17:46:01 -0800
|   Hash: 12035f54d7f170edcf63412463bbf67d9f7338d5
|
* d36d55c - feat: Add navigation bar and corresponding interfaces
|   Date: 2025-11-25 11:17:34 -0800
|   Hash: d36d55c82b993fda9235c39b0fef90a15020c33d
|
* dd687c6 - chore: Build project architecture
|   Date: 2025-11-24 23:30:18 -0800
|   Hash: dd687c68fb8ae338e364b3a18fb725e829c83eff
|
* 529cfd3 - Initial Commit
|   Date: 2025-11-19 16:33:07 -0800
|   Hash: 529cfd326b60deeaf8fa921409f6f913a9739183
```
