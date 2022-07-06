//
//  UIImage+pixelBuffer.swift
//  EyeMeassure
//
//  Created by Vadim Aleshin on 08.04.2022.
//

import UIKit

extension UIImage {
    public convenience init?(pixelBuffer: CVPixelBuffer) {
        self.init(ciImage: CIImage(cvPixelBuffer: pixelBuffer))
    }
}
