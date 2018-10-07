//
//  Utility.swift
//  Energieq
//
//  Created by Binate on 10/5/18.
//  Copyright © 2018 Shah Yasin. All rights reserved.
//

import UIKit
import MBProgressHUD
import Reachability
class Utility: NSObject {

   class func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    class func showProgressView(view : UIView){
        let loadingNotification = MBProgressHUD.showAdded(to: view, animated: true)
        loadingNotification.mode = MBProgressHUDMode.indeterminate
        loadingNotification.label.text = "Loading"
    }
    
   class func hideProgressView(view : UIView){
        MBProgressHUD.hide(for: view, animated: true);
    }

    class func setLoginStatus(status: Bool){
        UserDefaults.standard.set(status, forKey: Constants.LoggedIn_Key)
    }
    
    class func getLoginStatus() -> Bool{
        return UserDefaults.standard.bool(forKey: Constants.LoggedIn_Key)
    }
    
    class func setUserUUID(id: String){
        UserDefaults.standard.set(id, forKey: Constants.UserUUID_Key)
    }
    
    class func getUserUUID() -> String{
        let value = UserDefaults.standard.object(forKey: Constants.UserUUID_Key) ?? ""
        return value as! String
    }
    
    class func setUserProfileStatus(value: NSInteger){
        UserDefaults.standard.set(value, forKey: Constants.UserProfile_Key)
    }
    
    class func getUserProfileStatus() -> NSInteger{
        let value = UserDefaults.standard.object(forKey: Constants.UserProfile_Key) ?? 0
        return value as! NSInteger
    }

    
    class func setUserToken(id: String){
        UserDefaults.standard.set(id, forKey: Constants.UserToken_Key)
    }
    
    class func getUserToken() -> String{
        let value = UserDefaults.standard.object(forKey: Constants.UserToken_Key) ?? ""
        return value as! String
    }
    
    class func setShadowInView(view: UIView){
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowColor = UIColor(displayP3Red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0).cgColor
    }
    
    class func setShadowInNavBar(view: UINavigationBar){
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowColor = UIColor(displayP3Red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0).cgColor
    }
    
    class func makeRoundedImageView(imageView:UIImageView){
        imageView.layer.cornerRadius = imageView.frame.size.width/2
        imageView.clipsToBounds = true
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 1.0
    }
    
    class func setIsFirstTimeLoggedIn(frstTime:Bool){
        UserDefaults.standard.set(frstTime, forKey: Constants.UserFrstTime_Key)
    }

    class func getIsFirstTimeLoggedIn() -> Bool{
        let value = UserDefaults.standard.object(forKey: Constants.UserFrstTime_Key) ?? true
        return value as! Bool
    }

    
    class func getHasAcceptedTerms() -> NSInteger{
        let value = UserDefaults.standard.object(forKey: Constants.AcceptedTerms_Key) ?? 0
        return value as! NSInteger
    }

    class func setHasAcceptedTerms(frstTime:NSInteger){
        UserDefaults.standard.set(frstTime, forKey: Constants.AcceptedTerms_Key)
    }

    
   class func isStringAnInt(string: String) -> Bool {
        return Int(string) != nil
    }
    class func checkIntenetConnection() -> Bool {
        var isConnected = Bool()
        
        let reachability = Reachability()!
        switch reachability.connection {
        case .wifi:
            isConnected = true
        case .cellular:
            isConnected = true
        case .none:
            isConnected = false
        }
        return isConnected
    }
    
    class func borderLayerFunc(id: AnyObject){
        id.layer.cornerRadius = 5.0
        id.layer.borderColor = UIColor.hexStringToUIColor(hex: Constants.primaryBlueColor).cgColor
        id.layer.borderWidth = 1.0
        id.layer.shadowOffset = CGSize(width: 0, height: 1.5)
        id.layer.shadowColor = UIColor.black.cgColor
        id.layer.shadowOpacity = 0.25
        id.layer.shadowRadius = 4.0
    }
}
