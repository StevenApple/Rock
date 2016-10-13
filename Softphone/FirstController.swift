////  Created by Steven H.A on 11/18/14.






import UIKit
import Foundation
import WebKit


let urlKey = "User URL"

class FirstController: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate {
  
  @IBOutlet weak var textField: UITextField!
  @IBOutlet weak var webView: UIWebView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    
    // 2 click hide the keyboard and hide textfield server
    
    let ttapRecognizer = UITapGestureRecognizer(target: self , action: #selector(FirstController.closeTheServerField(_:)))
    
    
    ttapRecognizer.numberOfTapsRequired = 2
    webView.addGestureRecognizer(ttapRecognizer)
    ttapRecognizer.delegate = self
    
    
    // tapGesture 3 click to change server
    
    let tapRecognizer = UITapGestureRecognizer(target: self , action: #selector(FirstController.ChangeTheServer(_:)))
    
    
    tapRecognizer.numberOfTapsRequired = 3
    webView.addGestureRecognizer(tapRecognizer)
    tapRecognizer.delegate = self
    
    //
    
    self.webView.isHidden = true
    
    if doesURLExist() {
      
      self.textField.text = getURL()
      self.webView.isHidden = false
      self.textField.isHidden = true
      self.textFieldDidUpdate(textField)
      
      
    } else {
      
      
      self.textField.addTarget(self, action: #selector(FirstController.textFieldDidUpdate(_:)), for: UIControlEvents.editingChanged)
    }
    
  }
  func gestureRecognizer(_: UIGestureRecognizer,  shouldRecognizeSimultaneouslyWith shouldRecognizeSimultaneouslyWithGestureRecognizer:UIGestureRecognizer) -> Bool
  {
    return true
  }
  
  
  // Text Field Delegate
  func textFieldDidUpdate(_ textField: UITextField)
  {
    // Remove Spaces
    var newText = textField.text! as NSString
    
    newText = textField.text!.replacingOccurrences(of: " ", with: "", options: [], range: nil) as NSString
    
    // if server less than 8 charecters and type again https://
    
    if newText.length <= 8 {
      
      textField.text = "https://"
      let nextViewController = UIAlertController()
      nextViewController.title = "OOPS"
      nextViewController.message = "need for server https://"
      let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {action in self.dismiss(animated: true, completion: nil)})
      nextViewController.addAction(okAction)
      present(nextViewController, animated: true, completion: nil)
      
    }
    
    // Validate URL
    URL.validateUrl(textField.text, completion: { (success, urlString, error) -> Void in
      DispatchQueue.main.async(execute: { () -> Void in
        
        
        if (success)
        {
          
          self.saveURL(urlString!)
          self.webView.isHidden = false
          self.textField.isHidden = true
          let request = URLRequest(url: URL(string: urlString!)!)
          self.webView.loadRequest(request)
          
        }
        else
        {
          self.webView.stopLoading()
          self.webView.isHidden = true
        }
        
        
      })
      
    })
    
  }
  @IBAction func dismissKeyboard(_ sender: AnyObject) {
    self.resignFirstResponder()
    self.view.endEditing(true)
  }
  
  // save the URL
  
  func saveURL(_ urlString: String)  {
    let defaults = UserDefaults.standard
    defaults.set(urlString, forKey: urlKey)
  }
  
  func getURL() -> String {
    let defaults = UserDefaults.standard
    let urlString = defaults.object(forKey: urlKey) as! String
    return urlString
  }
  
  func doesURLExist() -> Bool {
    let defaults = UserDefaults.standard
    guard let _ = defaults.object(forKey: urlKey) , defaults.object(forKey: urlKey) is String else {
      return false
    }
    return true
  }
  // you change the server here
  
  func ChangeTheServer(_ recognizer: UITapGestureRecognizer) {
    
    self.webView.isHidden = false
    self.textField.isHidden = false
    self.textField.layer.borderWidth = 2
    self.textField.layer.cornerRadius = 2
    self.textField.layer.borderColor = UIColor.black.cgColor
    self.textField.addTarget(self, action: #selector(FirstController.textFieldDidUpdate(_:)), for: UIControlEvents.editingChanged)
    
  }
  // You close the textfield and hide the keyboard
  func closeTheServerField(_ recognizer: UITapGestureRecognizer) {
    
    self.webView.isHidden = false
    self.textField.isHidden = true
    self.textField.resignFirstResponder()
    
    
  }
}

