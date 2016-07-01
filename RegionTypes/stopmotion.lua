local texture_types = WeakAurasStopMotion.texture_types;
local texture_data = WeakAurasStopMotion.texture_data;
local animation_types = WeakAurasStopMotion.animation_types;

local default = {
    foregroundTexture = "Interface\\AddOns\\WeakAurasStopMotion\\Textures\\Runes\\legionv",
    backgroundTexture = "Interface\\AddOns\\WeakAurasStopMotion\\Textures\\Runes\\legionv",
    desaturateBackground = false,
    desaturateForeground = false,
    sameTexture = true,
    width = 128,
    height = 128,
    foregroundColor = {1, 1, 1, 1},
    backgroundColor = {0.5, 0.5, 0.5, 0.5},
    blendMode = "BLEND",
    rotation = 0,
    discrete_rotation = 0,
    mirror = false,
    rotate = true,
    selfPoint = "CENTER",
    anchorPoint = "CENTER",
    xOffset = 0,
    yOffset = 0,
    frameStrata = 1,
    startPercent = 0,
    endPercent = 1,
    backgroundPercent = 1,
    frameRate = 15,
    animationType = "progress",
    inverse = false,
    customForegroundFrames = 0,
    customForegroundRows = 16,
    customForegroundColumns = 16,
    customBackgroundFrames = 0,
    customBackgroundRows = 16,
    customBackgroundColumns = 16,
    hideBackground = true
};

local function create(parent)
    local frame = CreateFrame("FRAME", nil, UIParent);
    frame:SetMovable(true);
    frame:SetResizable(true);
    frame:SetMinResize(1, 1);

    local background = frame:CreateTexture(nil, "BACKGROUND");
    frame.background = background;
    background:SetAllPoints(frame);

    local foreground = frame:CreateTexture(nil, "ART");
    frame.foreground = foreground;
    foreground:SetAllPoints(frame);

    frame.duration = 0;
    frame.expirationTime = math.huge;
    return frame;
end

local function SetTextureViaAtlas(self, texture)
  self:SetTexture(texture);
end

local function setTile(texture, frame, rows, columns )
  frame = frame - 1;
  local row = floor(frame / columns);
  local column = frame % columns;

  local deltaX = 1 / columns;
  local deltaY = 1 / rows;

  local left = deltaX * column;
  local right = left + deltaX;

  local top = deltaY * row;
  local bottom = top + deltaY;

  texture:SetTexCoord(left, right, top, bottom);
end

WeakAuras.setTile = setTile;

local function SetFrameViaAtlas(self, texture, frame)
  setTile(self, frame, self.rows, self.columns);
end

local function SetTextureViaFrames(self, texture)
    self:SetTexture(texture .. format("%03d", 0));
    self:SetTexCoord(0, 1, 0, 1);
end

local function SetFrameViaFrames(self, texture, frame)
    self:SetTexture(texture .. format("%03d", frame));
end

