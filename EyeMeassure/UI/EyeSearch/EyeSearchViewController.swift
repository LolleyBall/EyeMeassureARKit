//
//  ARKitViewController.swift
//  EyeMeassure
//
//  Created by Vadim Aleshin on 08.04.2022.
//

import UIKit
import SceneKit
import ARKit

protocol EyeSearchViewControllerDelegate: AnyObject {
    func eyeSearchViewController(_ viewController: EyeSearchViewController,
                                 didUpdateDistance distanceBetweenEyes: Float) -> String?
}

final class EyeSearchViewController: UIViewController {
    weak var delegate: EyeSearchViewControllerDelegate?

    @IBOutlet private weak var sceneView: ARSCNView!

    private let text = SCNText(string: "", extrusionDepth: 0)
    private let configuration = ARFaceTrackingConfiguration()
    private var distanceBetweenEyes: Float = 0

    struct ARData {
        let image: UIImage?
        let distanceBetweenEyes: Float
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .brown

        // Set the view's delegate
        sceneView.delegate = self
        sceneView.backgroundColor = .clear
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        sceneView.session.run(configuration)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        sceneView.session.pause()
    }

    // MARK: - Public

    func getARData() -> ARData {
        let data = ARData(image: sceneView.snapshotHighQuality(),
                          distanceBetweenEyes: distanceBetweenEyes)

        return data
    }

    func availableARKit() -> Bool {
        return ARFaceTrackingConfiguration.isSupported
    }
}

// MARK: - ARSCNViewDelegate

extension EyeSearchViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard let faceAnchor = anchor as? ARFaceAnchor,
              let maxAnchorZ = faceAnchor.geometry.vertices.map({ $0.z }).max() else { return SCNNode() }

        let eyeLeft = faceAnchor.leftEyeTransform.columns.3
        let eyeRight = faceAnchor.rightEyeTransform.columns.3

        let lineLeft = SCNGeometry.line(from: SCNVector3(eyeLeft.x, eyeLeft.y, eyeLeft.z + 0.008),
                                        to: SCNVector3(eyeLeft.x, eyeLeft.y, maxAnchorZ))
        let lineRight = SCNGeometry.line(from: SCNVector3(eyeRight.x, eyeRight.y, eyeRight.z + 0.008),
                                         to: SCNVector3(eyeRight.x, eyeRight.y, maxAnchorZ))
        let lineFrontLeft = SCNGeometry.line(from: SCNVector3(eyeLeft.x, eyeLeft.y, maxAnchorZ),
                                             to: SCNVector3(0.018, eyeRight.y, maxAnchorZ))
        let lineFrontRight = SCNGeometry.line(from: SCNVector3(eyeRight.x, eyeRight.y, maxAnchorZ),
                                              to: SCNVector3(-0.018, eyeLeft.y, maxAnchorZ))

        let textNode = Self.createTextNode(text: text,
                                           anchorY: CGFloat(eyeRight.y),
                                           anchorZ: CGFloat(maxAnchorZ))

        let lineNode = SCNNode()

        lineNode.addChildNode(textNode)
        [lineLeft, lineFrontLeft, lineFrontRight, lineRight]
            .map { SCNNode(geometry: $0) }
            .forEach { lineNode.addChildNode($0) }

        lineNode.geometry?.firstMaterial?.fillMode = .lines

        return lineNode

    }

    func renderer(_ renderer: SCNSceneRenderer, willUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let faceAnchor = anchor as? ARFaceAnchor else { return }

        let eyeLeft = faceAnchor.leftEyeTransform.columns.3
        let eyeRight = faceAnchor.rightEyeTransform.columns.3
        distanceBetweenEyes = distance(SIMD3<Float>(eyeLeft.x, eyeLeft.y, eyeLeft.z),
                                SIMD3<Float>(eyeRight.x, eyeRight.y, eyeRight.z))

        text.string = delegate?.eyeSearchViewController(self, didUpdateDistance: distanceBetweenEyes)
    }

    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let faceAnchor = anchor as? ARFaceAnchor,
              let faceGeometry = node.geometry as? ARSCNFaceGeometry
        else { return }

        faceGeometry.update(from: faceAnchor.geometry)
    }
}

// MARK: - Factory

extension EyeSearchViewController {
    private static func createTextNode(text: SCNText,
                                       scale: CGFloat = 0.008,
                                       containerFrame: CGRect = CGRect(x: 0, y: 0, width: 5, height: 2),
                                       anchorY: CGFloat,
                                       anchorZ: CGFloat) -> SCNNode {

        let fontOfSize: CGFloat = 1
        let textNode = SCNNode(geometry: text)
        let title: String = text.string as? String ?? ""
        let textHeiht = estimatedHeightOfText(text: title, fontOfSize: fontOfSize, rect: containerFrame.size)

        text.font = UIFont.systemFont(ofSize: fontOfSize)
        text.containerFrame = containerFrame
        text.isWrapped = true
        text.flatness = 1
        text.alignmentMode = CATextLayerAlignmentMode.center.rawValue
        text.materials.first?.diffuse.contents = UIColor.white.cgColor

        textNode.scale = SCNVector3(scale, scale, scale)
        textNode.position = SCNVector3(scale * containerFrame.width / -2,
                                       anchorY - containerFrame.height * scale + textHeiht / 2 * scale,
                                       anchorZ)

        return textNode
    }

    private static func estimatedHeightOfText(text: String, fontOfSize: CGFloat, rect: CGSize) -> CGFloat {
        let size = rect
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontOfSize)]
        let rectangleHeight = String(text).boundingRect(with: size,
                                                        options: options,
                                                        attributes: attributes,
                                                        context: nil).height

        return rectangleHeight
    }
}
