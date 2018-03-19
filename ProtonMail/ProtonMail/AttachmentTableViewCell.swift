//
//  AttachmentTableViewCell.swift
//  ProtonMail
//
//
// Copyright 2015 ArcTouch, Inc.
// All rights reserved.
//
// This file, its contents, concepts, methods, behavior, and operation
// (collectively the "Software") are protected by trade secret, patent,
// and copyright laws. The use of the Software is governed by a license
// agreement. Disclosure of the Software to third parties, in any form,
// in whole or in part, is expressly prohibited except as authorized by
// the license agreement.
//

import Foundation
import MCSwipeTableViewCell

class AttachmentTableViewCell: MCSwipeTableViewCell {
    struct Constant {
        static let identifier = "AttachmentTableViewCell"
    }
    
    @IBOutlet weak var downloadIcon: UIImageView!
    @IBOutlet weak var fileNameLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var attachmentIcon: UIImageView!
    
    func setFilename(_ filename: String, fileSize: Int) {
        let byteCountFormatter = ByteCountFormatter()
        fileNameLabel.text = "\(filename) (\(byteCountFormatter.string(fromByteCount: Int64(fileSize))))"
    }
    
    
    func configCell ( _ filename : String, fileSize : Int, showDownload : Bool = false) {
        let byteCountFormatter = ByteCountFormatter()
        fileNameLabel.text = "\(filename) (\(byteCountFormatter.string(fromByteCount: Int64(fileSize))))"
        
        if showDownload {
            downloadIcon.isHidden = false
        } else {
            downloadIcon.isHidden = true
        }
    }
    
    
    func configAttachmentIcon (_ mimeType : String) {
        //TODO:: sometime see general mime type like "application/octet-stream" then need parse the extention to get types
        //PMLog.D(mimeType)
        var image : UIImage;
        if mimeType == "image/jpeg" || mimeType == "image/jpg" {
            image = UIImage(named: "mail_attachment-jpeg")!
        } else if mimeType == "image/png" {
            image = UIImage(named: "mail_attachment-png")!
        } else if mimeType == "application/zip" {
            image = UIImage(named: "mail_attachment-zip")!
        } else if mimeType == "application/pdf" {
            image = UIImage(named: "mail_attachment-pdf")!
        } else if mimeType == "text/plain" {
            image = UIImage(named: "mail_attachment-txt")!
        } else if mimeType == "application/msword" {
          image = UIImage(named: "mail_attachment-doc")!
        } else {
            image = UIImage(named: "mail_attachment-file")!
        }
        
        attachmentIcon.image = image
        attachmentIcon.highlightedImage = image
    }
}
