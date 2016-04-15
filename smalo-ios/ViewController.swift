//
//  ViewController.swift
//  smalo-ios
//
//  Created by 須崎鉄 on 2016/04/07.
//  Copyright © 2016年 須崎鉄. All rights reserved.
//

import UIKit
import CoreBluetooth
import Pulsator

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    var centralManager: CBCentralManager!
    var peripheral: CBPeripheral!
    var closeCharacteristic: CBCharacteristic!
    var openCharacteristic: CBCharacteristic!
    var notifyCharacteristic: CBCharacteristic!
    var keyFlag = true
    var major: String?
    var mainor: String?
    let UUID: String = "\(UIDevice.currentDevice().identifierForVendor!.UUIDString)"
    let pulsator = Pulsator()
    @IBOutlet weak var keyButton: UIButton!
    @IBOutlet weak var gradationView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let options: [String: AnyObject] = [CBCentralManagerOptionRestoreIdentifierKey: "restoreKey"]
        self.centralManager = CBCentralManager(delegate: self, queue: nil, options: options)
        // Do any additional setup after loading the view, typically from a nib.
        pulsator.numPulse = 5
        pulsator.radius = 100.0
        pulsator.backgroundColor = UIColor(red: 0, green: 0.44, blue: 0.74, alpha: 1).CGColor
        keyButton.layer.addSublayer(pulsator)
        keyButton.superview?.layer.insertSublayer(pulsator, below: keyButton.layer)
        pulsator.start()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //グラデーションの開始色
        let topColor = UIColor(red:0.16, green:0.68, blue:0.76, alpha:1)
        //グラデーションの開始色
        let bottomColor = UIColor(red:0.57, green:0.84, blue:0.88, alpha:1)
        
        //グラデーションの色を配列で管理
        let gradientColors: [CGColor] = [topColor.CGColor, bottomColor.CGColor]
        
        //グラデーションレイヤーを作成
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        
        //グラデーションの色をレイヤーに割り当てる
        gradientLayer.colors = gradientColors
        //グラデーションレイヤーをスクリーンサイズにする
        gradientLayer.frame.size = self.gradationView.frame.size
        
        //グラデーションレイヤーをビューの一番下に配置
        self.gradationView.layer.insertSublayer(gradientLayer, atIndex: 0)
        pulsator.position = keyButton.center

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func centralManagerDidUpdateState(central: CBCentralManager) {
        switch central.state {
        case CBCentralManagerState.PoweredOff:
            print(central.state)
            self.centralManager.stopScan()
        case CBCentralManagerState.PoweredOn:
            let serviceUUIDs:NSArray = [CBUUID(string: "9ada4c64-c941-46c2-9156-c39addd4f77c")]
            self.centralManager.scanForPeripheralsWithServices(serviceUUIDs as? [CBUUID], options: nil)
        default:
            print(central.state)
        }
    }
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        print("発見したBLEデバイス\(peripheral)")
        localNotification("発見したBLEデバイス\(peripheral)")
        if peripheral.name == "健のiPad" {
            self.peripheral = peripheral
            self.centralManager.connectPeripheral(self.peripheral, options: nil)
        }
    }
    
    func localNotification(msg: String) {
        if UIApplication.sharedApplication().applicationState != UIApplicationState.Active {
            
            let notification = UILocalNotification()
            notification.timeZone = NSTimeZone.defaultTimeZone()
            notification.alertBody = msg
            notification.soundName = UILocalNotificationDefaultSoundName
            UIApplication.sharedApplication().scheduleLocalNotification(notification)
        }
    }
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        print("接続成功！")
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        let services: NSArray = peripheral.services!
        print("\(services.count)このサービス発見！　\(services)")
        for obj in services {
            if let service = obj as? CBService {
                if service.UUID.isEqual(CBUUID(string: "9ada4c64-c941-46c2-9156-c39addd4f77c")) {
                    peripheral.discoverCharacteristics(nil, forService: service)
                }
            }
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        let characteristics: NSArray = service.characteristics!
        print("\(characteristics.count)個のキャラクタリスティックを発見！　\(characteristics)")
        for obj in characteristics {
            if let characteristic = obj as? CBCharacteristic {
                print("\(characteristic.UUID)")
                if characteristic.UUID == CBUUID(string:"b2e238b4-5b26-48c1-9023-2099a02c99b0") {
                    peripheral.readValueForCharacteristic(characteristic)
                    peripheral.setNotifyValue(true, forCharacteristic: characteristic)
                }
                if characteristic.UUID == CBUUID(string:"68da96b6-7634-440a-8fcf-95ef1a5e7e5b") {
                    peripheral.readValueForCharacteristic(characteristic)
                    peripheral.setNotifyValue(true, forCharacteristic: characteristic)
                }
                if characteristic.UUID == CBUUID(string:"0ab375be-141a-4ba2-81ee-e6ecc695ac06") {
                    self.notifyCharacteristic = characteristic
                    peripheral.readValueForCharacteristic(self.notifyCharacteristic)
                    peripheral.setNotifyValue(true, forCharacteristic: self.notifyCharacteristic)
                }
                if characteristic.UUID == CBUUID(string: "c295a114-157d-4ba6-a788-37121cc04f51") {
                    self.openCharacteristic = characteristic
                }
                if characteristic.UUID == CBUUID(string: "47a10c88-f91f-45b0-9212-97cb6fbcd298") {
                    self.closeCharacteristic = characteristic
                }
            }
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        if characteristic.UUID == CBUUID(string: "b2e238b4-5b26-48c1-9023-2099a02c99b0") {
            print("読み出し成功！service uuid: \(characteristic.UUID),value: \(characteristic.value)")
            major = String(data:characteristic.value!, encoding:NSUTF8StringEncoding)
        }
        if characteristic.UUID == CBUUID(string: "68da96b6-7634-440a-8fcf-95ef1a5e7e5b") {
            print("読み出し成功！service uuid: \(characteristic.UUID),value: \(characteristic.value)")
            mainor = String(data: characteristic.value!, encoding: NSUTF8StringEncoding)
            localNotification("読み出し成功！service uuid: \(characteristic.UUID),value: \(characteristic.value)")
        }
        if characteristic.UUID == CBUUID(string: "0ab375be-141a-4ba2-81ee-e6ecc695ac06") {
            print("読み出し成功！service uuid: \(characteristic.UUID),value: \(characteristic.value)")
            localNotification("読み出し成功！service uuid: \(characteristic.UUID),value: \(String(data:characteristic.value!,encoding:NSUTF8StringEncoding)!)")
            switch String(data:characteristic.value!,encoding:NSUTF8StringEncoding)! {
            case "unlocked":
                keyFlag = false
                break
            case "locked":
                keyFlag = true
                break
            default:
                break
            }
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        print("Notify状態更新成功！　isNotifying: \(characteristic.isNotifying)")
    }
    
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        print("接続失敗・・・")
    }
    
    func peripheral(peripheral: CBPeripheral, didWriteValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        print("Write成功！")
    }
    
    func centralManager(central: CBCentralManager, willRestoreState dict: [String : AnyObject]) {
        localNotification("セントラル復元:\(dict)")
        let peripherals = dict[CBCentralManagerRestoredStatePeripheralsKey] as! NSArray;
        for aPeripheral in peripherals {
            if (aPeripheral as! CBPeripheral).state == CBPeripheralState.Connected {
                self.peripheral = aPeripheral as! CBPeripheral
                self.peripheral.delegate = self
            }
        }
        // 復元されたペリフェラルについて、キャラクタリスティックの状態を見てみる・プロパティにセットしなおす
        for aService in self.peripheral.services! {
            for aCharacteristic in aService.characteristics! {
                
                if aCharacteristic.UUID == CBUUID(string: "0ab375be-141a-4ba2-81ee-e6ecc695ac06") {
                    
                    print("characteristic: \(aCharacteristic)");
                    
                    // コンソール出力結果： characteristic: <CBCharacteristic: 0x174086680, UUID = 1112, properties = 0x12, value = <a5>, notifying = YES>
                    // → Notifyの状態まで復元されていることがわかる
                    
                    self.notifyCharacteristic = aCharacteristic;
                }
            }
        }
    }
    
    @IBAction func keyButton(sender: AnyObject) {
        if keyFlag {
            if openCharacteristic != nil {
                if !(major?.isEmpty)! && !(mainor?.isEmpty)! {
                    let value: String = (UUID+"|"+major!+"|"+mainor!).sha256
                    let data: NSData = value.dataUsingEncoding(NSUTF8StringEncoding)!
                    self.peripheral.writeValue(data, forCharacteristic: openCharacteristic, type: CBCharacteristicWriteType.WithResponse)
                    keyButton.backgroundColor = UIColor.redColor()
                    keyButton.setTitle("Close", forState: UIControlState.Normal)
                    keyFlag = false
                }
            }
        } else {
            if closeCharacteristic != nil {
                if !(major?.isEmpty)! && !(mainor?.isEmpty)! {
                    let value: String = (UUID+"|"+major!+"|"+mainor!).sha256
                    let data: NSData = value.dataUsingEncoding(NSUTF8StringEncoding)!
                    self.peripheral.writeValue(data, forCharacteristic: closeCharacteristic, type: CBCharacteristicWriteType.WithResponse)
                    keyButton.backgroundColor = UIColor.greenColor()
                    keyButton.setTitle("Open", forState: UIControlState.Normal)
                    keyFlag = true
                }
            }
        }
    }
}
extension String {
    var sha256: String! {
        return self.cStringUsingEncoding(NSUTF8StringEncoding).map { cstr in
            var chars = [UInt8](count: Int(CC_SHA256_DIGEST_LENGTH), repeatedValue: 0)
            CC_SHA256(
                cstr,
                CC_LONG(self.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)),
                &chars
            )
            return chars.map { String(format: "%02X", $0) }.reduce("", combine: +)
        }
    }
}

