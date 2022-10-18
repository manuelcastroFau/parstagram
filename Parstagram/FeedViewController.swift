//
//  FeedViewController.swift
//  Parstagram
//
//  Created by manuel  castro  on 10/4/22.
//

import UIKit
import Parse
import AlamofireImage
import MessageInputBar

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MessageInputBarDelegate{
    
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
        query.includeKeys(["author","comments", "comments.author"])
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
    
    let commentBar = MessageInputBar()
    var showsCommentBar = false
    
    var posts = [PFObject]()
    var selectedPost: PFObject!
    var numberOfPosts: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        commentBar.inputTextView.placeholder = "Add a comment"
        commentBar.sendButton.title = "Post"
        commentBar.delegate = self
        
        myRefreshControl.addTarget(self, action: #selector(loadInitialPosts), for: .valueChanged)
        tableView.refreshControl = myRefreshControl
        
        
        tableView.keyboardDismissMode = .interactive

        let center =  NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardWillBeHidden(note:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        

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
    
    @objc func keyboardWillBeHidden(note: Notification) {
        commentBar.inputTextView.text =  nil
        showsCommentBar =  false
        becomeFirstResponder()
    }
    
    override var inputAccessoryView: UIView? {
        return commentBar
    }
    
    override var canBecomeFirstResponder: Bool {
        return showsCommentBar
    }
    
    
    func loadMorePosts() {
        numberOfPosts += 5
        let query = PFQuery(className: "Posts")
        query.includeKeys(["author", "comments", "comments.author"])
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
    
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        // create the comment
        
        //let post = selectedPost as? PFObject!
        let comment = PFObject(className: "Comments")
        comment["text"] = commentBar.inputTextView.text
        comment["post"] = selectedPost
        comment["author"] = PFUser.current()!
        
        selectedPost.add(comment, forKey: "comments")
    
        selectedPost.saveInBackground { success, error in
            if success {
                print("comment saved")
            } else {
                        print("error saving comment")
            }
        }
        
        tableView.reloadData()
        
        //clear and dismiss input bar
        commentBar.inputTextView.text = nil
         
        showsCommentBar = false
        becomeFirstResponder()
        commentBar.inputTextView.resignFirstResponder()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            let post = posts[section]
            let comments = (post["comments"] as? [PFObject]) ?? []
            return comments.count + 2
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.section]
        let comments = (post["comments"] as? [PFObject]) ?? []
         
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
            
            let user = post["author"] as! PFUser
            cell.usernameLabel.text = user.username
            
            cell.captionLabel.text =  post["caption"] as! String
            
            let imageFile =  post["image"] as!  PFFileObject
            let urlString = imageFile.url!
            let url = URL(string: urlString)!
            
            cell.photoView.af.setImage(withURL: url)
             
            return cell
            
        } else if indexPath.row <= comments.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
            
            let comment = comments[indexPath.row - 1]
            
            cell.commentLabel.text =  comment["text"] as? String
            let user = comment["author"] as! PFUser
            cell.nameLabel.text = user.username
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddCommentCell")!
            return cell
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let post = posts[indexPath.row]
        let post = posts[indexPath.section]
//        let comment = PFObject(className: "Comments")
        let comments = post["comments"] as? [PFObject] ?? []
        
        
        if indexPath.row == comments.count + 1 {
        //if indexPath.section == comments.count + 1 {
            showsCommentBar = true
            becomeFirstResponder()
             
            commentBar.inputTextView.becomeFirstResponder()
            
            selectedPost = post
            
        }
//        comment["text"] = "this is a random comment"
//        comment["post"] = post
//        comment["author"] =  PFUser.current()!
//
//        post.add(comment, forKey: "comments")
//
//        post.saveInBackground { success, error in
//            if success {
//                print("comment saved")
//            } else {
//                print("error saving comment")
//            }
//        }
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section + 1 == posts.count {
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
    @IBAction func onLOgoutButton(_ sender: Any) {
        PFUser.logOut()
        
        let main = UIStoryboard(name:"Main", bundle: nil)
        let loginViewController =  main.instantiateViewController(withIdentifier: "LoginViewController")
        
        guard let windowsScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let delegate = windowsScene.delegate as? SceneDelegate else {return}
        delegate.window?.rootViewController = loginViewController
        
    }
    
}
