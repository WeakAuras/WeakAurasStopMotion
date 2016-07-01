--local WeakAuras = WeakAuras
local L = WeakAuras.L; -- TODO

WeakAurasStopMotion = {};

WeakAurasStopMotion.animation_types = {
  loop = L["Loop"],
  bounce = L["Forward, Reverse Loop"],
  once = L["Forward"],
  progress = L["Progress"]
  
};

WeakAurasStopMotion.texture_types = {};
WeakAurasStopMotion.texture_types.Basic = {
    ["Interface\\AddOns\\WeakAurasStopMotion\\Textures\\Basic\\circle"] = "Circle",
    ["Interface\\AddOns\\WeakAurasStopMotion\\Textures\\Basic\\checkmark"] = "Check Mark",
    ["Interface\\AddOns\\WeakAurasStopMotion\\Textures\\Basic\\redx"] = "Red X",
    ["Interface\\AddOns\\WeakAurasStopMotion\\Textures\\Basic\\leftarc"] = "Left Arc",
    ["Interface\\AddOns\\WeakAurasStopMotion\\Textures\\Basic\\rightarc"] = "Right Arc",
}

WeakAurasStopMotion.texture_data = {
  ["Interface\\AddOns\\WeakAurasStopMotion\\Textures\\Basic\\circle"] = {
     ["count"] = 256,
     ["rows"] = 16,
     ["columns"] = 16
  },
}

WeakAurasStopMotion.texture_types.Runes = {
    ["Interface\\AddOns\\WeakAurasStopMotion\\Textures\\Runes\\AURARUNE8"] = "Spike-Ringed Aura Rune",
    ["Interface\\AddOns\\WeakAurasStopMotion\\Textures\\Runes\\legionv"] = "Legion V",
    ["Interface\\AddOns\\WeakAurasStopMotion\\Textures\\Runes\\legionw"] = "Legion W",
    ["Interface\\AddOns\\WeakAurasStopMotion\\Textures\\Runes\\legionf"] = "Legion F",
    ["Interface\\AddOns\\WeakAurasStopMotion\\Textures\\Runes\\legionword"] = "Legion Word"
}

WeakAurasStopMotion.texture_data["Interface\\AddOns\\WeakAurasStopMotion\\Textures\\Basic\\checkmark"] = {
     ["count"] = 64,
     ["rows"] = 8,
     ["columns"] = 8
  }

WeakAurasStopMotion.texture_data["Interface\\AddOns\\WeakAurasStopMotion\\Textures\\Basic\\redx"] = {
     ["count"] = 64,
     ["rows"] = 8,
     ["columns"] = 8
  }

WeakAurasStopMotion.texture_data["Interface\\AddOns\\WeakAurasStopMotion\\Textures\\Basic\\leftarc"] = {
     ["count"] = 256,
     ["rows"] = 16,
     ["columns"] = 16
  }

WeakAurasStopMotion.texture_data["Interface\\AddOns\\WeakAurasStopMotion\\Textures\\Basic\\rightarc"] = {
     ["count"] = 256,
     ["rows"] = 16,
     ["columns"] = 16
  }


WeakAurasStopMotion.texture_data["Interface\\AddOns\\WeakAurasStopMotion\\Textures\\Runes\\AURARUNE8"] = {
     ["count"] = 256,
     ["rows"] = 16,
     ["columns"] = 16
  }

WeakAurasStopMotion.texture_data["Interface\\AddOns\\WeakAurasStopMotion\\Textures\\Runes\\legionv"] = {
     ["count"] = 64,
     ["rows"] = 8,
     ["columns"] = 8
  }

WeakAurasStopMotion.texture_data["Interface\\AddOns\\WeakAurasStopMotion\\Textures\\Runes\\legionw"] = {
     ["count"] = 64,
     ["rows"] = 8,
     ["columns"] = 8
  }

WeakAurasStopMotion.texture_data["Interface\\AddOns\\WeakAurasStopMotion\\Textures\\Runes\\legionf"] = {
     ["count"] = 64,
     ["rows"] = 8,
     ["columns"] = 8
  }

WeakAurasStopMotion.texture_data["Interface\\AddOns\\WeakAurasStopMotion\\Textures\\Runes\\legionword"] = {
     ["count"] = 64,
     ["rows"] = 8,
     ["columns"] = 8
  }
  
WeakAurasStopMotion.texture_types.Kaitan = {
    ["Interface\\AddOns\\WeakAurasStopMotion\\Textures\\Kaitan\\CellRing"] = "CellRing",
    ["Interface\\AddOns\\WeakAurasStopMotion\\Textures\\Kaitan\\Gadget"] = "Gadget",
    ["Interface\\AddOns\\WeakAurasStopMotion\\Textures\\Kaitan\\Radar"] = "Radar",
    ["Interface\\AddOns\\WeakAurasStopMotion\\Textures\\Kaitan\\RadarComplex"] = "RadarComplex",
    ["Interface\\AddOns\\WeakAurasStopMotion\\Textures\\Kaitan\\Saber"] = "Saber",
    ["Interface\\AddOns\\WeakAurasStopMotion\\Textures\\Kaitan\\Waveform"] = "Waveform",
}

WeakAurasStopMotion.texture_data["Interface\\AddOns\\WeakAurasStopMotion\\Textures\\Kaitan\\CellRing"] = {
      ["count"] = 32,
      ["rows"] = 8,
      ["columns"] = 4
  }
  
WeakAurasStopMotion.texture_data["Interface\\AddOns\\WeakAurasStopMotion\\Textures\\Kaitan\\Gadget"] = {
     ["count"] = 32,
     ["rows"] = 8,
     ["columns"] = 4
  }
  
WeakAurasStopMotion.texture_data["Interface\\AddOns\\WeakAurasStopMotion\\Textures\\Kaitan\\Radar"] = {
     ["count"] = 32,
     ["rows"] = 8,
     ["columns"] = 4
  }
  
WeakAurasStopMotion.texture_data["Interface\\AddOns\\WeakAurasStopMotion\\Textures\\Kaitan\\RadarComplex"] = {
     ["count"] = 32,
     ["rows"] = 8,
     ["columns"] = 4
  }
  
WeakAurasStopMotion.texture_data["Interface\\AddOns\\WeakAurasStopMotion\\Textures\\Kaitan\\Saber"] = {
     ["count"] = 32,
     ["rows"] = 8,
     ["columns"] = 4
  }
  
WeakAurasStopMotion.texture_data["Interface\\AddOns\\WeakAurasStopMotion\\Textures\\Kaitan\\Waveform"] = {
     ["count"] = 32,
     ["rows"] = 8,
     ["columns"] = 4
  }