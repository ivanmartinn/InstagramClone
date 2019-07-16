//
//  CustomImageView.swift
//  InstagramClone
//
//  Created by Ivan Martin on 07/06/2019.
//  Copyright © 2019 Ivan Martin. All rights reserved.
//

import UIKit

var imageCache = [String: UIImage]()
//avoid image loaded is duplicated
class CustomImageView: UIImageView {
    
    var lastImageUrlUsedToLoadImage: String?
    
    func loadImage(with urlString: String){
        
        // set image to nil
        self.image = nil
        
        //set lastimageurl
        lastImageUrlUsedToLoadImage = urlString
        
        //check if image exists in cache
        if let cacheImage = imageCache[urlString]{
            self.image = cacheImage
            return
        }
        //if image cache does not exist
        //url for image location
        guard let url = URL(string: urlString) else { return }
        //fetch content of url
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            //error handler
            if let error = error {
                print("Failed to load image with error: ", error.localizedDescription)
                return
            }
            
            //return if it the url has been used(loaded image)
            if self.lastImageUrlUsedToLoadImage != url.absoluteString{
                return
            }
            
            //image data
            guard let imageData = data else { return }
            //create image using imagedata
            let image = UIImage(data: imageData)
            //set key and value for imagecache
            imageCache[url.absoluteString] = image
            
            //set image
            DispatchQueue.main.async {
                self.image = image
            }
            }.resume()
        
    }
}
