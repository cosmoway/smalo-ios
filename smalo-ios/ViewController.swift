//
//  ViewController.swift
//  smalo-ios
//
//  Created by 須崎鉄 on 2016/04/07.
//  Copyright © 2016年 須崎鉄. All rights reserved.
//

import UIKit
import Pulsator

class ViewController: UIViewController {
    
    var keyFlag = true
    var major: String?
    var mainor: String?
    let UUID: String = "\(UIDevice.currentDevice().identifierForVendor!.UUIDString)"
    let pulsator = Pulsator()
    @IBOutlet weak var keyButton: UIButton!
    @IBOutlet weak var gradationView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        pulsator.numPulse = 5
        pulsator.radius = 100.0
        pulsator.backgroundColor = UIColor(red: 0, green: 0.44, blue: 0.74, alpha: 1).CGColor
        keyButton.layer.addSublayer(pulsator)
        keyButton.superview?.layer.insertSublayer(pulsator, below: keyButton.layer)
        pulsator.start()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //グラデーションの開始色
        let topColor = UIColor(red:0.16, green:0.68, blue:0.76, alpha:1)
        //グラデーションの開始色
        let bottomColor = UIColor(red:0.57, green:0.84, blue:0.88, alpha:1)
        
        //グラデーションの色を配列で管理
        let gradientColors: [CGColor] = [topColor.CGColor, bottomColor.CGColor]
        
        //グラデーションレイヤーを作成
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        
        //グラデーションの色をレイヤーに割り当てる
        gradientLayer.colors = gradientColors
        //グラデーションレイヤーをスクリーンサイズにする
        gradientLayer.frame.size = self.gradationView.frame.size
        
        //グラデーションレイヤーをビューの一番下に配置
        self.gradationView.layer.insertSublayer(gradientLayer, atIndex: 0)
        pulsator.position = keyButton.center

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func localNotification(msg: String) {
        if UIApplication.sharedApplication().applicationState != UIApplicationState.Active {
            
            let notification = UILocalNotification()
            notification.timeZone = NSTimeZone.defaultTimeZone()
            notification.alertBody = msg
            notification.soundName = UILocalNotificationDefaultSoundName
            UIApplication.sharedApplication().scheduleLocalNotification(notification)
        }
    }
    
    @IBAction func keyButton(sender: AnyObject) {
        if keyFlag {
        } else {
        }
    }
}
extension String {
    var sha256: String! {
        return self.cStringUsingEncoding(NSUTF8StringEncoding).map { cstr in
            var chars = [UInt8](count: Int(CC_SHA256_DIGEST_LENGTH), repeatedValue: 0)
            CC_SHA256(
                cstr,
                CC_LONG(self.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)),
                &chars
            )
            return chars.map { String(format: "%02X", $0) }.reduce("", combine: +)
        }
    }
}

