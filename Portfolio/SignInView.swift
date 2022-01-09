//
//  SignInView.swift
//  Portfolio
//
//  Created by MacBook Pro on 09/01/2022.
//

import SwiftUI
import AuthenticationServices

struct SignInView: View {
    enum SignInStatus {
        case unknown
        case authorized
        case failure(Error?)
    }

    @State private var status = SignInStatus.unknown

    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Group {
            switch status {
            case .unknown:
                VStack(alignment: .leading) {

                    // The scroll view is used here so that when dynamic type is
                    // enabled the larger font will be scrollable
                    ScrollView {
                        Text("""
                        In order to keep our community safe, we ask that you sign in before commenting on a project.

                        We don't track your personal information; your name is used only for display purposes.

                        Please note: we reserve the right to remove messages that are inappropriate or offensive.
                        """)
                    }

                    Spacer()

                    // Without height the button would take all the place
                    SignInWithAppleButton(onRequest: configureSignIn, onCompletion: completeSignIn(_:))
                        .frame(height: 44)
                    // The color of the button doesn't adjust by itself to
                    // dark mode or light mode, had to do it manually
                        .signInWithAppleButtonStyle(colorScheme == .light ? .black : .white)

                    Button("Cancel", action: close)
                        .frame(maxWidth: .infinity)
                        .padding()
                }

            case .authorized:
                Text("You're all set!")
            case .failure(let error):
                if let error = error {
                    Text("Sorry, there was an error: \(error.localizedDescription)")
                } else {
                    Text("Sorry, there was an error.")
                }
            }
        }
        .padding()
        .navigationTitle("Please sign in")
    }

    /// Adjusts the request based on data we want
    /// - Parameter request: ASAuthorizationAppleIDRequest
    func configureSignIn(_ request: ASAuthorizationAppleIDRequest) {
        request.requestedScopes = [.fullName]
    }

    /// Evaluates SIWA result and decides what to do with it
    /// - Parameter result: Result
    func completeSignIn(_ result: Result<ASAuthorization, Error>) {
        switch result {

            // APPLE SENDS THE VALUE ONLY ONCE ON THE FIRST ATTEMPT OF LOGIN
            // MAKE SURE TO STORE IT
        case .success(let auth):
            if let appleID = auth.credential as? ASAuthorizationAppleIDCredential {
                if let fullName = appleID.fullName {
                    let formatter = PersonNameComponentsFormatter()
                    var username = formatter.string(from: fullName)

                    if username.isEmpty {
                        // Refuse to allow empty string names
                        username = "User-\(Int.random(in: 1001...9999))"
                    }

                    UserDefaults.standard.set(username, forKey: "username")
                    NSUbiquitousKeyValueStore.default.set(username, forKey: "username")
                    status = .authorized
                    close()
                    return
                }
            }

            status = .failure(nil)

            // if the user canceled, the status is set to unknown and asks for login
            // again. In other cases displays error.
        case .failure(let error):
            if let error = error as? ASAuthorizationError {
                if error.errorCode == ASAuthorizationError.canceled.rawValue {
                    status = .unknown
                    return
                }
            }

            status = .failure(error)
        }
    }

    func close() {
        presentationMode.wrappedValue.dismiss()
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}
