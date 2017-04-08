//
//  ViewController.swift
//  smalo-ios
//
//  Created by Tetsu Susaki on 2016/04/07.
//  Copyright (c) 2016 COSMOWAY inc. All rights reserved.
//

import UIKit
import WatchConnectivity
import Pulsator
import CoreLocation
import CoreBluetooth
import SocketRocket
import SwiftyJSON


class ViewController: UIViewController, WCSessionDelegate, CLLocationManagerDelegate, CBCentralManagerDelegate, SRWebSocketDelegate {
    
    @IBOutlet weak var keyButton: UIButton!
    var wcSession: WCSession?
    var doorState = ""
    let UUID = "\(UIDevice.current.identifierForVendor!.uuidString)"
    let pulsator = Pulsator()
    //グラデーションレイヤーを作成
    let gradientLayer = CAGradientLayer()
    var sendFlag = false
    var myLocationManager:CLLocationManager!
    var myBeaconRegion:CLBeaconRegion!
    var beaconRegion = CLBeaconRegion()
    var myCentralManager: CBCentralManager!
    var webClient: SRWebSocket?
    var bluetoothOn = true
    var animateStart = false
    var isReturned = false
    let notificationCenter = NotificationCenter.default

    
    // protcol NSCorder init
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    // UIViewController init override
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?){
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        initLayout()
        print(UUID)
        // CoreBluetoothを初期化および始動.
        myCentralManager = CBCentralManager(delegate: self, queue: nil, options: nil)
        //Beaconの初期設定
        initBeacon()
        webSocketConnect()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //グラデーションレイヤーをスクリーンサイズにする
        gradientLayer.frame.size = self.view.frame.size
        pulsator.position = keyButton.center
        (UIApplication.shared.delegate as! AppDelegate).pulsator = pulsator
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // check supported
        if #available(iOS 9.0, *) {
            if WCSession.isSupported() {
                //  get default session
                wcSession = WCSession.default()
                if self.wcSession != nil {
                    // set delegate
                    wcSession!.delegate = self
                    // activate session
                    wcSession!.activate()
                }
            } else {
                print("Not support WCSession")
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    func webSocketDidOpen(_ webSocket: SRWebSocket!) {
        print("接続しました。")
        //サーバーにメッセージをjson形式で送る処理
        let obj = [
            "uuid" : UUID
        ]
        let json = String(describing: JSON(obj))
        print(json)
        webClient?.send(json)
    }
    
    func webSocket(_ webSocket: SRWebSocket!, didFailWithError error: NSError!) {
        print(error)
        webSocketConnect()
    }
    
    func webSocket(_ webSocket: SRWebSocket!, didReceiveMessage message: Any!) {
        print("メッセージがきました。")
        print(message)
        var keyState = JSON.parse(message as! String)
        switch (keyState["state"]) {
        case "unlocked":
            DispatchQueue.main.async(execute: {
                self.pulsator.stop()
                self.keyButton.setImage(UIImage(named: "smalo_open_button.png"), for: UIControlState())
                self.gradientOpen()
                //ZFRippleButton.rippleColor = UIColor(red: 0.08, green: 0.57, blue: 0.31, alpha: 0.3)
                let message = [ "parentWakeOpen" : "Opened"]
                if #available(iOS 9.0, *) {
                    if self.wcSession != nil {
                        self.wcSession!.sendMessage(message, replyHandler: { replyDict in }, errorHandler:  { error in })
                    }
                }
                self.doorState = "close"
                (UIApplication.shared.delegate as! AppDelegate).doorState = self.doorState
                self.keyButton.isEnabled = true
                self.animateStart = false
                self.isReturned = true
            })
            break
        case "locked":
            DispatchQueue.main.async(execute: {
                self.pulsator.stop()
                self.keyButton.setImage(UIImage(named: "smalo_close_button.png"), for: UIControlState())
                self.gradientClose()
                //ZFRippleButton.rippleColor = UIColor(red: 0.0, green: 0.44, blue: 0.74, alpha: 0.15)
                let message = [ "parentWakeClose" : "Closed"]
                if #available(iOS 9.0, *) {
                    if self.wcSession != nil {
                        self.wcSession!.sendMessage(message, replyHandler: { replyDict in }, errorHandler:  { error in })
                    }
                }
                self.doorState = "open"
                (UIApplication.shared.delegate as! AppDelegate).doorState = self.doorState
                self.keyButton.isEnabled = true
                self.animateStart = false
                self.isReturned = true
            })
            break
        case "unknown":
            DispatchQueue.main.async(execute: {
                if !self.animateStart {
                    self.pulsator.start()
                    self.animateStart = true
                }
                self.keyButton.setImage(UIImage(named: "smalo_search_button.png"), for: UIControlState())
                self.gradientClose()
                let message = [ "smaloNG" : "スマロNG" ]
                if #available(iOS 9.0, *) {
                    if self.wcSession != nil {
                        self.wcSession!.sendMessage(message, replyHandler: { replyDict in }, errorHandler: { error in })
                    }
                }
                self.doorState = ""
                (UIApplication.shared.delegate as! AppDelegate).doorState = self.doorState
                self.keyButton.isEnabled = false
            })
            break
        default:
            break
        }
    }
    
    func webSocket(_ webSocket: SRWebSocket!, didCloseWithCode code: Int, reason: String!, wasClean: Bool) {
        print("\(code)"+reason)
        print("閉じました。")
        //アプリがアクティブになったとき
        notificationCenter.addObserver(
            self,
            selector: "webSocketConnect",
            name:NSNotification.Name.UIApplicationWillEnterForeground,
            object: nil)
        self.keyButton.setImage(UIImage(named: "smalo_search_button.png"), for: UIControlState())
        gradientClose()
        self.keyButton.isEnabled = false
        doorState = ""
        if !self.animateStart {
            pulsator.start()
            self.animateStart = true
        }
        (UIApplication.shared.delegate as! AppDelegate).doorState = doorState
        let message = [ "smaloNG" : "スマロNG" ]
        if #available(iOS 9.0, *) {
            if self.wcSession != nil {
                wcSession!.sendMessage( message, replyHandler: { replyDict in }, errorHandler: { error in })
            }
        }
    }
    
    func webSocketConnect() {
        if webSocketClosed() {
            webClient = SRWebSocket(urlRequest: URLRequest(url: URL(string: Bundle.main.object(forInfoDictionaryKey: "webSocketUrl") as! String)!))
            webClient?.delegate = self
            webClient?.open()
            notificationCenter.removeObserver(self)
        }
    }
    
    func webSocketOpened() -> Bool {
        if webClient != nil {
            if webClient!.readyState.rawValue == 1 {
                return true
            }
        }
        return false
    }
    
    func webSocketClosed() -> Bool {
        return !webSocketOpened()
    }
    
    func initBeacon() {
        //端末でiBeaconが使用できるかの判定できなければアラートをだす。
        if(CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self)) {
            
            // ロケーションマネージャの作成.
            myLocationManager = CLLocationManager()
            
            // デリゲートを自身に設定.
            myLocationManager.delegate = self
            
            // セキュリティ認証のステータスを取得
            let status = CLLocationManager.authorizationStatus()
            
            // 取得精度の設定.
            myLocationManager.desiredAccuracy = kCLLocationAccuracyBest
            
            // 取得頻度の設定.(1mごとに位置情報取得)
            myLocationManager.distanceFilter = 1
            
            // まだ認証が得られていない場合は、認証ダイアログを表示
            if(status != CLAuthorizationStatus.authorizedAlways) {
                print("CLAuthorizedStatus: \(status)");
                
                // まだ承認が得られていない場合は、認証ダイアログを表示.
                myLocationManager.requestAlwaysAuthorization()
            }
            
            
            // BeaconのUUIDを設定.
            let uuid = Foundation.UUID(uuidString: Bundle.main.object(forInfoDictionaryKey: "uuid") as! String)
            
            // リージョンを作成.
            myBeaconRegion = CLBeaconRegion(proximityUUID: uuid!,identifier: "EstimoteRegion")
            
            // ディスプレイがOffでもイベントが通知されるように設定(trueにするとディスプレイがOnの時だけ反応).
            myBeaconRegion.notifyEntryStateOnDisplay = false
            
            // 入域通知の設定.
            myBeaconRegion.notifyOnEntry = true
            
            // 退域通知の設定.
            myBeaconRegion.notifyOnExit = true
            
            beaconRegion = myBeaconRegion
            
            myLocationManager.startMonitoring(for: myBeaconRegion)
        } else {
            let alert = UIAlertController(title: "確認", message: "お使いの端末ではiBeaconをご利用できません。", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .default) { (action) -> Void in
                print("OK button tapped.")
            }
            
            alert.addAction(okAction)
            
            present(alert, animated: true, completion: nil)
        }
    }
    
    //初期レイアウトの設定
    func initLayout() {
        pulsator.numPulse = 5
        pulsator.radius = 170.0
        pulsator.animationDuration = 4.0
        pulsator.backgroundColor = UIColor(red: 0, green: 0.44, blue: 0.74, alpha: 1).cgColor
        keyButton.layer.addSublayer(pulsator)
        keyButton.superview?.layer.insertSublayer(pulsator, below: keyButton.layer)
        keyButton.isEnabled = false
        pulsator.start()
        animateStart = true
        gradientClose()
    }
    
    func gradientOpen() {
        //グラデーションの開始色
        let topColor = UIColor(red:0.13, green:0.71, blue:0.45, alpha:1.0)
        //グラデーションの開始色
        let bottomColor = UIColor(red:0.57, green:0.86, blue:0.73, alpha:1.0)
        
        //グラデーションの色を配列で管理
        let gradientColors = [topColor.cgColor, bottomColor.cgColor]
        
        //グラデーションの色をレイヤーに割り当てる
        gradientLayer.colors = gradientColors
        
        gradientLayer.locations = [0.8, 1]
        
        //グラデーションレイヤーをビューの一番下に配置
        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func gradientClose() {
        //グラデーションの開始色
        let topColor = UIColor(red:0.16, green:0.68, blue:0.76, alpha:1)
        //グラデーションの開始色
        let bottomColor = UIColor(red:0.57, green:0.84, blue:0.88, alpha:1)
        
        //グラデーションの色を配列で管理
        let gradientColors = [topColor.cgColor, bottomColor.cgColor]
        
        //グラデーションの色をレイヤーに割り当てる
        gradientLayer.colors = gradientColors
        
        gradientLayer.locations = [0.8, 1]
        
        //グラデーションレイヤーをビューの一番下に配置
        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    // watchからのメッセージを受け取る
    @available(iOS 9.0, *)
    func session(_ session: WCSession, didReceiveMessage message: [String: Any], replyHandler: @escaping ([String: Any]) -> Void) {
        print("ウェアから受け取りました。")
        
        if ((message["getState"] as? String) != nil) {
            
            if( doorState == "open" ){
                let message = [ "parentWakeClose" : "Closed"]
                if self.wcSession != nil {
                    wcSession!.sendMessage(message, replyHandler: { replyDict in }, errorHandler:  { error in })
                }
            }else if( doorState == "close" ){
                
                let message = [ "parentWakeOpen" : "Opened"]
                if self.wcSession != nil {
                    wcSession!.sendMessage(message, replyHandler: { replyDict in }, errorHandler:  { error in })
                }
            }else{
                let message = [ "smaloNG" : "スマロNG" ]
                if self.wcSession != nil {
                    wcSession!.sendMessage(message, replyHandler: { replyDict in }, errorHandler: { error in })
                }
                
            }
            
        }

        
        //鍵の開閉要求だった場合
        if ((message["stateUpdate"] as? String) != nil) {
            if isReturned {
                sendHttpMessage()
                isReturned = false
            }
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func localNotification(_ msg: String) {
        if UIApplication.shared.applicationState == UIApplicationState.background {
            UIApplication.shared.cancelAllLocalNotifications();
            let notification = UILocalNotification()
            notification.timeZone = TimeZone.current
            notification.alertBody = msg
            notification.soundName = UILocalNotificationDefaultSoundName
            UIApplication.shared.scheduleLocalNotification(notification)
        }
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("state \(central.state)");
        switch (central.state) {
        case .poweredOff:
            print("Bluetoothの電源がOff")
            bluetoothOn = false
        case .poweredOn:
            print("Bluetoothの電源はOn")
            bluetoothOn = true
        case .resetting:
            print("レスティング状態")
        case .unauthorized:
            print("非認証状態")
        case .unknown:
            print("不明")
        case .unsupported:
            print("非対応")
        }
        var alertMessage: String?
        
        if (!bluetoothOn) {
            alertMessage = "BluetoothをONにしてください。"
            print("bluetoothをオンにしてください。")
        }
        if (alertMessage != nil) {
            let alertController = UIAlertController(title: "通知", message: alertMessage, preferredStyle: .alert)
            
            let otherAction = UIAlertAction(title: "はい", style: .default) {
                action in NSLog("はいボタンが押されました")
                self.myCentralManager = nil
            }
            
            // addActionした順に左から右にボタンが配置されます
            alertController.addAction(otherAction)
            
            present(alertController, animated: true, completion: nil)
        }
    }
    
    /*
     (Delegate) 認証のステータスがかわったら呼び出される.
     */
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        print("didChangeAuthorizationStatus");
        
        // 認証のステータスをログで表示
        var statusStr = "";
        switch (status) {
        case .notDetermined:
            statusStr = "NotDetermined"
        case .restricted:
            statusStr = "Restricted"
        case .denied:
            statusStr = "Denied"
        case .authorizedAlways:
            statusStr = "AuthorizedAlways"
        case .authorizedWhenInUse:
            statusStr = "AuthorizedWhenInUse"
        }
        print(" CLAuthorizationStatus: \(statusStr)")
        
        manager.startMonitoring(for: beaconRegion)
    }
    
    /*
     (Delegate): LocationManagerがモニタリングを開始したというイベントを受け取る.
     */
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        
        print("didStartMonitoringForRegion");
        
        // この時点でビーコンがすでにRegion内に入っている可能性があるので、その問い合わせを行う
        // (Delegate didDetermineStateが呼ばれる)
        manager.requestState(for: region);
    }
    
    /*
     (Delegate): 現在リージョン内にいるかどうかの通知を受け取る.
     */
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        print("locationManager: didDetermineState \(state)")
        switch (state) {
            
        case .inside: // リージョン内にいる
            print("CLRegionStateInside:");
            // すでに入っている場合は、そのままRangingをスタートさせる
            // (Delegate didRangeBeacons)
            manager.startRangingBeacons(in: region as! CLBeaconRegion)
            break;
            
        case .outside:
            print("CLRegionStateOutside:")
            // 外にいる、またはUknownの場合はdidEnterRegionが適切な範囲内に入った時に呼ばれるため処理なし。
            break;
            
        case .unknown:
            print("CLRegionStateUnknown:")
            // 外にいる、またはUknownの場合はdidEnterRegionが適切な範囲内に入った時に呼ばれるため処理なし。
        }
    }
    
    /*
     (Delegate): ビーコンがリージョン内に入り、その中のビーコンをNSArrayで渡される.
     */
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        
        // 範囲内で検知されたビーコンはこのbeaconsにCLBeaconオブジェクトとして格納される
        // rangingが開始されると１秒毎に呼ばれるため、beaconがある場合のみ処理をするようにすること.
        // 通信用のConfigを生成.
        
        
        if(beacons.count > 0){
            
            // 発見したBeaconの数だけLoopをまわす
            for i in 0 ..< beacons.count {
                
                let beacon = beacons[i]
                
                let beaconUUID = beacon.proximityUUID
                let minor = "\(beacon.minor)"
                let major = "\(beacon.major)"
                let rssi = beacon.rssi
                let accuracy = beacon.accuracy
                
                print("UUID: \(beaconUUID.uuidString)")
                print("minorID: \(minor)")
                print("majorID: \(major)")
                print("RSSI: \(rssi)")
                print("accuracy: \(accuracy)")
                
                switch (beacon.proximity) {
                    
                case CLProximity.unknown :
                    print("Proximity: Unknown")
                    break
                    
                case CLProximity.far:
                    print("Proximity: Far")
                    if (!sendFlag && UIApplication.shared.applicationState == UIApplicationState.background) {
                        //doorStateがopenだった場合施錠のAPIを叩く
                        if doorState == "open" && webSocketOpened() {
                            sendUnLock()
                        }
                    }
                    break
                case CLProximity.near:
                    print("Proximity: Near")
                    break
                    
                case CLProximity.immediate:
                    print("Proximity: Immediate")
                    break
                }
                
            }
        }
    }
    
    /*
     (Delegate) リージョン内に入ったというイベントを受け取る.
     */
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("didEnterRegion");
        localNotification("領域に入りました")
        var bgTask = UIBackgroundTaskIdentifier()
        bgTask = UIApplication.shared.beginBackgroundTask (expirationHandler: { () -> Void in
            UIApplication.shared.endBackgroundTask(bgTask)
        })
        let priority = DispatchQueue.GlobalQueuePriority.default
        DispatchQueue.global(priority: priority).async {
            // do some task
            // Rangingを始める
            manager.startRangingBeacons(in: region as! CLBeaconRegion)
        }
    }
    
    func beginBackgroundUpdateTask() -> UIBackgroundTaskIdentifier {
        return UIApplication.shared.beginBackgroundTask(expirationHandler: {})
    }
    
    func endBackgroundUpdateTask(_ taskID: UIBackgroundTaskIdentifier) {
        UIApplication.shared.endBackgroundTask(taskID)
    }
    
    /*
     (Delegate) リージョンから出たというイベントを受け取る.
     */
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        NSLog("didExitRegion");
        localNotification("領域をでました")
        self.sendFlag = false
        // Rangingを停止する
        manager.stopRangingBeacons(in: region as! CLBeaconRegion)
    }
    
    @IBAction func keyButton(_ sender: AnyObject) {
        if isReturned {
            sendHttpMessage()
            isReturned = false
        }
    }
    //APIで解錠施錠のリクエストを送る。
    func sendHttpMessage() {
        //doorStateがopenだった場合施錠のAPIを叩く
        if doorState == "open" {
            sendUnLock()
        //doorStateがopenだった場合解錠のAPIを叩く
        } else if doorState == "close" {
            sendLock()
        }
    }
    
    //施錠する処理
    func sendLock() {
        //サーバーにメッセージをjson形式で送る処理
        let obj = [
            "command" : "lock"
        ]
        let json = String(describing: JSON(obj))
        webClient?.send(json)
        self.sendFlag = true
        self.localNotification("施錠されました")
    }
    
    //解錠させる処理
    func sendUnLock() {
        //サーバーにメッセージをjson形式で送る処理
        let obj = [
            "command" : "unlock"
        ]
        let json = String(describing: JSON(obj))
        webClient?.send(json)
        self.sendFlag = true
        self.localNotification("解錠されました。")
    }
    
    func session(_:WCSession, activationDidCompleteWith: WCSessionActivationState, error: Error?) {
        
    }
    
    func sessionDidBecomeInactive(_:WCSession) {
        
    }
    
    func sessionDidDeactivate(_:WCSession)  {
        
    }
}
extension String {
    var sha256: String! {
        return self.cString(using: String.Encoding.utf8).map { cstr in
            var chars = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
            CC_SHA256(
                cstr,
                CC_LONG(self.lengthOfBytes(using: String.Encoding.utf8)),
                &chars
            )
            return chars.map { String(format: "%02X", $0) }.reduce("", +)
        }
    }
}

