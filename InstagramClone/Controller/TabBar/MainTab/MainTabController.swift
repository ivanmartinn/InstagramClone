//
//  MainTabController.swift
//  InstagramClone
//
//  Created by Ivan Martin on 07/05/2019.
//  Copyright © 2019 Ivan Martin. All rights reserved.
//

import UIKit
import Firebase

class MainTabController: UITabBarController, UITabBarControllerDelegate {

    // MARK: - Properties
    
    var currentUser: User?
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkIfUserIsLoggedIn()
        
        self.delegate = self
        configureView()
    }

    // MARK: - Configuration
    
    //create a view controller within tab bar controller
    func configureView(){
        
        //get userdata
        getUserData()
        
        //home feed controller
        let homeVC = constructNavController(unselectedImage: #imageLiteral(resourceName: "home_unselected"), selectedImage: #imageLiteral(resourceName: "home_selected"), rootViewController: HomeController(collectionViewLayout: UICollectionViewFlowLayout()))
        
        //search feed controller
        let searchVC = constructNavController(unselectedImage: #imageLiteral(resourceName: "search_unselected"), selectedImage: #imageLiteral(resourceName: "search_selected"), rootViewController: SearchController())
        
        //post controller
//        let postVC = constructNavController(unselectedImage: #imageLiteral(resourceName: "plus_unselected"), selectedImage: #imageLiteral(resourceName: "plus_unselected"), rootViewController: PostController())
        
        let selectedImageVC = constructNavController(unselectedImage: #imageLiteral(resourceName: "plus_unselected"), selectedImage: #imageLiteral(resourceName: "plus_unselected"))
        
        //notification controller
        let notificationVC = constructNavController(unselectedImage: #imageLiteral(resourceName: "like_unselected"), selectedImage: #imageLiteral(resourceName: "like_selected"), rootViewController: NotificationController())
        
        //profile controller
        let userProfileVC = constructNavController(unselectedImage: #imageLiteral(resourceName: "profile_unselected"), selectedImage: #imageLiteral(resourceName: "profile_selected"), rootViewController: UserProfileController(collectionViewLayout: UICollectionViewFlowLayout()))
        
        //add view controller to tab bar
        viewControllers = [homeVC, searchVC, selectedImageVC, notificationVC, userProfileVC]
        tabBar.tintColor = .black
    }

    //construct nav controller
    func constructNavController(unselectedImage: UIImage, selectedImage: UIImage, rootViewController: UIViewController = UIViewController()) -> UINavigationController {
        
        let navController = UINavigationController(rootViewController: rootViewController)
        navController.tabBarItem.image = unselectedImage
        navController.tabBarItem.selectedImage = selectedImage
        navController.navigationBar.barTintColor = .white
        navController.navigationBar.tintColor = .black
        
        return navController
    }
    
    // MARK: - UITabBarControllerDelegate
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        let index = viewControllers?.firstIndex(of: viewController)
        if index == 2{
            let selectImageVC = SelectImageController(collectionViewLayout: UICollectionViewFlowLayout())
            let navController = UINavigationController(rootViewController: selectImageVC)
            navController.navigationBar.tintColor = .black
            present(navController, animated: true, completion: nil)
            return false
        }
        return true
    }
    
    // MARK: - API
    
    func checkIfUserIsLoggedIn(){
        
        if Auth.auth().currentUser == nil {
            DispatchQueue.main.async {
                let loginVC = LoginController()
                let navController = UINavigationController(rootViewController: loginVC)
                self.present(navController, animated: true, completion: nil)
            }
            return
        }
        
    }
    
    func getUserData(){
        Service.shared.fetchCurrentUser {
            guard let currentUser = Service.currentUser else { return }
            self.currentUser = currentUser
            
            //event
//            Service.userFetchEvent.raise(data: currentUser)
        }
    }
}
