import Foundation
import SwiftSCAD

struct Dice: Shape3D {
    let width = 16.0

    @UnionBuilder3D
    var solid: any Geometry3D {
        let outerDiameter = width * 1.35
        let mask = Box(width).aligned(at: .center)

        Sphere(diameter: outerDiameter)
            .intersection(mask)
    }

    var body: any Geometry3D {
        let fullPipDepth = 5.0

        solid.subtracting {
            for (index, (direction, pattern)) in pips.enumerated() {
                pattern
                    .aligned(at: .center)
                    .extruded(height: fullPipDepth / Double(index + 1))
                    .aligned(at: .maxZ)
                    .translated(z: width / 2 + 0.01)
                    .transformed(.rotation(from: .up, to: direction))
            }
        }
    }

    private var pips: [(direction: Vector3D, pattern: any Geometry2D)] {
        let pip = Circle(diameter: width * 0.2)
        let wide = 2.4
        let tight = 1.6

        return [
            (.up, pip),
            (.left, pip.repeated(along: .x, spacing: wide, count: 2)),
            (.backward, pip.repeated(along: .x, spacing: tight, count: 3)
                .rotated(45°)),
            (.forward, pip.repeated(along: .x, spacing: wide, count: 2)
                .repeated(along: .y, spacing: wide, count: 2)),
            (.right, pip.repeated(along: .x, spacing: tight, count: 2)
                .repeated(count: 4)
                .rotated(45°)),
            (.down, pip.repeated(along: .x, spacing: 1, count: 3)
                .repeated(along: .y, spacing: tight, count: 2)),
        ]
    }

    func pipPattern(_ number: Int) -> any Geometry2D {
        pips[number - 1].pattern
            .aligned(at: .center)
    }

    func rotated(to number: Int) -> any Geometry3D {
        rotated(from: pips[number - 1].direction, to: .up)
            .aligned(at: .bottom)
    }
}
