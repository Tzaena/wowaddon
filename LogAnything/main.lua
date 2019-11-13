
--*********************** EVENTS ***********************

local EventFrameLoot = CreateFrame("Frame")
EventFrameLoot:RegisterEvent("LOOT_OPENED")
EventFrameLoot:SetScript("OnEvent", function(self,event,...) 
	-- Event trigger lorsqu'on ouvre une fenêtre de loot
	setLootInfos()
	LogAnything_Frame:Show()
end)
local EventFrameLogin = CreateFrame("Frame")
EventFrameLogin:RegisterEvent("PLAYER_LOGIN")
EventFrameLogin:SetScript("OnEvent", function(self,event,...) 
	-- Event trigger au login
	LA_ItemArray = LootInfos
	showInfos(LA_LootInfos)
	initialize()
	setSelected('Gelée délayée', true)
end)


LogAnything_Frame:SetScript("OnUpdate", function(self, elapsed)
	ChatFrame1:AddMessage('test')
end)

-- initialisation des variables globales
function initialize()
	if type(LootInfos) ~= "table" then
		LootInfos = {}
	end
	if type(LA_Parameters) == "nil" then
		LA_Parameters = {
			selectedItems = {}
		}
	end
end

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
	if type(LootInfos[item]) ~= "table" then
		LootInfos[item] = {}
	end
	local itemPosition = {
		posX = posX,
		posY = posY,
		zone = GetZoneText(),
		count = 1
		}
	local position = nearPosition(LootInfos[item], itemPosition, 0.5)
	if position > 0 then
		LootInfos[item][position].count =LootInfos[item][position].count + 1
		ChatFrame1:AddMessage(LootInfos[item][position].count)
	else
		LootInfos[item][tablelength(LootInfos[item])] = itemPosition
		addToMap(itemPosition, item)
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
function showInfos(table)
	for key,value in pairs(table) do 
		if key == 'Gelée délayée' then
			ChatFrame1:AddMessage('**' .. key)
			for key2,item in pairs(value) do 
				ChatFrame1:AddMessage( item.zone .. ' ' .. item.posX .. ' ' .. item.posY .. ' ' .. item.count)
			end
		else
		end
	end
  end
  
-- sélectionne un item
function setSelected(name, state)
	LA_Parameters.selectedItems[name] = state
end
  
--*********************** CARTE ***********************

-- vide la carte et affiche à la place tous les items sélectionnés
function showSelectedOnMap()
	deleteAll()
	for key,value in pairs(LA_Parameters.selectedItems) do 
		if value then
			showOnMap(key)
		end
	end	
end

-- affiche sur la carte toutes les positions d'un item donné
function showOnMap(name)
	local item = LootInfos[name]
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