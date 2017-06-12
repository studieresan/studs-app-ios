//
//  SecondViewController.swift
//  studsapp
//
//  Created by Jesper Bränn on 2017-05-30.
//  Copyright © 2017 Jesper Bränn. All rights reserved.
//

import UIKit
import Firebase

class FAQViewController: UIViewController {
    @IBOutlet var webView: UIWebView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    var databaseRef: DatabaseReference!
    fileprivate var _refHandle: DatabaseHandle!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        webView.delegate = self
        webView.isOpaque = false;
        webView.backgroundColor = UIColor.clear
        //webView.scalesPageToFit = true;
        
        databaseRef = Database.database().reference()
        _refHandle = databaseRef.child("static").child("faq").observe(.value, with: { snapshot in
            let value = snapshot.value as! String
            self.webView.loadHTMLString(value, baseURL: nil)
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        if (_refHandle) != nil {
            databaseRef.child("static").child("faq").removeObserver(withHandle: _refHandle)
        }
    }
}

extension FAQViewController: UIWebViewDelegate {
    func webViewDidFinishLoad(_ webView : UIWebView) {
        activityIndicator.stopAnimating()
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        switch navigationType {
        case .linkClicked:
            // Open links in Safari
            guard let url = request.url else { return true }
            
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                // openURL(_:) is deprecated in iOS 10+.
                UIApplication.shared.openURL(url)
            }
            return false
        default:
            // Handle other navigation types...
            return true
        }
    }
}
