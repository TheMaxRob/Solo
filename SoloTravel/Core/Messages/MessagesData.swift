//
//  MessagesData.swift
//  SoloTravel
//
//  Created by Max Roberts on 4/28/24.
//

import SwiftUI
import FirebaseDatabase

class MessagesData {
    // Static dictionary where each key is a username (someone you've messaged) and each value is an array with exactly two arrays, the first array is messages received and second is messages sent.
    
    struct Message {
        let content: String
        let isSent: Bool
        let sentTime: Date
    }
    static var messagingSystem: [String: ([Message], [Message])] = [:]
    
    static func addUser(username: String) {
        if messagingSystem[username] == nil {
            messagingSystem[username] = ([], [])
        }
    }
    
    static func sendMessage(message: String, from: String, to: String) {
//        let keyExists = messagingSystem[to] != nil
//        let sentMessage = Message(content: message, isSent: true, sentTime: Date())
//        print("Sent Message: " + sentMessage.content)
//        
//        if (!keyExists) {
//            addUser(username: to)
//        }
//        
//        if var userMessages = messagingSystem[to] {
//                userMessages.1.append(sentMessage)
//                messagingSystem[to] = userMessages
//            } else {
//                print("Cannot find \(to). Wrong number?")
//            }
        let ref = Database.database().reference()
        let messageData: [String: Any] = ["content": message, "isSent": true, "sentTime": Date().timeIntervalSince1970]
        
        ref.child("messages").child(from).child(to).childByAutoId().setValue(messageData)
            
        
        receiveMessage(message: message, from: from, to: to)
        
    }
    
    static func receiveMessage(message: String, from: String, to: String) {
        let keyExists = messagingSystem[from] != nil
        let receivedMessage = Message(content: message, isSent: false, sentTime: Date())
        print("Received Message: " + receivedMessage.content)
        
        if (!keyExists) {
            addUser(username: from)
        }
        
        if var userMessages = messagingSystem[from] {
            userMessages.0.append(receivedMessage)
            messagingSystem[from] = userMessages
        } else {
            print("Cannot find \(from). Wrong number?")
        }
    }
    
    static func getMessages(from: String, to: String) -> [Message] {
        var messageHistory: [Message] = []
        
        if let userMessages = messagingSystem[to] {
            for message in userMessages.1 {
                messageHistory.append(message)
            }
        }
        
        if let userMessages = messagingSystem[to] {
            for message in userMessages.0{
                messageHistory.append(message)
            }
        }
        messageHistory.sort { $0.sentTime > $1.sentTime }
        
        return messageHistory
    }
}
