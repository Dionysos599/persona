import SwiftUI

struct APISettingsView: View {
    @AppStorage(Constants.StorageKeys.apiKey) private var apiKey: String = ""
    @AppStorage(Constants.StorageKeys.apiBaseURL) private var apiBaseURL: String = Constants.API.defaultBaseURL
    @AppStorage(Constants.StorageKeys.apiModel) private var apiModel: String = Constants.API.defaultModel
    
    @State private var showAPIKey: Bool = false
    @State private var showSaveAlert: Bool = false
    @State private var errorMessage: String?
    @State private var isBaseURLManuallyEdited: Bool = false
    
    var body: some View {
        Form {
            Section {
                HStack {
                    Text("API Key")
                    Spacer()
                    if showAPIKey {
                        Text(apiKey.isEmpty ? "未设置" : apiKey)
                            .foregroundStyle(.secondary)
                            .font(.caption)
                            .lineLimit(1)
                    } else {
                        Text(apiKey.isEmpty ? "未设置" : String(repeating: "•", count: min(apiKey.count, 20)))
                            .foregroundStyle(.secondary)
                            .font(.caption)
                    }
                }
                
                SecureField("输入 API Key", text: $apiKey)
                    .textContentType(.password)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                
                Button {
                    showAPIKey.toggle()
                } label: {
                    HStack {
                        Image(systemName: showAPIKey ? "eye.slash" : "eye")
                        Text(showAPIKey ? "隐藏" : "显示")
                    }
                }
            } header: {
                Text("OpenAI API Key")
            } footer: {
                Text("你的 API Key 仅存储在本地设备，不会上传到任何服务器")
            }
            
            Section {
                TextField("Base URL", text: $apiBaseURL)
                    .textContentType(.URL)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                    .onChange(of: apiBaseURL) { oldValue, newValue in
                        if let modelBaseURL = Constants.API.baseURL(for: apiModel),
                           newValue != modelBaseURL {
                            isBaseURLManuallyEdited = true
                        }
                    }
                
                if isBaseURLManuallyEdited {
                    Button {
                        if let modelBaseURL = Constants.API.baseURL(for: apiModel) {
                            apiBaseURL = modelBaseURL
                            isBaseURLManuallyEdited = false
                        }
                    } label: {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text("重置为模型默认 URL")
                        }
                        .font(.subheadline)
                    }
                }
            } header: {
                Text("API Base URL")
            } footer: {
                if let modelBaseURL = Constants.API.baseURL(for: apiModel), !isBaseURLManuallyEdited {
                    Text("当前模型默认: \(modelBaseURL)\n支持 OpenAI 兼容的 API 服务")
                } else {
                    Text("默认: \(Constants.API.defaultBaseURL)\n支持 OpenAI 兼容的 API 服务\n\n常用服务 Base URL：\n• Qwen: https://dashscope.aliyuncs.com/compatible-mode/v1\n• DeepSeek: https://api.deepseek.com/v1\n• Doubao: https://ark.cn-beijing.volces.com/api/v3")
                }
            }
            
            Section {
                Picker("模型", selection: $apiModel) {
                    Group {
                        Text("GPT-4o").tag("gpt-4o")
                        Text("GPT-4 Turbo").tag("gpt-4-turbo")
                        Text("GPT-3.5 Turbo").tag("gpt-3.5-turbo")
                        Text("Claude 3.5 Sonnet").tag("claude-3-5-sonnet-20241022")
                    }
                    
                    Divider()
                    
                    Group {
                        Text("Qwen Turbo").tag("qwen-turbo")
                        Text("Qwen Plus").tag("qwen-plus")
                        Text("Qwen Max").tag("qwen-max")
                    }
                    
                    Divider()
                    
                    Group {
                        Text("DeepSeek Chat").tag("deepseek-chat")
                        Text("DeepSeek Coder").tag("deepseek-coder")
                    }
                    
                    Divider()
                    
                    Group {
                        Text("Doubao Pro").tag("doubao-pro")
                        Text("Doubao Lite").tag("doubao-lite")
                    }
                }
                .onChange(of: apiModel) { oldValue, newValue in
                    if !isBaseURLManuallyEdited, let modelBaseURL = Constants.API.baseURL(for: newValue) {
                        apiBaseURL = modelBaseURL
                    }
                }
            } header: {
                Text("模型选择")
            } footer: {
                Text("选择要使用的 AI 模型。不同模型的价格和性能不同。选择模型后会自动更新对应的 API Base URL")
            }
            
            Section {
                Button {
                    saveSettings()
                } label: {
                    HStack {
                        Spacer()
                        Text("保存设置")
                            .fontWeight(.semibold)
                        Spacer()
                    }
                }
                .disabled(apiKey.isEmpty)
            }
        }
        .navigationTitle("API 设置")
        .navigationBarTitleDisplayMode(.inline)
        .alert("设置已保存", isPresented: $showSaveAlert) {
            Button("确定") {}
        } message: {
            Text("API 配置已更新，将在下次使用时生效")
        }
        .alert("错误", isPresented: Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("确定") {
                errorMessage = nil
            }
        } message: {
            Text(errorMessage ?? "")
        }
        .onAppear {
            loadSettings()
        }
    }
    
    private func loadSettings() {
        // Settings are automatically loaded from AppStorage
        // If Base URL is empty or default, try to set it based on current model
        if apiBaseURL.isEmpty || apiBaseURL == Constants.API.defaultBaseURL {
            if let modelBaseURL = Constants.API.baseURL(for: apiModel) {
                apiBaseURL = modelBaseURL
                isBaseURLManuallyEdited = false
            }
        } else {
            // Check if current Base URL matches model's default
            if let modelBaseURL = Constants.API.baseURL(for: apiModel),
               apiBaseURL != modelBaseURL {
                isBaseURLManuallyEdited = true
            }
        }
        
        // Configure AIService with current settings
        Task {
            await configureAIService()
        }
    }
    
    private func saveSettings() {
        guard !apiKey.isEmpty else {
            errorMessage = "API Key 不能为空"
            return
        }
        
        // Validate URL
        guard URL(string: apiBaseURL) != nil else {
            errorMessage = "Base URL 格式不正确"
            return
        }
        
        // Configure AIService
        Task {
            await configureAIService()
            await MainActor.run {
                showSaveAlert = true
            }
        }
    }
    
    private func configureAIService() async {
        guard let baseURL = URL(string: apiBaseURL) else { return }
        await AIService.shared.configure(
            apiKey: apiKey,
            baseURL: baseURL,
            model: apiModel
        )
    }
}

#Preview {
    NavigationStack {
        APISettingsView()
    }
}

