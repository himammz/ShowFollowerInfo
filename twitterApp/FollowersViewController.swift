//
//  FollowersViewController.swift
//  twitterApp
//
//  Created by Ibrahim Mostafa on 11/18/17.
//  Copyright © 2017 Ibrahim Mostafa. All rights reserved.
//

import Foundation

import UIKit

class FollowersViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
 
    var followers = [follower]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
       // tableView.rowHeight = UITableViewAutomaticDimension
        //tableView.estimatedRowHeight = 44
        getFollowers()

    }
    override func viewWillAppear(_ animated: Bool) {
        print ("hahahahaha")
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return followers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "followerCell")!
        
        let name = followers[indexPath.row].name!
        let scName = followers[indexPath.row].screenName!
        let imageUrl = followers[indexPath.row].imageUrl!
        
        let string = NSMutableAttributedString(string: name, attributes: [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 14)])
        
        string.append(NSMutableAttributedString(string:"\n@\(scName)", attributes: [NSAttributedStringKey.font  :UIFont.systemFont(ofSize: 14) ]))
        cell.textLabel?.attributedText = string
        User.sharedInstance().getImage(from: imageUrl) { (data, error) in
            if let data = data {
                cell.imageView?.image = UIImage(data: data)
            }
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Followers"
    }
    
    
  //  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    //   return UITableViewAutomaticDimension
    //}
    
    func getFollowers(){
        User.sharedInstance().getMyFollowers { (followers, error) in
            
            if let followers = followers{
                self.followers = followers
                self.tableView.reloadData()
            }
            
            
        }
    }
    
    
}
