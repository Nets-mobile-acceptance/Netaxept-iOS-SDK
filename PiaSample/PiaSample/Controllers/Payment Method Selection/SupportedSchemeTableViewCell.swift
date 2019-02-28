//
//  SupportedSchemeTableViewCell.swift
//
//  MIT License
//
//  Copyright (c) 2019 Nets Denmark A/S
//
//  Permission is hereby granted, free of charge, to any person obtaining a
//  copy of this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation
//  the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//  OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
//  ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

import UIKit

class SupportedSchemeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var suportedSchemeView: UIView!
    
    func populate(schemes: [String]) {
        
        let stackView = UIStackView()
        stackView.spacing = 10.0
        stackView.alignment = .leading
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        
        let sizeOfImage = self.suportedSchemeView.bounds.width / CGFloat(schemes.count)  - 10.0
        
        for scheme in schemes {
            let imageView = UIImageView()
            imageView.heightAnchor.constraint(equalToConstant: sizeOfImage).isActive = true
            imageView.widthAnchor.constraint(equalToConstant: sizeOfImage).isActive = true
            imageView.image = UIImage(named: "\(scheme)")
            imageView.contentMode = .scaleAspectFit
            
            stackView.addArrangedSubview(imageView)
        }
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        self.suportedSchemeView.addSubview(stackView)
        
        stackView.leadingAnchor.constraint(equalTo: self.suportedSchemeView.leadingAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: self.suportedSchemeView.centerYAnchor).isActive = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.suportedSchemeView = nil
    }

}
