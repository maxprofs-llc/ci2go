//
//  InversedColorButton.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 2018/06/21.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import UIKit

class InversedColorButton: UIButton {

    override func layoutSubviews() {
        super.layoutSubviews()
        let s = ColorScheme.current
        tintColor = s.background
        backgroundColor = s.foreground
    }

}