//
//  MessangerViewController.swift
//  Rocket Turtle
//
//  Created by James Grom on 7/3/20.
//  Copyright © 2020 Rocket Turtle Innovations. All rights reserved.
//

import UIKit
import Firebase 

class MessengerViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    //create a basic array of messages to hold the info
    var messages: [Message] = [Message(sender: "Steve", body:)]
   

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
