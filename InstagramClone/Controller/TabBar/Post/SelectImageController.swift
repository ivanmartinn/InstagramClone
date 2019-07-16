//
//  SelectImageController.swift
//  InstagramClone
//
//  Created by Ivan Martin on 27/05/2019.
//  Copyright © 2019 Ivan Martin. All rights reserved.
//

import UIKit
import Photos

private let reuseIdentifier = "SelectImageCell"
private let headerIdentifier = "SelectImageHeader"

class SelectImageController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    // MARK: - Variables
    
    var images = [UIImage]()
    var assets = [PHAsset]()
    var selectedImage: UIImage?
    var header: SelectImageHeader?
    var firstTime = false
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //register
        collectionView.register(SelectImageCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.register(SelectImageHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)
        
        //configure
        configureView()
        
        fetchPhotos()
    }
    
    // MARK: - Configuration
    
    func configureView(){
        collectionView.backgroundColor = .white
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancelSelectImage))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(handleNext))
    }
    
    // MARK: - UICollectionViewFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width = view.frame.width
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 3) / 4
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    // MARK: - UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! SelectImageCell
        cell.imageView.image = images[indexPath.row]
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as! SelectImageHeader
        self.header = header
        if let selectedImage = self.selectedImage{
            //index of selectedImage
            if let index = self.images.firstIndex(of: selectedImage){
                //asset associated with selected image
                let selectedAsset = self.assets[index]
                let imageManager = PHImageManager.default()
                let targetSize = CGSize(width: 600, height: 600)
//                let targetSize = PHImageManagerMaximumSize
                let options = PHImageRequestOptions()//i dont want image manager executed twice
                options.isSynchronous = true
                imageManager.requestImage(for: selectedAsset, targetSize: targetSize, contentMode: .aspectFit, options: options) { (image, info) in
                    guard let image = image else { return }
                    header.imageView.image = image
                    let imageSize = image.size
                    header.setImage(with: imageSize)
                }
            }
        }
        return header
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedImage = images[indexPath.row]
        self.collectionView.reloadData()
        
        //make it scroll back up
        let indexPath = IndexPath(item: 0, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
    }
    
    // MARK: - Selectors
    
    @objc func handleCancelSelectImage(){
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleNext(){
        guard let header = header else { return }
        
        //crop image
        let scale:CGFloat = 1 / header.scrollView.zoomScale
        let x:CGFloat = header.scrollView.contentOffset.x * scale
        let y:CGFloat = header.scrollView.contentOffset.y * scale
        let width:CGFloat = header.scrollView.frame.size.width * scale
        let height:CGFloat = header.scrollView.frame.size.height * scale
        let croppedCGImage = header.imageView.image?.cgImage?.cropping(to: CGRect(x: x, y: y, width: width, height: height))
        let croppedImage = UIImage(cgImage: croppedCGImage!)
        
        //push to postVC
        let postVC = PostController()
//        postVC.selectedImage = header.imageView.image
        postVC.selectedImage = croppedImage
        navigationController?.pushViewController(postVC, animated: true)
    }
    
    // MARK: - Functions
    
    func getAssetFetchOptions() -> PHFetchOptions {
        let options = PHFetchOptions()
        //limit
        options.fetchLimit = 30
        //sort photos by date
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        //set sort descriptor for option
        options.sortDescriptors = [sortDescriptor]
        return options
    }
    
    func fetchPhotos(){
        
        if !firstTime{
            firstTime = !firstTime
            //grab images from photos
            let allPhotos = PHAsset.fetchAssets(with: .image, options: getAssetFetchOptions())
            //fetch images on background thread
            DispatchQueue.global(qos: .background).async {
                //enumerateObjects
                allPhotos.enumerateObjects({ (asset, count, stop) in
                    
                    let imageManager = PHImageManager.default()
                    let targetSize = CGSize(width: 200, height: 200)
                    let options = PHImageRequestOptions()
                    options.isSynchronous = true
                    //request image representation for specified asset
                    imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: options, resultHandler: { (image, info) in
                        if let image = image{
                            //append image to datasource
                            self.images.append(image)
                            //append assets to datasource
                            self.assets.append(asset)
                            //set selected image with first image
                            if self.selectedImage == nil{
                                self.selectedImage = image
                            }
                            //reload collectionView with images once count has completed
                            if count == allPhotos.count - 1{
                                //reload collectionview on main thread
                                DispatchQueue.main.async {
                                    self.collectionView.reloadData()
                                }
                            }
                        }
                    })
                    
                })
            }
        }
    }
}
