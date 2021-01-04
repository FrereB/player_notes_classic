-- Initialization 

local function setDefault()
	NonoListSavedVariables = {}
	NonoListSavedVariables["Data"] = {["Anaark-Razorgore"] = "Addon creator, feel free to say hi ;)"}
end

--Set the notes table the 1st time the addon is loaded
local LoadFrame = CreateFrame("Frame")
LoadFrame : RegisterEvent("ADDON_LOADED")
LoadFrame : SetScript("OnEvent", function(self, event, AddonName)
	if AddonName == "NonoList" then
		if NonoListSavedVariables == nil then
			setDefault()
		end
		LoadFrame : UnregisterEvent("ADDON_LOADED")
	end
end)

-- Mouseover active/unactive

local checkMouseoverFrame = CreateFrame ("Frame")

local name, realm
local fullName

checkMouseoverFrame : RegisterEvent("UPDATE_MOUSEOVER_UNIT")

checkMouseoverFrame : SetScript("OnEvent", function(self, event, ...)
	if event == "UPDATE_MOUSEOVER_UNIT" then
		name, realm = UnitName("mouseover")
		if not realm then
			realm = GetNormalizedRealmName()
		end
		fullName = name.."-"..realm

		local noteText = NonoListSavedVariables["Data"][fullName]
		if noteText then
			GameTooltip:AddLine(noteText, 1, 0, 0)
			GameTooltip:Show()
		end
	end
end)

-- Add to list 

function add_list(note)
	local name_note, realm_note
	name_note, realm_note = UnitName("target")
	if not name_note then
		local split_note = split(note)
		add_list_helper(split_note[1],split_note[0])
		return split_note[0]
	elseif not realm_note then
		add_list_helper(note,name_note.."-"..GetNormalizedRealmName())
		return name_note.."-"..GetNormalizedRealmName()
	else
		add_list_helper(note,name_note.."-"..realm_note)
		return name_note.."-"..realm_note
	end
end


function add_list_helper(note, name)
	NonoListSavedVariables["Data"][name] = note
end

-- Remove from list

function remove_list(name)
	NonoListSavedVariables["Data"][name] = nil
	return name
end

-- List frame

-- (1)
local listFrame = CreateFrame("Frame", "NonoListFrame", UIParent)
listFrame:SetSize(400, 500)
listFrame:SetPoint("CENTER")
listFrame:Hide()

-- (2)
listFrame:SetBackdrop({
	bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
	edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
	edgeSize = 1,
})
listFrame:SetBackdropColor(0, 0, 0, .5)
listFrame:SetBackdropBorderColor(0, 0, 0)

local mouseoverText = listFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
mouseoverText:SetPoint("CENTER")
mouseoverText:SetText("Hello dood!")

-- Slash commands

function split(string)
	local c = 0
	local chunks = {}
	for substring in string:gmatch("%S+") do
		chunks[c] = substring
		c = c+1
	end
	local result = {}
	result[0] = chunks[0]
	local temp_msg = ""
	temp_msg = chunks[1]
	if c>1 then
		for i=2,c-1 do
			temp_msg = temp_msg.." "..chunks[i]
		end
	end
	result[1] = temp_msg
	return result
end

SlashCmdList["NONOLIST"] = function(msg)
	local split_msg = split(msg)
	if split_msg[0] == nil then
		print("Hello dood !")
	elseif split_msg[0] == "show" then
		checkMouseoverFrame : RegisterEvent("UPDATE_MOUSEOVER_UNIT")
	elseif split_msg[0] == "hide" then
		checkMouseoverFrame : UnregisterEvent("UPDATE_MOUSEOVER_UNIT")
	elseif split_msg[0] == "add" then
		local note_added = add_list(split_msg[1])
		print("Note added for "..note_added)
	elseif split_msg[0] == "remove" then
		local note_removed = remove_list(split_msg[1])
		print("Note removed for "..note_removed)
	elseif split_msg[0] == "list" then
		listFrame:Show()
	else
		print("Unrecognized command")
	end
end

SLASH_NONOLIST1 = "/NonoList"
SLASH_NONOLIST2 = "/nl"