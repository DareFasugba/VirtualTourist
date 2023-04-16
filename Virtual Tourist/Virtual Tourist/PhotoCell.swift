//
//  PhotoCell.swift
//  Virtual Tourist
//
//  Created by The Fasugba Crew  on 11/4/2023.
//

import Foundation
import UIKit

class PhotoCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
        let spinner = UIActivityIndicatorView(style: .large)
        
        override func awakeFromNib() {
            super.awakeFromNib()
            spinner.style = .medium
            spinner.hidesWhenStopped = true
            spinner.center = contentView.center
            contentView.addSubview(spinner)
        }
        
        func setupCell(with photos: [UIImage], indexPath: IndexPath) {
            guard !photos.isEmpty else { return }
            imageView.image = photos[indexPath.row]
        }
    }
    

