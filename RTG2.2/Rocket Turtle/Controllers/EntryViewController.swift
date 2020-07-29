//
//  ViewController.swift
//  Rocket Turtle
//
//  Created by James Grom on 6/30/20.
//  Copyright © 2020 Rocket Turtle Innovations. All rights reserved.
//

import UIKit
import SwiftUI

class EntryViewController: UIViewController {

    @IBAction func LoginButtonPressed(_ sender: UIButton) {
        sender.setBackgroundImage(UIImage(named: "BlueLoginButton"), for: .normal)
            DispatchQueue.main.async {
                Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: {_ in sender.setBackgroundImage(UIImage(named: "LoginPaintButton"), for: .normal)})
                
            }
    }
    
    @IBAction func RegisterButtonPressed(_ sender: UIButton) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.isHidden=true
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden=true
    }
}




//create a uiviewControllerRepresentable
struct EntryViewControllerRepresentable: UIViewControllerRepresentable{
    
    func makeUIViewController(context: Context) -> EntryViewController {
        return EntryViewController()
    }
    func updateUIViewController(_ uiViewController: EntryViewController, context: Context) {
        
    }
}




struct EntryViewController_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}
