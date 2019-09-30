-- Simple LFG
-- Author: Sythalin


SLFG = SLFG or {}
local SLFG = CreateFrame("FRAME")
SLFG:RegisterEvent("ADDON_LOADED")
SLFG:SetScript("OnEvent", function(self, event, ...) if SLFG[event] then return SLFG[event](self, event, ...) end end)
SLFG:Show()

function SLFG:ADDON_LOADED(_, addon)
	if addon ~= "SLFG" then return end
	-- LOAD/CREATE SETTINGS
	SLFG_Settings = SLFG_Settings or {
		["pos"] = {
			["point"] = "CENTER",
			["parent"] = "UIParent",
			["relPoint"] = "CENTER",
			["offX"] = 0,
			["offY"] = 0 
			},
		["curPanel"] = "lfg",
		}
		
	SLFG_Info = SLFG_Info or {
		["msgLFG"] = "",
		["msgLFM"] = "",
		["customChan"] = "",
		["role"] = "",
		["dungeon"] = "",
		["numTank"] = 1,
		["numHeal"] = 1,
		["numDPS"] = 1,
		["numLFM"] = 1
		}
		
	SLFG_Options = SLFG_Options or {
		["postCharInfo"] = false,
		["lfg"] = false,
		["guild"] = false,
		["general"] = false,
		["custom"] = false,
		["needTank"] = false,
		["needHeal"] = false,
		["needDPS"] = false
		}

	-- CREATE NEW VARIABLES IF NEEDED
	SLFG_Info.customChan = SLFG_Info.customChan or ""
	SLFG_Options.custom = SLFG_Options.custom or false
	
	SLFG_DungeonList = {
		"Ragefire Chasm (RFC)",
		"Wailing Caverns (WC)",
		"Deadmines (VC)",
		"Shadowfang Keep (SFK)",
		"Blackfathom Deeps (BFD)",
		"Stockade (Stocks)",
		"Gnomeregan (Gnomer)",
		"Razorfen Kraul (RFK)",
		"SM: Graveyard (GY)",
		"SM: Library (SM: Lib)",
		"SM: Armory (SM: Armory)",
		"SM: Cathedral (SM: Cath)",
		"Razorfen Downs (SM: RFD)",
		"Uldaman (Ulda)",
		"Zul'Farrack (ZF)",
		"Maraudon (Mara)",
		"Sunken Temple (ST)",
		"Blackrock Depths (BRD)",
		"Lower Blackrock Spire (LBRS)",
		"Upper Blackrock Spire (UBRS)",
		-- "Dire Maul: East (DM:E)",
		-- "Dire Maul: West (DM:W)",
		-- "Dire Maul: North (DM:N)",
		"Scholomance (Scholo)",
		"Stratholme: Live (Live Strat)",
		"Stratholme: Dead (UD Strat)",
		"Molten Core (MC)",
		"Onyxia's Lair (Ony)" }
	
	-- Post Macro
	-- CreateMacro("SLFG Message", "Spell_Holy_PrayerOfHealing", "/script SLFG_PostMsg()", nil)
	 
	-- SLASH COMMANDS
	SLASH_SLFG1 = "/slfg"
	SlashCmdList["SLFG"] = SLFG_GUIToggle
	self:UnregisterEvent("ADDON_LOADED")
	
end

	----------------------
	-- WIDGET TEMPLATES --
	----------------------

function SLFG_CreatePanel(name, parent)
	panel = CreateFrame("FRAME", parent:GetName().. name, parent)
		panel:SetSize(parent:GetWidth()*.94, 75)
		panel:SetBackdrop({
			edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
			edgeSize = 10,
			})
	return panel
end

	-------------------
	-- MAIN FUNCTION --
	-------------------
