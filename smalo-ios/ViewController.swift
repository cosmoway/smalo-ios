//
//  ViewController.swift
//  smalo-ios
//
//  Created by 須崎鉄 on 2016/04/07.
//  Copyright © 2016年 須崎鉄. All rights reserved.
//

import UIKit
import WatchConnectivity

class ViewController: UIViewController,WCSessionDelegate {
    
    var wcSession = WCSession.defaultSession()
    //ドアの状態、edisonとの通信状態の管理用変数
    var doorState = "close" ,connectState = "NG"
    
    // protcol NSCorder init
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    // UIViewController init override
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?){
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // check supported
        if WCSession.isSupported() {
            //  get default session
            wcSession = WCSession.defaultSession()
            // set delegate
            wcSession.delegate = self
            // activate session
            wcSession.activateSession()
        } else {
            print("Not support WCSession")
        }
    }
    
    //Edisonと通信できてるかの仮ボタン
    //TODO 完成したら削除
//    @IBAction func BLEbutton(sender: AnyObject) {
//        if( connectState == "OK" ){
//            connectState = "NG"
//        }else if( connectState == "NG" ){
//            connectState = "OK"
//        }
//    }
    
    // watchからのメッセージを受け取る
    func session(session: WCSession, didReceiveMessage message: [String: AnyObject], replyHandler: [String: AnyObject] -> Void) {
        
        if(connectState == "OK" ){
        
            //鍵の状態の取得要求だった場合
            if let watchMessage = message["getState"] as? String {
            
                if( connectState == "OK" ){
            
                    if( doorState == "open" ){
                
                        let message = [ "parentWakeOpen" : "Opened"]
            
                        wcSession.sendMessage(message, replyHandler: { replyDict in }, errorHandler:  { error in })
                
                    }else if( doorState == "close" ){
                
                        let message = [ "parentWakeClose" : "Closed"]
                
                        wcSession.sendMessage(message, replyHandler: { replyDict in }, errorHandler:  { error in })
                    }
                }
            }
        
            //鍵の開閉要求だった場合
            if let watchMessage = message["stateUpdate"] as? String {
                if( doorState == "close" ){
                    //TODO edisonに解錠要求
                
                    let message = [ "parentOpen" : "Opened"]
                
                    wcSession.sendMessage(message, replyHandler: { replyDict in }, errorHandler:  { error in })
                
                    doorState = "open"
                }else if( doorState == "open" ){
                    //TODO edisonに施錠要求
                
                    let message = [ "parentClose" : "Closed"]
                
                    wcSession.sendMessage(message, replyHandler: { replyDict in }, errorHandler:  { error in })
                
                    doorState = "close"
                }
            }
        }else if(connectState == "NG" ){
            
            let message = [ "smaloNG" : "スマロNG" ]
            
            wcSession.sendMessage( message, replyHandler: { replyDict in }, errorHandler: { error in })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

