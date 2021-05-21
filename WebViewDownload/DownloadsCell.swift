//
//  DownloadsCell.swift
//  WebViewDownload
//
//  Created by Matrix Marketers on 04/03/21.
//

import UIKit

class DownloadsCell: UITableViewCell {

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var playPauseBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func playPauseBtnClicked(_ sender: Any) {
    }
    
}
