//
//  TiPasskeysModule.swift
//  titanium-passkeys
//
//  Created by Hans Knöchel
//  Copyright (c) 2022 TiDev. All rights reserved.
//

import UIKit
import TitaniumKit
import AuthenticationServices

@objc(TiPasskeysModule)
@available(iOS 16.0, *)
class TiPasskeysModule: TiModule, ASAuthorizationControllerPresentationContextProviding {
  
  func moduleGUID() -> String {
    return "03eeaec6-0366-402f-bf59-5d9ad4385ffe"
  }
  
  override func moduleId() -> String! {
    return "ti.passkeys"
  }

  @objc(performAutoFillAssistedRequests:)
  func performAutoFillAssistedRequests(args: [Any]) {
    guard let params = args.first as? [String: Any],
          let relyingPartyIdentifier = params["relyingPartyIdentifier"] as? String,
          let challengeString = params["challenge"] as? String else {
      fatalError("Missing required parameters!")
    }

    let challenge = challengeString.data(using: .utf8)
    let platformProvider = ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: relyingPartyIdentifier)
    let platformKeyRequest = platformProvider.createCredentialAssertionRequest(challenge: challenge!)
    let authController = ASAuthorizationController(authorizationRequests: [platformKeyRequest])

    authController.delegate = self
    authController.presentationContextProvider = self

    // This does the magic!
    authController.performAutoFillAssistedRequests()
  }
  
  func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
    return ASPresentationAnchor()
  }
}

// MARK: ASAuthorizationControllerDelegate

@available(iOS 16.0, *)
extension TiPasskeysModule : ASAuthorizationControllerDelegate {

  func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
     if let credential = authorization.credential as? ASAuthorizationPlatformPublicKeyCredentialRegistration {
       // Take steps to handle the registration.
       fireEvent("complete", with: [
        "type": "registration",
        "credential": credential.credentialID
       ])
     } else if let credential = authorization.credential as? ASAuthorizationPlatformPublicKeyCredentialAssertion {
       let signature = credential.signature
       let clientDataJSON = credential.rawClientDataJSON
       
       // Take steps to verify the challenge by sending it to your server tio verify
       fireEvent("complete", with: [
        "type": "assertion",
        "signature": TiBlob(data: signature, mimetype: "text/plain")!,
        "clientDataJSON": TiBlob(data: clientDataJSON, mimetype: "text/plain")!
       ])
     } else {
       // Handle other authentication cases, such as Sign in with Apple.
       // TODO: Handle here as well? We usually have ti.applesignin for that
     }
   }
   
   func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
     fireEvent("error", with: [
      "error": error.localizedDescription,
     ])
   }
}
