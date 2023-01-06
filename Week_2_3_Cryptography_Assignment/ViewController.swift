//
//  ViewController.swift
//  Week_2_Cryptography
//
//  Created by Dat Vu on 30/12/2022.
//

import UIKit

enum AESMode {
    case CBC, CTR
}

struct CustomCipher {
    var key: String // hex
    var iv: String! // hex
    var fullCipherText: String // hex - with IV
    var cipherText: String! // hex - without IV
    var mode: AESMode
    var padding: Padding
    
    var keyUInt8: Array<UInt8> = []
    var ivUInt8: Array<UInt8> = []
    var cipherTextUInt8: Array<UInt8> = []
    
    init(key: String, mode: AESMode = .CBC, padding: Padding = .pkcs5, fullCipherText: String) {
        self.key = key
        self.mode = mode
        self.padding = padding
        self.fullCipherText = fullCipherText
        iv = fullCipherText.ivFromFullCipherText()
        cipherText = fullCipherText.cipherTextFromFullCipherText()
        keyUInt8 = key.transformToArrayUInt8()
        ivUInt8 = iv.transformToArrayUInt8()
        cipherTextUInt8 = cipherText.transformToArrayUInt8()
    }
    
    func decrypt() {
        switch mode {
        case .CTR:
            do {
                let decrypted = try AES(key: keyUInt8, blockMode: CTR(iv: ivUInt8), padding: .pkcs5).decrypt(cipherTextUInt8)
                if let plainText = String(bytes: decrypted, encoding: .utf8) {
                    print("\(plainText) \n")
                } else {
                    print("not a valid UTF-8 sequence")
                }
            } catch {
                print(error)
            }
        default:
            do {
//                let encrypted = try AES(key: key, blockMode: CBC(iv: iv), padding: .pkcs7).encrypt(input)
//                let decrypted = try AES(key: cipher.keyUInt8, blockMode: CBC(iv: cipher.ivUInt8), padding: .pkcs5).decrypt(cipher.cipherTextUInt8)
                let decrypted = try AES(key: keyUInt8, blockMode: CBC(iv: ivUInt8), padding: .pkcs5).decrypt(cipherTextUInt8)
                if let plainText = String(bytes: decrypted, encoding: .utf8) {
                    print("\(plainText) \n")
                } else {
                    print("not a valid UTF-8 sequence")
                }
            } catch {
                print(error)
            }
        }
    }
}

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let cipherObjects = [
            CustomCipher(key: "140b41b22a29beb4061bda66b6747e14", fullCipherText: "4ca00ff4c898d61e1edbf1800618fb2828a226d160dad07883d04e008a7897ee2e4b7465d5290d0c0e6c6822236e1daafb94ffe0c5da05d9476be028ad7c1d81"),
            CustomCipher(key: "140b41b22a29beb4061bda66b6747e14", fullCipherText: "5b68629feb8606f9a6667670b75b38a5b4832d0f26e1ab7da33249de7d4afc48e713ac646ace36e872ad5fb8a512428a6e21364b0c374df45503473c5242a253"),
            CustomCipher(key: "36f18357be4dbd77f050515c73fcf9f2", mode: .CTR, fullCipherText: "69dda8455c7dd4254bf353b773304eec0ec7702330098ce7f7520d1cbbb20fc388d1b0adb5054dbd7370849dbf0b88d393f252e764f1f5f7ad97ef79d59ce29f5f51eeca32eabedd9afa9329"),
            CustomCipher(key: "36f18357be4dbd77f050515c73fcf9f2", mode: .CTR, fullCipherText: "770b80259ec33beb2561358a9f2dc617e46218c0a53cbeca695ae45faa8952aa0e311bde9d4e01726d3184c34451")
        ]
        
        // Week 2
        for cipher in cipherObjects {
            cipher.decrypt()
        }
        
        // Week 3
