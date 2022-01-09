//
//  SharedItemView.swift
//  Portfolio
//
//  Created by MacBook Pro on 09/01/2022.
//

import SwiftUI
import CloudKit

struct SharedItemsView: View {
    let project: SharedProject

    @State private var items = [SharedItem]()
    @State private var itemsLoadState = LoadState.inactive

    /// tracks all the messages loaded
    @State private var messages = [ChatMessage]()

    /// Stores username
    @AppStorage("username") var username: String?

    /// track whether showing the sign in sheet or not
    @State private var showingSignIn = false

    /// Tracks the current message text
    @State private var newChatText = ""

    /// Tracks loading messages list state
    @State private var messagesLoadState = LoadState.inactive

    /// Responsible for presenting alert with error
    @State private var cloudError: CloudError?

    var body: some View {
        List {
            Section {
                switch itemsLoadState {
                case .inactive, .loading:
                    ProgressView()
                case .noResults:
                    Text("No results")
                case .success:
                    ForEach(items) { item in
                        VStack(alignment: .leading) {
                            Text(item.title)
                                .font(.headline)

                            if item.detail.isEmpty == false {
                                Text(item.detail)
                            }
                        }
                    }
                }
            }

            Section(
                header: Text("Chat about this project…"),
                footer: messagesFooter
            ) {
                if messagesLoadState == .success {
                    ForEach(messages) { message in
                        Text("\(Text(message.from).bold()): \(message.text)")
                                    .multilineTextAlignment(.leading)
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle(project.title)
        .onAppear {
            fetchSharedItems()
            fetchChatMessages()
        }
        .sheet(isPresented: $showingSignIn, content: SignInView.init)
        .alert(item: $cloudError) { error in
            Alert(
                title: Text("There was an error"),
                message: Text(error.message)
            )
        }
    }

    func fetchSharedItems() {
        guard itemsLoadState == .inactive else { return }
        itemsLoadState = .loading

        let recordID = CKRecord.ID(recordName: project.id)

        // Passing a CKRecord.Reference directly into a predicate
        // to get all items that belong to the current project
        let reference = CKRecord.Reference(recordID: recordID, action: .none)
        let pred = NSPredicate(format: "project == %@", reference)
        let sort = NSSortDescriptor(key: "title", ascending: true)
        let query = CKQuery(recordType: "Item", predicate: pred)
        query.sortDescriptors = [sort]

        let operation = CKQueryOperation(query: query)
        operation.desiredKeys = ["title", "detail", "completed"]
        operation.resultsLimit = 50

        operation.recordFetchedBlock = { record in
            let id = record.recordID.recordName
            let title = record["title"] as? String ?? "No title"
            let detail = record["detail"] as? String ?? ""
            let completed = record["completed"] as? Bool ?? false

            let sharedItem = SharedItem(id: id, title: title, detail: detail, completed: completed)
            items.append(sharedItem)
            itemsLoadState = .success
        }

        operation.queryCompletionBlock = { _, error in
            if let error = error {
                cloudError = error.getCloudKitError()
            }

            if items.isEmpty {
                itemsLoadState = .noResults
            }
        }
        CKContainer.init(identifier: "iCloud.iam.mrnoone.portfolio").publicCloudDatabase.add(operation)
    }

    /// Opens Sign in sheet
    func signIn() {
        showingSignIn = true
    }

    /// Sends chat messaget to the iCloud
    func sendChatMessage() {

        // making sure there is username and text is long enough
        let text = newChatText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard text.count > 2 else { return }
        guard let username = username else {
            return
        }

        // creating "Message" record with username, text and reference to the project
        let message = CKRecord(recordType: "Message")
        message["from"] = username
        message["text"] = text

        let projectID = CKRecord.ID(recordName: project.id)
        message["project"] = CKRecord.Reference(recordID: projectID, action: .deleteSelf)

        // copying chat and clearning text
        let backupChatText = newChatText
        newChatText = ""

        // Only one record to be saved to .save method is used
        CKContainer.init(identifier: "iCloud.iam.mrnoone.portfolio")
            .publicCloudDatabase.save(message) { record, error in
            if let error = error {
                cloudError = error.getCloudKitError()
                newChatText = backupChatText
            } else if let record = record {
                let message = ChatMessage(from: record)
                messages.append(message)
            }
        }
    }

    func fetchChatMessages() {
        guard messagesLoadState == .inactive else { return }
        messagesLoadState = .loading

        let recordID = CKRecord.ID(recordName: project.id)
        let reference = CKRecord.Reference(recordID: recordID, action: .none)
        let pred = NSPredicate(format: "project == %@", reference)
        let sort = NSSortDescriptor(key: "creationDate", ascending: true)
        let query = CKQuery(recordType: "Message", predicate: pred)
        query.sortDescriptors = [sort]

        let operation = CKQueryOperation(query: query)
        operation.desiredKeys = ["from", "text"]

        operation.recordFetchedBlock = { record in
            let message = ChatMessage(from: record)
            messages.append(message)
            messagesLoadState = .success
        }

        operation.queryCompletionBlock = { _, error in
            if let error = error {
                cloudError = error.getCloudKitError()
            }
            if messages.isEmpty {
                messagesLoadState = .noResults
            }
        }

        CKContainer.init(identifier: "iCloud.iam.mrnoone.portfolio").publicCloudDatabase.add(operation)
    }

    /// A footer with list of messages and button for adding them
    @ViewBuilder var messagesFooter: some View {
        if username == nil {
            Button("Sign in to comment", action: signIn)
                .frame(maxWidth: .infinity)
        } else {
            VStack {
                TextField("Emter your message", text: $newChatText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textCase(nil)

                Button(action: sendChatMessage) {
                    Text("Send")
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                        .contentShape(Capsule())
                }
            }
        }
    }
}

struct SharedItemsView_Previews: PreviewProvider {
    static var previews: some View {
        SharedItemsView(project: SharedProject.example)
    }
}
