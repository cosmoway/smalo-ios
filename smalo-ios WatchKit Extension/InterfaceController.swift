//
//  InterfaceController.swift
//  smalo-ios WatchKit Extension
//
//  Created by 須崎鉄 on 2016/04/07.
//  Copyright © 2016年 須崎鉄. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class InterfaceController: WKInterfaceController,WCSessionDelegate {
    
    @IBOutlet var openButton: WKInterfaceButton!
    @IBOutlet var buttonImage: WKInterfaceImage!
    @IBOutlet var group: WKInterfaceGroup!
    
    var wcSession = WCSession.defaultSession()
    var state = "connectNG"
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        openButton.setBackgroundColor(UIColor.redColor())
        
        // check supported
        if WCSession.isSupported() {
            // get default session
            wcSession = WCSession.defaultSession()
            //  set delegate
            wcSession.delegate = self
            //  activate session
            wcSession.activateSession()
        }
        //鍵の状態の取得
        let message = [ "getState" : "watch:OK" ]
        
        wcSession.sendMessage(message, replyHandler: { replyDict in }, errorHandler: { error in })

        openButton.setEnabled(false)
        // Configure interface objects here.
    }

    @IBAction func button() {
        
        //バイブレーション
        WKInterfaceDevice.currentDevice().playHaptic(WKHapticType.Click)
        
        if( state == "connectNG" ){
            
        //開閉要求
            let message = [ "getState" : "watchから" ]
        
            wcSession.sendMessage(message, replyHandler: { replyDict in }, errorHandler: { error in })
        }else if( state == "connectOpen" ){
            group.setBackgroundColor(UIColor(red: 0.20, green: 0.71, blue: 0.94, alpha: 0.3))
            //開閉要求
            let message = [ "stateUpdate" : "watchから" ]
            
            wcSession.sendMessage(message, replyHandler: { replyDict in }, errorHandler: { error in })
            
        }else if( state == "connectClose"){
            group.setBackgroundColor(UIColor(red: 0.99, green: 0.93, blue: 0.13, alpha: 0.3))
            //開閉要求
            let message = [ "stateUpdate" : "watchから" ]
            
            wcSession.sendMessage(message, replyHandler: { replyDict in }, errorHandler: { error in })
        }
    }
    
    //iPhoneからメッセージを受け取る
    func session(session: WCSession, didReceiveMessage message: [String: AnyObject], replyHandler: [String: AnyObject] -> Void) {
        
        //鍵が閉まってる場合
        if ((message["parentWakeClose"] as? String) != nil) {
            
            state = "connectClose"
            openButton.setEnabled(true)
            buttonImage.setImageNamed("close_button")
        }
        
        //鍵が開いている場合
        if ((message["parentWakeOpen"] as? String) != nil) {
            
            state = "connectOpen"
            openButton.setEnabled(true)
            buttonImage.setImageNamed("open_button")
        }
        
        //解錠メッセージを受け取る
        if ((message["parentOpen"] as? String) != nil) {
            
            state = "connectOpen"
            buttonImage.setImageNamed("open_button")
        }
        
        //施錠メッセージを受け取る
        if ((message["parentClose"] as? String) != nil) {
            
            state = "connectClose"
            buttonImage.setImageNamed("close_button")
        }
        
        //BLE接続のメッセージを受け取る
        if ((message["smaloNG"] as? String) != nil) {
            state = "connectNG"
            openButton.setEnabled(false)
            buttonImage.setImageNamed("search_button")
            
        }
        group.setBackgroundColor(UIColor.clearColor())
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
