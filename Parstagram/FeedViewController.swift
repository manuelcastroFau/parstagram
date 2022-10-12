//
//  FeedViewController.swift
//  Parstagram
//
//  Created by manuel  castro  on 10/4/22.
//

import UIKit
import Parse
import AlamofireImage

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    //var refreshControl: UIRefreshControl!
    
    let myRefreshControl = UIRefreshControl()
    
//    @objc func onRefresh() {
         
        //refreshControl = UIRefreshControl()
        //refreshControl.addTarget(self, action: #selector(onRefresh), for: .valueChanged)
        //tableView.insertSubview(refreshControl, at: 0)
        //tableView.refreshControl = refreshControl
//    }
    
    

    @objc func loadInitialPosts() {
        numberOfPosts = 5
        
        let query = PFQuery(className: "Posts")
        query.includeKey("author")
        query.limit = numberOfPosts
        query.order(byDescending: "updatedAt")
        
        query.findObjectsInBackground { (posts, error) in
            if posts != nil {
                self.posts = posts!
                self.tableView.reloadData()
                self.myRefreshControl.endRefreshing()
            }
        }
    }
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var posts = [PFObject]()
    var numberOfPosts: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        myRefreshControl.addTarget(self, action: #selector(loadInitialPosts), for: .valueChanged)
        tableView.refreshControl = myRefreshControl
        
        

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        numberOfPosts = 5
//
//        let query = PFQuery(className: "Posts")
//        query.includeKey("author")
//        query.limit = numberOfPosts
//
//        query.findObjectsInBackground { (posts, error) in
//            if posts != nil {
//                self.posts = posts!
//                self.tableView.reloadData()
//            }
//        }
        self.loadInitialPosts()
        
    }
    
    
    
    func loadMorePosts() {
        numberOfPosts += 5
        let query = PFQuery(className: "Posts")
        query.includeKey("author")
        query.limit = numberOfPosts
        //query.addAscendingOrder("createdAt")
        query.order(byDescending: "updatedAt")
        
        query.findObjectsInBackground { (posts, error) in
            if posts != nil {
                self.posts = posts!
                self.tableView.reloadData()
            }
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
        
        let post = posts[indexPath.row]
        
        let user = post["author"] as! PFUser
        cell.usernameLabel.text = user.username
        
        cell.captionLabel.text =  post["caption"] as! String
        
        let imageFile =  post["image"] as!  PFFileObject
        let urlString = imageFile.url!
        let url = URL(string: urlString)!
        
        cell.photoView.af.setImage(withURL: url)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == posts.count {
            loadMorePosts()
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