function SLFG_CreateGUI()

	local mainFrame, postFrame, panel, b, cb, fs, eb
	
	----------------
	-- MAIN FRAME --
	----------------
	mainFrame = CreateFrame("FRAME", "SLFG_GUI", UIParent)
		mainFrame:SetSize(320, 225)
		mainFrame:SetPoint(SLFG_Settings.pos.point, SLFG_Settings.pos.parent, SLFG_Settings.pos.relPoint, SLFG_Settings.pos.offX,SLFG_Settings.pos.offY)
		mainFrame:SetBackdrop({
			bgFile = "Interface/FrameGeneral/UI-Background-Marble",
			edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
			tile = "true",
			tileSize = 400,
			edgeSize = 10,
			insets = {left = 3, right = 3, top = 3, bottom = 3}
			})
		mainFrame:EnableMouse(true)
		mainFrame:SetMovable(true)
		mainFrame:SetClampedToScreen(true)
		mainFrame:RegisterForDrag("LeftButton")
		mainFrame:SetScript("OnDragStart", mainFrame.StartMoving)
		mainFrame:SetScript("OnDragStop", function()
			mainFrame:StopMovingOrSizing()
			local point, parent, relPoint, offX, offY = mainFrame:GetPoint()
			SLFG_Settings.pos.point = point
			SLFG_Settings.pos.parent = parent
			SLFG_Settings.pos.relPoint = relPoint
			SLFG_Settings.pos.offX = offX
			SLFG_Settings.pos.offY = offY
			end)

		tinsert(UISpecialFrames,"SLFG_GUI")
	
	
	e = CreateFrame("EDITBOX", "SLFG_Title", mainFrame)
		e:SetSize(mainFrame:GetSize()/2, 20)
		e:SetPoint("CENTER", mainFrame, "TOP", 0, 0)
		e:SetBackdrop({
			bgFile = "Interface/Buttons/UI-Listbox-Highlight2",
			edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
			tile = "false",
			tileSize = 150,
			edgeSize = 10,
			insets = {left = 3, right = 3, top = 3, bottom = 3}
			})
		e:SetBackdropColor(1,1,1,1)
		e:SetAutoFocus(false)
		e:SetTextInsets(0,0,0,0)
		e:SetFontObject("GameFontWhite")
		e:SetTextColor(0,0,0)
		e:SetText("Simple LFG (1.3)")
		e:SetJustifyH("CENTER")
		e:Disable()
		
	----------------
	-- POST FRAME --
	----------------
	postFrame = CreateFrame("FRAME", "SLFG_PostFrame", mainFrame)
		postFrame:SetSize(235, 48)
		postFrame:SetPoint("BOTTOM", mainFrame, "BOTTOM", 0, 30)
		postFrame:SetBackdrop({
			edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
			edgeSize = 10,
			})
	fs = postFrame:CreateFontString("SLFG_PostTo")
		fs:SetPoint("TOPLEFT", postFrame, "TOPLEFT", 10, -8)
		fs:SetFontObject("GameFontNormal")
		fs:SetJustifyH("LEFT")
		fs:SetText("Post To:")
		
	-- GENERAL CHECKBOX
	cb = CreateFrame("CHECKBUTTON", mainFrame:GetName().."_GeneralCheck", mainFrame, "UIRadioButtonTemplate")
		cb:SetPoint("LEFT", fs, "RIGHT", 10, 0)
		cb:SetScript("OnClick", function(self)
				if self:GetChecked() then
					SLFG_Options.general = true
				else
					SLFG_Options.general = false
				end
			end)
		if SLFG_Options.general == true then
			cb:SetChecked(true)
		end	
		
	fs = cb:CreateFontString("SLFG_PostGeneral")
		fs:SetPoint("LEFT", cb, "RIGHT", 2,0)
		fs:SetFontObject("GameFontNormalSmall")
		fs:SetJustifyH("LEFT")
		fs:SetText("General")
		
	-- LFG CHECKBOX
	cb = CreateFrame("CHECKBUTTON", mainFrame:GetName().."_LFGCheck", mainFrame, "UIRadioButtonTemplate")
		cb:SetPoint("LEFT", SLFG_PostGeneral, "RIGHT", 5, 0)
		cb:SetScript("OnClick", function(self)
				if self:GetChecked() then
					SLFG_Options.lfg = true
				else
					SLFG_Options.lfg = false
				end
			end)
		if SLFG_Options.lfg == true then
			cb:SetChecked(true)
		end	
	fs = cb:CreateFontString("SLFG_PostLFG")
		fs:SetPoint("LEFT", cb, "RIGHT", 2,0)
		fs:SetFontObject("GameFontNormalSmall")
		fs:SetJustifyH("LEFT")
		fs:SetText("LFG")
		
	-- GUILD CHECKBOX
	cb = CreateFrame("CHECKBUTTON", mainFrame:GetName().."_GuildCheck", mainFrame, "UIRadioButtonTemplate")
		cb:SetPoint("LEFT", SLFG_PostLFG, "RIGHT", 5, 0)
		cb:SetScript("OnClick", function(self)
				if self:GetChecked() then
					SLFG_Options.guild = true
				else
					SLFG_Options.guild = false
				end
			end)
		if SLFG_Options.guild == true then
			cb:SetChecked(true)
		end	
	fs = cb:CreateFontString("SLFG_PostGuild")
		fs:SetPoint("LEFT", cb, "RIGHT", 2,0)
		fs:SetFontObject("GameFontNormalSmall")
		fs:SetJustifyH("LEFT")
		fs:SetText("Guild")

	-- CUSTOM CHECKBOX
	cb = CreateFrame("CHECKBUTTON", mainFrame:GetName().."_CustomCheck", mainFrame, "UIRadioButtonTemplate")
		cb:SetPoint("TOP", SLFG_GUI_GeneralCheck, "BOTTOM", 0, -2)
		cb:SetScript("OnClick", function(self)
				if self:GetChecked() then
					SLFG_Options.custom = true
				else
					SLFG_Options.custom = false
				end
			end)
		if SLFG_Options.custom == true then
			cb:SetChecked(true)
		end	
	
	e = CreateFrame("EDITBOX", "SLFG_CustomBox", SLFG_GUI)
		e:SetSize(148,20)
		e:SetPoint("LEFT", SLFG_GUI_CustomCheck, "RIGHT", 0, 0)
		e:SetBackdrop({
			edgeFile="Interface/Tooltips/UI-Tooltip-Border",
			edgeSize=10
			})
		e:SetAutoFocus(false)
		e:SetTextInsets(5,0,0,0)
		e:SetFontObject("GameFontNormal")
		e:SetScript("OnEscapePressed", e.ClearFocus)
		e:SetScript("OnEnterPressed", function(self)
			self:ClearFocus()
			SLFG_Info.customChan = self:GetText()
			self:SetTextColor(SLFG_ValidateChannel(self))
			end)
		e:SetText(SLFG_Info.customChan)
		e:SetTextColor(SLFG_ValidateChannel(self))

	--------------------
	-- DUNGEON SELECT --
	--------------------
	fs = mainFrame:CreateFontString("SLFG_DungeonText")
		fs:SetFontObject("GameFontNormal")
		fs:SetJustifyH("RIGHT")
		fs:SetWidth(60)
		fs:SetText("Dungeon: ")
		fs:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 15, -20)

	dm = CreateFrame("FRAME", "SLFG_DungeonMenu", mainFrame, "UIDropDownMenuTemplate")
		dm:SetPoint("LEFT", SLFG_DungeonText, "RIGHT", -10, -2)
		UIDropDownMenu_SetWidth(dm, 190)
		UIDropDownMenu_Initialize(dm, SLFG_DungeonMenu_Init)
	
	----------------
	-- OUTPUT BOX --
	----------------
	
	e = CreateFrame("EDITBOX", "SLFG_MessageBox", SLFG_GUI)
		e:SetSize(236,20)
		e:SetPoint("BOTTOMLEFT", SLFG_GUI, "BOTTOMLEFT", 4, 6)
		e:SetBackdrop({
			edgeFile="Interface/Tooltips/UI-Tooltip-Border",
			edgeSize=10
			})
		e:SetAutoFocus(false)
		e:SetTextInsets(5,0,0,0)
		e:SetFontObject("GameFontNormal")
		e:SetTextColor(1,1,1)
		e:SetScript("OnEscapePressed", e.ClearFocus)
		e:SetScript("OnEnterPressed", function(self)
			self:ClearFocus()
			if SLFG_Settings.curPanel == "lfg" then
				SLFG_Info.msgLFG = self:GetText()
			else
				SLFG_Info.msgLFM = self:GetText()
			end
			end)
		e:SetText(SLFG_Info.msgLFG)
		
	-----------------
	-- POST BUTTON --
	-----------------
	b = CreateFrame("BUTTON", "SLFG_MsgButton", SLFG_GUI, "OptionsButtonTemplate")
		b:SetWidth(75)
		b:SetText("Post")
		b:SetPoint("LEFT", e, "RIGHT", 0, 0)
		b:RegisterForClicks("LeftButtonUp")
		b:SetNormalFontObject("GameFontNormal")
		b:SetHighlightFontObject("GameFontWhite")
		b:SetScript("OnClick", SLFG_PostMsg)

	------------------
	-- CLOSE BUTTON --
	------------------		
	b = CreateFrame("BUTTON", mainFrame:GetName().."_CLOSE", mainFrame, "OptionsButtonTemplate")
		b:SetText("X")
		b:SetWidth(25)
		b:SetPoint("TOPRIGHT", mainFrame, "TOPRIGHT", 0, 0)
		b:SetBackdrop({
			edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
			edgeSize = 10,
			})
		b:RegisterForClicks("LeftButtonUp")
		b:SetNormalFontObject("GameFontNormalSmall")
		b:SetHighlightFontObject("GameFontWhiteSmall")
		b:SetScript("OnClick", function()
			mainFrame:Hide()
			end)
		



	-----------------
	-- TAB BUTTONS --
	-----------------
	b = CreateFrame("BUTTON", mainFrame:GetName().."_LFGButton", mainFrame)
		b:SetSize(150, 25)
		 b:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 10, -45)
		 b:SetBackdrop({
			bgFile = "Interface/CHATFRAME/ChatFrameTab",
			edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
			tile = "false",
			tileSize = 64,
			edgeSize = 10,
			insets = {left = 3, right = 3, top = 3, bottom = 3}
			})
		--b:SetNormalTexture("Interface/CHATFRAME/ChatFrameTab")
		b:SetText("LFG")
		b:RegisterForClicks("LeftButtonUp")
		b:SetNormalFontObject("GameFontNormalSmall")
		b:SetHighlightFontObject("GameFontWhiteSmall")
		b:SetScript("OnClick", function(self)
			SLFG_GUI_Panel1:Show()
			SLFG_GUI_Panel2:Hide()
			self:SetAlpha(1)
			SLFG_GUI_LFMButton:SetAlpha(.25)
			-- SLFG_GUI_Panel3:Hide()
			SLFG_Settings.curPanel = "lfg"
			SLFG_UpdateMsg()
			end)
						
	b = CreateFrame("BUTTON", mainFrame:GetName().."_LFMButton", mainFrame)
		b:SetSize(150, 25)
		 b:SetPoint("LEFT", SLFG_GUI_LFGButton, "RIGHT", 0, 0)
		 b:SetBackdrop({
			bgFile = "Interface/CHATFRAME/ChatFrameTab",
			edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
			tile = "false",
			tileSize = 64,
			edgeSize = 10,
			insets = {left = 3, right = 3, top = 3, bottom = 3}
			})
		--b:SetNormalTexture("Interface/CHATFRAME/ChatFrameTab")
		b:SetText("LFM")	
		b:RegisterForClicks("LeftButtonUp")
		b:SetNormalFontObject("GameFontNormalSmall")
		b:SetHighlightFontObject("GameFontWhiteSmall")
		b:SetAlpha(.25)
		b:SetScript("OnClick", function(self)
			SLFG_GUI_Panel1:Hide()
			SLFG_GUI_Panel2:Show()
			-- SLFG_GUI_Panel3:Hide()
			self:SetAlpha(1)
			SLFG_GUI_LFGButton:SetAlpha(.25)
			SLFG_Settings.curPanel = "lfm"
			SLFG_UpdateMsg()
			end)
			

