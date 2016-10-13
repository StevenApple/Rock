//
//  UsernamePassword.swift
//
//  Created by steven on 9/21/16.
//

import Foundation
import WebKit
import UIKit


// Not very Mohem

extension URL {

func webViewDidFinishLoad(_ webView: UIWebView) {
  
  // fill data
  let savedUsername = "USERNAME"
  let savedPassword = "PASSWORD"
  
  let fillForm = String(format: "document.getElementById('expert_email').value = '\(savedUsername)';document.getElementById('expert_password').value = '\(savedPassword)';")
  webView.stringByEvaluatingJavaScript(from: fillForm)
  
  //check checkboxes
  webView.stringByEvaluatingJavaScript(from: "document.getElementById('expert_remember_me').checked = true; document.getElementById('expert_terms_of_service').checked = true;")
  
  //submit form
  DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(1 * NSEC_PER_SEC)) / Double(NSEC_PER_SEC)){
    webView.stringByEvaluatingJavaScript(from: "document.forms[\"new_expert\"].submit();")
  }
}
}
