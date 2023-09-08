//
//  CustomImageView.swift
//  InstagramFirebase
//
//  Created by Mediha Karakuş on 25.03.23.
//

import UIKit

var imageCache = [String: UIImage]()

class CustomImageView: UIImageView {
    
    var lastURLUsedToLoadImage: String?
    
    func loadImage(urlString: String) {
        lastURLUsedToLoadImage = urlString
        
        self.image = nil
        
        if let cachedImage = imageCache[urlString] {
            self.image = cachedImage
            return
        }
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, resp, err in
            
            if let err = err {
                print("Failed to fetch post image: ", err)
                return
            }
            
            if url.absoluteString != self.lastURLUsedToLoadImage  {
                return
            }
            
            guard let data = data else { return }
            let image = UIImage(data: data)
            
            imageCache[url.absoluteString] = image
            
            DispatchQueue.main.async {
                self .image = image
            }
            
        }.resume()
    }
}
