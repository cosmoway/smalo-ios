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
    let open = 0 , close = 1 , NG = 0 , OK = 1
    var doorState = 1 ,connectState = 0
    
    @IBOutlet weak var label: UILabel!
    
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
    @IBAction func BLEbutton(sender: AnyObject) {
        if( connectState == OK ){
            connectState = NG
        }else if( connectState == NG ){
            connectState = OK
        }
    }
    
    // watchからのメッセージを受け取る
    func session(session: WCSession, didReceiveMessage message: [String: AnyObject], replyHandler: [String: AnyObject] -> Void) {
        
        if(connectState == OK ){
        
            //鍵の状態の取得要求
            if let watchMessage = message["getState"] as? String {
            
                label.text = watchMessage
            
                if( connectState == OK ){
            
                    if( doorState == open ){
                
                        let message = [ "parentWakeOpen" : "Opened"]
            
                        wcSession.sendMessage(message, replyHandler: { replyDict in }, errorHandler:  { error in })
                
                    }else if( doorState == close ){
                
                        let message = [ "parentWakeClose" : "Closed"]
                
                        wcSession.sendMessage(message, replyHandler: { replyDict in }, errorHandler:  { error in })
                    }
                    let notification = UILocalNotification()
                    notification.fireDate = NSDate()	// すぐに通知したいので現在時刻を取得
                    notification.timeZone = NSTimeZone.defaultTimeZone()
                    notification.alertBody = "通信完了"
                    notification.alertAction = "OK"
                    notification.soundName = UILocalNotificationDefaultSoundName
                    UIApplication.sharedApplication().presentLocalNotificationNow(notification)
                
                }
            }
        
            //鍵の開閉要求
            if let watchMessage = message["stateUpdate"] as? String {
                if( doorState == close ){
                    label.text = watchMessage + "解錠"
                
                    let message = [ "parentOpen" : "Opened"]
                
                    wcSession.sendMessage(message, replyHandler: { replyDict in }, errorHandler:  { error in })
                
                    doorState = open
                }else if( doorState == open ){
                
                    label.text = watchMessage + "施錠"
                
                    let message = [ "parentClose" : "Closed"]
                
                    wcSession.sendMessage(message, replyHandler: { replyDict in }, errorHandler:  { error in })
                
                    doorState = close
                }
            }
        }else if(connectState == NG ){
            
            let message = [ "smaloNG" : "スマロ接続NG" ]
            
            wcSession.sendMessage( message, replyHandler: { replyDict in }, errorHandler: { error in })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

