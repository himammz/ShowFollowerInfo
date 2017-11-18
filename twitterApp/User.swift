//
//  User.swift
//  twitterApp
//
//  Created by Ibrahim Mostafa on 11/18/17.
//  Copyright © 2017 Ibrahim Mostafa. All rights reserved.
//

import Foundation
class User {
    
  
    func getMyFollowers(completionHandlerForFollowers: @escaping (_ followers: [follower]?, _ errorString: String?) -> Void)
    {
        let userid = "252103558"
        let client = TWTRAPIClient(userID: userid)
        let followerListEndpoint = "https://api.twitter.com/1.1/followers/list.json"
        
        var clientError : NSError?
        
        let request = client.urlRequest(withMethod: "GET", url: followerListEndpoint, parameters: nil, error: &clientError)
        
        client.sendTwitterRequest(request) { (response, data, connectionError) -> Void in
            
            if connectionError != nil {
                print("Error: \(connectionError)")
                completionHandlerForFollowers(nil,connectionError?.localizedDescription)
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
                
                guard let users = json["users"] as? [[String:AnyObject]]  else{
                    print ("No users Returned in Json")
                    completionHandlerForFollowers(nil,"Error in GetMyFollowers: missing users Key")
                    return
                }
                var followers = [follower]()
                for user in users{
                    guard let img = user["profile_image_url_https"] as? String , let name = user["name"] as? String ,let scName = user["screen_name"] as? String  else{
                        print ("No data for this user")
                        continue
                    }
                    followers.append(follower(name: name, screenName: scName, imageUrl: img))
                    print ("\(name)   @\(scName)")
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
