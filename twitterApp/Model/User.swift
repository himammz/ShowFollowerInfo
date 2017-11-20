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
                    var background = "https://mareeg.com/wp-content/uploads/2016/11/twitter.jpg"
                    
                    if  let bacImg = user["profile_background_image_url_https"] as? String {
                        background = bacImg
                    }
                    
                    var profImgData:Data?
                    var backgroundImgData:Data?
                    
                    //print (img)
                    let imageData1 = self.getImage(from: img)
                    if let imgData = imageData1{
                        profImgData = imgData
                    }
                    
                    //print (background)
                    //print ("-------")
                   let  imageData2 = self.getImage(from: background)
                    if let imgData = imageData2{
                        backgroundImgData = imgData
                    }
                    
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
    
    func getImage(from: String) ->Data?
    {
        let url =  URL(string: from)
        do{
            let imageData = try  Data(contentsOf: url!)
            return imageData
        }catch {
            print (url)
            return nil
            
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
                self.SaveTweets(screenName,tweets)
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
                print ("can't save follower info.")
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
              /*  print (followerInfo.name)
                print (followerInfo.scName)
                print (followerInfo.profileImage)
                print (followerInfo.bio)
                print (followerInfo.backgroundImage)
                print ("----------")*/
                followers.append(follower(name: followerInfo.name!, screenName: followerInfo.scName!, imageData: followerInfo.profileImage!, bio: followerInfo.bio!, backgroundImageData: followerInfo.backgroundImage!) )
            }
            
        }catch{
            print ("can't Load Follower offline")
            
        }
        return followers
    }
    
    
    func SaveTweets(_ screenName:String,_ tweets:[String]){
        deleteTweets(screenName)
        let owner  = getFollower(screenName)
        for tweet in tweets{
            let tweetInfo = Tweet(context: context)
            
            tweetInfo.tweetText = tweet
            
            
            print (owner?.scName!)
            tweetInfo.followerOwner = owner!
            print ("-->", tweetInfo.followerOwner?.scName!)
            
            do{
                ad.saveContext()
            }catch{
                print ("can't save tweet")
            }
            
        }
        
    }
    func getFollower (_ scName:String) -> FollowerInfo?{
        let fetch:NSFetchRequest<FollowerInfo> = FollowerInfo.fetchRequest()
         fetch.predicate = NSPredicate(format: "scName == %@", scName)
        do{
            let Finfo = try context.fetch(fetch)
            return Finfo[0]
        }catch{
            return nil
        }
        
    }
    func deleteTweets(_ scName:String){
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Tweet")
        fetch.predicate = NSPredicate(format: "followerOwner.scName == %@", scName)
        let request = NSBatchDeleteRequest(fetchRequest: fetch)
        
        
        do {
            try  context.execute(request)
            try context.save()
        } catch let error as NSError {
            // TODO: handle the error
            print ("Error While delete tweets.")
        }
        
    }
    
    func getTweetsOffline(_ screenName:String) -> [String]{
        let fetch:NSFetchRequest<Tweet> = Tweet.fetchRequest()
        fetch.predicate = NSPredicate(format: "followerOwner.scName == %@", screenName)
        
        var tweetsInfo:[Tweet]
        var tweets = [String]()
        do{
            tweetsInfo = try context.fetch(fetch)
            
            for tweet in tweetsInfo{
                print (tweet.followerOwner?.scName)
                tweets.append(tweet.tweetText!)
            }
            
        }catch{
            print ("can't Load Follower offline")
            
        }
        return tweets
    }
    //
    class func sharedInstance() -> User {
        struct Singleton {
            static var sharedInstance = User()
        }
        return Singleton.sharedInstance
    }
}
