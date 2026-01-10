//
//  ProfileView.swift
//  ios
//
//  Created by Lindsay Cheng on 2026-01-10.
//

import SwiftUI
import GoogleSignIn

struct ProfileView: View {
    @Binding var user: GoogleUser?
    
    // default to purple for now since account type isn't defined yet
    private var avatarColor: Color {

        // TODO: implement account type color
        return .purple
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // profile header section
                VStack(spacing: 16) {
                    // avatar with initials
                    ZStack {
                        Circle()
                            .fill(avatarColor.gradient)
                            .frame(width: 120, height: 120)
                        
                        Text(getInitials(from: "\(user?.firstName ?? "") \(user?.lastName ?? "")"))
                            .font(.system(size: 48, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .padding(.top, 16)
                    
                    // name and email
                    VStack(spacing: 4) {
                        Text("\(user?.firstName ?? "") \(user?.lastName ?? "")")
                            .font(.system(size: 28, weight: .bold))
                        
                        Text(user?.email ?? "")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 8)
                
                // account information section
                VStack(alignment: .leading, spacing: 12) {
                    VStack(spacing: 0) {
                        AccountInfoRow(label: "First Name", value: user?.firstName ?? "")
                        
                        Divider()
                            .padding(.horizontal, 16)
                        
                        AccountInfoRow(label: "Last Name", value: user?.lastName ?? "")
                        
                        Divider()
                            .padding(.horizontal, 16)
                        
                        AccountInfoRow(label: "Email", value: user?.email ?? "")
                        
                        Divider()
                            .padding(.horizontal, 16)
                        
                        AccountInfoRow(label: "Account Type", value: "Professor")
                    }
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
                    .shadow(color: Color.black.opacity(0.04), radius: 2, x: 0, y: 1)
                }
                .padding(.horizontal)
                
                // log out button
                Button {
                    GIDSignIn.sharedInstance.signOut()
                    self.user = nil
                } label: {
                    Text("Log Out")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
                        .shadow(color: Color.black.opacity(0.04), radius: 2, x: 0, y: 1)
                }
                .padding(.horizontal)
                .padding(.bottom, 32)
            }
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // helper function to get initials from name
    private func getInitials(from name: String) -> String {
        let components = name.split(separator: " ")
        if components.count >= 2 {
            let firstInitial = components[0].prefix(1)
            let lastInitial = components[1].prefix(1)
            return "\(firstInitial)\(lastInitial)".uppercased()
        } else if components.count == 1 {
            return String(components[0].prefix(1)).uppercased()
        }
        return ""
    }
    
}

// account info row component
struct AccountInfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 15))
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
    }
}

#Preview {
    ProfileView(user: .constant(GoogleUser(
        firstName: "Jane",
        lastName: "Doe",
        email: "jane.doe@university.edu",
    )))
}
