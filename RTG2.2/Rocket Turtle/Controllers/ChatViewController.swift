//
//  ChatViewController.swift
//  Rocket Turtle
//
//  Created by James Grom on 7/4/20.
//  Copyright © 2020 Rocket Turtle Innovations. All rights reserved.
//

import UIKit
import MessageKit
import FirebaseFirestore
import Firebase
import InputBarAccessoryView


struct Sender: SenderType{
    var senderId: String
    var displayName: String
}

struct Message: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
}

class ChatViewController: MessagesViewController, MessagesDataSource,MessagesLayoutDelegate,MessagesDisplayDelegate, InputBarAccessoryViewDelegate {
    var ChatIdentifier: String? //gives the identifier for the name of the chat in the firebase database
    let db = Firestore.firestore()
    let currentUser = nativeUserInfo.username //= Auth.auth().currentUser?.phoneNumber! //Sender(senderId: (Auth.auth().currentUser?.email)! , displayName: "displayName" )
    var chatReference : String = ""
    var contactsReference: String = ""
    var otherUser : String? //Sender(senderId: destinationLabel, displayName: "displayName" )
    var messages = [MessageType]()
    override func viewDidLoad() {
        self.navigationController?.navigationBar.isHidden = false
        self.navigationItem.hidesBackButton = false 
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
        let imageName = "BlueBackground.png"
        let image = UIImage(named: imageName)
        let imageView = UIImageView(image: image!)
        imageView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        view.addSubview(imageView)
        
        super.viewDidLoad()
        chatReference = "/" + K.Fstore.messageCollection + "/" + ChatIdentifier! + "/" + K.Fstore.chatCollection //prevents processing this multiple times
        contactsReference = "/"+K.Fstore.contactsCollection+"/"+currentUser!+"/"+K.Fstore.userContacts
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.backgroundColor=#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        messageInputBar.delegate=self as InputBarAccessoryViewDelegate
        loadMessages()
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    
    //the inputBar button was pressed
    //send message to the database at the location of the conversationID
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        //func addToContacts( newFriend: temp)
        //addOtherUser to contacts if not already present
        addToContacts(otherUser!)
        //make the message collection have the following format "/messages/<ChatIdentifier>/chat "
        //needed to break apart string so compiler could function efficiently
        db.collection(chatReference).addDocument(data: [
            K.Fstore.senderField: currentUser!,
            K.Fstore.bodyField: text,
            K.Fstore.timestamp: Date().timeIntervalSince1970]){(error) in
                if let e = error{
                    print(e.localizedDescription)
                    
                }else{
                    print("\(text) : successfully saved to firestore")
                    
                }
        }
        messagesCollectionView.reloadDataAndKeepOffset()
        inputBar.inputTextView.text = ""
    }
    
    
    //determines if user has this person in their contacts already or not, if not it adds them to both parties's contacts
    func addToContacts(_ newFriend: String ){
        //newFriend is the id of the person to be checked/added to contacts
        var isPresent = false
        //search currentUser contacts for the newFriend
        //searches the collection: "/user Contacts/<userName>/contacts List"
        //old collection = K.Fstore.contactsCollection + newFriend
        db.collection(contactsReference).whereField(K.Fstore.contactsName, isEqualTo: newFriend).getDocuments { (querySnapshot, error) in
            if let e = error{
                print(e.localizedDescription)
            }else{
                if let queryData = querySnapshot?.documents{
                    for doc in queryData{
                        print(doc.data())
                    }
                }
                //if a document was found where the contactsName is equalto the current user then the user is already present in the collection
                if querySnapshot?.isEmpty == false{
                    isPresent=true
                    print("query is known to be empty")
                }else{
                    print("query is supposedly not empty")
                }
                //ifPresent already, just return
                if isPresent == true {
                    print("knows contact is present already and returns after this statement")
                    return
                }
                //ifNotPresent then add newFriend User to current user contacts
                //"/user Contacts/<userName>/contacts List"
                self.db.collection(self.contactsReference).addDocument(data: [K.Fstore.contactsName: newFriend])
                //also add currentUser to NewFriend's contacts
                //"/user Contacts/<userName>/contacts List"
                let newComplexString = "/"+K.Fstore.contactsCollection+"/"+newFriend+"/"+K.Fstore.userContacts
                self.db.collection(newComplexString).addDocument(data: [K.Fstore.contactsName: self.currentUser!])
            }
        }
    }
    
    
    
    func loadMessages(){
        //load the messages from the current chat identified by the "messages" + currentIdentifier
        
        db.collection(chatReference)
            .order(by: K.Fstore.timestamp).limit(to: 50).addSnapshotListener { (querySnapshot, error) in
                if let e = error{
                    print(e.localizedDescription)
                }else{
                    self.messages=[]//clear the buffer
                    if let snapshotDocuments = querySnapshot?.documents{
                        for doc in snapshotDocuments{
                            print(doc.data())
                            let data = doc.data()
                            if let sender = data[K.Fstore.senderField] as? String, let messageBody = data[K.Fstore.bodyField] as? String{
                                self.messages.append(Message(sender: Sender(senderId: sender, displayName: "tempDisplayName"), messageId: "\(self.messages.count + 1)" , sentDate: Date().addingTimeInterval(-36400), kind: .text(messageBody)))
                                
                                DispatchQueue.main.async {
                                    self.messagesCollectionView.reloadData()
                                }
                            }
                        }
                    }
                }
                
        }
    }
    
    
    //define new colors for the sender and reciever
    func backgroundColor(for message: MessageType, at  indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        
        switch message.kind {
        case .emoji:
            return .clear
        default:
            guard let dataSource = messagesCollectionView.messagesDataSource else { return UIColor.black }
            return dataSource.isFromCurrentSender(message: message) ? #colorLiteral(red: 0.04577282071, green: 0.3740736246, blue: 0.5337628722, alpha: 1) : #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
        }
    }
    
    
    func currentSender() -> SenderType {
        let temp = Sender(senderId: currentUser!, displayName: "temp")//SenderType(senderId: currentUser, displayName: "temp " )
        return temp
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        print( "indexPath.section =  \(indexPath.section)")
        return messages[indexPath.section]
        
    }
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = true
        self.navigationItem.hidesBackButton = true
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        self.navigationItem.hidesBackButton = false
    }
}




