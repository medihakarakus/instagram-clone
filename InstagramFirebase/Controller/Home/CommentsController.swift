//
//  CommentsController.swift
//  InstagramFirebase
//
//  Created by Mediha Karakuş on 29.03.23.
//

import UIKit
import Firebase

class CommentsController: BaseListController, UICollectionViewDelegateFlowLayout, CommentInputAccessoryViewDelegate{
    
    var post: Post?
    var cellId = "cellId"
     
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = .white
        navigationItem.title = "Comments"
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .interactive
        
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: -80, right: 0)
        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: -80, right: 0)
        collectionView.register(CommentCell.self, forCellWithReuseIdentifier: cellId)
        fetchComments()
    }
    
    var comments = [Comment]()
    fileprivate func fetchComments() {
        guard let postId = post?.id else { return }
        let ref = Database.database().reference().child("comments").child(postId)
        ref.observe(.childAdded, with: { snapshot in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            guard let uid = dictionary["uid"] as? String else { return }
            
            Database.fetchUserWithUID(uid) { user in
                let comment = Comment(user: user, dictionary: dictionary)
                self.comments.append(comment)
                self.collectionView.reloadData()
            }
        }) { err in
            print("Failed to observe comments.")
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return comments.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! CommentCell
        cell.comment = self.comments[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let dummyCell = CommentCell(frame: frame)
        dummyCell.comment = comments[indexPath.item]
        dummyCell.layoutIfNeeded()
        
        let targetSize = CGSize(width: view.frame.width, height: 1000)
        let estimatedSize = dummyCell.systemLayoutSizeFitting(targetSize)
        let heigt = max(40 + 8 + 8, estimatedSize.height)
        
        return .init(width: view.frame.width, height: heigt)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    // everytime view disappears, show tabbar
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    lazy var containerView: CommentInputAccessoryView = {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 80)
        let commentInputAccessoryView = CommentInputAccessoryView(frame: frame)
        commentInputAccessoryView.delegate = self
        return commentInputAccessoryView
    }()
    
    func didSubmit(for comment: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let postId = post?.id else { return }
        guard let values = ["text": comment, "creationDate": Date().timeIntervalSince1970, "uid": uid ] as? [String : Any] else { return }
        
        //childByAutoId: to insert more than one comment
        Database.database().reference().child("comments").child(postId).childByAutoId().updateChildValues(values) { err, ref in
            if let err = err {
                print("Failed to insert comment: ", err)
                return
            }
            print("Successfully inserted comment.")
            self.containerView.clearCommentTextView()
        }
    }
    
    override var inputAccessoryView: UIView? {
        get {
            return containerView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
}
 
