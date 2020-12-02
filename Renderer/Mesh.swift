//
//  Mesh.swift
//  RasterizationWithMetal
//
//  Created by Chao Li on 12/1/20.
//

import Foundation
import simd

struct Mesh {
    var vertices: [simd_float3]
    var facets: [simd_uint3]
    var verteices_normal: [simd_float3]
    var facets_normal: [simd_float3]
    
    var lines: [Vertex]
    var triangles: [Vertex]
    
    init?(with path: String) {
        do {
            let data = try String(contentsOfFile: path)
            let contents = data.components(separatedBy: NSCharacterSet.newlines)
            let nums = contents[1].components(separatedBy: NSCharacterSet.whitespaces)
            let nv = Int(nums[0])!
            let nf = Int(nums[1])!
            self.vertices = []
            self.verteices_normal = [simd_float3](repeating: simd_float3(), count: nv)
            self.facets = []
            self.facets_normal = []
            self.lines = []
            self.triangles = []
            for line in contents[2..<2+nv] {
                let vString = line.components(separatedBy: NSCharacterSet.whitespaces)
                assert(vString.count >= 3)
                let vertex = vString[..<3].map({
                    (value: String) -> Float in
                    return Float(value)!
                })
                self.vertices.append(simd_float3(vertex[0], vertex[1], vertex[2]))
            }
            var u, v: simd_float3
            for line in contents[2+nv..<2+nv+nf] {
                let fString = line.components(separatedBy: NSCharacterSet.whitespaces)
                assert(fString.count >= 4)
                let facet = fString[..<4].map({
                    return UInt32($0)!
                })
                assert(facet[0] == 3)
                u = vertices[Int(facet[2])] - vertices[Int(facet[1])]
                v = vertices[Int(facet[3])] - vertices[Int(facet[1])]
                let normal = simd_normalize(simd_cross(u, v))
                self.facets_normal.append(normal)
                facet[...3].forEach({
                    self.verteices_normal[Int($0)] += normal
                })
                self.facets.append(simd_uint3(facet[1], facet[2], facet[3]))
            }
            self.verteices_normal = self.verteices_normal.map({
                return simd_normalize($0)
            })
            for i in 0..<facets.count {
                // facets[i] has three indexes
                for j in 0...2 {
                    self.lines.append(Vertex(position: vector_float4(self.vertices[Int(facets[i][j])], 1),
                                             color: vector_float4(0,0.5,1,1),
                                             normal: vector_float4()))
                    self.lines.append(Vertex(position: vector4(self.vertices[Int(facets[i][(j+1)%3])], 1),
                                             color: vector_float4(0,0.5,1,1),
                                             normal: vector_float4()))
                }
            }
        } catch let err as NSError {
            print(err.description)
            return nil
        }
    }
}