--[[
	b = CreateFrame("BUTTON", mainFrame:GetName().."_OptionButton", mainFrame)
		b:SetSize(60, 25)
		 b:SetPoint("LEFT", SLFG_GUI_LFMButton, "RIGHT", 0, 0)
		 b:SetBackdrop({
			bgFile = "Interface/CHATFRAME/ChatFrameTab",
			edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
			tile = "false",
			tileSize = 64,
			edgeSize = 10,
			insets = {left = 3, right = 3, top = 3, bottom = 3}
			})
		--b:SetNormalTexture("Interface/CHATFRAME/ChatFrameTab")
		b:SetText("Options")	
		b:RegisterForClicks("LeftButtonUp")
		b:SetNormalFontObject("GameFontNormalSmall")
		b:SetHighlightFontObject("GameFontWhiteSmall")
		b:SetScript("OnClick", function(self)
			SLFG_GUI_Panel1:Hide()
			SLFG_GUI_Panel2:Hide()
			SLFG_GUI_Panel3:Show()
			end)
]]		
	---------------
	-- LFG PANEL --
	---------------
	
	panel = SLFG_CreatePanel("_Panel1", mainFrame)
		panel:SetPoint("TOPLEFT", SLFG_GUI_LFGButton, "BOTTOMLEFT", 0, 0)
		panel:Show()
	
	fs = panel:CreateFontString("SLFG_RoleText")
		fs:SetFontObject("GameFontNormal")
		fs:SetJustifyH("RIGHT")
		--fs:SetWidth(30)
		fs:SetText("Role")
		fs:SetPoint("TOPLEFT", SLFG_GUI_Panel1, "TOPLEFT", 10, -15)
		
	dm = CreateFrame("FRAME", "SLFG_RoleMenu", panel, "UIDropDownMenuTemplate")
		dm:SetPoint("LEFT", SLFG_RoleText, "RIGHT", -10, -2)
		UIDropDownMenu_SetWidth(dm, 70)
		UIDropDownMenu_Initialize(dm, SLFG_RoleMenu_Init)
		
	cb = CreateFrame("CHECKBUTTON", mainFrame:GetName().."_InfoCheck", panel, "OptionsCheckButtonTemplate")
		cb:SetSize(20,20)
		cb:SetPoint("TOPLEFT", fs, "BOTTOMLEFT", 0, -12)
		cb:SetScript("OnClick", function(self)
				if self:GetChecked() then
					SLFG_Options.postCharInfo = true
				else
					SLFG_Options.postCharInfo = false
				end
				SLFG_UpdateMsg()
			end)
		if SLFG_Options["postCharInfo"] == true then
			cb:SetChecked(true)
		end	
	
	fs = panel:CreateFontString("SLFG_InfoCheck")
				fs:SetFontObject("GameFontNormal")
				fs:SetJustifyH("RIGHT")
				fs:SetText("Add Character Info")
				fs:SetPoint("LEFT", cb, "RIGHT", 0, 0)
	
	---------------
	-- LFM Panel --
	---------------
	panel = SLFG_CreatePanel("_Panel2", mainFrame)
		panel:SetPoint("TOPLEFT", SLFG_GUI_LFGButton, "BOTTOMLEFT", 0, 0)
		panel:Hide()
	
	fs = panel:CreateFontString("SLFG_LFMText")
		fs:SetFontObject("GameFontNormal")
		fs:SetJustifyH("RIGHT")
		fs:SetWidth(60)
		fs:SetText("Need: ")
		fs:SetPoint("LEFT", SLFG_GUI_Panel2, "LEFT", 0, 0)
	
	dm = CreateFrame("FRAME", "SLFG_LFMMenu", panel, "UIDropDownMenuTemplate")
		dm:SetPoint("LEFT", SLFG_LFMText, "RIGHT", 0, -2)
		UIDropDownMenu_SetWidth(dm, 40)
		UIDropDownMenu_Initialize(dm, SLFG_LFMMenu_Init)
	
		
	cb = CreateFrame("CHECKBUTTON", mainFrame:GetName().."_TankCheck", panel, "UIRadioButtonTemplate")
		cb:SetPoint("TOPLEFT", panel, "TOP", 10, -10)
		cb:SetScript("OnClick", function(self)
				if self:GetChecked() then
					SLFG_Options.needTank = true
				else
					SLFG_Options.needTank = false
				end
				SLFG_UpdateMsg()
			end)
		cb:SetChecked(SLFG_Options.needTank)
			
	fs = panel:CreateFontString("SLFG_TankText")
		fs:SetFontObject("GameFontNormal")
		fs:SetJustifyH("LEFT")
		--fs:SetWidth(60)
		fs:SetText("Tank")
		fs:SetPoint("LEFT", cb, "RIGHT", 5, 0)
		
	cb = CreateFrame("CHECKBUTTON", mainFrame:GetName().."_HealerCheck", panel, "UIRadioButtonTemplate")
		cb:SetPoint("TOPLEFT", SLFG_GUI_TankCheck, "BOTTOMLEFT", 0, -2)
		cb:SetScript("OnClick", function(self)
				if self:GetChecked() then
					SLFG_Options.needHeal = true
				else
					SLFG_Options.needHeal = false
				end
				SLFG_UpdateMsg()
			end)
		cb:SetChecked(SLFG_Options.needHeal)
			
	fs = panel:CreateFontString("SLFG_HealerText")
		fs:SetFontObject("GameFontNormal")
		fs:SetJustifyH("LEFT")
		--fs:SetWidth(60)
		fs:SetText("Healer")
		fs:SetPoint("LEFT", cb, "RIGHT", 5, 0)
		
	cb = CreateFrame("CHECKBUTTON", mainFrame:GetName().."_DPSCheck", panel, "UIRadioButtonTemplate")
		cb:SetPoint("TOPLEFT", SLFG_GUI_HealerCheck, "BOTTOMLEFT", 0, -2)
		cb:SetScript("OnClick", function(self)
				if self:GetChecked() then
					SLFG_Options.needDPS = true
				else
					SLFG_Options.needDPS = false
				end
				SLFG_UpdateMsg()
			end)
		cb:SetChecked(SLFG_Options.needDPS)
			
	fs = panel:CreateFontString("SLFG_HealerText")
		fs:SetFontObject("GameFontNormal")
		fs:SetJustifyH("LEFT")
		--fs:SetWidth(60)
		fs:SetText("DPS")
		fs:SetPoint("LEFT", cb, "RIGHT", 5, 0)
		
	-------------------
	-- Options Panel --
	-------------------
	
	--panel = SLFG_CreatePanel("_Panel3", mainFrame)
	---	panel:SetPoint("TOPLEFT", SLFG_GUI_LFGButton, "BOTTOMLEFT", 0, 0)
	--	panel:Hide()
			
	
	SLFG_GUIToggle()
