//
//  TextCell.swift
//  PinpointKit
//
//  Created by Matěj Novák on 12.01.2023.
//  Copyright © 2023 Lickability. All rights reserved.
//

import UIKit

class TextCell: UITableViewCell {

    var textView: UITextField = {
            let textView = UITextField()
            textView.translatesAutoresizingMaskIntoConstraints = false
        textView.placeholder = "Message"
            return textView
        }()
    var callback:((String) -> Void)?
    
    init(style: UITableViewCell.CellStyle, reuseIdentifier: String?, callback:((String) -> Void)?, descriptionText:String) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            contentView.addSubview(textView)
            textView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10).isActive = true
            textView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 10).isActive = true
            textView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
            self.callback = callback
        self.textView.text = descriptionText

        textView.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        }

    @objc func textFieldDidChange(textField: UITextField) {
        callback?(textField.text ?? "")
    }
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

}
