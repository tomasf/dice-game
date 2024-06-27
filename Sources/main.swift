import SwiftSCAD

save(environment: .defaultEnvironment.withTolerance(0.3)) {
    Dice()
        .named("dice")

    let can = TrashCan()
    can
        .named("can")

    can.lid
        .named("lid")

    can.assembled
        .named("assembled-can")
}
