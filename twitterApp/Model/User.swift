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
                    var background:String
                    if  user["profile_banner_url"] == nil{
                        background = "https://mareeg.com/wp-content/uploads/2016/11/twitter.jpg"
                    }
                    else {
                        background = user["profile_banner_url"] as! String
                    }
                    var profImgData:Data?
                    var backgroundImgData:Data?
                    self.getImage(from: img, completionHandlerForImage: { (imageData, error) in
                        if let imgData = imageData{
                            profImgData = imgData
                        }
                        
                    })
                    self.getImage(from: background, completionHandlerForImage: { (imageData, error) in
                        if let imgData = imageData{
                            backgroundImgData = imgData
                        }
                    })
                    followers.append(follower(name: name, screenName: scName, imageData: profImgData, bio: desc, backgroundImageData: backgroundImgData))
                    // print ("\(name)   @\(scName) ")
                }
                
                self.SaveFollowersInfo(followers)
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
    
    
    func getFollowerTweets(_ screenName:String, completionHandlerForFollowerDetails: @escaping (_ tweets:[String]?, _ errorString:String?)-> Void){
        
        let client = TWTRAPIClient()
        let statusesShowEndpoint = "https://api.twitter.com/1.1/statuses/user_timeline.json"
        let params = ["screen_name": screenName ,"count": "10"]
        var clientError : NSError?
        
        let request = client.urlRequest(withMethod: "GET", url: statusesShowEndpoint, parameters: params, error: &clientError)
        
        client.sendTwitterRequest(request) { (response, data, connectionError) -> Void in
            if connectionError != nil {
                print("Error: \(connectionError)")
                completionHandlerForFollowerDetails(nil, connectionError?.localizedDescription)
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as? [[String:AnyObject]]
                //print("json: \(json)")
                var  tweets = [String]()
                for tweetInfo in json!{
                    guard let tweet = tweetInfo["text"] as? String else{
                        print ("text key not found!!")
                        continue
                    }
                    
                    tweets.append(tweet)
                    
                }
                
                completionHandlerForFollowerDetails(tweets, nil)
            } catch let jsonError as NSError {
                print("json error: \(jsonError.localizedDescription)")
                completionHandlerForFollowerDetails(nil, jsonError.localizedDescription)
            }
        }
    }
    
    
    
    func SaveFollowersInfo(_ followers:[follower]){
        deleteFollowers()
        for follower in followers{
            let followerData = FollowerInfo(context: context)
            
            followerData.name = follower.name
            followerData.scName = follower.screenName
            followerData.bio = follower.bio
            followerData.profileImage = follower.imageData
            followerData.backgroundImage = follower.backgroundImageData
            
            do{
                ad.saveContext()
            }catch{
                print ("cant save")
            }
            
        }
        
        
    }
    func deleteFollowers(){
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "FollowerInfo")
        let request = NSBatchDeleteRequest(fetchRequest: fetch)
        
        
        do {
            try  context.execute(request)
            try context.save()
        } catch let error as NSError {
            // TODO: handle the error
            print ("Error While delete Follower data")
        }
        
        
        
    }
    func getFollowersOffline() -> [follower]{
        let fetch:NSFetchRequest<FollowerInfo> = FollowerInfo.fetchRequest()
        
        var followersInfo:[FollowerInfo]
        var followers = [follower]()
        do{
            followersInfo = try context.fetch(fetch)
            
            for followerInfo in followersInfo{
                followers.append(follower(name: followerInfo.name!, screenName: followerInfo.scName!, imageData: followerInfo.profileImage!, bio: followerInfo.bio!, backgroundImageData: followerInfo.backgroundImage!) )
            }
            
        }catch{
            print ("can't Load Follower offline")
            
        }
        return followers
    }
    class func sharedInstance() -> User {
        struct Singleton {
            static var sharedInstance = User()
        }
        return Singleton.sharedInstance
    }
}
