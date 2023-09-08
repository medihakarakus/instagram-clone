//
//  UserProfileController.swift
//  InstagramFirebase
//
//  Created by Mediha Karakuş on 17.03.23.
//

import UIKit
import Firebase

class UserProfileController: BaseListController,UICollectionViewDelegateFlowLayout, UserProfileHeaderDelegate {
    
    var isGridView = true
    func didChangeToListView() {
        isGridView = false
        collectionView.reloadData()
    }
    
    func didChangeToGridView() {
        isGridView = true
        collectionView.reloadData()
    }
    
    var userId: String?
    let cellId = "cellId"
    let headerId = "headerId"
    let homePostCellId = "homePostCellId"
    
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(UserProfilePhotoCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.register(UserProfileHeaderCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerId)
        collectionView.register(HomePostCell.self, forCellWithReuseIdentifier: homePostCellId)
   
        setupLogOutButton()
        fetchUser()
    }
    
    
    var isFinishedPaging = false
    var posts = [Post]()
    fileprivate func paginatePosts() {
        guard let uid = user?.uid else { return }
        let ref = Database.database().reference().child("posts").child(uid)
        
        var query = ref.queryOrdered(byChild: "creationDate")
        if posts.count > 0 {
            let value = posts.last?.creationDate.timeIntervalSince1970
            query = query.queryEnding(atValue: value)
        }
        
        query.queryLimited(toLast: 4).observeSingleEvent(of: .value, with: { snapshot in
            guard var allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
            
            allObjects.reverse()
            
            if allObjects.count < 4 {
                self.isFinishedPaging = true
            }
            
            if self.posts.count > 0 && !allObjects.isEmpty {
                allObjects.removeFirst()
            }
            
            guard let user = self.user else { return }
            
            allObjects.forEach { snapshot in
                guard let dictionary = snapshot.value as? [String: Any] else { return }
                var post = Post(user: user, dictionary: dictionary)
                post.id = snapshot.key
                self.posts.append(post)
            }
            self.collectionView.reloadData()
        }) { err in
            print("Failed to paginate for posts :", err)
        }
    }
    
    fileprivate func fetchOrderedPosts() {
        guard let uid = user?.uid else { return }
        let ref = Database.database().reference().child("posts").child(uid)
        
        ref.queryOrdered(byChild: "creationDate").observe(.childAdded, with: { snapshot in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            guard let user = self.user else { return }
            
            let post = Post(user: user, dictionary: dictionary)
            
            self.posts.insert(post, at: 0)
            self.collectionView.reloadData()
        }) { err in
            print("Failed to fetch ordered photos: ", err)
        }
    }
    
    fileprivate func setupLogOutButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "gear")?.withRenderingMode(.alwaysOriginal) , style: .plain, target: self, action: #selector(handleLogOut))
    }
    
    @objc func handleLogOut() {
        let ac = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { _ in
            do {
                try Auth.auth().signOut()
                
                let loginController = LoginController()
                let navController = UINavigationController(rootViewController: loginController)
                navController.modalPresentationStyle = .fullScreen
                self.present(navController, animated: true)
            } catch let signOutErr {
                print("Failed to signout: ", signOutErr)
            }
        }))

        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    fileprivate func fetchUser() {
        let uid = userId ?? Auth.auth().currentUser?.uid ?? ""
        
        Database.fetchUserWithUID(uid) { user in
            self.user = user
            self.navigationItem.title = self.user?.username
            self.collectionView?.reloadData()
            self.paginatePosts()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerId, for: indexPath) as! UserProfileHeaderCell
        header.user = self.user
        header.delegate = self
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return .init(width: view.frame.width, height: 200)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.item == posts.count - 1 && !isFinishedPaging {
            paginatePosts()
        }
        if isGridView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! UserProfilePhotoCell
            cell.post = posts[indexPath.item]
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homePostCellId, for: indexPath) as! HomePostCell
            cell.post = posts[indexPath.item]
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if isGridView {
            let width = (view.frame.width - 2) / 3
            return .init(width: width, height: width)
        } else {
            var heigt: CGFloat = 40 + 8 + 8 // userprofilemageview + padding
            heigt += view.frame.width
            heigt += 50 //bottom actions
            heigt += 60 // caption
            return .init(width: view.frame.width, height: heigt)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
}

