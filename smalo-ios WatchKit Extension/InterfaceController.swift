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
    
    @IBOutlet var myGroup: WKInterfaceGroup!
    @IBOutlet var openButton: WKInterfaceButton!
    @IBOutlet var connectButton: WKInterfaceButton!
    
    var wcSession = WCSession.defaultSession()
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        myGroup.setBackgroundColor(UIColor.blueColor())
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
        
        // Configure interface objects here.
    }

    @IBAction func button() {
        
        //バイブレーション
        WKInterfaceDevice.currentDevice().playHaptic(WKHapticType.Click)
        
        label.setText("要求送信中")
        
        //開閉要求
        let message = [ "watchOC" : "watchから" ]
        
        wcSession.sendMessage(message, replyHandler: { replyDict in }, errorHandler: { error in })
        
    }
    
    @IBAction func button2() {
        WKInterfaceDevice.currentDevice().playHaptic(WKHapticType.Click)
        
        label3.setText("接続要求送信")
        
        //BLEの接続確認
        let message = [ "connect" : "接続要求" ]
        
        wcSession.sendMessage(message, replyHandler: { replyDict in }, errorHandler: { error in })
    }
    
    //iPhoneからメッセージを受け取る
    func session(session: WCSession, didReceiveMessage message: [String: AnyObject], replyHandler: [String: AnyObject] -> Void) {
        
        //鍵が閉まってる場合
        if let parentMessage = message["parentWakeClose"] as? String {
            
            openButton.setTitle("Open")
            
            label2.setText("通信完了")
            label.setText(parentMessage)
        }
        
        //鍵が開いている場合
        if let parentMessage = message["parentWakeOpen"] as? String {
            
            openButton.setTitle("Close")
            
            label2.setText("通信完了")
            label.setText(parentMessage)
        }
        
        //解錠メッセージを受け取る
        if let parentMessage = message["parentOpen"] as? String {
            
            myGroup.setBackgroundColor(UIColor.blackColor())
            label.setText(parentMessage)
            openButton.setTitle("Close")
        }
        
        //施錠メッセージを受け取る
        if let parentMessage = message["parentClose"] as? String {
            
            myGroup.setBackgroundColor(UIColor.blueColor())
            label.setText(parentMessage)
            openButton.setTitle("Open")
        }
        
        //BLE接続のメッセージを受け取る
        if let parentMessage = message["BLE"] as? String {
            
            myGroup.setBackgroundColor(UIColor.blueColor())
            label3.setText(parentMessage)
        }
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
