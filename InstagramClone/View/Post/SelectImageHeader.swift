//
//  SelectImageHeader.swift
//  InstagramClone
//
//  Created by Ivan Martin on 27/05/2019.
//  Copyright © 2019 Ivan Martin. All rights reserved.
//

import UIKit

class SelectImageHeader: UICollectionViewCell, UIScrollViewDelegate{
    
    // MARK: - Properties
    
    let scrollView: UIScrollView = {
        let scroll = UIScrollView()
//        scroll.isPagingEnabled = true
        scroll.showsVerticalScrollIndicator = false
        scroll.showsHorizontalScrollIndicator = false
        scroll.backgroundColor = .black
        return scroll
    }()
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .black
        iv.isUserInteractionEnabled = true
        return iv
    }()
    
    let guideLabel: UILabel = {
        let label = UILabel()
        label.text = "Move/Zoom to Set Desired Image"
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .white
        label.layer.backgroundColor = UIColor.lightGray.cgColor
        label.layer.cornerRadius = 15
        label.textAlignment = .center
        label.alpha = 0
        return label
    }()
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
        scrollView.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuration
    
    func configureView(){
        addSubview(scrollView)
        scrollView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        scrollView.addSubview(imageView)
        imageView.anchor(top: scrollView.topAnchor, left: scrollView.leftAnchor, bottom: scrollView.bottomAnchor, right: scrollView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        addSubview(guideLabel)
        guideLabel.anchor(top: nil, left: scrollView.leftAnchor, bottom: scrollView.bottomAnchor, right: scrollView.rightAnchor, paddingTop: 0, paddingLeft: 12, paddingBottom: 12, paddingRight: 12, width: 0, height: 30)
    }
    
    func setImage(with imageSize: CGSize){
        scrollView.contentMode = .scaleAspectFit
        imageView.sizeToFit()
        scrollView.contentSize = imageSize
        let scrollViewFrame = scrollView.frame
        let scaleWidth = scrollViewFrame.size.width / scrollView.contentSize.width
        let scaleHeight = scrollViewFrame.size.height / scrollView.contentSize.height
        let minScale = min(scaleHeight , scaleWidth)
        scrollView.minimumZoomScale = minScale
        scrollView.maximumZoomScale = 4
        scrollView.zoomScale = minScale
        centerScrollViewContents()
    }
    
    func centerScrollViewContents(){
        let offsetX = max((scrollView.bounds.width - scrollView.contentSize.width) * 0.5, 0)
        let offsetY = max((scrollView.bounds.height - scrollView.contentSize.height) * 0.5, 0)
        scrollView.contentInset = UIEdgeInsets(top: offsetY, left: offsetX, bottom: 0, right: 0)
        
        //guideLabel animation
        guideLabel.alpha = 1
        let animationDuration = 0.5
        UIView.animate(withDuration: animationDuration, delay: 5, options: .curveEaseIn, animations: {
            self.guideLabel.alpha = 0
        }, completion: nil)
        
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerScrollViewContents()
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
}
