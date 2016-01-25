//
//  ViewController.swift
//  Dated
//
//  Created by Benjamin Van Houten on 1/24/16.
//  Copyright © 2016 Benjamin Van Houten. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import ParseFacebookUtilsV4
import Parse

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func signInToFacebook(sender: AnyObject) {
        
        let permissions = ["public_profile", "email"];
        
        PFFacebookUtils.logInInBackgroundWithReadPermissions(permissions) {
            (user: PFUser?, error: NSError?) -> Void in
            if let user = user {
                if user.isNew {
                    print("User signed up and logged in through Facebook!")
                } else {
                    print("User logged in through Facebook!")
                }
            } else {
                print("Uh oh. The user cancelled the Facebook login.")
            }
            
            print(user);
            print("Current user token=\(FBSDKAccessToken.currentAccessToken().tokenString)");
            print("Current user id \(FBSDKAccessToken.currentAccessToken().userID)");
            
            self.getUserInfo()
        }
    }
    
    func getUserInfo(){
        if((FBSDKAccessToken.currentAccessToken()) != nil){
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).startWithCompletionHandler({ (connection, result, error) -> Void in
                if (error == nil ){
                    if(result != nil){
                        let userId:String = result["id"] as! String
                        let userFirstName:String? = result["first_name"] as? String
                        let userLastName:String? = result["last_name"] as? String
                        let userEmail:String? = result["email"] as? String
                        let myUser:PFUser = PFUser.currentUser()!
                        
                        // Save first name
                        if(userFirstName != nil){
                            myUser.setObject(userFirstName!, forKey: "first_name")
                        }
                        //Save last name
                        if(userLastName != nil){
                            myUser.setObject(userLastName!, forKey: "last_name")
                        }
                        // Save email address
                        if(userEmail != nil){
                            myUser.setObject(userEmail!, forKey: "email")
                        }
                        
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                            
                            // Get Facebook profile picture
                            let userProfile = "https://graph.facebook.com/" + userId + "/picture?type=large"
                            let profilePictureUrl = NSURL(string: userProfile)
                            let profilePictureData = NSData(contentsOfURL: profilePictureUrl!)
                            
                            if(profilePictureData != nil)
                            {
                                let profileFileObject = PFFile(data:profilePictureData!)
                                myUser.setObject(profileFileObject!, forKey: "profile_picture")
                            }
                            
                            myUser.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                                if(success)
                                {
                                    print("User details are now updated")
                                }
                            })
                            
                        }
                        
                    }

                    self.triggerSegue()
                }
            })
        }
    }
    
    func triggerSegue(){
        let protected = self.storyboard?.instantiateViewControllerWithIdentifier("ProtectedViewController") as! ProtectedViewController
        
        let protectedNav = UINavigationController(rootViewController: protected)
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        appDelegate.window?.rootViewController = protectedNav
    }

}

