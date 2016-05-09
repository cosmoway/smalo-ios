//
//  LoginViewController.swift
//  smalo-ios
//
//  Created by 坂野健 on 2016/05/09.
//  Copyright © 2016年 須崎鉄. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    @IBOutlet weak var userNameText: UITextField!
    @IBOutlet weak var userNameSendButton: UIButton!
    let gradientLayer = CAGradientLayer()

    override func viewDidLoad() {
        super.viewDidLoad()
        //グラデーションの開始色
        let topColor = UIColor(red:0.07, green:0.42, blue:0.78, alpha:1.0)
        //グラデーションの開始色
        let bottomColor = UIColor(red:0.57, green:0.84, blue:0.88, alpha:1.0)
        
        //グラデーションの色を配列で管理
        let gradientColors: [CGColor] = [topColor.CGColor, bottomColor.CGColor]
        
        gradientLayer.frame = self.view.bounds
        
        //グラデーションの色をレイヤーに割り当てる
        gradientLayer.colors = gradientColors
        
        gradientLayer.locations = [0, 1]
        
        //グラデーションレイヤーをビューの一番下に配置
        self.view.layer.insertSublayer(gradientLayer, atIndex: 0)
    }
    
    override func viewDidLayoutSubviews() {
        userNameText.attributedPlaceholder = NSAttributedString(string: "ユーザーネーム", attributes: [NSForegroundColorAttributeName: UIColor.lightGrayColor()])
        userNameSendButton.layer.borderColor = UIColor.whiteColor().CGColor
        userNameSendButton.layer.borderWidth = 1.0
    }
}