local function modify(parent, region, data)
    if(data.frameStrata == 1) then
        region:SetFrameStrata(region:GetParent():GetFrameStrata());
    else
        region:SetFrameStrata(WeakAuras.frame_strata_types[data.frameStrata]);
    end

    -- Frames...
    local tdata = texture_data[data.foregroundTexture];
    if (tdata) then
      local lastFrame = tdata.count - 1;
      region.startFrame = floor( (data.startPercent or 0) * lastFrame) + 1;
      region.endFrame = floor( (data.endPercent or 1) * lastFrame) + 1;
      region.foreground.rows = tdata.rows;
      region.foreground.columns = tdata.columns;
    else
      local lastFrame = (data.customForegroundFrames or 256) - 1;
      region.startFrame = floor( (data.startPercent or 0) * lastFrame) + 1;
      region.endFrame = floor( (data.endPercent or 1) * lastFrame) + 1;
      region.foreground.rows = data.customForegroundRows;
      region.foreground.columns = data.customForegroundColumns;
    end

    local backgroundTexture = data.sameTexture
                             and data.foregroundTexture
                             or data.backgroundTexture;

    local tbdata = texture_data[backgroundTexture];
    if (tbdata) then
      local lastFrame = tbdata.count - 1;
      region.backgroundFrame = floor( (data.backgroundPercent or 1) * lastFrame + 1);
      region.background.rows = tbdata.rows;
      region.background.columns = tbdata.columns;
    else
      local lastFrame = (data.sameTexture and data.customForegroundFrames
                                          or data.customBackgroundFrames or 256) - 1;
      region.backgroundFrame = floor( (data.backgroundPercent or 1) * lastFrame + 1);
      region.background.rows = data.sameTexture and data.customForegroundRows
                                                 or data.customBackgroundRows;
      region.background.columns = data.sameTexture and data.customForegroundColumns
                                                   or data.customBackgroundColumns;
    end

    if (region.foreground.rows and region.foreground.columns) then
      region.foreground.SetBaseTexture = SetTextureViaAtlas;
      region.foreground.SetFrame = SetFrameViaAtlas;
    else
      region.foreground.SetBaseTexture = SetTextureViaFrames;
      region.foreground.SetFrame = SetFrameViaFrames;
    end

    if (region.background.rows and region.background.columns) then
      region.background.SetBaseTexture = SetTextureViaAtlas;
      region.background.SetFrame = SetFrameViaAtlas;
    else
      region.background.SetBaseTexture = SetTextureViaFrames;
      region.background.SetFrame = SetFrameViaFrames;
    end


    region.background:SetBaseTexture(backgroundTexture);
    region.background:SetFrame(backgroundTexture, region.backgroundFrame or 1);
    region.background:SetDesaturated(data.desaturateBackground)
    region.background:SetVertexColor(data.backgroundColor[1], data.backgroundColor[2], data.backgroundColor[3], data.backgroundColor[4]);
    region.background:SetBlendMode(data.blendMode);

    if (data.hideBackground) then
      region.background:Hide();
    else
      region.background:Show();
    end

    region.foreground:SetBaseTexture(data.foregroundTexture);
    region.foreground:SetFrame(data.foregroundTexture, 1);
    region.foreground:SetDesaturated(data.desaturateForeground);
    region.foreground:SetBlendMode(data.blendMode);

    region:SetWidth(data.width);
    region:SetHeight(data.height);
    region:ClearAllPoints();
    region:SetPoint(data.selfPoint, parent, data.anchorPoint, data.xOffset, data.yOffset);

    function region:Scale(scalex, scaley)
        if(scalex < 0) then
            region.mirror_h = true;
            scalex = scalex * -1;
        else
            region.mirror_h = nil;
        end
        region:SetWidth(data.width * scalex);
        if(scaley < 0) then
            scaley = scaley * -1;
            region.mirror_v = true;
        else
            region.mirror_v = nil;
        end
        region:SetHeight(data.height * scaley);
    end

    function region:Color(r, g, b, a)
        region.foregroundColor_r = r;
        region.foregroundColor_g = g;
        region.foregroundColor_b = b;
        region.foregroundColor_a = a;
        region.foreground:SetVertexColor(r, g, b, a);
    end

    function region:GetColor()
        return region.foregroundColor_r or data.foregroundColor[1], region.foregroundColor_g or data.foregroundColor[2],
               region.foregroundColor_b or data.foregroundColor[3], region.foregroundColor_a or data.foregroundColor[4];
    end

    region:Color(data.foregroundColor[1], data.foregroundColor[2], data.foregroundColor[3], data.foregroundColor[4]);

    local function UpdateValue(value, total)
        region.progress = value;
        region.duration = total;
    end

    function region:PreShow()
      region.startTime = GetTime();
    end

    local function onUpdate()
      if (not region.startTime) then return end
      local timeSinceStart = (GetTime() - region.startTime);
      local newCurrentFrame = floor(timeSinceStart * (data.frameRate or 15));
      if (newCurrentFrame == region.currentFrame) then
          return;
      end

      region.currentFrame = newCurrentFrame;

      local frames;
      local startFrame = region.startFrame;
      local endFrame = region.endFrame;
      local inverse = data.inverse;
      if (endFrame >= startFrame) then
        frames = endFrame - startFrame + 1;
      else
        frames = startFrame - endFrame + 1;
        startFrame, endFrame = endFrame, startFrame;
        inverse = not inverse;
      end

      local frame = 0;
      if (data.animationType == "loop") then
          frame = (newCurrentFrame % frames) + startFrame;
      elseif (data.animationType == "bounce") then
          local direction = floor(newCurrentFrame / frames) % 2;
          if (direction == 0) then
              frame = (newCurrentFrame % frames) + startFrame;
          else
              frame = endFrame - (newCurrentFrame % frames);
          end
      elseif (data.animationType == "once") then
          frame = newCurrentFrame + startFrame
          if (frame > endFrame) then
            frame = endFrame;
          end
      elseif (data.animationType == "progress") then
        if (region.customValueFunc) then
          UpdateValue(region.customValueFunc(data.trigger));
        end
        if (region.mode == "progress") then
          local progress = region.progress or 0
          local duration = region.duration ~= 0 and region.duration or 1
          frame = floor((frames - 1) * progress / duration) + startFrame;
        else
          local remaining = region.expirationTime - GetTime();
          local progress = 1 - (remaining / region.duration);
          frame = floor( (frames - 1) * progress) + startFrame;
        end
      end

      if (inverse) then
        frame = endFrame - frame + startFrame;
      end

      if (frame > endFrame) then
        frame = endFrame
         end
      if (frame < startFrame) then
        frame = startFrame
      end
      region.foreground:SetFrame(data.foregroundTexture, frame);
    end;
    region:SetScript("OnUpdate", onUpdate);

    function region:SetDurationInfo(duration, expirationTime, customValue)
        if (not duration or not expirationTime) then return end
        if(duration <= 0.01 or duration > region.duration or not data.stickyDuration) then
            region.duration = duration;
        end
        region.expirationTime = expirationTime;
        region.customValueFunc = nil;

        if(customValue) then
            region.mode = "progress";
            if(type(customValue) == "function") then
                local value, total = customValue(data.trigger);
                if(total > 0 and value <= total) then
                    region.customValueFunc = customValue;
                else
                    UpdateValue(duration, expirationTime);
                end
                onUpdate();
            else
                UpdateValue(duration, expirationTime);
                onUpdate();
            end
        else
            region.mode = "time";
            onUpdate();
        end
    end
end

WeakAuras.RegisterRegionType("stopmotion", create, modify, default);
