//
//  MessageKitViewController.swift
//  Rocket Turtle
//
//  Created by James Grom on 7/4/20.
//  Copyright © 2020 Rocket Turtle Innovations. All rights reserved.
//

import UIKit
import FirebaseFirestore
import MessageKit


//this serves as the users inbox page
class MessageKitViewController: UIViewController, UITableViewDelegate,UITableViewDataSource {
    @IBOutlet weak var myTabelView: UITableView!
    @IBOutlet weak var newMessageTextField: UITextField!
    
    //global variables for this class
    let db = Firestore.firestore()
    var inboxMessages : [String] = [] //array used to store UserNames from existing friends/chats
    var currentUsername = nativeUserInfo.username
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        self.navigationController?.navigationBar.isHidden=false
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
        tap.cancelsTouchesInView = false
        myTabelView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        myTabelView.delegate=self
        myTabelView.dataSource=self
        //populate the inboxMessagesArray with the list of people they have active chats with
        //user's contacts list is stored in collection: "user Contacts <username>"
        if currentUsername != nil{
            //add a listener to the collection of contacts for the current user: "user Contacts/<userName>/Contacts List " is the label for the collection
            db.collection("/" + K.Fstore.contactsCollection + "/" + currentUsername! + "/" + K.Fstore.userContacts).addSnapshotListener {
                (querySnapshot, error) in
                if let e = error{
                    print(e.localizedDescription)
                }else{
                    self.inboxMessages=[]
                    if let snapshotDocuments = querySnapshot?.documents{
                        for doc in snapshotDocuments{
                            //for each collection in the snapshot array (snapshot array is an array of collections)
                            let data = doc.data()
                            if let sender = data[K.Fstore.contactsName] as? String{
                                self.inboxMessages.append(sender)
                            }
                            
                        }
                    }
                    self.myTabelView.reloadData()
                }
                
            }
        }
        
    }
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if inboxMessages.count != 0{
            print("number of rows in section is \(inboxMessages.count)" )
            return inboxMessages.count
        }else{
            print("number of rows in section is 1")
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //print("cellForRowAt() called here")
        //myTabelView.reloadData()
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if inboxMessages.count != 0{
            cell.textLabel?.text = inboxMessages[indexPath.last!]
        }else{
            cell.textLabel?.text = "No Messages, Sorry Looser haha jk go find some friends!! :)"
        }
        cell.accessoryType = .disclosureIndicator//shows arrow when u tap into it
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        //if the user doesn't have any actual messages, don't do anything
        if inboxMessages.count == 0{
            return
        }
        //show chatmessages
        let vc = ChatViewController()
        //define the Indentifier of the chat by ordering the usernames alphabetically
        //string comparison works alphabetically not numberically therefore, ordering the usernames should never result in ==
        if let currentIndex = indexPath.last{
            let otherUsername = inboxMessages[currentIndex]
            if currentUsername != nil{
                //always defined to be greater string first
                var chatID: String?
                if otherUsername < currentUsername! {
                    chatID = currentUsername! + otherUsername
                }else{
                    chatID = otherUsername + currentUsername!
                }
                vc.ChatIdentifier = chatID
                vc.otherUser = otherUsername
                vc.title = otherUsername
                print("chat selected with chat ID = \(chatID ?? "")")
                //navigationController?.present(vc, animated: true, completion: nil)
                navigationController?.navigationBar.isHidden = false 
                navigationController?.pushViewController(vc, animated: true)
            }
            
        }
    }
    
    @IBAction func newMessageButtonPressed(_ sender: UIButton) {
        //define known variables
        if let otherUser = newMessageTextField.text {
            if currentUsername != nil{
                //always defined to be greater string first
                var chatID: String?
                if otherUser < currentUsername! {
                    chatID = currentUsername! + otherUser
                }else{
                    chatID = otherUser + currentUsername!
                }
                let vc = ChatViewController()
                vc.ChatIdentifier = chatID
                print("New message Button pressed opens chat with ID = \(chatID ?? "")")
                vc.otherUser = otherUser
                vc.title = otherUser
                self.navigationController?.pushViewController(vc, animated: true)
            }else{
                newMessageTextField.attributedPlaceholder = NSAttributedString(string: "Send Message To: ", attributes: [NSAttributedString.Key.foregroundColor : UIColor.black.withAlphaComponent(0.4)])
                return
            }
            
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.hidesBackButton=true
        self.navigationController?.navigationBar.isHidden=false
    }
}
