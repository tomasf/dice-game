import Cadova

let can = TrashCan()

await Project {
    await Model("dice-game-dice") {
        Dice()
    }
    await Model("dice-game-can") {
        can
    }
    await Model("dice-game-lid") {
        can.lid
    }
    //await Model("dice-game-assembled-can") {
    //    can.assembled
    //}
} environment: {
    $0.tolerance = 0.6
}
