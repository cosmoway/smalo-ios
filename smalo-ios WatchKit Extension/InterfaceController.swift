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
    
    
    var wcSession = WCSession.defaultSession()
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        // check supported
        if WCSession.isSupported() {
            // get default session
            wcSession = WCSession.defaultSession()
            //  set delegate
            wcSession.delegate = self
            //  activate session
            wcSession.activateSession()
        } else {
            self.label.setText("通信失敗")
        }
        // Configure interface objects here.
    }

    @IBAction func button() {
        WKInterfaceDevice.currentDevice().playHaptic(WKHapticType.Click)
        
        let message = [ "NotificationOn" : "watch:OK" ]
        
        wcSession.sendMessage(message, replyHandler: { replyDict in }, errorHandler: { error in })
        
    }
    
    // get message from watch
    func session(session: WCSession, didReceiveMessage message: [String: AnyObject], replyHandler: [String: AnyObject] -> Void) {
        
        if let parentMessage = message["parentOK"] as? String {
            
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
