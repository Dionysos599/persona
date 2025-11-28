import SwiftUI
import SwiftData
import PhotosUI

struct PersonaCreationView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    private let aiService: AIService
    @State private var viewModel: PersonaCreationViewModel?
    
    init(aiService: AIService) {
        self.aiService = aiService
    }
    
    var body: some View {
        NavigationStack {
            if let viewModel = viewModel {
                Form {
                    Section("基本信息") {
                        TextField("名称", text: Binding(
                            get: { viewModel.name },
                            set: { viewModel.name = $0 }
                        ))
                        .textInputAutocapitalization(.words)
                    
                    PhotosPicker(
                        selection: Binding(
                            get: { viewModel.selectedPhoto },
                            set: { viewModel.selectedPhoto = $0 }
                        ),
                        matching: .images,
                        photoLibrary: .shared()
                    ) {
                        HStack {
                            if let image = viewModel.avatarImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: Constants.AvatarSize.large, height: Constants.AvatarSize.large)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "person.crop.circle.badge.plus")
                                    .font(.title)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Text(viewModel.avatarImage == nil ? "选择头像" : "更换头像")
                                .foregroundStyle(.secondary)
                            
                            Spacer()
                        }
                    }
                    .onChange(of: viewModel.selectedPhoto) {
                        Task {
                            await viewModel.loadPhoto()
                        }
                    }
                }
                
                Section("性格特征") {
                    PersonalityPickerView(selectedTraits: Binding(
                        get: { viewModel.selectedTraits },
                        set: { viewModel.selectedTraits = $0 }
                    ))
                    
                    if !viewModel.selectedTraits.isEmpty {
                        Text("已选择 \(viewModel.selectedTraits.count) 个特征")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Section("背景故事") {
                    TextEditor(text: Binding(
                        get: { viewModel.backstory },
                        set: { viewModel.backstory = $0 }
                    ))
                    .frame(minHeight: 100)
                    .overlay(alignment: .topLeading) {
                        if viewModel.backstory.isEmpty {
                            Text("描述这个 Persona 的背景故事...")
                                .foregroundStyle(.secondary)
                                .padding(.top, 8)
                                .padding(.leading, 4)
                                .allowsHitTesting(false)
                        }
                    }
                }
                
                Section("说话风格") {
                    Picker("风格", selection: Binding(
                        get: { viewModel.voiceStyle },
                        set: { viewModel.voiceStyle = $0 }
                    )) {
                        ForEach(VoiceStyle.allCases, id: \.self) { style in
                            Text(style.displayName).tag(style)
                        }
                    }
                }
                
                Section("兴趣标签") {
                    TextField("添加兴趣（用逗号分隔）", text: Binding(
                        get: { viewModel.interests.joined(separator: ", ") },
                        set: { viewModel.interests = $0.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty } }
                    ))
                    .textInputAutocapitalization(.words)
                    
                    if !viewModel.interests.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: Constants.Spacing.sm) {
                                ForEach(viewModel.interests, id: \.self) { interest in
                                    Text(interest)
                                        .font(.caption)
                                        .padding(.horizontal, Constants.Spacing.sm)
                                        .padding(.vertical, Constants.Spacing.xs)
                                        .background(Color.secondaryBackground)
                                        .clipShape(Capsule())
                                }
                            }
                        }
                    }
                }
                
                Section {
                    Button {
                        Task {
                            await viewModel.generateWithAI()
                        }
                    } label: {
                        HStack {
                            Image(systemName: "sparkles")
                            Text("AI 一键生成")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .disabled(viewModel.isGenerating)
                }
                }
                .navigationTitle("创建 Persona")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("创建") {
                            let persona = viewModel.createPersona()
                            try? modelContext.save()
                            dismiss()
                        }
                        .disabled(!viewModel.isValid)
                    }
                    ToolbarItem(placement: .cancellationAction) {
                        Button("取消") {
                            dismiss()
                        }
                    }
                }
                .overlay {
                    if viewModel.isGenerating {
                        ProgressView("AI 生成中...")
                            .padding()
                            .background(.ultraThinMaterial)
                            .cornerRadius(Constants.CornerRadius.medium)
                    }
                }
                .alert("错误", isPresented: Binding(
                    get: { viewModel.errorMessage != nil },
                    set: { if !$0 { viewModel.errorMessage = nil } }
                )) {
                    Button("确定") {
                        viewModel.errorMessage = nil
                    }
                } message: {
                    Text(viewModel.errorMessage ?? "")
                }
            } else {
                ProgressView()
            }
        }
        .onAppear {
            if viewModel == nil {
                viewModel = PersonaCreationViewModel(
                    aiService: aiService,
                    modelContext: modelContext
                )
            }
        }
    }
}

#Preview {
    PersonaCreationView(aiService: AIService.shared)
        .modelContainer(for: [Persona.self, Post.self, Conversation.self, Message.self])
}

