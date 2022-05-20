//
//  ViewController.swift
//  KeychainExample
//
//  Created by 강대민 on 2022/05/20.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        getPassword()
    }

    
    func getPassword() {
        guard let data = try KeychainManager.get(
            service: "facebook.com",
            account: "daemin")
                
        else {
            print("암호 읽기 실패.")
            return
        }
        
        //암호 읽기 성공후 하고 싶은것.
        //우선 암호의 데이터를 문자열로 디코딩한다.
        let password = String(decoding: data, as: UTF8.self)
        print("암호 읽었당 : \(password)")
        
    }
    
    //이것을 save super creative라고 부를것이다.
    func save() {
        //키체인에서 우리의 최고 보안 암호를 실제로 읽을 수 있는지 보자.
        //여기에서 진행했고 실제로 무언가를 저장했으므로...
        //모든것이 성공하면 print("saved")를 볼수있다.
        do {
            try KeychainManager.save(service: "facebook.com",
                                     account: "daemin",
                                     password: "무언가...".data(using: .utf8) ?? Data()
            )
        } catch {

            print(error)
        }
    }
    

}

class KeychainManager {
    
    enum KeychainError: Error {
        case duplicateEntry //중복에러?
        case unknown(OSStatus) //알수없는에러
    }
    
    static func save(
        service: String,
        account: String,
        password: Data
    ) throws {
        //service, account, password, class,
        let query: [String: AnyObject] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service as AnyObject,
            kSecAttrAccount as String: account as AnyObject,
            kSecValueData as String: password as AnyObject
        ]
        
        let status = SecItemAdd(
            query as CFDictionary,
            nil
        )
        
        //중복 항목인 경우의 에러
        guard status != errSecDuplicateItem else {
            throw KeychainError.duplicateEntry
        }
        //성공 이외의 다른 경우에는
        guard status == errSecSuccess else {
            throw KeychainError.unknown(status)
        }
        
        print("saved")
        
    }
    
    static func get(
        service: String,
        account: String
        //우린 최대 하나만 원하고있고, 일치하는 항목을 찾지 못하면 nil을 반환하려한다.
    ) -> Data? {
        //service, account, password, class,
        let query: [String: AnyObject] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service as AnyObject,
            kSecAttrAccount as String: account as AnyObject,
            kSecReturnData as String: kCFBooleanTrue,
            //limitOne!
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary,
            //이게 중요하다 왜냐하면 우리는 키체인이 우리의 결과를 넣을것에 대한 가변 포인터를 실제로 전달하기를
            //원하기 떄문이다. 여기에서 우리는 결과가 임의의 객체가 될것이라고 말하고 이것을 참조로 전달할 것이다.
                                         &result
        )
        
        print("read status : \(status)")
        
        return result as? Data
        
        
    }
}
