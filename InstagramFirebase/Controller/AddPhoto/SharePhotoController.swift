//
//  SharePhotoController.swift
//  InstagramFirebase
//
//  Created by Mediha Karakuş on 23.03.23.
//

import UIKit
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth

class SharePhotoController: UIViewController {
    
    var selectedImage: UIImage? {
        didSet {
            imageView.image = selectedImage
        }
    }
    
    let imageView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        return image
    }()
    
    let textView: UITextView = {
        let text = UITextView()
        text.font = UIFont.systemFont(ofSize: 14 )
        return text
    }()
    
    let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.rgb(red: 240, green: 240, blue: 240)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(handleShare))
        
        view.addSubview(containerView)
        containerView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, size: .init(width: 0, height: 100))
        
        containerView.addSubview(imageView)
        imageView.anchor(top: containerView.topAnchor, leading: containerView.leadingAnchor, bottom: containerView.bottomAnchor, trailing: nil, padding: .init(top: 8, left: 8, bottom: 8, right: 8), size: .init(width: 84, height: 84))
        
        containerView.addSubview(textView)
        textView.anchor(top: containerView.topAnchor, leading: imageView.trailingAnchor, bottom: containerView.bottomAnchor, trailing: containerView.trailingAnchor, padding: .init(top: 4, left: 0, bottom: 0, right: 0))
    }
    
    @objc func handleShare() {
        guard let caption = textView.text, !caption.isEmpty else { return }
        guard let image = selectedImage else { return }
        
        guard let uploadData = image.jpegData(compressionQuality: 0.5) else { return }
        
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        let filename = NSUUID().uuidString
       
        let storageRef = Storage.storage().reference().child("posts").child(filename)
        storageRef.putData(uploadData, metadata: nil) { (metadata, err) in
            
            if let err = err {
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                print("Failed to upload post image:", err)
                return
            }
            
            storageRef.downloadURL(completion: { (downloadURL, err) in
                if let err = err {
                    print("Failed to fetch downloadURL:", err)
                    return
                }
                guard let imageUrl = downloadURL?.absoluteString else { return }
                
                print("Successfully uploaded post image:", imageUrl)
                
                self.saveToDatabaseWithImageUrl(imageUrl: imageUrl)
            })
        }
    }
    
    static let updateFeedNotificationName = NSNotification.Name(rawValue: "UpdateFeed")
    fileprivate func saveToDatabaseWithImageUrl(imageUrl: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let caption = textView.text else { return }
        guard let postImage = selectedImage else { return }
        
        let userPostref = Database.database().reference().child("posts").child(uid)
        
        //childByAutoId() : to save list of items into the database
        let ref = userPostref.childByAutoId()
        let values = ["imageUrl": imageUrl, "caption": caption,"imageWidth": postImage.size.width, "imageHeight": postImage.size.height, "creationDate": Date().timeIntervalSince1970] as [String : Any]
        
        ref.updateChildValues(values) { err, ref in
            if let err = err {
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                print("Failed to save post to DB", err)
            }
            
            print("Sucessfully saved post to DB")
            
            NotificationCenter.default.post(name: SharePhotoController.updateFeedNotificationName, object: nil)
            self.dismiss(animated: true, completion: nil)
        }
    }
}
