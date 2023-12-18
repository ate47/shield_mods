--[[
Prototype and notes for LUA

Engine.PrintInfo(0, "Fuck lua") -> PrintInfo should be XHASH instead of STRING

-- Engine[@"func"]
-- Enum[@"name"]
-- Enum[@"name"][@"name2"]
-- CoD[@"hash_8A9D1228888C8CB"]
-- CoD.BlackMarketTableUtility[@"name"]
-- Dvar[@"name"]


Hooks:
x64:2cfcd4cb80781b03.lua -> 27cac000f20ef647 (PC version)
x64:12dd4ff313102b79.lua -> 4a3eb94d551ddf71 (Frontend)
x64:66eee5926f63b60b.lua -> 4ed0bcba9d999e0f (Frontend 2)
x64:2cb5bf4e094259d8.lua -> 46f417a74d9ab424 (Zombies)
x64:8f9e828ebdeac4c.lua  -> 7f750379a77f3190 (Warzone)
x64:5be322a54ff91a9a.lua -> 4fb12287640e989a (Multiplayer/Warzone)


Hud factories:
x64:31824fcd24cd5764.lua -> 2b23cf5ef446c848 (Zombies / T7Hud_zm_factory)
57d27ab8e2f7a9d0 (Others / Hud)

619241173 = Failed to allocate from element pool

LUI.UI????.new(leftAnchor, rightAnchor, left, right, topAnchor, bottomAnchor, top, bottom)

The hooks for blackout and the multiplayer is probably in one these files (dump required)
elseif CoD.isWarzone then
      require( "x64:8f9e828ebdeac4c" )
else
      require( "x64:eb491e34e330ae0" )
      require( "x64:6b7fc557f641386" )
      require( "x64:2f1b9c001eb57aa3" )
      require( "x64:37c614e146b5eea5" )
]]

Engine[ @"PrintInfo" ](0, "Hello from map  " .. Engine[ @"GetCurrentMap"]() .. " inject? " .. tostring(LUI.createMenu["T7Hud_" .. Engine[@"getcurrentmap"]()] ~= nil))

-- Should be injected after 2b23cf5ef446c848

LUI.createMenu["T7Hud_" .. Engine[@"getcurrentmap"]()] = function ( controller ) 
      local self = LUI.createMenu.T7Hud_zm_factory( controller )
      Engine[ @"PrintInfo" ](0, "Injecting custom menu")

      self.luatest = {}

      -- ConstructLUIElement(leftAnchor, rightAnchor, left, right, topAnchor, bottomAnchor, top, bottom)

      --local box = LUI.UIImage.new(0.5, 0.5, -64, 64, 0.5, 0.5, -20, 20)
	--box:setImage(RegisterImage(@"$white"))
      --box:setRGB(1, 1, 0)
      --box:setAlpha(0.25)
      --self:addElement(box)

      local notf = {}
      self.luatest.notf = notf
      notf.linesData = {}
      notf.lines = {}
      notf.linesDataStart = 0
      notf.linesDataSize = 0
      for i=1,15 do
            notf.linesData[i] = ""
            local elem = LUI.UIText.new(0.5, 0, 64, 0, 0.5, 0.5, 20 + (i - 1) * 30, 50 + (i - 1) * 30)
            elem:setText("")
            elem:setRGB(0.4, 0.9, 0.4)
            elem:setTTF("ttmussels_demibold")
            elem:setAlignment( Enum[@"luialignment"][@"lui_alignment_left"] )
            elem:setAlignment( Enum[@"luialignment"][@"lui_alignment_top"] )
            self:addElement(elem)
            notf.lines[i] = elem
      end

      local first = notf.lines[1]
      first:subscribeToGlobalModel(controller, "PerController", "scriptNotify", function ( model )
            if CoD.ModelUtility.IsParamModelEqualToHashString( model, @"testlua_points" ) then
                  local scriptData = CoD.GetScriptNotifyData(model)
                  if scriptData[1] == 1 then
                        if notf.linesDataSize >= #notf.linesData then
                              -- increase the start
                              notf.linesDataStart = (notf.linesDataStart + 1) % #notf.linesData
                        else
                              notf.linesDataSize = notf.linesDataSize + 1
                        end

                        notf.linesData[(notf.linesDataStart + notf.linesDataSize - 1) % #notf.linesData + 1] = "+ " .. tostring(scriptData[2])

                        -- update lines
                        for i=1,notf.linesDataSize do
                              (notf.lines[i]):setText(notf.linesData[(notf.linesDataStart + i - 1) % #notf.linesData + 1])
                        end
                  elseif scriptData[1] == 2 then
                        -- set only reduce
                        first:setText("^1- " .. tostring(scriptData[2]))
                        for i=2,#notf.lines do
                              (notf.lines[i]):setText("")
                        end
                        notf.linesDataSize = 0
                  elseif scriptData[1] == 0 then
                        -- reset all
                        for i=1,#notf.lines do
                              (notf.lines[i]):setText("")
                        end
                        notf.linesDataSize = 0
                  end

                  --notf:setText("^1Zombies: ^5" .. tostring(scriptData[1]) .. " ^1(^5" .. tostring(scriptData[2]) .. " ^1remaining)")
            end
      end)
      
      local counter = LUI.UIText.new(0.5, 1, 0, -6, 0, 0, 6, 46)
      self.luatest.counter = counter
      counter:setText("")
      --counter:setTTF( "ttmussels_regular" )
	counter:setAlignment( Enum[@"luialignment"][@"lui_alignment_right"] )
	counter:setAlignment( Enum[@"luialignment"][@"lui_alignment_top"] )
      counter:subscribeToGlobalModel(controller, "PerController", "scriptNotify", function ( model )
            if CoD.ModelUtility.IsParamModelEqualToHashString( model, @"testlua_update_counter" ) then
                  local scriptData = CoD.GetScriptNotifyData(model)
                  counter:setText("^1Zombies: ^5" .. tostring(scriptData[1]) .. " ^1(^5" .. tostring(scriptData[2]) .. " ^1remaining)")
            end
      end)
      self:addElement(counter)

      return self
end