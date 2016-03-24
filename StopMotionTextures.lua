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
    ["Interface\\AddOns\\WeakAurasStopMotion\\Textures\\Basic\\orbred1"] = "Red Orb",
    ["Interface\\AddOns\\WeakAurasStopMotion\\Textures\\Basic\\orbred2"] = "Red Orb 2",
    ["Interface\\AddOns\\WeakAurasStopMotion\\Textures\\Basic\\orbgreen"] = "Green Orb",
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

WeakAurasStopMotion.texture_data["Interface\\AddOns\\WeakAurasStopMotion\\Textures\\Basic\\orbred1"] = {
     ["count"] = 256,
     ["rows"] = 16,
     ["columns"] = 16
  }
  
WeakAurasStopMotion.texture_data["Interface\\AddOns\\WeakAurasStopMotion\\Textures\\Basic\\orbred2"] = {
     ["count"] = 256,
     ["rows"] = 16,
     ["columns"] = 16
  }
  
WeakAurasStopMotion.texture_data["Interface\\AddOns\\WeakAurasStopMotion\\Textures\\Basic\\orbgreen"] = {
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