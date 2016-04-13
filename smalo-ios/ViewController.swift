//
//  ViewController.swift
//  smalo-ios
//
//  Created by 須崎鉄 on 2016/04/07.
//  Copyright © 2016年 須崎鉄. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    var centralManager: CBCentralManager!
    var peripheral: CBPeripheral!
    var closeCharacteristic: CBCharacteristic!
    var openCharacteristic: CBCharacteristic!
    var keyFlag = true
    var major: String?
    var mainor: String?
    let UUID: String = "\(UIDevice.currentDevice().identifierForVendor!.UUIDString)"
    @IBOutlet weak var keyButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let options: [String: AnyObject] = [CBCentralManagerOptionRestoreIdentifierKey: "restoreKey"]
        self.centralManager = CBCentralManager(delegate: self, queue: nil, options: options)
        // Do any additional setup after loading the view, typically from a nib.
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
                    peripheral.readValueForCharacteristic(characteristic)
                    peripheral.setNotifyValue(true, forCharacteristic: characteristic)
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
            localNotification("読み出し成功！service uuid: \(characteristic.UUID),value: \(characteristic.value)")
            switch String(data:characteristic.value!,encoding:NSUTF8StringEncoding)! {
            case "open":
                keyFlag = false
                break
            case "close":
                keyFlag = true
                break
            default:
                break
            }
        }
        if characteristic.UUID == CBUUID(string: "68da96b6-7634-440a-8fcf-95ef1a5e7e5b") {
            print("読み出し成功！service uuid: \(characteristic.UUID),value: \(characteristic.value)")
            major = String(data:characteristic.value!, encoding:NSUTF8StringEncoding)
        }
        if characteristic.UUID == CBUUID(string: "0ab375be-141a-4ba2-81ee-e6ecc695ac06") {
            print("読み出し成功！service uuid: \(characteristic.UUID),value: \(characteristic.value)")
            mainor = String(data: characteristic.value!, encoding: NSUTF8StringEncoding)
        }
        print("読み出し成功！service uuid: \(characteristic.UUID),value: \(characteristic.value)")
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
        let peripherals = dict[CBCentralManagerOptionRestoreIdentifierKey] as! NSArray;
        for aPeripheral in peripherals {
            if (aPeripheral as! CBPeripheral).state == CBPeripheralState.Connected {
                self.peripheral = aPeripheral as! CBPeripheral
                self.peripheral.delegate = self
            }
        }
    }
    
    @IBAction func keyButton(sender: AnyObject) {
        if keyFlag {
            var value: String = ("open"+"|"+UUID+"|"+mainor!+"|"+mainor!).sha256
            let data: NSData = NSData(bytes: &value, length: 4)
            if openCharacteristic != nil {
                self.peripheral.writeValue(data, forCharacteristic: openCharacteristic, type: CBCharacteristicWriteType.WithResponse)
                keyButton.backgroundColor = UIColor.redColor()
                keyButton.setTitle("Close", forState: UIControlState.Normal)
                keyFlag = false
            }
        } else {
            var value: String = ("close"+"|"+UUID+"|"+major!+"|"+mainor!).sha256
            let data: NSData = NSData(bytes: &value, length: 5)
            if closeCharacteristic != nil {
                self.peripheral.writeValue(data, forCharacteristic: closeCharacteristic, type: CBCharacteristicWriteType.WithResponse)
                keyButton.backgroundColor = UIColor.greenColor()
                keyButton.setTitle("Open", forState: UIControlState.Normal)
                keyFlag = true
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

