//
//  HomeController.swift
//  InstagramFirebase
//
//  Created by Mediha Karakuş on 26.03.23.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class HomeController: BaseListController, UICollectionViewDelegateFlowLayout, HomePostCellDelegate {
    
    
    let cellId = "cellId"
    override func viewDidLoad() {
        super.viewDidLoad()
    
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateFeed), name: SharePhotoController.updateFeedNotificationName, object: nil)
        
        collectionView.register(HomePostCell.self, forCellWithReuseIdentifier: cellId)
        
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView.refreshControl = refreshControl
        
        setupNavigationItems()
        fetchAllPosts()
    }
    
    @objc func handleUpdateFeed() {
        handleRefresh()
    }
    
    @objc func handleRefresh() {
        posts.removeAll()
        fetchAllPosts()
    }
    func fetchAllPosts() {
        fetchPosts()
        fetchFollowingUserIds()
    }
    
    fileprivate func fetchFollowingUserIds() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("Following").child(uid).observeSingleEvent(of: .value, with: { snapshot in
            guard let userDictionary = snapshot.value as? [String: Any] else { return }
            userDictionary.forEach { (key, value) in
                Database.fetchUserWithUID(key) { user in
                    self.fetchPostsWithUser(user: user)
                }
            }
            
        }) { err in
            print("Failed to fetch following users uid:", err)
        }
    }
    
    var posts = [Post]()

    fileprivate func fetchPosts() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Database.fetchUserWithUID(uid) { user in
            self.fetchPostsWithUser(user: user)
        }
    }
    
    fileprivate func fetchPostsWithUser(user: User) {
        let ref = Database.database().reference().child("posts").child(user.uid)
        
        ref.observeSingleEvent(of: .value, with: { snapshot in
            guard let dictionaries = snapshot.value as? [String: Any] else { return }
            
            self.collectionView.refreshControl?.endRefreshing()
            
            dictionaries.forEach { (key, value) in
                guard let dictionary = value as? [String: Any] else { return }
                
                var post = Post(user: user, dictionary: dictionary)
                
                post.id = key
                
                guard let uid = Auth.auth().currentUser?.uid else { return }
                Database.database().reference().child("likes").child(key).child(uid).observeSingleEvent(of: .value, with: { snapshot in
                    if let value = snapshot.value as? Int,  value == 1 {
                        post.hasLiked = true
                    } else {
                        post.hasLiked = false
                    }
                    
                    self.posts.append(post)
                    self.posts.sort { p1, p2 in
                        return p1.creationDate.compare(p2.creationDate) == .orderedDescending
                    }
                    self.collectionView?.reloadData()
                    
                }) { err in
                    print("Failed to fetch like info for posts: ", err)
                }
            }
        }) { err in
            print("Failed to fetch posts:", err)
        }
    }
    
    fileprivate func setupNavigationItems() {
        navigationItem.titleView = UIImageView(image: UIImage(named: "logo2"))
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "camera3"), style: .plain, target: self, action: #selector(handleCamera))
    }
    
    @objc func handleCamera() {
        let cameraController = CameraController()
        cameraController.modalPresentationStyle = .fullScreen
        present(cameraController, animated: true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! HomePostCell
        if !self.posts.isEmpty {
            cell.post = self.posts[indexPath.item]
        }
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var heigt: CGFloat = 40 + 8 + 8 // userprofilemageview + padding
        heigt += view.frame.width
        heigt += 50 //bottom actions
        heigt += 60 // caption
        
        return .init(width: view.frame.width, height: heigt)
    }
    
    func didTapComment(post: Post) {
        let commentsController = CommentsController()
        commentsController.post = post
        navigationController?.pushViewController(commentsController, animated: true)
    }
    
    func didLike(for cell: HomePostCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        var post = self.posts[indexPath.item]
        guard let postId = post.id else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let values = [uid: post.hasLiked == true ? 0 : 1]
        
        Database.database().reference().child("likes").child(postId).updateChildValues(values) { err, ref in
            if let err = err {
                print("Failed to like post: ", err)
                return
            }
            print("Successfully liked post.")
            post.hasLiked = !post.hasLiked
            self.posts[indexPath.item] = post
            self.collectionView.reloadItems(at: [indexPath])
        }
    }
    
}
