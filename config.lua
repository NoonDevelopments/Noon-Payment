Config = {}

Config.MaxActiveBills = 3 -- Maximum number of active bills at one time

Config.Business = {
    taxi = { -- I do not have burgershot, so im using taxi as an example
        logo = 'burgerlogo.png',
        items = {
            { name = 'Water', price = 1, image = 'water.png' },
            { name = 'Snack', price = 2, image = 'donut.png' },
            { name = 'Snack', price = 2, image = 'fries.png' },
            { name = 'Snack', price = 2, image = 'fries.png' },
            { name = 'Snack', price = 2, image = 'fries.png' },
            { name = 'Snack', price = 2, image = 'fries.png' },
            { name = 'Snack', price = 2, image = 'fries.png' },
            { name = 'Snack', price = 2, image = 'fries.png' },
            { name = 'Snack', price = 2, image = 'burger.png' },
        },
        registers = {
            {
                name = "burgershot1",
                coords = vector3(250.26, -1004.1, 29.27),
                length = 0.8,
                width = 1.0,
                debug = true,
                minZ = 28.27,
                maxZ = 29.87,
                heading = 334,
            }
        }
    }
}
