//
//  ARSCNView+snapshotHighQuality.swift
//  EyeMeassure
//
//  Created by Vadim Aleshin on 08.04.2022.
//

import UIKit
import SceneKit
import ARKit
import SwiftyImages

extension ARSCNView {
    func snapshotHighQuality() -> UIImage? {
        guard let image = self.getImageHighQuality().map(UIImage.init),
              let arRender = self.getARRender(),
              let arRenderScaled = arRender.scaled(toSize: image.size, mode: .aspectFit)
        else { return nil }

        return image + arRenderScaled
    }

    private func getImageHighQuality() -> CGImage? {
        self.session.currentFrame
            .map(\.capturedImage)
            .map { CIImage(cvPixelBuffer: $0) }
            .map { $0.transformed(by: .init(rotationAngle: .pi / -2)) }
            .flatMap(Self.cgImage)
    }

    private func getARRender() -> UIImage? {
        let contents = self.scene.background.contents
        self.scene.background.contents = UIColor.clear
        let render = self.snapshot()
        self.scene.background.contents = contents

        return render
    }

    private static func cgImage(from inputImage: CIImage) -> CGImage? {
        let context = CIContext(options: nil)
        return context.createCGImage(inputImage, from: inputImage.extent)
    }
}
