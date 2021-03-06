-- Fixed color palettes, so we can refer to colors by name or purpose 
-- rather than by magic numbers

require 'game.color'
Palette = {}

Palette.COLOR_SHIP = Color(100, 100, 100, 255)
Palette.COLOR_BULLET = Color.fromHex("ffffff")
Palette.COLOR_BACKGROUND = Color(30, 30, 30, 255)
Palette.COLOR_OPPONENT = Color.fromHex("f8ca00")
Palette.COLOR_SEEKER = Color.fromHex("CC4A14")

return Palette
