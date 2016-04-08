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
    
    @IBOutlet weak var label: UILabel!
    var i = 0
    
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
    
    // get message from watch
    func session(session: WCSession, didReceiveMessage message: [String: AnyObject], replyHandler: [String: AnyObject] -> Void) {
        
        if let watchMessage = message["NotificationOn"] as? String {
            
            label.text = "watchOK"
            
            let message = [ "parentOK" : "通信完了"]
            
            wcSession.sendMessage(message, replyHandler: { replyDict in }, errorHandler:  { error in })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

