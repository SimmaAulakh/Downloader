//
//  DownloadsVC.swift
//  WebViewDownload
//
//  Created by Matrix Marketers on 04/03/21.
//

import UIKit
import RealmSwift
import AVFoundation

class DownloadsVC: UIViewController {
    
    //MARK:- Variables
    @IBOutlet weak var downloadsTblView: UITableView!
    
    //MARK:- Variables
    // Get the default Realm
    let realm = try! Realm()
    var downloads :[Downloads] = []
    var player: AVAudioPlayer?
    var rowPlaying:Int?
    
    //MARK:- View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        getDownloads()
        downloadsTblView.tableFooterView = UIView()
    }
    
    //MARK:- User defined functions
    func getDownloads(){
        let downloadList = realm.objects(Downloads.self)
        for d in downloadList{
            downloads.append(d)
        }
        DispatchQueue.main.async {
            self.downloadsTblView.reloadData()
        }
    }
    
    func playSound(at:URL) {
        //  guard let url = Bundle.main.url(forResource: "soundName", withExtension: "mp3") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            player = try AVAudioPlayer(contentsOf: at, fileTypeHint: AVFileType.mp3.rawValue)
            
            /* iOS 10 and earlier require the following line:
             player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */
            
            guard let player = player else { return }
            
            player.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func getFilePath(index:Int) -> URL?{
        if let pathComponent = downloads[index].itemPath{
            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
            let url = NSURL(fileURLWithPath: path)
            if let fullPath = url.appendingPathComponent(pathComponent) {
                return fullPath
            }
        }
        return nil
    }
    
    
    //MARK:- IBActions
    @IBAction func backBtnClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func playPauseBtnClicked(_ sender:UIButton){
        
        
        if let pathComponent = downloads[sender.tag].itemPath{
            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
            let url = NSURL(fileURLWithPath: path)
            if let fullPath = url.appendingPathComponent(pathComponent) {
                self.playSound(at: fullPath)
                rowPlaying = sender.tag
                self.downloadsTblView.reloadData()
            }
        }
    }
    
    
}

extension DownloadsVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return downloads.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DownloadsCell", for: indexPath) as? DownloadsCell
        cell?.playPauseBtn.tag = indexPath.row
        cell?.titleLbl?.text = downloads[indexPath.row].itemName
        cell?.playPauseBtn.addTarget(self, action: #selector(playPauseBtnClicked(_ :)), for: .touchUpInside)
        if let isPlaying = rowPlaying{
            cell?.playPauseBtn.isSelected = isPlaying == indexPath.row
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "PlayerVC") as? PlayerVC
        vc?.filePath = getFilePath(index: indexPath.row)
        self.present(vc!, animated: true, completion: nil)
    }
}
