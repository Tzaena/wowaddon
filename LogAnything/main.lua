local EventFrame = CreateFrame("Frame")
EventFrame:RegisterEvent("LOOT_OPENED")
EventFrame:SetScript("OnEvent", function(self,event,...) 
	getInfos()
end)
local EventFrame2 = CreateFrame("Frame")
EventFrame2:RegisterEvent("PLAYER_LOGIN")
EventFrame2:SetScript("OnEvent", function(self,event,...) 
	LogAnything_Frame:Show()
end)

function LogAnything_ShowMessage()
	ChatFrame1:AddMessage('test')
  end

function getInfos()
	local info = GetLootInfo();
	if type(LootInfos) ~= "table" then
	LootInfos = {}
	end
	for key,value in pairs(info) do
		local map = C_Map.GetBestMapForUnit("player")
		local position = C_Map.GetPlayerMapPosition(map, "player")
		local posX = round2(position.x * 100,2)
		local posY = round2(position.y * 100,2)
		if type(LootInfos[value.item]) ~= "table" then
			LootInfos[value.item] = {}
		end
		local item = {
			posX = posX,
			posY = posY,
			zone = GetZoneText(),
			count = 1
			}
		local position = nearPosition(LootInfos[value.item], item, 0.5)
		if position > 0 then
			LootInfos[value.item][position].count =LootInfos[value.item][position].count + 1
			ChatFrame1:AddMessage(LootInfos[value.item][position].count)
		else
			LootInfos[value.item][tablelength(LootInfos[value.item])] = item
			addToMap(item, value.item)
		end
   end
  end

  function nearPosition(table, item, precision)
	local count = 0
	for key,value in pairs(table) do 
		if (value.posX < item.posX + precision and value.posX > item.posX - precision) and (value.posY < item.posY + precision and value.posY > item.posY - precision) then
			return count
		end
		count = count + 1
	end
	return 0
  end

function showInfos(table)
	for key,value in pairs(table) do 
		ChatFrame1:AddMessage('**' .. key);
		for key2,item in pairs(value) do 
			ChatFrame1:AddMessage( item.zone .. ' ' .. item.posX .. ' ' .. item.posY .. ' ' .. item.count)
		end
	end
  end

  function addToMap (item, name) 
	DEFAULT_CHAT_FRAME.editBox:SetText('/way ' .. item.zone .. ' ' .. item.posX .. ' ' .. item.posY .. ' ' .. name .. '(' .. item.count .. ')') 
	ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox, 0)
  end

function tablelength(T)
	local count = 0
	for _ in pairs(T) do count = count + 1 end
	return count
  end

function round2(num, numDecimalPlaces)
	return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", num))
  end