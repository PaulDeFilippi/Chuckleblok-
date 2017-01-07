//
//  SignInVC.swift
//  lets-get-social
//
//  Created by Paul Defilippi on 10/5/16.
//  Copyright © 2016 Paul Defilippi. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase
import SwiftKeychainWrapper

class SignInVC: UIViewController {
    
    @IBOutlet weak var emailField: FancyField!
    @IBOutlet weak var passwordField: FancyField!
    //@IBOutlet weak var usernameField: FancyField!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let _ = KeychainWrapper.standard.string(forKey: KEY_UID) {
            print("PAUL: ID found in keychain")
            performSegue(withIdentifier: "goToFeed", sender: nil)
        }
    }

//    @IBAction func facebookBtnPressed(_ sender: AnyObject) {
//        
//        let facebookLogin = FBSDKLoginManager()
//        
//        facebookLogin.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
//            if error != nil {
//                print("PAUL: Unable to authenticate with Facebook - \(error)")
//            } else if result?.isCancelled == true {
//                print("PAUL: User cancelled Facebook authentication")
//            } else {
//                print("PAUL: Successfully authenticated with Facebook")
//                let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
//                self.firebaseAuth(credential)
//            }
//        }
//    
//    }
    
    func firebaseAuth(_ credential: FIRAuthCredential) {
        FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
            if error != nil {
                print("PAUL: Unable to authenticate with Firebase - \(error)")
            } else {
                print("PAUL: Successfully authenticated with Firebase")
                if let user = user {
                    let userData = ["provider": credential.provider]
                    self.completeSignIn(id: user.uid, userData: userData)
                }
            }
        })
    }
    
    @IBAction func signInTapped(_ sender: AnyObject) {
        
        if let email = emailField.text, let pwd = passwordField.text {
            FIRAuth.auth()?.signIn(withEmail: email, password: pwd, completion: { (user, error) in
                if error == nil {
                    print("PAUL: Email user authenticated with Firebase")
                    if let user = user {
                        let userData = ["provider": user.providerID]
                        self.completeSignIn(id: user.uid, userData: userData)
                    }
                } else {
                    FIRAuth.auth()?.createUser(withEmail: email, password: pwd, completion:  { (user, error) in
                        if error != nil {
                            print("PAUL: Unable to authenticate with firebase \(error)")
                        } else {
                            print("PAUL: Successfully authenticated with Firebase")
                            if let user = user {
                                let userData = ["provider": user.providerID]
                                self.completeSignIn(id: user.uid, userData: userData)
                            }
                            
                        }
                        
                    })
                }
            })
        }
    }
    
    func completeSignIn(id: String, userData: Dictionary<String, String>) {
        DataService.ds.createFirebaseDBUser(uid: id, userData: userData)
        let keychainResult = KeychainWrapper.standard.set(id, forKey: KEY_UID)
        print("PAUL: Data saved to keychain \(keychainResult)")
        performSegue(withIdentifier: "goToFeed", sender: nil)
    }
}

