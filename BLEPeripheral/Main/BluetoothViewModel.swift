//
//  BluetoothViewModel.swift
//  BLEPeripheral
//
//  Created by Brandon Fraune on 8/25/22.
//

import Foundation
import CoreBluetooth

class BluetoothViewModel: NSObject, ObservableObject, CBPeripheralManagerDelegate {
    
    private var peripheralManager: CBPeripheralManager!
    
    @Published var bluetoothState = "none"
    @Published var message = "aaa"
    @Published var readValue = "98.1 ºF"
    @Published var writeValue = ""
    
    // Health Thermometer GATT service
    private let service: CBUUID = CBUUID(string: "1809")
    // Temperature Measurement GATT Characteristic
    private let characteristicA = CBMutableCharacteristic(type: CBUUID(string: "2A1C"), properties: [.notify], value: nil, permissions: [.readable])
    // private let characteristicB = CBMutableCharacteristic(type: CBUUID(string: "2A1C"), properties: [.read], value: valueData, permissions: [.readable])
    // private let characteristicC = CBMutableCharacteristic(type: CBUUID(string: "2A1C"), properties: [.notify, .write, .read], value: nil, permissions: [.readable, .writeable])
    
    override init() {
        super.init()
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        bluetoothState = peripheral.state.humanReadable()
        switch peripheral.state {
        case .unknown:
            print("Bluetooth Device is UNKNOWN")
        case .unsupported:
            print("Bluetooth Device is UNSUPPORTED")
        case .unauthorized:
            print("Bluetooth Device is UNAUTHORIZED")
        case .resetting:
            print("Bluetooth Device is RESETTING")
        case .poweredOff:
            print("Bluetooth Device is POWERED OFF")
        case .poweredOn:
            print("Bluetooth Device is POWERED ON")
            addServices()
        @unknown default:
            fatalError()
        }
    }
    
    private func addServices() {
        let myService = CBMutableService(type: service, primary: true)
        myService.characteristics = [characteristicA]
        peripheralManager.add(myService)
        startAdvertising()
    }
    
    private func startAdvertising() {
        message = "Advertising Data Started"
        peripheralManager.startAdvertising([CBAdvertisementDataLocalNameKey: "TAIDOC TD1242-BJF", CBAdvertisementDataServiceUUIDsKey: [service]])
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        message = "Characteristic read"
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        message = "Received write"
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        message = "Subscriber added"
        let value = Temperature().value
        peripheral.updateValue(value.hexadecimal!, for: characteristicA, onSubscribedCentrals: [central])
    }
    
}
