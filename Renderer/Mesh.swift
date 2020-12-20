//
//  Mesh.swift
//  RasterizationWithMetal
//
//  Created by Chao Li on 12/1/20.
//

import Foundation
import simd

struct Mesh {
    let vertices: [simd_float3]
    var facets: [simd_uint3]
    var verteices_normal: [simd_float3]
    var facets_normal: [simd_float3]
    let min: simd_float3
    let max: simd_float3
    let midpoint: simd_float3
    
    var lines: [Vertex]
    var triangles: [Vertex]
    var trianglesPerVertex: [Vertex]
    
    init?(with path: String) {
        do {
            let data = try String(contentsOfFile: path)
            let contents = data.components(separatedBy: NSCharacterSet.newlines)
            let nums = contents[1].components(separatedBy: NSCharacterSet.whitespaces)
            let nv = Int(nums[0])!
            let nf = Int(nums[1])!
            self.verteices_normal = [simd_float3](repeating: simd_float3(), count: nv)
            self.facets = []
            self.facets_normal = []
            self.lines = []
            self.triangles = []
            self.trianglesPerVertex = []

            self.vertices = contents[2..<2+nv].map({ (line) -> simd_float3 in
                let vString = line.components(separatedBy: NSCharacterSet.whitespaces)
                return simd_float3(Float(vString[0])!, Float(vString[1])!, Float(vString[2])!)
            })
            self.min = self.vertices.reduce(simd_float3(repeating: Float.greatestFiniteMagnitude), { (min, value) -> simd_float3 in
                return simd_min(min, value)
            })
            self.max = self.vertices.reduce(simd_float3(repeating: Float.leastNormalMagnitude), { (max, value) -> simd_float3 in
                return simd_max(max, value)
            })
            self.midpoint = (self.min + self.max) / 2
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
                                             normal: vector_float4()))
                    self.lines.append(Vertex(position: vector4(self.vertices[Int(facets[i][(j+1)%3])], 1),
                                             normal: vector_float4()))
                    self.triangles.append(Vertex(position: vector_float4(self.vertices[Int(facets[i][j])], 1),
                                                 normal: vector_float4(self.facets_normal[i], 0)))
                    self.trianglesPerVertex.append(Vertex(position: vector_float4(self.vertices[Int(facets[i][j])], 1),
                                                          normal: vector_float4(self.verteices_normal[Int(facets[i][j])], 1)))
                }
            }
        } catch let err as NSError {
            print(err.description)
            return nil
        }
    }
}
