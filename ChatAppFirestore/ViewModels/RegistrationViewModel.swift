//
//  RegistrationViewModel.swift
//  ChatAppFirestore
//
//  Created by OuSS on 6/26/19.
//  Copyright © 2019 OuSS. All rights reserved.
//

import UIKit
import Firebase

class RegistrationViewModel {
    var bindableIsRegistering = Bindable<Bool>()
    var bindableImage = Bindable<UIImage>()
    var bindableIsFormValid = Bindable<Bool>()
    
    var fullname: String? { didSet { checkFormValidity() } }
    var email: String? { didSet { checkFormValidity() } }
    var password: String? { didSet { checkFormValidity() } }
    
    func checkFormValidity() {
        let isFormValid = fullname?.isEmpty == false && email?.isEmpty == false && email?.isValidEmail() == true && password?.isEmpty == false && bindableImage.value != nil
        bindableIsFormValid.value = isFormValid
    }
    
    func performRegistration(completion: @escaping (_ result: Result<Bool,Error>) -> ()) {
        guard let email = email else { return }
        guard let password = password else { return }
        guard let fullname = fullname else { return }
        guard let image = bindableImage.value else { return }
        
        bindableIsRegistering.value = true
        
        AuthService.shared.registerUserWith(email: email, password: password, name: fullname, image: image) { (result) in
            self.bindableIsRegistering.value = false
            completion(result)
        }
    }
}
