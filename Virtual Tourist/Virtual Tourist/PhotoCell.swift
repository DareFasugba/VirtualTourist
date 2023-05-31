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
    @IBOutlet weak var spinner: UIActivityIndicatorView!
        
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
            let size = CGSize(width: 100, height: 100)
            let renderer = UIGraphicsImageRenderer(size: size)
            let placeholderImage = renderer.image { context in
                context.cgContext.setFillColor(UIColor.gray.cgColor)
                context.cgContext.fill(CGRect(origin: .zero, size: size))
            }
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
            imageView.image = placeholderImage
            contentView.addSubview(imageView)
        }
    
    
    }
    

