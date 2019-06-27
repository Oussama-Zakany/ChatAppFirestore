//
//  LoginViewModel.swift
//  ChatAppFirestore
//
//  Created by OuSS on 6/26/19.
//  Copyright © 2019 OuSS. All rights reserved.
//

import Foundation
import Firebase

class LoginViewModel {
    
    var isLoggingIn = Bindable<Bool>()
    var isFormValid = Bindable<Bool>()
    
    var email: String? { didSet { checkFormValidity() } }
    var password: String? { didSet { checkFormValidity() } }
    
    fileprivate func checkFormValidity() {
        let isValid = email?.isEmpty == false && email?.isValidEmail() == true && password?.isEmpty == false
        isFormValid.value = isValid
    }
    
    func performLogin(completion: @escaping (_ result: Result<Bool,Error>) -> ()) {
        guard let email = email, let password = password else { return }
        isLoggingIn.value = true
        AuthService.shared.loginUserWith(email: email, password: password) { (result) in
            completion(result)
        }
    }
}
