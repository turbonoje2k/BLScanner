//
//  ScannerView.swift
//  BluetoothScanner
//
//  Created by Xavier Sirvent on 13/11/2023.
//

import SwiftUI

struct ScannerView: View {
  
  @StateObject var ble = BluetoothManager()
  
  var body: some View {
    VStack(spacing: 10) {
      Text("Bluetooth devices")
        .font(.largeTitle)
        .frame(maxWidth: .infinity, alignment: .center)
      
      List(ble.peripherals) { peripheral in
        HStack {
          Text(peripheral.name)
          Spacer()
          Text("\(peripheral.rssi) dB")
        }
      }
      .frame(height: UIScreen.main.bounds.height / 2)
      
      Spacer()
      
      Text("Status")
        .font(.headline)
      
      if ble.isOn {
        Text("Bluetooth is available")
          .foregroundStyle(.green)
      } else {
        Text("Bluetooth is not available")
          .foregroundStyle(.red)
      }
      
      Spacer()
      
      VStack( spacing: 25) {
        Button(action: {
          ble.startScan(timer: 10)
        }) {
          Text("Start scanning")
            .foregroundColor(ble.isScanning ? .gray : .blue)
        }
        .disabled(ble.isScanning)
        
        Button(action: {
          ble.stopScan()
        }) {
          Text("Stop scanning")
            .foregroundColor(ble.isScanning ? .blue : .gray)
        }
        .disabled(!ble.isScanning)
      }.padding()
      
      Spacer()

    }
  }
}

#Preview {
    ScannerView()
}
