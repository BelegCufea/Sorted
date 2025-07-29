local _, S = ...
local pairs, ipairs, string, type, time, GetTime = pairs, ipairs, string, type, time, GetTime

S.Color = {}


S.Color.WHITE = CreateColor(1, 1, 1)
S.Color.GREY = CreateColor(0.2, 0.2, 0.2)
S.Color.GRAY = S.Color.GREY
S.Color.LIGHT_GREY = CreateColor(0.4, 0.4, 0.4)
S.Color.LIGHT_GRAY = S.Color.LIGHT_GREY
S.Color.YELLOWISH_TEXT = CreateColor(1, 0.95, 0.85)

S.Color.RED = CreateColor(1, 0.2, 0.3)
S.Color.YELLOW = CreateColor(1, 0.8, 0)

S.Color.RED_HIGHLIGHT = CreateColor(1, 0.4, 0.6)
S.Color.YELLOW_HIGHLIGHT = CreateColor(1, 0.96, 0.5)