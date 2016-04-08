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
    
    @IBOutlet var myGroup: WKInterfaceGroup!
    @IBOutlet var openButton: WKInterfaceButton!
    
    
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
        
        let message = [ "watchWake" : "watch:OK" ]
        
        wcSession.sendMessage(message, replyHandler: { replyDict in }, errorHandler: { error in })
        
        // Configure interface objects here.
    }

    @IBAction func button() {
        WKInterfaceDevice.currentDevice().playHaptic(WKHapticType.Click)
        
        let message = [ "watchOC" : "watchから" ]
        
        wcSession.sendMessage(message, replyHandler: { replyDict in }, errorHandler: { error in })
        
    }
    
    // get message from watch
    func session(session: WCSession, didReceiveMessage message: [String: AnyObject], replyHandler: [String: AnyObject] -> Void) {
        
        if let parentMessage = message["parentWake"] as? String {
            
            label2.setText("通信完了")
            label.setText(parentMessage)
        }
        
        if let parentMessage = message["parentOpen"] as? String {
            
            myGroup.setBackgroundColor(UIColor.cyanColor())
            label.setText(parentMessage)
        }
        
        if let parentMessage = message["parentClose"] as? String {
            
            myGroup.setBackgroundColor(UIColor.blueColor())
            label.setText(parentMessage)
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
