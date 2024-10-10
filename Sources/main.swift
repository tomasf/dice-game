import SwiftSCAD

save(environment: .defaultEnvironment.withTolerance(0.6)) {
    Dice()
        .named("dice-game-dice")

    let can = TrashCan()
    can
        .named("dice-game-can")

    can.lid
        .named("dice-game-lid")

    can.assembled
        .named("dice-game-assembled-can")
}
