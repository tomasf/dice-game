import Foundation
import SwiftSCAD
import Helical

struct TrashCan: Shape3D {
    private let outerDiameter = 90.0
    private let wallThickness = 1.0
    private let threadDepth = 1.0
    private let threadedHeight = 6.0
    private let outerHeight = 110.0

    private var innerDiameter: Double { outerDiameter - 2 * threadDepth - 2 * wallThickness }

    private var thread: ScrewThread {
        .init(pitch: 5,
              majorDiameter: outerDiameter,
              minorDiameter: outerDiameter - 2 * threadDepth,
              form: TrapezoidalThreadForm(angle: 90°, crestWidth: 0.6)
        )
    }

    var body: any Geometry3D {
        let bodyHeight = outerHeight - threadedHeight
        let taper = 5.0
        let taperAngle: Angle = atan(taper / bodyHeight)

        // Vertical ridges
        let ridgeWidth = 10.0
        let ridgeDepth = 0.5
        let ridgeInset = 20.0
        let ridgeCount = 16

        // Horizontal bands
        let bandWidth = 1.0
        let bandInset = 7.0
        let bandDepth = 0.25

        Cylinder(bottomDiameter: outerDiameter - 2 * taper, topDiameter: outerDiameter, height: bodyHeight)
            .adding {
                Screw(thread: thread, length: threadedHeight)
                    .translated(z: outerHeight - threadedHeight)
                    .forceRendered()
            }
            .subtracting {
                Cylinder(bottomDiameter: innerDiameter - 2 * taper, topDiameter: innerDiameter, height: outerHeight)
                    .translated(z: wallThickness * 2)

                Sphere(diameter: ridgeWidth)
                    .scaled(y: (ridgeDepth * 2) / ridgeWidth)
                    .cloned { $0.translated(z: bodyHeight - 2 * ridgeInset) }
                    .convexHull()
                    .translated(z: ridgeInset)
                    .rotated(x: -taperAngle)
                    .translated(y: outerDiameter / 2 - taper, z: 0)
                    .repeated(around: .z, count: ridgeCount)

                for z in [bandInset, bodyHeight - bandInset] {
                    let f = z / bodyHeight
                    let x = outerDiameter / 2 - taper + f * taper
                    Circle(diameter: bandWidth)
                        .translated(x: x + bandWidth / 2 - bandDepth)
                        .extruded()
                        .translated(z: z)
                }
            }
    }

    @UnionBuilder3D
    var lid: any Geometry3D {
        let dice = Dice()
        let lidOuterDiameter = outerDiameter + 5
        let lidThickness = threadedHeight + wallThickness
        let bodyThickness = lidThickness + 0.4

        let knurlDepth = 0.6
        let knurlAngle = 10°
        let knurlCount = 80
        let diceOffset = 28.0
        let handleSize = Vector2D(7, 2.2)
        let handleAreaDiameter = diceOffset * 2 - dice.width - 1

        Circle(diameter: lidOuterDiameter)
            .extruded(
                height: lidThickness,
                topEdge: .chamfer(size: knurlDepth),
                bottomEdge: .chamfer(size: knurlDepth),
                method: .convexHull
            )
            .subtracting {
                ThreadedHole(thread: thread, depth: threadedHeight, leadinChamferSize: 0.2)
                    .forceRendered()

                // Knurl
                let knurl = Rectangle(knurlDepth)
                    .aligned(at: .center)
                    .rotated(45°)
                    .translated(x: lidOuterDiameter / 2)

                knurl
                    .extruded(height: lidThickness, twist: knurlAngle)
                    .repeated(around: .z, count: knurlCount)
                knurl
                    .extruded(height: lidThickness, twist: -knurlAngle)
                    .repeated(around: .z, count: knurlCount)
            }
            .rotated(x: 180°)
            .aligned(at: .bottom)
            .adding {
                Cylinder(diameter: innerDiameter - 1, height: bodyThickness)
            }
            .subtracting {
                // Dice slots
                let diceSlotTolerance = 1.4
                let diceSlotPipDepth = 1.0
                let diceSlotPipScale = 0.8

                for i in 1...6 {
                    dice.solid
                        .resized(alignment: .center) { $0 + diceSlotTolerance }
                        .aligned(at: .bottom)
                        .translated(z: diceSlotPipDepth)
                        .adding {
                            dice.pipPattern(i)
                                .scaled(diceSlotPipScale)
                                .extruded(height: diceSlotPipDepth + 1)

                            dice.rotated(to: i)
                                .background()
                        }
                        .translated(x: diceOffset, z: wallThickness)
                        .rotated(z: -Double(i) * 60°)
                }

                // Handle area
                let handleAreaDepth = bodyThickness - 1
                Cylinder(
                    bottomDiameter: handleAreaDiameter,
                    topDiameter: handleAreaDiameter - handleAreaDepth * 2,
                    height: handleAreaDepth
                )
                .translated(z: -0.01)

                // Rings
                let lidRadius = lidOuterDiameter / 2
                let ringWidth = 0.8
                Rectangle(ringWidth)
                    .aligned(at: .center)
                    .rotated(45°)
                    .distributed(at: [lidRadius * 0.6, lidRadius * 0.8], along: .x)
                    .extruded()
            }
            .adding {
                // Handle
                Box(x: handleAreaDiameter, y: handleSize.x, z: handleSize.y)
                    .aligned(at: .centerXY)
            }
            .forceRendered()
    }

    var assembled: any Geometry3D {
        self.adding {
            lid
                .rotated(x: 180°)
                .translated(z: outerHeight + wallThickness)
        }
    }
}
