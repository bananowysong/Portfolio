//
//  EditProjectView.swift
//  Portfolio
//
//  Created by MacBook Pro on 16/11/2021.
//

import SwiftUI
import CoreHaptics
import CloudKit

struct EditProjectView: View {
    @ObservedObject var project: Project

    @EnvironmentObject var dataController: DataController

    @State private var title: String
    @State private var detail: String
    @State private var color: String

    @State private var engine = try? CHHapticEngine()

    @Environment(\.presentationMode) var presentationMode
    @State private var showingDeleteConfirm = false

    @State private var remindMe: Bool
    @State private var reminderTime: Date

    /// Determines whether notification adding error message is visible or not
    @State private var showingNotificationsError = false

    /// User name satored in UserDefaults
    @AppStorage("username") var username: String?

    /// Responsible for showing the SignIn sheet
    @State private var showingSignIn = false

    let colorColumns = [
        GridItem(.adaptive(minimum: 44))
    ]

    var body: some View {
        Form {
            Section(content: {
                TextField("Project name", text: $title.onChange(update))
                TextField("Description of this project", text: $detail.onChange(update))
            }, header: { Text("Basic setting") })

            Section(content: {
                LazyVGrid(columns: colorColumns) {
                    ForEach(Project.colors, id: \.self, content: colorButton)
                }
                .padding(.vertical)
            }, header: { Text("Custom project color") })

            // swiftlint:disable:next line_length
            Section(footer: Text("Closing a project moves it from the Open to Closed tab; deleting it removes the project completely.")) {
                Button(project.closed ? "Reopen this project" : "Close this project", action: toggleProject)

                Button("Delete this project") {
                    showingDeleteConfirm.toggle()
                }
                .accentColor(.red)
            }

            Section(content: {
                Toggle("Show reminders", isOn: $remindMe.animation().onChange(update))
                    .alert(isPresented: $showingNotificationsError) {
                        Alert(
                            title: Text("Oops!"),
                            message: Text("There was a problem. Please check you have notifications enabled."),
                            primaryButton: .default(Text("Check settings"), action: showApppSettings),
                            secondaryButton: .cancel()
                        )
                    }

                if remindMe {
                    DatePicker(
                        "Reminder time",
                        selection: $reminderTime.onChange(update),
                        displayedComponents: .hourAndMinute
                    )
                }
            }, header: { Text("Project reminders") })

        }
        .navigationTitle("Edit Project")
        .toolbar {
            // Performs operation on Cloud
            Button(action: uploadToCloud, label: {
                Label("Upload to iCloud", systemImage: "icloud.and.arrow.up")
            })
        }
        .sheet(isPresented: $showingSignIn, content: SignInView.init)
        .onDisappear(perform: dataController.save)
        .alert(isPresented: $showingDeleteConfirm) {
            Alert(
                title: Text("Delete project?"),
                message: Text("Are you sure you want to delete this project? You will also delete all the items it contains."), // swiftlint:disable:this line_length
                primaryButton: .default(Text("Delete"), action: delete),
                secondaryButton: .cancel()
            )
        }
    }

    init(project: Project) {
        self.project = project
        _title = State(wrappedValue: project.projectTitle)
        _detail = State(wrappedValue: project.projectDetail)
        _color = State(wrappedValue: project.projectColor)

        if let projectReminderTime = project.reminderTime {
            _reminderTime = State(wrappedValue: projectReminderTime)
            _remindMe = State(wrappedValue: true)
        } else {
            _reminderTime = State(wrappedValue: Date())
            _remindMe = State(wrappedValue: false)
        }
    }

    func update() {
        project.title = title
        project.detail = detail
        project.color = color

        if remindMe {
            project.reminderTime = reminderTime

            dataController.addReminders(for: project) { success in
                if success == false {
                    project.reminderTime = nil
                    remindMe = false

                    showingNotificationsError = true
                }
            }
        } else {
            project.reminderTime = nil
            dataController.removeReminders(for: project)
        }
    }

    func delete() {
        dataController.delete(project)
        presentationMode.wrappedValue.dismiss()
    }

    func colorButton(for item: String) -> some View {
        ZStack {
            Color(item)
                .aspectRatio(1, contentMode: .fit)
                .cornerRadius(6)

            if item == color {
                Image(systemName: "checkmark.circle")
                    .foregroundColor(.white)
                    .font(.largeTitle)
            }
        }
        .onTapGesture {
            color = item
            update()
        }
        .accessibilityElement(children: .ignore)
        .accessibilityAddTraits(
            item == color
            ? [.isButton, .isSelected]
            : .isButton
        )
        .accessibilityLabel(LocalizedStringKey(item))

    }

    /// Opens app's settings
    func showApppSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }

        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl)
        }
    }

    /// Toggles project close status and uses vibration as confirmation.
    func toggleProject() {
        project.closed.toggle()
        if project.closed {

            do {
                try engine?.start()
                let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0)
                let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1)

                let start = CHHapticParameterCurve.ControlPoint(relativeTime: 0, value: 1)
                let end = CHHapticParameterCurve.ControlPoint(relativeTime: 1, value: 0)

                // use that curve to control the haptic strength
                let parameter = CHHapticParameterCurve(
                    parameterID: .hapticIntensityControl,
                    controlPoints: [start, end],
                    relativeTime: 0
                )

                let event1 = CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [intensity, sharpness],
                    relativeTime: 0
                )

                let event2 = CHHapticEvent(
                    eventType: .hapticContinuous,
                    parameters: [sharpness, intensity],
                    relativeTime: 0.125,
                duration: 1
                )

                let pattern = try CHHapticPattern(events: [event1, event2], parameterCurves: [parameter])

                let player = try engine?.makePlayer(with: pattern)
                try player?.start(atTime: 0)

            } catch {
                // playing haptics didn't work, but that's okay
            }
        }
    }

    func uploadToCloud() {
        if let username = username {
            let records = project.prepareCloudRecords(owner: username)
            let operation = CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: nil)
            operation.savePolicy = .allKeys

            if #available(iOS 15.0, *) {
                operation.modifyRecordsResultBlock = { result in
                    switch result {
                    case .success:
                        return
                    case .failure(let error):
                        print("Error: \(error.localizedDescription)")
                    }
                }
            } else {
                operation.modifyRecordsCompletionBlock = { _, _, error in
                    if let error = error {
                        print("Error: \(error.localizedDescription)")
                    }
                }
            }

            // Use identifier when initializing Container because the
            // bundle ID which is used by default to init container
            // differs from iCloud container I created when making app
            CKContainer.init(identifier: "iCloud.iam.mrnoone.portfolio").publicCloudDatabase.add(operation)
        } else {
            showingSignIn = true
        }
    }
}

struct EditProjectView_Previews: PreviewProvider {
    static var dataController = DataController.preview

    static var previews: some View {
        EditProjectView(project: Project.example)
            .environmentObject(dataController)
    }
}
