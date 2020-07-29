//
//  UserInfo.swift
//  Rocket Turtle
//
//  Created by James Grom on 7/7/20.
//  Copyright © 2020 Rocket Turtle Innovations. All rights reserved.
//

import Foundation
//user info whose values are to be set upon login
//The purpose of this variable is to avoid unnecessary calls to the Firebase database
struct NativeUserInfo {
    var isValid = false //changed to true only once the nativeUserInfo variable has been updated
    var username: String?
    var email: String?
    var age: Int?
    var phoneNumber: String?
    var honorScore: String?
}
//global variable that is hopefully accessible to all files in the project
var nativeUserInfo = NativeUserInfo()