end

	----------------
	-- GUI TOGGLE --
	----------------
function SLFG_GUIToggle(self, button)
	if not SLFG_GUI then SLFG_CreateGUI() return end
	if button == "LeftButton" then
		if SLFG_GUI:IsShown() then 
			SLFG_GUI:Hide()
		else
			SLFG_GUI:Show()
		end
	elseif button == "RightButton" then
		SLFG_PostMsg()
	end
end

	--------------------
	-- DROPDOWN INITS --
	--------------------
	
function SLFG_DungeonMenu_Init(self)
	local info = UIDropDownMenu_CreateInfo()
	for i = 1,#SLFG_DungeonList do
		info.text = SLFG_DungeonList[i]
		info.value = i-1		-- value should start at 0
		info.func = SLFG_DungeonMenuClick
		info.owner = self
		info.checked = nil
		info.icon = nil
		UIDropDownMenu_AddButton(info)
	end
end	



function SLFG_RoleMenu_Init(self)
	local info = UIDropDownMenu_CreateInfo()
	
	info.text = "Tank"
	info.value = 0
	info.func = SLFG_RoleMenuClick
	info.owner = self
	info.checked = nil
	info.icon = nil
	UIDropDownMenu_AddButton(info)
	
	info.text = "Healer"
	info.value = 1
	info.func = SLFG_RoleMenuClick
	info.owner = self
	info.checked = nil
	info.icon = nil
	UIDropDownMenu_AddButton(info)
	
	info.text = "DPS"
	info.value = 2
	info.func = SLFG_RoleMenuClick
	info.owner = self
	info.checked = nil
	info.icon = nil
	UIDropDownMenu_AddButton(info)
	
