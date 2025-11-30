import SwiftUI

struct LoginView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var username = ""
    @State private var password = ""
    @State private var isRegistering = false
    @State private var errorMessage: String?
    @State private var showError = false
    
    private let authService = AuthService.shared
    
    var body: some View {
        NavigationStack {
            VStack(spacing: Constants.Spacing.lg) {
                Spacer()
                
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(Color.personaPrimary)
                
                Text(isRegistering ? "创建账户" : "欢迎回来")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text(isRegistering ? "注册一个新账户" : "登录你的账户")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                VStack(spacing: Constants.Spacing.md) {
                    TextField("用户名", text: $username)
                        .textFieldStyle(.roundedBorder)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    
                    SecureField("密码", text: $password)
                        .textFieldStyle(.roundedBorder)
                }
                .padding(.horizontal)
                .padding(.top, Constants.Spacing.lg)
                
                Button {
                    performAction()
                } label: {
                    Text(isRegistering ? "注册" : "登录")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Constants.Spacing.md)
                        .background(Color.personaPrimary)
                        .cornerRadius(Constants.CornerRadius.medium)
                }
                .padding(.horizontal)
                .disabled(username.isEmpty || password.isEmpty)
                
                Button {
                    withAnimation {
                        isRegistering.toggle()
                        errorMessage = nil
                    }
                } label: {
                    Text(isRegistering ? "已有账户？登录" : "没有账户？注册")
                        .font(.subheadline)
                        .foregroundStyle(Color.personaPrimary)
                }
                
                Spacer()
                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
            .alert("提示", isPresented: $showError) {
                Button("确定") {
                    showError = false
                }
            } message: {
                Text(errorMessage ?? "")
            }
        }
    }
    
    private func performAction() {
        let result: Result<LocalUser, AuthError>
        
        if isRegistering {
            result = authService.register(username: username, password: password)
        } else {
            result = authService.login(username: username, password: password)
        }
        
        switch result {
        case .success:
            dismiss()
        case .failure(let error):
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}

#Preview {
    LoginView()
}

