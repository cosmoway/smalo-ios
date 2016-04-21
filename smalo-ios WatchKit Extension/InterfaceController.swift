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

    @IBOutlet var label: WKInterfaceLabel!
    @IBOutlet var label2: WKInterfaceLabel!
    @IBOutlet var label3: WKInterfaceLabel!
    
    @IBOutlet var group: WKInterfaceGroup!
    @IBOutlet var openButton: WKInterfaceButton!
    @IBOutlet var buttonImage: WKInterfaceImage!
    
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
        
        label2.setText("取得中")
        label3.setText("取得中")
        
        wcSession.sendMessage(message, replyHandler: { replyDict in }, errorHandler: { error in })
        
        // Configure interface objects here.
    }

    @IBAction func button() {
        
        //バイブレーション
        WKInterfaceDevice.currentDevice().playHaptic(WKHapticType.Click)
        
        label.setText("SEARCH")
        label2.setText("スマホNG")
        label3.setText("スマロNG")
        
        if( state == "connectNG" ){
            
        //開閉要求
            let message = [ "getState" : "watchから" ]
        
            wcSession.sendMessage(message, replyHandler: { replyDict in }, errorHandler: { error in })
        }else if( state == "connectOpen" ){
            
            //開閉要求
            let message = [ "stateUpdate" : "watchから" ]
            group.setBackgroundColor(UIColor(red: 0.20, green: 0.71, blue: 0.94, alpha: 0.3))
            
            wcSession.sendMessage(message, replyHandler: { replyDict in }, errorHandler: { error in })
            
        }else if( state == "connectClose"){
            //開閉要求
            let message = [ "stateUpdate" : "watchから" ]
            group.setBackgroundColor(UIColor(red: 0.99, green: 0.93, blue: 0.13, alpha: 0.3))
            
            wcSession.sendMessage(message, replyHandler: { replyDict in }, errorHandler: { error in })
        }
    }
    
    //iPhoneからメッセージを受け取る
    func session(session: WCSession, didReceiveMessage message: [String: AnyObject], replyHandler: [String: AnyObject] -> Void) {
        
        //鍵が閉まってる場合
        if let parentMessage = message["parentWakeClose"] as? String {
            
            openButton.setTitle("Open")
            
            label.setText(parentMessage)
            label2.setText("スマホOK")
            state = "connectClose"
            
            buttonImage.setImageNamed("close_button")
        }
        
        //鍵が開いている場合
        if let parentMessage = message["parentWakeOpen"] as? String {
            
            openButton.setTitle("Close")
            
            label.setText(parentMessage)
            label2.setText("スマホOK")
            state = "connectOpen"
            buttonImage.setImageNamed("open_button")
        }
        
        //解錠メッセージを受け取る
        if let parentMessage = message["parentOpen"] as? String {
            
            label.setText(parentMessage)
            openButton.setTitle("Close")
            state = "connectOpen"
            buttonImage.setImageNamed("open_button")
        }
        
        //施錠メッセージを受け取る
        if let parentMessage = message["parentClose"] as? String {
            
            label.setText(parentMessage)
            openButton.setTitle("Open")
            state = "connectClose"
            buttonImage.setImageNamed("close_button")
        }
        
        //BLE接続のメッセージを受け取る
        if let parentMessage = message["smaloNG"] as? String {
            
            label.setText("UNKNOWN")
            label2.setText("スマホOK")
            label3.setText(parentMessage)
            openButton.setTitle("SEARCH")
            state = "connectNG"
            buttonImage.setImageNamed("search_button")
            
        }else{
            
            label2.setText("スマホOK")
            label3.setText("スマロOK")
            
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