end
	
function SLFG_LFMMenu_Init(self)
	local info = UIDropDownMenu_CreateInfo()
	
	for i = 1, 5 do
		info.text = i
		info.value = i-1
		info.func = SLFG_LFMMenuClick
		info.owner = self
		info.checked = nil
		info.icon = nil
		UIDropDownMenu_AddButton(info)
	end
end

	-------------------------------
	-- DROPDOWN ONCLICK HANDLERS --
	-------------------------------
	
function SLFG_DungeonMenuClick(self)
	local info = UIDropDownMenu_CreateInfo()
	UIDropDownMenu_SetSelectedValue(self.owner, self.value)
	SLFG_Info.dungeon = string.match(SLFG_DungeonList[self.value+1], "%((.+)%)")
	SLFG_UpdateMsg()
end
	
function SLFG_RoleMenuClick(self)
	UIDropDownMenu_SetSelectedValue(self.owner, self.value)
	if self.value == 0 then
		SLFG_Info.role = "Tank"
	elseif self.value == 1 then
		SLFG_Info.role = "Healer"
	elseif self.value == 2 then
		SLFG_Info.role = "DPS"
	end
	SLFG_UpdateMsg()
end

function SLFG_LFMMenuClick(self)
	UIDropDownMenu_SetSelectedValue(self.owner, self.value)
	SLFG_Info.numLFM = self.value+1
	SLFG_UpdateMsg()
