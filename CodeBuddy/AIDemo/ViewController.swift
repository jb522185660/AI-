//
//  ViewController.swift
//  AIDemo
//
//  Created by JackLi on 2025/9/20.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 创建 PhotoListViewController 并嵌入到导航控制器中
        let photoListVC = PhotoListViewController()
        let navController = UINavigationController(rootViewController: photoListVC)
        
        addChild(navController)
        view.addSubview(navController.view)
        navController.view.frame = view.bounds
        navController.didMove(toParent: self)
    }
}

