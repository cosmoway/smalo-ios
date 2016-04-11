//
//  ViewController.swift
//  smalo-ios
//
//  Created by 須崎鉄 on 2016/04/07.
//  Copyright © 2016年 須崎鉄. All rights reserved.
//

import UIKit
import WatchConnectivity
import CoreBluetooth

class ViewController: UIViewController,WCSessionDelegate, CBCentralManagerDelegate {
    
    var wcSession = WCSession.defaultSession()
    let open = 0 , close = 1
    var state = 1
    var centralManager: CBCentralManager!
    
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
        self.centralManager = CBCentralManager(delegate: self, queue: nil, options: nil)
    }
    
    // 1-2. CentralManager状態の受信
    func centralManagerDidUpdateState(central: CBCentralManager) {
        
        switch (central.state) {
        case .PoweredOff:
            print("BLE PoweredOff")
        case .PoweredOn:
            print("BLE PoweredOn")
            // 2-1. Peripheral探索開始
            central.scanForPeripheralsWithServices(nil, options: nil)
            /* ↑の第1引数はnilは非推奨。
            該当サービスのCBUUIDオブジェクトの配列が望ましい */
            let message = [ "BLE" : "CM状態受信完了"]
            
            wcSession.sendMessage(message, replyHandler: { replyDict in }, errorHandler:  { error in })
            
        case .Resetting:
            print("BLE Resetting")
        case .Unauthorized:
            print("BLE Unauthorized")
        case .Unknown:
            print("BLE Unknown")
        case .Unsupported:
            print("BLE Unsupported")
        }
    }
    
    // watchからのメッセージを受け取る
    func session(session: WCSession, didReceiveMessage message: [String: AnyObject], replyHandler: [String: AnyObject] -> Void) {
        
        //鍵の状態の取得要求
        if let watchMessage = message["getState"] as? String {
            
            label.text = watchMessage
            
            if( state == open ){
                
                let message = [ "parentWakeClose" : "閉まっています"]
            
                wcSession.sendMessage(message, replyHandler: { replyDict in }, errorHandler:  { error in })
                
            }else if( state == close ){
                
                let message = [ "parentWakeOpen" : "開いています"]
                
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
        
        //鍵の開閉要求
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
        
        //BLEの接続要求
        if let watchMessage = message["connect"] as? String {
            //ここでEdisonとBLE接続できるかどうかを返す
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