end

function SLFG_ValidateChannel(self)
	if GetChannelName(tostring(SLFG_Info.customChan)) == 0 then
		return 1,0,0
	else
		return 1,1,1
	end
end

	----------------------
	-- MESSAGE HANDLING --
	----------------------
function SLFG_UpdateMsg()
	local var = SLFG_Info
	
	if SLFG_Settings.curPanel == "lfg" then
		var.msgLFG = "[".. var.role.. "] "		
		if SLFG_Options.postCharInfo == true then 
			var.msgLFG = var.msgLFG.. UnitLevel("player").. " ".. UnitClass("player").. " "
		end
		var.msgLFG = var.msgLFG.. "LFG ".. var.dungeon
		SLFG_MessageBox:SetText(var.msgLFG)
	else
		var.msgLFM = "LF".. var.numLFM.. "M "
		if SLFG_Options.needTank == true then
			var.msgLFM = var.msgLFM.. "TANK "
		end
		if SLFG_Options.needHeal == true then
			var.msgLFM = var.msgLFM.. "HEALS "
		end
		if SLFG_Options.needDPS == true then
			var.msgLFM = var.msgLFM.. "DPS "
		end
		var.msgLFM = var.msgLFM.. var.dungeon	
		SLFG_MessageBox:SetText(var.msgLFM)
	end
