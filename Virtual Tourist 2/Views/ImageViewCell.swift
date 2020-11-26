//
//  ImageViewCell.swift
//  Virtual Tourist 2
//
//  Created by Muhammed Ibrahim on 30/10/2020.
//  Copyright © 2020 Ovansa. All rights reserved.
//

import UIKit
import MBProgressHUD

class ImageViewCell: UICollectionViewCell {
    let mapImage: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleToFill
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        mapImage.image = #imageLiteral(resourceName: "VirtualTourist_76")
        mapImage.showLoader(message: "")
        
        addSubview(mapImage)
        NSLayoutConstraint.activate([
            mapImage.topAnchor.constraint(equalTo: topAnchor),
            mapImage.leadingAnchor.constraint(equalTo: leadingAnchor),
            mapImage.trailingAnchor.constraint(equalTo: trailingAnchor),
            mapImage.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    func configureCell(image: String) {
        let document = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let imagePath = document.appendingPathComponent(image)
        mapImage.image = UIImage(contentsOfFile: imagePath.path)
        mapImage.hideLoader()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        mapImage.image = #imageLiteral(resourceName: "VirtualTourist_76")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension UIImageView {
    func showLoader(message msg: String?) {
        let Indicator = MBProgressHUD.showAdded(to: self, animated: true)
        Indicator.isUserInteractionEnabled = true
        Indicator.detailsLabel.text = msg
        Indicator.show(animated: true)
    }
    
    func hideLoader() {
        MBProgressHUD.hide(for: self, animated: true)
    }
}
