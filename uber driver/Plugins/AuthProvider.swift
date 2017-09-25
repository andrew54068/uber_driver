//
//  AuthProvider.swift
//  uber driver
//
//  Created by kidnapper on 22/09/2017.
//  Copyright © 2017 kidnapper.com. All rights reserved.
//

import Foundation
import FirebaseAuth

typealias LoginHandler = (_ msg: String?) -> Void

struct LoginErrorCode {
    static let INVALID_EMAIL = "Invalid Email Address. Please Provide A Real Email Address"
    static let WRONG_PASSWORD = "Invalid Password, Please Enter the Correct Password"
    static let PROBLOM_CONNECTING = "Problem Connecting To Database, Please Try Later"
    static let USER_NOT_FOUND = "User Not Found, Please Register"
    static let EMAIL_AREADY_IN_USE = "Email Already In Use, Please Use Another Email"
    static let WEAK_PASSWORD = "Password Should Be At least 6 Characters long"
    
}

class AuthProvider{
    private static let _instance = AuthProvider()
    static var Instance: AuthProvider{
        return _instance
    }
    
    func login(withEmail:String, password:String, loginHandler:LoginHandler?){
        Auth.auth().signIn(withEmail: withEmail, password: password) { (user, error) in
            if error != nil {
                self.handleErrors(err: error! as NSError, loginHandler: loginHandler)
            }else{
                loginHandler?(nil)
            }
        }
    }
    func signUp(withEmail: String, password: String, loginHandler:LoginHandler?){
        Auth.auth().createUser(withEmail: withEmail, password: password) { (user, error) in
            if error != nil{
                self.handleErrors(err: error! as NSError, loginHandler: loginHandler)
            }else {
                if user?.uid != nil {
                    
                    //store the user to database
                    DBProvider.Instance.saveUser(withID: user!.uid, email: withEmail, password: password)
                    //login the user
                    self.login(withEmail: withEmail, password: password, loginHandler: loginHandler)
                }
            }
        }
    }
    func logout() -> Bool {
        if Auth.auth().currentUser != nil{
            do {
                try Auth.auth().signOut()
                return true
            }catch{
                return false
            }
        }
        return true
    }
    
    private func handleErrors(err: NSError, loginHandler: LoginHandler?){
        print("\(err.code)")
        if let error = AuthErrorCode.init(rawValue: err.code)   {
            print("error = \(error.rawValue)")
            switch error{
            
            case .wrongPassword:
                loginHandler?(LoginErrorCode.WRONG_PASSWORD)
                break;
            case .invalidEmail:
                loginHandler?(LoginErrorCode.INVALID_EMAIL)
                break;
            case .userNotFound:
                loginHandler?(LoginErrorCode.USER_NOT_FOUND)
                break;
            case .emailAlreadyInUse:
                loginHandler?(LoginErrorCode.EMAIL_AREADY_IN_USE)
                break;
            case .weakPassword:
                loginHandler?(LoginErrorCode.WEAK_PASSWORD)
                break;
            default:
                loginHandler?(LoginErrorCode.PROBLOM_CONNECTING)
                break;
            }
        }
    }
    
}
