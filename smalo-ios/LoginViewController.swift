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
    let UUID: String = "\(UIDevice.currentDevice().identifierForVendor!.UUIDString)"

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
    @IBAction func sendUserName(sender:
        AnyObject) {
        if userNameText.text != "" {
            let config = NSURLSessionConfiguration.defaultSessionConfiguration()
            //短いタイムアウト
            config.timeoutIntervalForRequest = 20
            //長居タイムアウト
            config.timeoutIntervalForResource = 30
            let session = NSURLSession(configuration: config)
            
            let urlString = "https://smalo.cosmoway.net:8443/api/v1/devices"
            let request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
            
            // set the method(HTTP-POST)
            request.HTTPMethod = "POST"
            // set the header(s)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            // set the request-body(JSON)
            let params: [String: AnyObject] = [
                "uuid" : UUID,
                "name" : userNameText.text!
            ]
            do {
                request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(params, options: NSJSONWritingOptions.init(rawValue: 2))
            } catch {
                print("NSJSONSerialization Error")
                return
            }
            
            // use NSURLSessionDataTask
            let task = session.dataTaskWithRequest(request, completionHandler: { data, response, error in
                if (error == nil) {
                    let result = NSString(data: data!, encoding: NSUTF8StringEncoding)!
                    switch (result) {
                    case "204":
                        dispatch_async(dispatch_get_main_queue(), {
                            let ud = NSUserDefaults.standardUserDefaults()
                            ud.setBool(false, forKey: "isLogin")
                            self.performSegueWithIdentifier("showMain", sender: nil)
                            print("登録されたよ")
                        })
                        break
                    case "400 Bad Request":
                       
                        break
                    case "403 Forbidden":
                        
                        break
                    default:
                        break
                    }
                    print(result)
                } else {
                    print(error)
                }
            })
            task.resume()
        }
    }
    @IBAction func tapScreen(sender: AnyObject) {
        self.view.endEditing(true)
    }
    
    override func viewDidLayoutSubviews() {
        userNameText.attributedPlaceholder = NSAttributedString(string: "名前を入力してください。", attributes: [NSForegroundColorAttributeName: UIColor(colorLiteralRed: 1, green: 1, blue: 1, alpha: 1)])
        userNameText.textColor = UIColor(colorLiteralRed: 1, green: 1, blue: 1, alpha: 1)
        userNameText.backgroundColor = UIColor(colorLiteralRed: 1, green: 1, blue: 1, alpha: 0.25)
        userNameSendButton.layer.borderColor = UIColor.whiteColor().CGColor
        userNameSendButton.layer.borderWidth = 1.0
    }
}