end

	-------------
	-- POSTING --
	-------------
function SLFG_PostMsg()
	local id = 0
	local msg = SLFG_MessageBox:GetText()
	if SLFG_Options.general == true then 
		SendChatMessage(msg, "CHANNEL", nil, 1)
		--SendChatMessage("GENERAL: ".. msg, "WHISPER", nil, "AddonTest")
	end
	if SLFG_Options.lfg == true then
		 id = GetChannelName("LookingForGroup")
		 SendChatMessage(msg, "CHANNEL", nil, id)
		 --SendChatMessage("LFG: ".. msg, "WHISPER", nil, "AddonTest")
	end
	if SLFG_Options.guild == true then 
		 SendChatMessage(msg, "GUILD")
		 --SendChatMessage("GUILD: ".. msg, "WHISPER", nil, "AddonTest")
	end
	if SLFG_Options.custom == true then
		id = GetChannelName(tostring(SLFG_Info.customChan))
		if id == 0 then
			print("|cFFFF0000SLFG: No valid custom channel found.|r")
			print("Please check the spelling, number and/or if you have joined the requested channel.")
		else
			SendChatMessage(msg, "CHANNEL", nil, id)
		end
	end
end

	----------------
	-- LDB MODULE --
	----------------
	local ldb = LibStub("LibDataBroker-1.1"):NewDataObject("SLFG", {
	type = "data source",
	text = "SLFG", 
	--icon = "Interface/LFGFRAME/BattlenetWorking0",
	icon = "Interface/Addons/SLFG/icon",
	OnClick = function(self, button) SLFG_GUIToggle(self, button) end,
	OnEnter = function(self) 
		GameTooltip:SetOwner(self, "ANCHOR_TOP")
		GameTooltip:AddDoubleLine("SLFG", "1.3");
		GameTooltip:AddLine("|cff00FF00Left Click|r: Toggle Config",1,1,1)
		GameTooltip:AddLine("|cff00FF00Right Click|r: Post Current Message",1,1,1)
		GameTooltip:AddLine(" ")
		if SLFG_MessageBox then
			GameTooltip:AddLine("|cFF00FF00Current Message:|r ".. SLFG_MessageBox:GetText(),1,1,1)
		else
			GameTooltip:AddLine("|cFF00FF00Current Message:|r ".. SLFG_Info.msgLFG,1,1,1)
		end
		GameTooltip:Show()
		end		
	})
