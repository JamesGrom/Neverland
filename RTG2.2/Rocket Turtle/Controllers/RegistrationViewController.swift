//
//  CompleteRegistrationViewController.swift
//  Rocket Turtle
//
//  Created by James Grom on 7/6/20.
//  Copyright © 2020 Rocket Turtle Innovations. All rights reserved.
//

import UIKit
import FirebaseFirestore
import Firebase
import FirebaseAuth
import FirebaseStorage

import Photos
class RegistrationViewController: UIViewController {
    
    //view Outlets
    @IBOutlet weak var ProfilePicture: UIImageView!
    @IBOutlet weak var ProfilePicBoarderview: UIView!
    @IBOutlet weak var addProfilePicLabelButton: UIButton!
    @IBOutlet weak var FirstNameTextField: UITextField!
    @IBOutlet weak var LastNameTextField: UITextField!
    @IBOutlet weak var PhoneNumberTextField: UITextField!
    @IBOutlet weak var EmailTextField: UITextField!
    @IBOutlet weak var PasswordTextField: UITextField!
    @IBOutlet weak var AgePickerView: UIPickerView!
    @IBOutlet weak var UserNameLabel: UILabel!
    @IBOutlet weak var SMSTextField: UITextField!
    @IBOutlet weak var CreateAccountButton: UIButton!
    @IBOutlet weak var AddProfilePicButton: UIButton!
    @IBOutlet weak var ErrorMessageLabel: UILabel!
    @IBOutlet weak var SMSStackView: UIStackView!
    @IBOutlet weak var LoadingIndicatorLabel: UILabel!
    
    //viewGlobalVariables
    let db = Firestore.firestore()
    var photoDataRepresentation: String?
    var profilePic : UIImage? // = UIImage(named: "BlueProfilePic") //as default
    var firstName: String?
    var lastName: String?
    var phoneNumber: String?
    var email: String?
    var password: String?
    var age: Int? // must be set once createAccountButton is pushed
    var username: String?
    var SMSCode: String?
    var data = Array(1...100) //used to fill agePicker
    var profilePicButtonPressed = false
    var smsFormattedPhoneNumber: String? //formatted without +countrycode
    var verifID : String? //used to store verification ID
    let passwordRegex = NSPredicate(format: "SELF MATCHES %@ ", "^(?=.*[A-Za-z])(?=.*\\d)(?=.*[$@$!%*#?&])[A-Za-z\\d$@$!%*#?&]{8,}$")
    
    //regex used to ensure password has 8 characters (at least 1 alphabet and 1 number and 1 special character)
    //must enable deselecting the text fields without pressing return and deselecting after pressing return
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //reenable the navigation bar to have go back functionality
        self.navigationController?.navigationBar.isHidden=false
        self.SMSStackView.isHidden = true
        self.LoadingIndicatorLabel.isHidden = true
        print("viewLoaded")
        //set needed delegates
        AgePickerView.delegate=self
        AgePickerView.dataSource=self
        FirstNameTextField.delegate=self
        LastNameTextField.delegate=self
        PhoneNumberTextField.delegate=self
        EmailTextField.delegate=self
        PasswordTextField.delegate=self
        SMSTextField.delegate=self
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        //prevent keyboard from blocking active textfields
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
    
