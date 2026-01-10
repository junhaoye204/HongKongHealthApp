//
//  LoginView.swift
//  HongKongHealthApp
//
//  Created by Ye on 16/1/2026.
//


import SwiftUI

// MARK: - Login View (Improved UI)
struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color.blue.opacity(0.8), Color.green.opacity(0.6)],
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Image(systemName: "leaf.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.white)
                
                Text("登入 Hong Kong Health")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "envelope.fill")
                            .foregroundColor(.gray)
                        TextField("電郵", text: $email)
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                            .autocorrectionDisabled()
                    }
                    .padding()
                    .background(Color.white.opacity(0.9))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(radius: 4)
                    
                    HStack {
                        Image(systemName: "lock.fill")
                            .foregroundColor(.gray)
                        SecureField("密碼", text: $password)
                            .autocorrectionDisabled()
                    }
                    .padding()
                    .background(Color.white.opacity(0.9))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(radius: 4)
                }
                .padding(.horizontal, 32)
                
                if let error = authManager.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.subheadline)
                        .padding(.horizontal, 32)
                }
                
                Button("登入") {
                    authManager.login(email: email, password: password)
                }
                .font(.headline.bold())
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal, 32)
                .shadow(radius: 4)
                
                NavigationLink(destination: SignupView()) {
                    Text("未有帳戶？註冊")
                        .foregroundColor(.white.opacity(0.9))
                        .underline()
                }
            }
            .padding(.vertical, 40)
        }
    }
}