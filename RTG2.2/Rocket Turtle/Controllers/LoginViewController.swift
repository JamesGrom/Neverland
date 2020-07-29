//
//  LoginViewController.swift
//  Rocket Turtle
//
//  Created by James Grom on 7/2/20.
//  Copyright © 2020 Rocket Turtle Innovations. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
class LoginViewController: UIViewController {
    
    @IBOutlet weak var EmailTextField: UITextField!
    @IBOutlet weak var PasswordTextField: UITextField!
    @IBOutlet weak var EnterButton: UIButton!
    let db = Firestore.firestore()
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
        //enable the navigation bar
        self.navigationController?.navigationBar.isHidden=false
        EmailTextField.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSAttributedString.Key.foregroundColor : UIColor.white.withAlphaComponent(0.7)])
        PasswordTextField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.foregroundColor : UIColor.white.withAlphaComponent(0.7)])
        EmailTextField.delegate=self
        PasswordTextField.delegate=self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillShowNotification , object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillHideNotification , object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification , object: nil)
    }
    
    deinit{
        //stop listening for keyboard hide/show events
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        
        
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    @IBAction func EnterButtonPressed(_ sender: UIButton) {
        sender.titleLabel!.numberOfLines = 0;
        sender.titleLabel!.adjustsFontSizeToFitWidth = true;
        if let email = EmailTextField.text , let password = PasswordTextField.text {
            if(email == "" || password == "" ){
                EnterButton.setImage(UIImage(named: ""), for: .normal)
                EnterButton.setBackgroundImage(UIImage(named: "CompactSplatterButton"), for: .normal)
                EnterButton.setTitle("^ Missing Fields !", for: .normal)
            }else{
                //attempt login if all fields are filled out
                Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                    if let e = error{
                        self.EnterButton.setImage(UIImage(named: ""), for: .normal)
                        self.EnterButton.setBackgroundImage(UIImage(named: "CompactSplatterButton"), for: .normal)
                        self.EnterButton.setTitle("\(e.localizedDescription)", for: .normal)
                    }else{
                        print("native user data saved  now ")
                        //store topical user data locally
                        //set up the native user info globalVariables
                        self.db.collection(K.Fstore.usersCollection).whereField(K.Fstore.userEmail, isEqualTo: email).getDocuments { (querySnapshot, error) in
                            if let e = error{
                                print (e.localizedDescription)
                                return
                            }
                            //no error fetching documents
                            //optionally bind query documents to the queryData
                            if let queryData = querySnapshot?.documents{
                                //querySnapshot not == nil
                                for doc in queryData{
                                    //pull out each of the variables from the doc
                                    let data = doc.data()
                                    if let tempusername = data[K.Fstore.userUserName] as? String, let tempemail = data[K.Fstore.userEmail] as? String, let tempage = data[K.Fstore.userAge] as? Int, let tempphoneNumber = data[K.Fstore.userPhoneNumber] as? String{
                                        //store userInfo data in the local nativeUserInfo struct
                                        nativeUserInfo.username=tempusername
                                        nativeUserInfo.email=tempemail
                                        nativeUserInfo.age=tempage
                                        nativeUserInfo.phoneNumber=tempphoneNumber
                                        nativeUserInfo.isValid = true //data saved into the nativeUserInfo variable successfully
                                        print("value of nativeUserInfo.isValid = \(nativeUserInfo.isValid)")
                                        self.performSegue(withIdentifier: K.segueNames.LoginToHomeScreen, sender: self)
                                    }
                                }
                                
                            }
                            
                        }
                        
                    }
                    
                }
                
                
            }
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //hide the navigation bar from the onset
        self.navigationController?.navigationBar.isHidden=true
        
    }
    
    
}
//MARK :- UITextFieldDelegate
extension LoginViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true) //stop the textfield from editing
        print(textField.text!)
        return true
    }
    
    
    @objc func keyboardWillChange(notification: Notification){
        print(" keyboard will show \(notification.name.rawValue)")
        
        guard let keyboardRect=(notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        
        if notification.name == UIResponder.keyboardWillChangeFrameNotification || notification.name == UIResponder.keyboardWillShowNotification{
            view.frame.origin.y = -keyboardRect.height
        }else{
            view.frame.origin.y = 0.0
        }
        
    }
    
}
