//
//  FontManager.swift
//  CodeBuddyAppDemo
//
//  Created by JackLi on 2025/9/27.
//

import UIKit

class FontManager {
    static let shared = FontManager()
    
    private init() {}
    
    func montserratBold(size: CGFloat) -> UIFont {
        return UIFont(name: "Montserrat-Bold", size: size) ?? UIFont.boldSystemFont(ofSize: size)
    }
    
    func montserratRegular(size: CGFloat) -> UIFont {
        return UIFont(name: "Montserrat-Regular", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    
    func montserratSemiBold(size: CGFloat) -> UIFont {
        return UIFont(name: "Montserrat-SemiBold", size: size) ?? UIFont.systemFont(ofSize: size, weight: .semibold)
    }
}