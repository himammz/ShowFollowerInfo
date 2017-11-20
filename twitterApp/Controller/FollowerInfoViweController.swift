//
//  FollowerInfoViweController.swift
//  twitterApp
//
//  Created by Ibrahim Mostafa on 11/19/17.
//  Copyright © 2017 Ibrahim Mostafa. All rights reserved.
//

import UIKit

class FollowerInfoViweController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    var follower:follower!
    var tweets = [String]()
    
    @IBOutlet weak var followerName: UILabel!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        addDetails()
        loadTweets()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tweet")!
        cell.textLabel?.text = tweets[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Tweets"
    }
    
    func addDetails(){
        
        followerName.text = follower.name!
        
        var imgData = follower.backgroundImageData!
        backgroundImage.image = UIImage(data:imgData)
        
        imgData = follower.imageData!
        profileImage.image = UIImage(data:imgData)
        
    }
    
    func loadTweets()  {
        User.sharedInstance().getFollowerTweets(follower.screenName!) { (tweets, error) in
            if let tweets = tweets{
                self.tweets = tweets
    
            }else {
                
                self.tweets = User.sharedInstance().getTweetsOffline(self.follower.screenName!)
                
            }
            
            DispatchQueue.main.async{
                self.tableView.reloadData()
            }
        }
        
    }
    
    
}
