//
//  LoginViewController.swift
//  smalo-ios
//
//  Created by Takeru Sakano on 2016/05/09.
//  Copyright (c) 2016 COSMOWAY inc. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var userNameText: UITextField!
    @IBOutlet weak var userNameSendButton: UIButton!
    let gradientLayer = CAGradientLayer()
    let UUID: String = "\(UIDevice.current.identifierForVendor!.uuidString)"

    override func viewDidLoad() {
        super.viewDidLoad()
        //グラデーションの開始色
        let topColor = UIColor(red:0.07, green:0.42, blue:0.78, alpha:1.0)
        //グラデーションの開始色
        let bottomColor = UIColor(red:0.57, green:0.84, blue:0.88, alpha:1.0)
        
        //グラデーションの色を配列で管理
        let gradientColors: [CGColor] = [topColor.cgColor, bottomColor.cgColor]
        
        gradientLayer.frame = self.view.bounds
        
        //グラデーションの色をレイヤーに割り当てる
        gradientLayer.colors = gradientColors
        
        gradientLayer.locations = [0, 1]
        
        //グラデーションレイヤーをビューの一番下に配置
        self.view.layer.insertSublayer(gradientLayer, at: 0)
        userNameText.delegate = self
        userNameText.returnKeyType = UIReturnKeyType.done
        userNameText.resignFirstResponder()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == "\n" {
            userNameText.resignFirstResponder()
            return false
        }
        return true
    }
    
    @IBAction func sendUserName(_ sender:
        AnyObject) {
        self.view.endEditing(true)
        if userNameText.text != "" {
            let config = URLSessionConfiguration.default
            //短いタイムアウト
            config.timeoutIntervalForRequest = 20
            //長居タイムアウト
            config.timeoutIntervalForResource = 30
            let session = URLSession(configuration: config)
            
            let urlString = "https://smalo.cosmoway.net/api/v1/devices"
            var request = URLRequest(url: URL(string: urlString)!)
            
            // set the method(HTTP-POST)
            request.httpMethod = "POST"
            // set the header(s)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            // set the request-body(JSON)
            let params: [String: AnyObject] = [
                "uuid" : UUID as AnyObject,
                "name" : userNameText.text! as AnyObject
            ]
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions.init(rawValue: 2))
            } catch {
                print("NSJSONSerialization Error")
                return
            }
            var alertString = ""
            // use NSURLSessionDataTask
            let task = session.dataTask(with: request, completionHandler: { data, response, error in
                if (error == nil) {
                    if let httpResponse = response as? HTTPURLResponse {
                        switch(httpResponse.statusCode) {
                        case 204:
                            DispatchQueue.main.async(execute: {
                                let ud = UserDefaults.standard
                                ud.set(true, forKey: "isLogin")
                                self.performSegue(withIdentifier: "showMain", sender: nil)
                            })
                            break
                        case 404:
                            alertString = "サーバーが見つかりませんでした。開発者に御問合せ下さい。"
                            break
                        case 400:
                            alertString = "予期せぬエラーが発生致しました。開発者に御問合せ下さい。"
                            break
                        case 500:
                            alertString = "サーバー内部でエラーが発生致しました。開発者に御問合せ下さい。"
                            break
                        default:
                            alertString = "通信処理が正常に終了されませんでした。通信環境を御確認下さい。"
                            break
                        }
                        DispatchQueue.main.async(execute: {
                            if alertString != "" {
                                let alertController = UIAlertController(title: "通知", message: alertString, preferredStyle: .alert)
                        
                                let otherAction = UIAlertAction(title: "はい", style: .default) {
                                    action in NSLog("はいボタンが押されました")
                                }
                            
                                // addActionした順に左から右にボタンが配置されます
                                alertController.addAction(otherAction)
                        
                                self.present(alertController, animated: true, completion: nil)
                            }
                        })
                    }
                } else {
                    print(error)
                }
            })
            task.resume()
        }
    }
    @IBAction func tapScreen(_ sender: AnyObject) {
        self.view.endEditing(true)
    }
    
    override func viewDidLayoutSubviews() {
        userNameText.attributedPlaceholder = NSAttributedString(string: "名前を入力してください。", attributes: [NSForegroundColorAttributeName: UIColor(colorLiteralRed: 1, green: 1, blue: 1, alpha: 1)])
        userNameText.textColor = UIColor(colorLiteralRed: 1, green: 1, blue: 1, alpha: 1)
        userNameText.backgroundColor = UIColor(colorLiteralRed: 1, green: 1, blue: 1, alpha: 0.25)
        userNameSendButton.layer.borderColor = UIColor.white.cgColor
        userNameSendButton.layer.borderWidth = 1.0
    }
}
