//
//  SCNGeometry+line.swift
//  EyeMeassure
//
//  Created by Vadim Aleshin on 08.04.2022.
//

import ARKit

extension SCNGeometry {
    static func line(from vector1: SCNVector3, to vector2: SCNVector3) -> SCNGeometry {
        let indices: [Int32] = [0, 1]
        let source = SCNGeometrySource(vertices: [vector1, vector2])
        let element = SCNGeometryElement(indices: indices, primitiveType: .line)
        return SCNGeometry(sources: [source], elements: [element])
    }
}
