//
//  UserSearchController.swift
//  InstagramFirebase
//
//  Created by Mediha Karakuş on 26.03.23.
//

import UIKit
import Firebase

class UserSearchController: BaseListController, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {
    
    let cellId = "cellId"
    
    lazy var searchbar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "Enter username"
        sb.delegate = self
        return sb
    }()
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredUsers = users
        } else {
            self.filteredUsers = self.users.filter { user in
                return user.username.lowercased().contains(searchText.lowercased())
            }
        }
        self.collectionView.reloadData()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let navBar =  navigationController?.navigationBar
        navBar?.addSubview(searchbar)
        
        searchbar.anchor(top: navBar?.topAnchor, leading: navBar?.leadingAnchor, bottom: navBar?.bottomAnchor, trailing: navBar?.trailingAnchor,padding: .init(top: 0, left: 8, bottom: 0, right: 8))
        
        collectionView.register(UserSearchCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .onDrag
        
        fetchUsers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchbar.isHidden = false
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        searchbar.isHidden = true
        searchbar.resignFirstResponder() //to hide the keyboard
         
        let user = filteredUsers[indexPath.item]
        
        let userProfileContoller = UserProfileController()
        userProfileContoller.userId = user.uid
        navigationController?.pushViewController(userProfileContoller, animated: true)
    }
    var filteredUsers = [User]()
    var users = [User]()
    fileprivate func fetchUsers() {
        let ref = Database.database().reference().child("users")
        
        ref.observeSingleEvent(of: .value, with: { snapshot in
            guard let dictionaries = snapshot.value as? [String: Any] else { return }
            
            dictionaries.forEach { key, value in
                if key == Auth.auth().currentUser?.uid {
                    return
                }
                guard let userDictionary = value as? [String: Any] else { return }
                let user = User(uid: key, dictionary: userDictionary)
                self.users.append(user)
            }
            self.users.sort { u1, u2 in
                return u1.username.compare(u2.username) == .orderedAscending 
            }
            self.filteredUsers = self.users
            self.collectionView.reloadData()
        }) { err in
            print("Failed to fetch users for search")
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredUsers.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! UserSearchCell
        cell.user = filteredUsers[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: view.frame.width, height: 66)
    }
}
