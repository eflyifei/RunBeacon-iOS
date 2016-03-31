//
//  LoginViewController.swift
//  Run
//
//  Created by Jason Ho on 17/3/2016.
//  Copyright © 2016 Arefly. All rights reserved.
//

import UIKit
import CoreLocation
import Foundation
import Async
import Alamofire
import CocoaLumberjack
import KLCPopup
import Locksmith

class LoginViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate {
    
    // MARK: - IBOutlet var
    @IBOutlet var loginView: UIView!
    @IBOutlet var usernameTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var loginButton: UIButton!
    
    // MARK: - Basic var
    var locationManager: CLLocationManager!
    
    
    // MARK: - Override func
    override func viewDidLoad() {
        super.viewDidLoad()
        DDLogInfo("Login View Controller 之 super.viewDidLoad() 已加載")
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        self.view.addGestureRecognizer(tap)
        
        
        self.view.backgroundColor = UIColor(red: 135/255, green: 211/255, blue: 124/255, alpha: 1.0)
        
        loginView.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.3)
        loginView.layer.cornerRadius = 4.0
        
        
        loginButton.addTarget(self, action: #selector(self.loginButtonAction), forControlEvents: .TouchUpInside)
        
        
        usernameTextField.delegate = self
        usernameTextField.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.7)
        
        passwordTextField.delegate = self
        passwordTextField.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.7)
        
        
        /*
        /*** 僅供測試、實際將使用下方viewWillAppear的函數 ***/
        DDLogInfo("目前沒有Checkpoints相關數據儲存於本地、即將顯示下載View")
        self.performSegueWithIdentifier("showDataLoadingView", sender: self)
        */
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        DDLogInfo("Login View Controller 之 super.viewWillAppear() 已加載")
        
        usernameTextField.text = ""
        passwordTextField.text = ""
        
        
        if(CheckpointFunc().getCheckpoints().count > 0){
            DDLogInfo("目前已有Checkpoints相關數據儲存於本地")
        }else{
            DDLogInfo("目前沒有Checkpoints相關數據儲存於本地、即將顯示下載View")
            self.performSegueWithIdentifier("showDataLoadingView", sender: self)
        }
        
        
        if let accountData = Locksmith.loadDataForUserAccount(BasicConfig.UserAccountID) {
            if let username = accountData["username"] {
                if let _ = accountData["password"] {
                    DDLogInfo("目前用戶已登入賬戶（\(accountData)）、即將進入主界面")
                    Async.main {
                        let screenSize: CGRect = UIScreen.mainScreen().bounds
                        
                        let welcomeLabel = UILabel(frame: CGRectMake(0, 0, screenSize.width*0.8, 80.0))
                        welcomeLabel.text = "Welcome back, \(username)!"
                        welcomeLabel.textAlignment = .Center
                        welcomeLabel.backgroundColor = UIColor.whiteColor()
                        welcomeLabel.layer.cornerRadius = 5.0
                        welcomeLabel.clipsToBounds = true
                        
                        let popupController = KLCPopup(contentView: welcomeLabel)
                        popupController.shouldDismissOnContentTouch = true
                        popupController.shouldDismissOnBackgroundTouch = true
                        popupController.maskType = .Dimmed
                        popupController.showType = .GrowIn
                        popupController.dismissType = .GrowOut
                        
                        popupController.willStartDismissingCompletion = {
                            self.showPracticeView()
                        }
                        
                        let layout = KLCPopupLayoutMake(.Center, .Center)
                        popupController.showWithLayout(layout, duration: 2.0)
                    }
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - TextField func
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if(textField == usernameTextField){ // Switch focus to other text field
            passwordTextField.becomeFirstResponder()
        }else if(textField == passwordTextField){
            loginButton.sendActionsForControlEvents(.TouchUpInside)
        }
        
        return true
    }
    
    
    // MARK: - Action func
    func loginButtonAction() {
        let dataToBeStored = ["username": usernameTextField.text!, "password": passwordTextField.text!]
        
        do {
            try Locksmith.updateData(dataToBeStored, forUserAccount: BasicConfig.UserAccountID)
            DDLogDebug("已儲存用戶名及密碼：\(dataToBeStored)")
            
            showPracticeView()
        } catch {
            DDLogError("無法儲存用戶名及密碼（\(dataToBeStored)）：\(error)")
        }
    }
    
    func showPracticeView() {
        Async.main {
            self.performSegueWithIdentifier("showPracticeView", sender: self)
        }
    }
    
    func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
}