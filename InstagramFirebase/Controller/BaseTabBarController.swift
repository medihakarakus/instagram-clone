//
//  BaseTabBarController.swift
//  InstagramFirebase
//
//  Created by Mediha Karakuş on 17.03.23.
//

import UIKit
import Firebase

class BaseTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        let index = viewControllers?.firstIndex(of: viewController)
        
        if index == 2 {
            let photoSelectorController = PhotoSelectorController()
            let navController = UINavigationController(rootViewController: photoSelectorController)
            navController.modalPresentationStyle = .fullScreen
            present(navController, animated: true)
            
            return false
        }
        return true
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        self.delegate = self
        
        DispatchQueue.main.async {
            if Auth.auth().currentUser == nil {
                let loginController = LoginController()
                let navController = UINavigationController(rootViewController: loginController)
                navController.modalPresentationStyle = .fullScreen
                self.present(navController, animated: true)
            } else {
                self.setupViewControllers()
            }
            return
        }
        
    }
    
    func setupViewControllers() {
        viewControllers = [
            createViewController(viewController: HomeController(), imageName: "home_unselected", selectedImageName: "home_selected"),
            createViewController(viewController: UserSearchController(), imageName: "search_unselected", selectedImageName: "search_selected"),
            createViewController(viewController: PhotoSelectorController(), imageName: "plus_unselected", selectedImageName: "plus_unselected"),
            createViewController(viewController: UIViewController(), imageName: "like_unselected", selectedImageName: "like_selected"),
            createViewController(viewController: UserProfileController(), imageName: "profile_unselected", selectedImageName: "profile_selected"),
            
        ]
    }

    fileprivate func createViewController(viewController: UIViewController, imageName: String, selectedImageName: String ) -> UIViewController {
        let navigationController = UINavigationController(rootViewController: viewController)
        viewController.view.backgroundColor = .white
        viewController.tabBarItem.image = UIImage(named: imageName)
        viewController.tabBarItem.selectedImage = UIImage(named: selectedImageName)
        tabBar.tintColor = .black
        return navigationController
    }
}


