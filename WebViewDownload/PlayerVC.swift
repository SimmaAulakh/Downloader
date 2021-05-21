//
//  PlayerVC.swift
//  WebViewDownload
//
//  Created by Matrix Marketers on 04/03/21.
//

import UIKit
import WebKit

class PlayerVC: UIViewController {
    
    //MARK:- IBOutlets
    @IBOutlet weak var playerWebView: WKWebView!
    
    //MARK:- Variables
    var filePath:URL?
    
    //MARK:- View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        if let path = filePath{
        let req = URLRequest(url: path)
        playerWebView.load(req)
        }
    }
    


    @IBAction func dismissBtnClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
