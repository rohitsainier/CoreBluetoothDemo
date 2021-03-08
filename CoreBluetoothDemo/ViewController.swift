//
//  ViewController.swift
//  CoreBluetoothDemo
//
//  Created by Rohit Saini on 20/01/21.
//

import UIKit
import CoreBluetooth


class ViewController: UIViewController {
    var centralManager: CBCentralManager!
    var bluePeripheral: CBPeripheral!
    var blueCharacteristic:CBCharacteristic?
    var CAP_UDID = CBUUID(string: "1111")
    var CAP_CHAR_UUID = CBUUID(string: "2222")
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configUI()
        
    }
    
    private func configUI(){
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    @IBAction func clickSendBtn(_ sender: UIButton) {
        let dataStr = "My name is rohit saini"
        let data = dataStr.data(using: .utf8)
        guard let blueCharacteristic = blueCharacteristic else{
            print("No Characteristic Found")
            return
        }
        writeValueToChar(withCharacteristic: blueCharacteristic, withValue: data!)
        
    }
    
    private func writeValueToChar( withCharacteristic characteristic: CBCharacteristic, withValue value: Data) {
        
        bluePeripheral.writeValue(value, for: characteristic, type: .withResponse)
        
    }
    
}

extension ViewController: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("central.state is .unknown")
        case .resetting:
            print("central.state is .resetting")
        case .unsupported:
            print("central.state is .unsupported")
        case .unauthorized:
            print("central.state is .unauthorized")
        case .poweredOff:
            print("central.state is .poweredOff")
        case .poweredOn:
            print("central.state is .poweredOn")
            centralManager.scanForPeripherals(withServices: nil)
        @unknown default:
            fatalError()
        }
    }
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
            print("Device Available: \(peripheral)")
            bluePeripheral = peripheral
            centralManager.stopScan()
            centralManager.connect(bluePeripheral)
            bluePeripheral.delegate = self

    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected! to \(peripheral)")
        bluePeripheral.discoverServices([CAP_UDID])
    }
    
    
}

extension ViewController:CBPeripheralDelegate{
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        print("Services Available: \(services)")
        var count = 1
        for service in services {
            print("Service \(count): \(service)")
            count += 1
            peripheral.discoverCharacteristics(nil, for: service)
        }
        
    }
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        print("Characteristic Available: \(characteristics)")
        var count = 1
        for characteristic in characteristics {
            print("Characteristic \(count): \(characteristic)")
            count += 1
            if characteristic.uuid == CAP_CHAR_UUID{
                blueCharacteristic = characteristic
                bluePeripheral.setNotifyValue(true, for: characteristic)
            }
            
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print("Data Received from characteristic: \(characteristic)")
        if characteristic.uuid == CAP_CHAR_UUID{
            if let data = characteristic.value{
                let str = String(decoding: data, as: UTF8.self)
                print("received Data: \(str)")
            }
        }
        
    }
    public func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        for service in invalidatedServices {
            print("Invalid Service \(service)")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error{
            print(error)
        }
        else{
            print("Data Sent Successfully!")
        }
    }
}

