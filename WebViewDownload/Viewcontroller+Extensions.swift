//
//  Viewcontroller+Extensions.swift
//  WebViewDownload
//
//  Created by Matrix Marketers on 04/03/21.
//

import UIKit
import WebKit

extension ViewController: WKNavigationDelegate,WKUIDelegate, UIDocumentInteractionControllerDelegate,URLSessionDownloadDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url {
            
            print("fileDownload: check ::  \(url.lastPathComponent)")
            
            let extention = "\(url)".suffix(4)
            
            if extention == ".pdf" ||  extention == ".mp3" || extention == ".png" || extention == ".jpeg" || extention == ".mp4" || extention == ".3gp" || extention == ".jpg" || extention == ".avi" || extention == ".xlsr" || extention == ".doc" || extention == ".xls" || extention == ".xlsx" || extention == ".mov" {
                print("fileDownload: redirect to download events. \(extention)")
                if !self.isDownloading{
                    self.isDownloading = true
                if !checkIfFileExists(nameOfFile: url.lastPathComponent){
                    DispatchQueue.main.async {
                    
                        self.downloadPDF(tempUrl: "\(url)")
                        
                    }
                    decisionHandler(.cancel)
                    return
                }else{
                    self.showAlert(message: "File already Downloaded") { (status) in
                        self.isDownloading = false
                        if status{
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "DownloadsVC") as? DownloadsVC
                            self.navigationController?.pushViewController(vc!, animated: true)
                        }
                    }
                    decisionHandler(.cancel)
                    return
                }
                }else{
                    decisionHandler(.cancel)
                    return
                }
            }
            
        }
        
        decisionHandler(.allow)
    }
    
    func downloadPDF(tempUrl:String){
        print("fileDownload: downloadPDF")
        guard let url = URL(string: tempUrl) else { return }
        let urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        let downloadTask = urlSession.downloadTask(with: url)
        downloadTask.resume()
        //showHUD(isShowBackground: true); //show progress if you need
    }
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        print("fileDownload: documentInteractionControllerViewControllerForPreview")
        return self
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        // println("download task did write data")
        
        let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        
        DispatchQueue.main.async {
            self.downloadView.isHidden = false
            self.downloadProgressView.progress = progress
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        // create destination URL with the original pdf name
        print("fileDownload: urlSession")
        guard let url = downloadTask.originalRequest?.url else { return }
        print("fileDownload: urlSession \(url)")
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let destinationURL = documentsPath.appendingPathComponent(url.lastPathComponent)
       
        // delete original copy
        try? FileManager.default.removeItem(at: destinationURL)
        // copy from temp to Document
        do {
            try FileManager.default.copyItem(at: location, to: destinationURL)
//            if destinationURL.absoluteString.contains(".pdf"){
//                myViewDocumentsmethod(PdfUrl:destinationURL)
//            }else{
                do {
                    //Show UIActivityViewController to save the downloaded file
                    let contents  = try FileManager.default.contentsOfDirectory(at: documentsPath, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
                    for indexx in 0..<contents.count {
                        if contents[indexx].lastPathComponent == destinationURL.lastPathComponent {
                            DispatchQueue.main.async {
                                // self.showAlert()
                                self.saveToRealmDB(fileName: destinationURL.lastPathComponent)
                                self.isDownloading = false
                                self.downloadView.isHidden = true
                                self.downloadProgressView.progress = 0
                                let vc = self.storyboard?.instantiateViewController(withIdentifier: "DownloadsVC") as? DownloadsVC
                                self.navigationController?.pushViewController(vc!, animated: true)
                                //  self.share(url: contents[indexx])
                                //                                       let activityViewController = UIActivityViewController(activityItems: [contents[indexx]], applicationActivities: nil)
                                //                                       self.present(activityViewController, animated: true, completion: nil)
                            }
                        }
                    }
                }
                catch (let err) {
                    print("error: \(err)")
                }
//            }
            print("fileDownload: downloadLocation", destinationURL)
            DispatchQueue.main.async {
                print("downloadCompleted")
            }
        } catch let error {
            print("fileDownload: error \(error.localizedDescription)")
        }
        // dismissHUD(isAnimated: false); //dismiss progress
    }
    func myViewDocumentsmethod(PdfUrl:URL){
        print("fileDownload: myViewDocumentsmethod \(PdfUrl)")
        DispatchQueue.main.async {
            let controladorDoc = UIDocumentInteractionController(url: PdfUrl)
            controladorDoc.delegate = self
            controladorDoc.presentPreview(animated: true)
        }
    }
}

extension ViewController {
    func share(url: URL) {
        documentInteractionController.url = url
        documentInteractionController.uti = url.typeIdentifier ?? "public.data, public.content"
        documentInteractionController.name = url.localizedName ?? url.lastPathComponent
        documentInteractionController.presentOptionsMenu(from: view.frame, in: view, animated: true)
    }
}

extension URL {
    var typeIdentifier: String? {
        return (try? resourceValues(forKeys: [.typeIdentifierKey]))?.typeIdentifier
    }
    var localizedName: String? {
        return (try? resourceValues(forKeys: [.localizedNameKey]))?.localizedName
    }
}


extension UIViewController{
    func showAlert(message:String,completion:@escaping(_ status:Bool)->()){
        let alert = UIAlertController(title: "Done", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "View", style: .default) { (action) in
            completion(true)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (ac) in
            completion(false)
        }
        alert.addAction(cancel)
        alert.addAction(okAction)
        alert.show()
    }
}

public extension UIAlertController {
    func show() {
        if #available(iOS 13.0, *) {
            if var topController = UIApplication.shared.keyWindow?.rootViewController  {
                while let presentedViewController = topController.presentedViewController {
                    topController = presentedViewController
                }
                topController.present(self, animated: true, completion: nil)
            }
        }else{
            let win = UIWindow(frame: UIScreen.main.bounds)
            let vc = UIViewController()
            vc.view.backgroundColor = .clear
            win.rootViewController = vc
            win.windowLevel = UIWindow.Level.alert + 1  // Swift 3-4: UIWindowLevelAlert + 1
            win.makeKeyAndVisible()
            vc.present(self, animated: true, completion: nil)
        }
    }
}