//        hash()
        
        // Week 4
        request()
    }
    
    func hash() {
        guard let data = getFileData() else {
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
    
    func request() {
        let iv = "f20bdba6ff29eed7b046d1df9fb70000"
        let c0 = "58b1ffb4210a580f748b4ac714c001bd"
        let c1 = "4a61044426fb515dad3f21f18aa577c0"
        let c2 = "bdf302936266926ff37dbf7035d5eeb4"
        
        let c1UInt8Array = c1.transformToArrayUInt8()
        
        for padding in 1...16 {
            let expectPadding = expectPadding(UInt8(padding))
            for supposeG in 0..<256 {
                let guessG = g(UInt8(supposeG))
                let xorCipher = iv + c0 + "\(xor(xor(c1UInt8Array, expectPadding), guessG).transformToHex())" + c2
                ResourceRequest<Int, Int>(resourcePath: xorCipher).get { result in
                    switch result {
                    case .failure(let code):
                        print("\(guessG) --- \(expectPadding) - \(code)")
                        if code == 404 {
                            print(xorCipher)
                        }
                        break
                    }
                }
                Thread.sleep(forTimeInterval: 0.1)
            }
        }
    }
    
    func expectPadding(_ paddingElementValue: UInt8) -> [UInt8] {
        var padding = Array(repeating: UInt8(0), count: 16)
        for index in (padding.count-Int(paddingElementValue))..<padding.count {
            padding[index] = paddingElementValue
        }
        return padding
    }
    
    func g(_ supposeG: UInt8) -> [UInt8] {
        var g = Array(repeating: UInt8(0), count: 16)
        g[g.count-1] = supposeG
        return g
    }
    
    func xor(_ l: [UInt8], _ r: [UInt8]) -> [UInt8] {
        var result = Array(repeating: UInt8(0), count: 16)
        for index in 0..<result.count {
            result[index] = l[index] ^ r[index]
        }
        print(l)
        print(r)
        print(result)
        return result
    }
    
    
    
    
    
    func getFileData() -> [UInt8]? {
        guard let path = Bundle.main.path(forResource: "6.1.intro.mp4_download", ofType: "") else {
            print("Cannot find file in Main Bundle!")
            return nil
        }
//        var chunks = [UInt8]()
//        if let stream = InputStream(fileAtPath: path) {
//            var buf = [UInt8](repeating: 0, count: 1024)
//            stream.open()
//
//            while case let amount = stream.read(&buf, maxLength: 1024), amount > 0 {
//                // print(amount)
//                chunks.append(contentsOf: Array(buf[..<amount]))
////                chunks.append(Array(buf[..<amount]))
//            }
//            stream.close()
//        }
//        return chunks
        
        let filePath = URL(fileURLWithPath: path)
        do {
            let data = try Data(contentsOf: filePath)
            return data.bytes
        } catch {
            print("Cannot load file data!")
            return nil
        }
    }
}

extension String {
    func transformToArrayUInt8() -> [UInt8] {
        var result: Array<UInt8> = []
        let utf8 = Array<UInt8>(self.utf8)
        let skip0x = self.hasPrefix("0x") ? 2 : 0
        for idx in stride(from: utf8.startIndex.advanced(by: skip0x), to: utf8.endIndex, by: utf8.startIndex.advanced(by: 2)) {
            let byteHex = "\(UnicodeScalar(utf8[idx]))\(UnicodeScalar(utf8[idx.advanced(by: 1)]))"
            if let byte = UInt8(byteHex, radix: 16) {
                result.append(byte)
            }
        }
        return result
    }
    func transformToArrayUInt8ByTrimmingIV() -> [UInt8] {
        let trimedIVCipherText = self[self.index(self.startIndex, offsetBy: 32)..<self.endIndex]
        return String(trimedIVCipherText).transformToArrayUInt8()
    }
    func ivFromFullCipherText() -> String {
        return String(self[self.startIndex..<self.index(self.startIndex, offsetBy: 32)])
    }
    func cipherTextFromFullCipherText() -> String {
        let trimedIVCipherText = self[self.index(self.startIndex, offsetBy: 32)..<self.endIndex]
        return String(trimedIVCipherText)
    }
}

extension Array where Element == UInt8 {
    public init(customHex: String) {
        self.init()
        let utf8 = Array<Element>(customHex.utf8)
        let skip0x = customHex.hasPrefix("0x") ? 2 : 0
        for idx in stride(from: utf8.startIndex.advanced(by: skip0x), to: utf8.endIndex, by: utf8.startIndex.advanced(by: 2)) {
            let byteHex = "\(UnicodeScalar(utf8[idx]))\(UnicodeScalar(utf8[idx.advanced(by: 1)]))"
            if let byte = UInt8(byteHex, radix: 16) {
                self.append(byte)
            }
        }
    }
    
    func transformToHex() -> String {
        let hexValueTable = ["0", "1", "2", "3",
                        "4", "5", "6", "7",
                        "8", "9", "a", "b",
                        "c", "d", "e", "f"]
        var hexString = ""
        for number in self {
            let decimal = Int(number)
            let firstHex = decimal / 16
            let secondHex = decimal % 16
            hexString += hexValueTable[firstHex]
            hexString += hexValueTable[secondHex]
        }
        return hexString
    }
}

