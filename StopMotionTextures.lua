--local WeakAuras = WeakAuras

WeakAuras.StopMotion.texture_types.Basic = {
    ["Interface\\AddOns\\WeakAuras\\Media\\Textures\\stopmotion"] = "Example",
    ["Interface\\AddOns\\WeakAurasStopMotion\\Textures\\Basic\\circle"] = "Circle",
    ["Interface\\AddOns\\WeakAurasStopMotion\\Textures\\Basic\\checkmark"] = "Check Mark",
    ["Interface\\AddOns\\WeakAurasStopMotion\\Textures\\Basic\\redx"] = "Red X",
    ["Interface\\AddOns\\WeakAurasStopMotion\\Textures\\Basic\\leftarc"] = "Left Arc",
    ["Interface\\AddOns\\WeakAurasStopMotion\\Textures\\Basic\\rightarc"] = "Right Arc",
    ["Interface\\AddOns\\WeakAurasStopMotion\\Textures\\Basic\\fireball"] = "Fireball",
}

WeakAuras.StopMotion.texture_data["Interface\\AddOns\\WeakAurasStopMotion\\Textures\\Basic\\circle"] = {
     ["count"] = 256,
     ["rows"] = 16,
     ["columns"] = 16
  }

WeakAuras.StopMotion.texture_types.Runes = {
    ["Interface\\AddOns\\WeakAurasStopMotion\\Textures\\Runes\\AURARUNE8"] = "Spike-Ringed Aura Rune",
    ["Interface\\AddOns\\WeakAurasStopMotion\\Textures\\Runes\\legionv"] = "Legion V",
    ["Interface\\AddOns\\WeakAurasStopMotion\\Textures\\Runes\\legionw"] = "Legion W",
    ["Interface\\AddOns\\WeakAurasStopMotion\\Textures\\Runes\\legionf"] = "Legion F",
    ["Interface\\AddOns\\WeakAurasStopMotion\\Textures\\Runes\\legionword"] = "Legion Word"
}

WeakAuras.StopMotion.texture_types.Kaitan = {
  ["Interface\\AddOns\\WeakAurasStopMotion\\Textures\\Kaitan\\CellRing"] = "CellRing",
  ["Interface\\AddOns\\WeakAurasStopMotion\\Textures\\Kaitan\\Gadget"] = "Gadget",
  ["Interface\\AddOns\\WeakAurasStopMotion\\Textures\\Kaitan\\Radar"] = "Radar",
  ["Interface\\AddOns\\WeakAurasStopMotion\\Textures\\Kaitan\\RadarComplex"] = "RadarComplex",
  ["Interface\\AddOns\\WeakAurasStopMotion\\Textures\\Kaitan\\Saber"] = "Saber",
  ["Interface\\AddOns\\WeakAurasStopMotion\\Textures\\Kaitan\\Waveform"] = "Waveform",
}



WeakAuras.StopMotion.texture_types.IconOverlays = {
  ["Interface\\AddOns\\WeakAurasStopMotion\\Textures\\IconOverlays\\Electric"] = "Electric",
}

WeakAuras.StopMotion.texture_data["Interface\\AddOns\\WeakAurasStopMotion\\Textures\\IconOverlays\\Electric"] = {
  count = 60,
  rows = 8,
  columns = 8
}

local frames64IconOverlays = {
  "ArcReactor", "Core", "Energize", "Fire", "Frost", "Ghostbuster", "Haze", "Heat", "Kryptonite", "Water", "Zap"
}

local frames64Data = {
  count = 64,
  rows = 8,
  columns = 8
}

for _, key in ipairs(frames64IconOverlays) do
  local file = "Interface\\AddOns\\WeakAurasStopMotion\\Textures\\IconOverlays\\" .. key
  WeakAuras.StopMotion.texture_types.IconOverlays[file] = key
  WeakAuras.StopMotion.texture_data[file] = frames64Data
end