    //enable tap anywhere to dismiss keyboard
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //hide the navigation bar from the onset
        self.navigationController?.navigationBar.isHidden=true
        
    }
    
    //viewActions
    @IBAction func AddProfilePicButtonPressed(_ sender: UIButton) {
        profilePicButtonPressed=true
        //check if the photolibrary is empty or not to avoid an error
        LoadingIndicatorLabel.text = "Loading Photo access credentials Please Wait"
        LoadingIndicatorLabel.isHidden = false
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            //status indicates yes or no
            PHPhotoLibrary.requestAuthorization { (status) in
                switch status{
                case .authorized:
                    DispatchQueue.main.sync{
                        let myPickerController = UIImagePickerController()
                        myPickerController.delegate = self
                        myPickerController.sourceType = .photoLibrary
                        self.present(myPickerController,animated: true)
                    }
                    break //break from this case Statement
                    
                default: break
                }
            }
            LoadingIndicatorLabel.text = "Loading Please Wait"
            LoadingIndicatorLabel.isHidden = true
            
        }
        
        
    }
    
    @IBAction func CreateAccountButtonPressed(_ sender: Any) {
        //1st check that none of the fields are nil or basic
        ErrorMessageLabel.text = ""
        ErrorMessageLabel.isHidden = false
        //make sure a profile pic is submitted and valid
        if profilePic == nil{
            ErrorMessageLabel.text = "Missing Profile Pic"
            return
        }
        if firstName==nil || firstName==""{
            ErrorMessageLabel.text = "Missing First Name"
            return
        }
        if firstName!.contains(" "){
            ErrorMessageLabel.text = "First Name can't have spaces"
            return
        }
        if lastName==nil || lastName==""{
            ErrorMessageLabel.text = "Missing Last Name"
            return
        }
        if lastName!.contains(" "){
            ErrorMessageLabel.text = "Last Name can't have spaces"
            return
        }
        if phoneNumber==nil || phoneNumber==""{
            ErrorMessageLabel.text = "Missing Phone Number"
            return
        }
        if phoneNumber!.contains(" "){
            ErrorMessageLabel.text = "Phone number can't have spaces"
            return
        }
        if CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: phoneNumber!)){
            
        }else{
            ErrorMessageLabel.text = "please type phone number using only numbers"
            return
        }
        if email==nil || email==""{
            ErrorMessageLabel.text = "Missing Email"
            return
        }
        if email!.contains(" "){
            ErrorMessageLabel.text = "Email can't have spaces"
            return
        }
        if password==nil || password==""{
            ErrorMessageLabel.text = "Missing Password"
            return
        }
        if age == nil{
            ErrorMessageLabel.text = "missing or invalid age"
            return
        }
        if username == nil || username==""{
            ErrorMessageLabel.text = "missing Username"
            return
        }
        //check if the username is unused in the database
        db.collection(K.Fstore.usersCollection).document(username!).getDocument { (document, error) in
            if let doc = document{
                if doc.exists{
                    self.ErrorMessageLabel.text = "the name: \(self.username!) is already taken"
                    return
                }
            }else{
                self.ErrorMessageLabel.text = "the name: \(self.username!) is already taken"
                return
            }
            print("username was found to be unique")
            //all valid inputs, therefore prevent user interaction to change fields
            //disable editing of the user text fields
            self.FirstNameTextField.isUserInteractionEnabled = false
            self.FirstNameTextField.text = "Answer Locked in"
            self.LastNameTextField.isUserInteractionEnabled = false
            self.LastNameTextField.text = "Answer Locked in"
            self.PhoneNumberTextField.isUserInteractionEnabled = false
            self.PhoneNumberTextField.text = "Answer Locked in"
            self.EmailTextField.isUserInteractionEnabled = false
            self.EmailTextField.text = "Answer Locked in"
            self.PasswordTextField.isUserInteractionEnabled = false
            self.PasswordTextField.text = "Answer Locked in"
            self.AgePickerView.isUserInteractionEnabled = false
            self.AddProfilePicButton.isUserInteractionEnabled = false
            
            
            self.LoadingIndicatorLabel.text = "Loading SMS Authentication Please Wait"
            self.LoadingIndicatorLabel.isHidden = false
            //prepare for and perform SMS verification call
            self.smsFormattedPhoneNumber="+1" + self.phoneNumber!
            PhoneAuthProvider.provider().verifyPhoneNumber(self.smsFormattedPhoneNumber!, uiDelegate: nil) { (verificationID, error) in
                if let e = error{
                    //print out the errorMessage
                    self.ErrorMessageLabel.text=e.localizedDescription
                    self.LoadingIndicatorLabel.text = "Loading Please Wait"
                    self.LoadingIndicatorLabel.isHidden = true
                    return
                }
                //save the verificationID and the code sent to the user
                //save the VerificationID in persistent data
                UserDefaults.standard.set(verificationID, forKey: K.smsAuthID )
                self.verifID = UserDefaults.standard.string(forKey: K.smsAuthID)
                //unhide the sms verifcation view
                self.ErrorMessageLabel.text = "Enter Code From Messages Below v"
                self.SMSStackView.isHidden = false
                self.CreateAccountButton.isHidden = true //hide the create account button
                self.LoadingIndicatorLabel.text = "Loading Please Wait"
                self.LoadingIndicatorLabel.isHidden = true
            }
        }
        
    }
    
    @IBAction func FirstNameTextfieldDidEndEditing(_ sender: UITextField) {
        if FirstNameTextField.text != nil && FirstNameTextField.text! != ""{
            FirstNameTextField.backgroundColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
            firstName = FirstNameTextField.text!
            print("Firstname Saved As: \(firstName!)")
            if lastName != nil {
                username = firstName! + " " + lastName!
            }else{
                username = firstName! + " "
            }
            UserNameLabel.text = username!
            print("username Saved as \(username!)")
            
        }else{
            FirstNameTextField.backgroundColor = #colorLiteral(red: 0.9693604275, green: 0.1983119405, blue: 0.09824349952, alpha: 1)
            FirstNameTextField.text = ""
            FirstNameTextField.attributedPlaceholder = NSAttributedString(string: "incomplete answer!", attributes: [NSAttributedString.Key.foregroundColor : UIColor.black.withAlphaComponent(0.3)])
            print("firstnameTextfieldDIDend editing but no value saved")
        }
        
        
        
    }
    @IBAction func LastNameTextFieldDidEndEditing(_ sender: UITextField) {
        if LastNameTextField.text != nil && LastNameTextField.text! != ""{
            LastNameTextField.backgroundColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
            lastName = LastNameTextField.text!
            print("lastname saved as: \(lastName!)")
            if firstName != nil{ //then username won't be nil
                username = firstName! + " " + lastName!
            }else{
                username = lastName!
            }
            UserNameLabel.text = username!
            print("username saved as \(username!)")
        }else{
            LastNameTextField.backgroundColor = #colorLiteral(red: 0.9693604275, green: 0.1983119405, blue: 0.09824349952, alpha: 1)
            LastNameTextField.text = ""
            LastNameTextField.attributedPlaceholder = NSAttributedString(string: "incomplete answer!", attributes: [NSAttributedString.Key.foregroundColor : UIColor.black.withAlphaComponent(0.3)])
            
        }
    }
    
    @IBAction func PhoneNumberTextFieldDidEndEditing(_ sender: UITextField) {
        if PhoneNumberTextField.text != nil && PhoneNumberTextField.text! != ""{
            if CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: PhoneNumberTextField.text!)) {
                if PhoneNumberTextField.text!.count != 10{
                    PhoneNumberTextField.text = ""
                    PhoneNumberTextField.attributedPlaceholder = NSAttributedString(string: "enter a 10 digit number", attributes: [NSAttributedString.Key.foregroundColor : UIColor.black.withAlphaComponent(0.3)])
                    PhoneNumberTextField.backgroundColor = #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)
                    return
                }
                phoneNumber = sender.text!
                PhoneNumberTextField.backgroundColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
            }else{
                PhoneNumberTextField.text = ""
                PhoneNumberTextField.attributedPlaceholder = NSAttributedString(string: "type only numbers", attributes: [NSAttributedString.Key.foregroundColor : UIColor.black.withAlphaComponent(0.3)])
                PhoneNumberTextField.backgroundColor = #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)
                return
            }
            print("phoneNumber saved as: \(phoneNumber!)")
        }else{
            PhoneNumberTextField.attributedPlaceholder = NSAttributedString(string: "incomplete phone number!!", attributes: [NSAttributedString.Key.foregroundColor : UIColor.black.withAlphaComponent(0.3)])
            PhoneNumberTextField.backgroundColor = #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)
        }
    }
    @IBAction func EmailTextfieldDidEndEditing(_ sender: UITextField) {
        if sender.text != nil && sender.text! != ""{
            email = sender.text!
            EmailTextField.backgroundColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
            print("email saved as \(email!)")
        }else{
            EmailTextField.attributedPlaceholder = NSAttributedString(string: "incomplete answer!!", attributes: [NSAttributedString.Key.foregroundColor : UIColor.black.withAlphaComponent(0.3)])
            EmailTextField.backgroundColor = #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)
        }
    }
    
    @IBAction func PasswordTextFieldDidEndEditing(_ sender: UITextField) {
        //use passwordRegex to validate that password has  8 characters (at least 1 alphabet and 1 number and 1 special character)
        if sender.text != nil && sender.text! != ""{
            password = sender.text!
            
            if passwordRegex.evaluate(with: password!) == false{
                PasswordTextField.attributedPlaceholder = NSAttributedString(string: "^Missing password Requirements", attributes: [NSAttributedString.Key.foregroundColor : UIColor.black.withAlphaComponent(0.3)])
                if password!.count < 8 {
                    PasswordTextField.attributedPlaceholder = NSAttributedString(string: "at least 8 characters long", attributes: [NSAttributedString.Key.foregroundColor : UIColor.black.withAlphaComponent(0.3)])
                }
                LoadingIndicatorLabel.isHidden = false
                LoadingIndicatorLabel.text = "Password requires 1 letter, 1 number 1 special character"
                PasswordTextField.backgroundColor = #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)
                PasswordTextField.text = ""
                return
            }
            
            //valid password was provided
            PasswordTextField.backgroundColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
            LoadingIndicatorLabel.isHidden = true
            LoadingIndicatorLabel.text = "Loading Please Wait"
            print("password saved as \(password!)")
            return
        }
        PasswordTextField.backgroundColor = #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)
        PasswordTextField.text = ""
        PasswordTextField.attributedPlaceholder = NSAttributedString(string: "incomplete answer!!", attributes: [NSAttributedString.Key.foregroundColor : UIColor.black.withAlphaComponent(0.3)])
        
    }
    
    
    @IBAction func SMStextFieldDidEndEditing(_ sender: UITextField) {
        //immediately submit code to firebase
        //show loading animation when needed
        if sender.text != nil && sender.text! != ""{
            //a valid number has been entered into the sms verification field
            if let validVerifID = verifID, let smsValue = sender.text{
                LoadingIndicatorLabel.isHidden = false
                LoadingIndicatorLabel.text = "Creating Account, Just a moment please"
                ErrorMessageLabel.isHidden = false
                ErrorMessageLabel.text = "Creating Account, Just a moment please"
                let credential = PhoneAuthProvider.provider().credential(withVerificationID: validVerifID, verificationCode: smsValue)
                //create user in the database based on their phoneNumber
                Auth.auth().signIn(with: credential) { (authResult, error) in
                    if let e = error{
                        self.ErrorMessageLabel.text = e.localizedDescription
                        self.LoadingIndicatorLabel.isHidden = true
                        return
                    }
                    //now merge user in database with their email/account info
                    let Ecredential = EmailAuthProvider.credential(withEmail: self.email!, password: self.password!)
                    Auth.auth().currentUser!.link(with: Ecredential){ authResult, error in
                        if error != nil{
                            self.ErrorMessageLabel.text = "invalid code, or an account is already linked to this phone number"//e.localizedDescription//"couldn't link account Close app and try again"
                            self.LoadingIndicatorLabel.isHidden = true
                            return
                        }
                        //create document in "Active Users <username> " collection named with the <username>
                        self.db.collection(K.Fstore.usersCollection).document(self.username!).setData([K.Fstore.userUserName: self.username!,K.Fstore.userPhoneNumber: self.phoneNumber!, K.Fstore.userEmail: self.email!, K.Fstore.userAge: self.age!], merge: true){ error in
                            if let e = error{
                                self.ErrorMessageLabel.text = e.localizedDescription
                                return
                            }
                            //store topical user information locally in the nativeUserInfo variable
                            nativeUserInfo.username=self.username
                            nativeUserInfo.email=self.email
                            nativeUserInfo.age=self.age
                            nativeUserInfo.phoneNumber=self.phoneNumber
                            nativeUserInfo.isValid = true //data saved into the nativeUserInfo variable successfully
                            let pathString =  nativeUserInfo.username! + "Pics" + "/profilePic.jpg"
                            let uploadRef = Storage.storage().reference(withPath: pathString )
                            guard let imageData = self.ProfilePicture.image?.jpegData(compressionQuality: 0.75) else{return}
                            let uploadMetadata = StorageMetadata.init()
                            uploadMetadata.contentType = "image/jpeg"
                            uploadRef.putData(imageData, metadata: uploadMetadata) { (downloadMetadata, error) in
                                if let error = error{
                                    print("error uploading image \(error.localizedDescription)")
                                    return
                                }
                                print("uploadImage is complete and I got this back: \(downloadMetadata)")
                            }
                            print("value of nativeUserInfo.isValid = \(nativeUserInfo.isValid)")
                            //account is now successfully created and stored in Firebase, Now segue to homeScreen
                            self.performSegue(withIdentifier: K.segueNames.RegisterToHomeScreen, sender: self)
                            return
                        }
                        
                    }
                }
            }
        }else{
            SMSTextField.backgroundColor = #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)
            SMSTextField.text = ""
            SMSTextField.attributedPlaceholder = NSAttributedString(string: "incomplete answer!!", attributes: [NSAttributedString.Key.foregroundColor : UIColor.black.withAlphaComponent(0.3)])
        }
        
    }
    
    
}

//Make View A photopickerDelegate
extension RegistrationViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            //set the globalFieldVariable
            profilePic = image
            self.ProfilePicture.image = image
            self.ProfilePicture.layer.cornerRadius=30
            addProfilePicLabelButton.setTitle("", for: .normal)
            AddProfilePicButton.setTitle("", for: .normal)
            ProfilePicBoarderview.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            ProfilePicBoarderview.layer.cornerRadius=35
            
        }
        dismiss(animated: true)
    }
}

extension RegistrationViewController: UIPickerViewDelegate ,UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 100
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return " \(data[row]) years old"
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        age = data[row]
        print("age Saved as: \(age!)")
    }
}

//make the view controller a textfield Delegate as to enable dismissing keyboard on pressing return key
extension RegistrationViewController: UITextFieldDelegate{
    //enable dismissing keyboard on pressing return key
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
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


