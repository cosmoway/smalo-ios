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
    let open = 0 , close = 1
    var state = 1
    
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
    
    // get message from watch
    func session(session: WCSession, didReceiveMessage message: [String: AnyObject], replyHandler: [String: AnyObject] -> Void) {
        
        if let watchMessage = message["watchWake"] as? String {
            
            label.text = watchMessage
            
            if( state == open ){
                
                let message = [ "parentWake" : "閉まっています"]
            
                wcSession.sendMessage(message, replyHandler: { replyDict in }, errorHandler:  { error in })
                
            }else if( state == close ){
                
                let message = [ "parentWake" : "開いています"]
                
                wcSession.sendMessage(message, replyHandler: { replyDict in }, errorHandler:  { error in })
            }
        }
        
        if let watchMessage = message["watchOC"] as? String {
            if( state == close ){
                label.text = watchMessage + "解錠"
                
                let message = [ "parentOpen" : "開きました"]
                
                wcSession.sendMessage(message, replyHandler: { replyDict in }, errorHandler:  { error in })
                
                state = open
            }else if( state == open ){
                
                label.text = watchMessage + "施錠"
                
                let message = [ "parentClose" : "閉めました"]
                
                wcSession.sendMessage(message, replyHandler: { replyDict in }, errorHandler:  { error in })
                
                state = close
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

