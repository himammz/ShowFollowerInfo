//
//  User.swift
//  twitterApp
//
//  Created by Ibrahim Mostafa on 11/18/17.
//  Copyright © 2017 Ibrahim Mostafa. All rights reserved.
//

import Foundation
import UIKit
class User {
    
    var userID:String?
    var userName:String?
    func initMe(_ id:String ,_ name:String){
        userName = name
        userID = id
    
    }
    func logUserIn(_ controllerSender:UIViewController, completionHandelerForLogIn: @escaping (_ success:Bool, _ errorString:String?) -> Void ){
        
        let logInButton = TWTRLogInButton(logInCompletion: { session, error in
            if (session != nil) {
                print("signed in as \(session?.userName)");
                self.userID =  session?.userID
                self.userName = session?.userName
                let userDef = UserDefaults.standard
                userDef.setValue(self.userID!, forKey: "id")
                userDef.setValue(self.userName!, forKey: "name")
                completionHandelerForLogIn(true, nil)
            } else {
                print("error: \(error?.localizedDescription)");
                completionHandelerForLogIn(false, "Error while Log in")
            }
            //print ( "-------------->" , Twitter.sharedInstance().sessionStore )
            
        })
        logInButton.center = controllerSender.view.center
        controllerSender.view.addSubview(logInButton)
        
    }
    
    
    func getMyFollowers(completionHandlerForFollowers: @escaping (_ followers: [follower]?, _ errorString: String?) -> Void)
    {
        let client = TWTRAPIClient(userID: userID)
        let followerListEndpoint = "https://api.twitter.com/1.1/followers/list.json"
        let parameter = ["count":"200"]
        var clientError : NSError?
        
        let request = client.urlRequest(withMethod: "GET", url: followerListEndpoint, parameters: parameter, error: &clientError)
        
        client.sendTwitterRequest(request) { (response, data, connectionError) -> Void in
            
            if connectionError != nil {
                print("Error: \(connectionError)")
                completionHandlerForFollowers(nil,connectionError?.localizedDescription)
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as? NSDictionary
                //print (json)
                guard let users = json?["users"] as? [[String:AnyObject]]  else{
                    print ("No users Returned in Json")
                    completionHandlerForFollowers(nil,"Error in GetMyFollowers: missing users Key")
                    return
                }
                var followers = [follower]()
                for user in users{
                    guard let img = user["profile_image_url_https"] as? String , let name = user["name"] as? String ,let scName = user["screen_name"] as? String  ,let desc = user["description"] as? String  else{
                        print ("No data for this user")
                        continue
                    }
                    followers.append(follower(name: name, screenName: scName, imageUrl: img, bio: desc))
                    print ("\(name)   @\(scName) ")
                }
                
                
                completionHandlerForFollowers(followers,nil)
                
                
            } catch let jsonError as NSError {
                print("json error: \(jsonError.localizedDescription)")
                completionHandlerForFollowers(nil,"Error in GetMyFollowers: can't parse to Json")
                
            }
            
            
        }
    }
    
    func getImage(from: String, completionHandlerForImage: @escaping (_ imageData: Data?, _ errorString:String?) -> Void)
    {
        let url =  URL(string: from)
        do{
            let imageData = try  Data(contentsOf: url!)
            completionHandlerForImage(imageData,nil)
        }catch {
            completionHandlerForImage(nil,"Error in getImage: data has an error")
            
        }
        
        
        
    }
    
    class func sharedInstance() -> User {
        struct Singleton {
            static var sharedInstance = User()
        }
        return Singleton.sharedInstance
    }
}
