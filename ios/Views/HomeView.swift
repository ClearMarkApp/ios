//
//  HomeView.swift
//  ios
//
//  Created by Lucian Cheng on 2026-01-10.
//

import SwiftUI

struct HomeView: View {
    @Binding var user: GoogleUser?
    @StateObject private var vm = CoursesViewModel()
    
    var body: some View {
        // header
//        VStack {
//            Text("ClearMark").fontWeight(.bold).font(.title)
//        }
//        .frame(maxWidth: .infinity, alignment: .leading)
//        .padding()
//        .overlay(alignment: .bottom) {
//            Rectangle()
//                .fill(Color.black2)
//                .frame(height: 1)
//        }
        
//        Spacer()
        
        Group {
            if vm.isLoading {
                ProgressView()
            } else if let error = vm.error {
                Text("Error")
                Text(error)
                Button("Retry") {
                    Task {
                        if let email = user?.email {
                            await vm.fetchCourses(email: email)
                        }
                    }
                }
            } else {
                TabView {
                    NavigationStack {
                        ClassListView(
                            email: user?.email ?? "",
                            classData: vm.classData,
                            onRefresh: {
                                if let email = user?.email {
                                    await vm.fetchCourses(email: email)
                                }
                            }
                        )
                    }
                    .tabItem{
                        Image(systemName: "house.fill")
                        Text("Home")
                    }
                    
                    ProfileView(user: self.$user)
                        .tabItem{
                            Image(systemName: "person.crop.circle.fill")
                            Text("Profile")
                        }
                }
            }
        }
        .task {
            if let email = user?.email {
                await vm.fetchCourses(email: email)
            }
        }
    }
}

#Preview {
    HomeView(user: .constant(GoogleUser(firstName: "Test", lastName: "User", email: "test@test.com")))
}

