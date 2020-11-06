//
//  ImageViewCell.swift
//  Virtual Tourist 2
//
//  Created by Muhammed Ibrahim on 30/10/2020.
//  Copyright © 2020 Ovansa. All rights reserved.
//

import UIKit

class ImageViewCell: UICollectionViewCell {
    let mapImage: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleToFill
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .green
        
        addSubview(mapImage)
        NSLayoutConstraint.activate([
            mapImage.topAnchor.constraint(equalTo: topAnchor),
            mapImage.leadingAnchor.constraint(equalTo: leadingAnchor),
            mapImage.trailingAnchor.constraint(equalTo: trailingAnchor),
            mapImage.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        mapImage.image = #imageLiteral(resourceName: "VirtualTourist_180")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
