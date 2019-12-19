
--*********************** EVENTS ***********************

local EventFrameLoot = CreateFrame("Frame")
EventFrameLoot:RegisterEvent("LOOT_OPENED")
EventFrameLoot:SetScript("OnEvent", function(self,event,...) 
	-- Event trigger lorsqu'on ouvre une fenêtre de loot
	setLootInfos()
end)
local EventFrameLogin = CreateFrame("Frame")
EventFrameLogin:RegisterEvent("PLAYER_LOGIN")
EventFrameLogin:SetScript("OnEvent", function(self,event,...) 
	-- Event trigger au login
	LogAnything_Frame:Hide()
	initialize()
	--setSelected('Gelée délayée', true)
	--showSelectedOnMap()
end)


LogAnything_Button:SetScript("OnClick", function(self, elapsed)
	ChatFrame1:AddMessage('**')
end)
LogAnything_Frame:SetScript("OnMouseUp",function(self,button)
	ChatFrame1:AddMessage('**')
end)

-- initialisation des variables globales
function initialize()
	if type(LA_ItemArray) ~= "table" then
		LA_ItemArray = {}
	end
	if type(LA_Parameters) == "nil" then
		LA_Parameters = {
			selectedItems = {}
		}
	end
end


local function AdddToMap(msg, editbox)
	showSelectedOnMap()
  end
  local function SwapItem(msg, editbox)
	  setSelected(msg)
	end
  
  SLASH_LAADDTOMAP1 = '/lamap'
  
  SlashCmdList["LAADDTOMAP"] = AdddToMap

  local function ShowAllItems(msg, editbox)
	showInfos(msg, true)
  end
  
  SLASH_LASHOWALL1 = '/lashow'
  SLASH_LAADDTOMAP1 = '/lamap'
  SLASH_LASWAP1 = '/laswap'
  
  SlashCmdList["LASHOWALL"] = ShowAllItems
  SlashCmdList["LAADDTOMAP"] = AdddToMap
  SlashCmdList["LASWAP"] = SwapItem

--*********************** ITEMS ***********************

-- enregistre les informations d'un loot
function setLootInfos()
	local info = GetLootInfo();
	for key,value in pairs(info) do
		addPositionToItem(value.item)
   end
end
  
-- ajoute la position courante à un item
function addPositionToItem(item)
	local map = C_Map.GetBestMapForUnit("player")
	local pos = C_Map.GetPlayerMapPosition(map, "player")
	local posX = round2(pos.x * 100,2)
	local posY = round2(pos.y * 100,2)
	if type(LA_ItemArray[item]) ~= "table" then
		LA_ItemArray[item] = {}
	end
	local itemPosition = {
		posX = posX,
		posY = posY,
		zone = GetZoneText(),
		count = 1
		}
	local position = nearPosition(LA_ItemArray[item], itemPosition, 0.5)
	if position > 0 then
		LA_ItemArray[item][position].count =LA_ItemArray[item][position].count + 1
		ChatFrame1:AddMessage(LA_ItemArray[item][position].count)
	else
		LA_ItemArray[item][tablelength(LA_ItemArray[item])] = itemPosition
		--addToMap(itemPosition, item)
	end
end

-- vérifie s'il existe déjà un item enregistré à cette position
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
  
-- affiche les informations dans les messages
function showInfos(name, detail)
	for key,value in pairs(LA_ItemArray) do 
		if key == name then
			ChatFrame1:AddMessage('**' .. key)
			if detail == true then
				for key2,item in pairs(value) do 
					ChatFrame1:AddMessage( item.zone .. ' ' .. item.posX .. ' ' .. item.posY .. ' ' .. item.count)
				end
			end
		end
	end
  end
  
-- sélectionne un item
function setSelected(name)
	LA_Parameters.selectedItems[name] = not LA_Parameters.selectedItems[name]
end
  
--*********************** CARTE ***********************

-- vide la carte et affiche à la place tous les items sélectionnés
function showSelectedOnMap()
	for key,value in pairs(LA_Parameters.selectedItems) do 
		if value == true then
			showOnMap(key)
		end
	end	
end

-- affiche sur la carte toutes les positions d'un item donné
function showOnMap(name)
	local item = LA_ItemArray[name]
	for key,value in pairs(item) do 
		addToMap(value, name)
	end
end

-- supprime tous les points sur la carte
function deleteAll() 
	DEFAULT_CHAT_FRAME.editBox:SetText('/tway reset all') 
	ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox, 0)
end

-- ajoute l'item sur la carte
  function addToMap (item, name) 
	DEFAULT_CHAT_FRAME.editBox:SetText('/tway ' .. item.zone .. ' ' .. item.posX .. ' ' .. item.posY .. ' ' .. name .. '(' .. item.count .. ')') 
	ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox, 0)
  end

--*********************** UTILITAIRES ***********************

-- calcule la taille d'un tableau
function tablelength(T)
	local count = 0
	for _ in pairs(T) do 
		count = count + 1 
	end
	return count
  end

-- arrondi un nombre à x décimales
function round2(num, numDecimalPlaces)
	return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", num))
  end