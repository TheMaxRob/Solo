//
//  AccountView.swift
//  SoloTravel
//
//  Created by Max Roberts on 4/16/24.
//

import SwiftUI

struct AccountView: View {
    
    @StateObject var viewModel = AccountViewModel()
    @FocusState private var focusedTextField: FormTextField?
    
    enum FormTextField {
        case firstName
        case lastName
        case email
        case id
    }
    
    var body: some View {
        NavigationStack {
            
                VStack(alignment: .trailing) {
                    Button {
                    viewModel.isShowingPFPChanger = true
                    print("isShowingPFPChanger is now true!")
                } label: {
                    AccountButton(image: Image("ProfilePic"))
                        .padding(.trailing, 25)
                }
                Form {
                        Section("Personal Info") {
                            TextField("First Name", text: $viewModel.user.firstName)
                                .focused($focusedTextField, equals: .firstName)
                                .onSubmit {
                                    focusedTextField = .lastName
                                }
                                .submitLabel(.next)
                            
                            TextField("Last Name", text: $viewModel.user.lastName)
                                .focused($focusedTextField, equals: .lastName)
                                .onSubmit {
                                   focusedTextField = .email
                                }
                                .submitLabel(.next)
                            
                            TextField("Email", text: $viewModel.user.email)
                                .focused($focusedTextField, equals: .email)
                                .onSubmit {
                                    focusedTextField = nil
                                }
                                .submitLabel(.continue)
                            
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .autocorrectionDisabled()
                            DatePicker("Birthday", selection: $viewModel.user.birthday, displayedComponents: .date)
                                .tint(Color("brandPrimary"))
                            
                            TextField("Username", text: $viewModel.user.id)
                                .focused($focusedTextField, equals: .id)
                            
                            Button {
                                viewModel.saveChanges()
                            } label: {
                                Text("Save Changes")
                            }
                        }
                        
                    }
                .navigationTitle("Account")
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Button("Dismiss") {
                            focusedTextField = nil
                        }
                    }
                }
            }
            
        Spacer()
        }
        
        .onAppear {
            viewModel.retrieveUser()
        }
        .alert(item: $viewModel.alertItem) { alertItem in
            Alert(title: alertItem.title, message: alertItem.message, dismissButton: alertItem.dismissButton)
        }
        
        if (viewModel.isShowingPFPChanger) {
            // MARK: Figure out how to access photos
        }
    }
}

#Preview {
    AccountView()
}
