//
//  ViewController.swift
//  WebViewDownload
//
//  Created by Matrix Marketers on 03/03/21.
//

import UIKit
import WebKit
import RealmSwift

class ViewController: UIViewController {
    
    //MARK:- IBOutlets
    @IBOutlet var downloadView: UIView!
    @IBOutlet weak var downloadProgressView: UIProgressView!
    @IBOutlet weak var demoWebView: WKWebView!
    
    //MARK:- Variables
    let documentInteractionController = UIDocumentInteractionController()
    let realm = try! Realm()
    var isDownloading = false
    
    //MARK:- View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let req = URLRequest(url: URL(string: "https://google.com")!)
        demoWebView.uiDelegate = self
        demoWebView.navigationDelegate = self
        demoWebView.load(req)
        self.downloadView.frame = CGRect(x: 0, y: 0, width: demoWebView.frame.width, height: demoWebView.frame.height)
        self.view.addSubview(self.downloadView)
        self.downloadView.isHidden = true
    }
    
    //MARK:- User defined functions
    func checkIfFileExists(nameOfFile:String) -> Bool{
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        if let pathComponent = url.appendingPathComponent(nameOfFile) {
            let filePath = pathComponent.path
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: filePath) {
                print("FILE AVAILABLE")
                return true
            } else {
                print("FILE NOT AVAILABLE")
                return false
            }
        } else {
            print("FILE PATH NOT AVAILABLE")
            return false
        }
    }
    
    func saveToRealmDB(fileName:String){
        let dataToWrite = Downloads()
        dataToWrite.itemName = fileName
        dataToWrite.itemPath = fileName
        
        // Persist your data easily
        try! realm.write {
            realm.add(dataToWrite)
        }
    }
    
    //MARK:- IBActions
    @IBAction func downloadsBtnClicked(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "DownloadsVC") as? DownloadsVC
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    @IBAction func backBtnClicked(_ sender: Any) {
        if(demoWebView.canGoBack) {
            //Go back in webview history
            demoWebView.goBack()
        }
    }
    
}

