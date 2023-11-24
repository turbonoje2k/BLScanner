//
//  BluetoothManager.swift
//  BluetoothScanner
//
//  Created by Xavier Sirvent on 14/11/2023.
//

import Combine
import CoreBluetooth

struct Peripheral: Identifiable {
  let id: UUID
  var name: String
  let rssi: Int
}

class BluetoothManager: NSObject, ObservableObject {
  
  private var centralManager: CBCentralManager!
  @Published var isOn = false
  @Published var isScanning = false
  @Published var peripherals: [Peripheral] = []
  
  override init() {
    super.init()
    centralManager = CBCentralManager(delegate: self, queue: nil)
  }
  
  public static let shared: BluetoothManager = BluetoothManager()
  
  var state = PassthroughSubject<CBManagerState, Never>()
  
  func startScan(timer: Double = 5.0) {
    print("Start Scan")
    centralManager.stopScan()
    centralManager.scanForPeripherals(withServices: nil)
    peripherals.removeAll()
    isScanning = true
    armScanTimer(timer: timer)
  }
  
  func stopScan() {
    print("Stop Scan")
    centralManager.stopScan()
    isScanning = false
    
  }
  
  private func armScanTimer(timer: Double) {
    DispatchQueue.main.asyncAfter(deadline: .now() + timer, execute: { [weak self] in
      self?.stopScan()
    })
  }
}

extension BluetoothManager: CBCentralManagerDelegate {
  
  func centralManagerDidUpdateState(_ central: CBCentralManager) {
    isOn = central.state == .poweredOn
  }
  
  func centralManager(_ central: CBCentralManager,
                      didDiscover peripheral: CBPeripheral,
                      advertisementData: [String: Any],
                      rssi RSSI: NSNumber) {
    
    print("New peripheral detected: \(peripheral)")
    addPeripheral(peripheral, with: RSSI.intValue)
  }
  
  private func addPeripheral(_ peripheral: CBPeripheral, with rssi: Int) {
    
    if let row = peripherals.firstIndex(where: { $0.id == peripheral.identifier }) {
      // Update already detected peripheral if needed
      if peripherals[row].name.isEmpty && peripheral.name != nil {
        peripherals[row].name = peripheral.name ?? "Unknown"
      }
    } else {
      // Add new peripheral
      let newPeripheral = Peripheral(id: peripheral.identifier, name: peripheral.name ?? "Unknown", rssi: rssi)
      peripherals.append(newPeripheral)
    }
  }
}
