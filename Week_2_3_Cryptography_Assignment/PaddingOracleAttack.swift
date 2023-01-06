//
//  PaddingOracleAttack.swift
//  Week_2_3_Cryptography_Assignment
//
//  Created by Dat vu on 06/01/2023.
//

import Foundation

func request() {
    let iv = "f20bdba6ff29eed7b046d1df9fb70000"
    let c0 = "58b1ffb4210a580f748b4ac714c001bd"
    let c1 = "4a61044426fb515dad3f21f18aa577c0"
    let c2 = "bdf302936266926ff37dbf7035d5eeb4"
    let c1UInt8Array = c1.transformToArrayUInt8()
    
    for padding in 1...16 {
        let expectPadding = expectPadding(UInt8(padding))
        let beforeFoundInverseIndex = foundInverseIndex
        for supposeG in 0..<256 {
            if (beforeFoundInverseIndex != foundInverseIndex) { break }
            let guessG = g(UInt8(supposeG))
            let xorCipher = iv + c0 + "\(xor(xor(c1UInt8Array, expectPadding), guessG).transformToHex())" + c2
            ResourceRequest(resourcePath: xorCipher).get { result in
                switch result {
                case .failure(let code):
                    print("\(guessG) --- \(expectPadding) - \(code)")
                    if code == 404 {
                        truePlainText[truePlainText.count - Int(padding)] = guessG[truePlainText.count - Int(padding)]
                        foundInverseIndex -= 1
                    }
                    break
                }
            }
            Thread.sleep(forTimeInterval: 0.3)
        }
    }
    print(truePlainText)
}

func expectPadding(_ padding: UInt8) -> [UInt8] {
    var result = Array(repeating: UInt8(0), count: 16)
    for index in (result.count-Int(padding))..<result.count {
        result[index] = padding
    }
    return result
}

var foundInverseIndex = 15
var truePlainText = Array(repeating: UInt8(0), count: 16)
func g(_ supposeG: UInt8) -> [UInt8] {
    var g = [UInt8]()
    g.append(contentsOf: truePlainText)
    g[foundInverseIndex] = supposeG
    return g
}

func xor(_ l: [UInt8], _ r: [UInt8]) -> [UInt8] {
    var result = Array(repeating: UInt8(0), count: 16)
    for index in 0..<result.count {
        result[index] = l[index] ^ r[index]
    }
    return result
}
