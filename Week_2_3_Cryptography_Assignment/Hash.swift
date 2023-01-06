//
//  Hash.swift
//  Week_2_3_Cryptography_Assignment
//
//  Created by Dat vu on 06/01/2023.
//

import Foundation

func hashFile() {
    guard let data = ViewController.getFileData() else {
        print("Cannot load file data!")
        return
    }
    var hashed: [UInt8] = []
    for index in stride(from: data.count - 1, through: 0, by: -1024) {
        var blockData: [UInt8]
        if index > 1024 {
            blockData = Array(data[index - 1023...index])
        } else {
            blockData = Array(data[0...index])
        }
        if (hashed.count == 0) {
            hashed = blockData.sha256()
        } else {
            blockData += hashed
            hashed = blockData.sha256()
        }
    }
    print("Hashed hex: \(hashed.toHexString())")
}
