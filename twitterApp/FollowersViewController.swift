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
        print ("DidLoad")
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .reply, target: self, action: #selector(logout))
        getFollowers()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        print ("Willappear")
        
        
    }
    @objc func logout(){
        let userDef = UserDefaults.standard
        userDef.removeObject(forKey: "id")
        userDef.removeObject(forKey: "name")
        
        dismiss(animated: true, completion: nil)
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return followers.count
    }
    
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "followerCell")!
        
        let name = followers[indexPath.row].name!
        let scName = followers[indexPath.row].screenName!
        let imageData = followers[indexPath.row].imageData!
        
        let string = NSMutableAttributedString(string: name, attributes: [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 14)])
        
        string.append(NSMutableAttributedString(string:"\n@\(scName)", attributes: [NSAttributedStringKey.font  :UIFont.systemFont(ofSize: 14) ]))
        cell.textLabel?.attributedText = string
        cell.imageView?.contentMode = UIViewContentMode.scaleToFill
        cell.imageView?.image = UIImage(data: imageData)
        
        
        
        cell.detailTextLabel?.text = followers[indexPath.row].bio
        
        return cell
        
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Followers"
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let nextController = self.storyboard?.instantiateViewController(withIdentifier: "followerDetailes") as! FollowerInfoViweController
        nextController.follower = followers[indexPath.row]
        navigationController?.pushViewController(nextController, animated: true)
    }
    
    func getFollowers(){
        User.sharedInstance().getMyFollowers { (followers, error) in
            
            if let followers = followers{
                self.followers = followers
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    
                }
            }else {
                let followers = User.sharedInstance().getFollowersOffline()
                self.followers = followers
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    
                }
            }
            
        }
    }
    
    
}
