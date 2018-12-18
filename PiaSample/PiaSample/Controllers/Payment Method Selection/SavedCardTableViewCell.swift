//
//  SavedCardTableViewCell.swift
//
//  MIT License
//
//  Copyright (c) 2018 Nets Denmark A/S
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
import Pia

class SavedCardTableViewCell: UITableViewCell {
    
    @IBOutlet weak var cardBackgroundImage: UIImageView!
    @IBOutlet weak var cardInfo: UILabel!
    
    func populate(tokenCardInfo: NPITokenCardInfo) {
        if tokenCardInfo.tokenId == "New card" {
            self.cardBackgroundImage.image = UIImage(named: "Card")
            self.cardInfo.text = "New card"
        } else {
            var tempCardInfo = ""
            
            switch tokenCardInfo.schemeType {
            case MASTER_CARD:
                self.cardBackgroundImage.image = UIImage(named: "BackgroundMasterCard")
                tempCardInfo += "MasterCard •••• "
            case VISA:
                self.cardBackgroundImage.image = UIImage(named: "BackgroundVisa")
                tempCardInfo += "Visa •••• "
            case AMEX:
                self.cardBackgroundImage.image = UIImage(named: "BackgroundAmericanExpress")
                tempCardInfo += "AmericanExpress •••• "
            case DANKORT:
                self.cardBackgroundImage.image = UIImage(named: "BackgroundDanCard")
                tempCardInfo += "Dankort •••• "
            case DINERS_CLUB_INTERNATIONAL:
                self.cardBackgroundImage.image = UIImage(named: "BackgroundDiners")
                tempCardInfo += "Diners •••• "
            default:
                break
            }
            
            tempCardInfo += tokenCardInfo.tokenId.suffix(4)
            self.cardInfo.text = tempCardInfo
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.cardInfo.text?.removeAll()
        self.cardBackgroundImage.image = nil
    }
    
}
