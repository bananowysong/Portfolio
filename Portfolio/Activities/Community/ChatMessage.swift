//
//  ChatMessage.swift
//  Portfolio
//
//  Created by MacBook Pro on 09/01/2022.
//

import CloudKit

/// Chat message with custom initializer that creates them from CKRecords
struct ChatMessage: Identifiable {
    let id: String
    let from: String
    let text: String
    let date: Date
}

// Extension added because memberwise initialiser of struct is lost if custom init
// is used
extension ChatMessage {
    init(from record: CKRecord) {
        id = record.recordID.recordName
        from = record["from"] as? String ?? "No author"
        text = record["text"] as? String ?? "No text"
        date = record.creationDate ?? Date()
    }
}
