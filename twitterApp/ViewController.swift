//
//  ViewController.swift
//  twitterApp
//
//  Created by Ibrahim Mostafa on 11/17/17.
//  Copyright © 2017 Ibrahim Mostafa. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        login()
    }
   
    func login(){
        let logInButton = TWTRLogInButton(logInCompletion: { session, error in
            if (session != nil) {
                print("signed in as \(session?.userName)");
                
            } else {
                print("error: \(error?.localizedDescription)");
            }
            //print ( "-------------->" , Twitter.sharedInstance().sessionStore )
            
        })
        logInButton.center = self.view.center
        self.view.addSubview(logInButton)
        
    }
}

