local NibTweaks = CreateFrame("Frame")

--Options menu config
NibTweaks.options = {
	TooltipAnchorCursor = {
		description = "Anchor tooltip to cursor",
		default = true,
	},
	SortBagsRightToLeft = {
		description = "Sort bags right to left",
		default = true,
	},
	InsertItemsLeftToRight = {
		description = "Insert items left to right",
		default = true,
	},
	VendorGreys = {
		description = "Vendor greys when opening vendor",
		default = true,
	},
	AutoRepair = {
		description = "Repairs when opening a vendor",
		default = true,
	}
}

function NibTweaks:OnEvent(event, properties)
	if event == "ADDON_LOADED" and properties == "NibTweaks" then
		self:SetupOptions()
		self:SetTweaks()
	end
	if event == "MERCHANT_SHOW" then
		self:CleanupInventory()
	end
end

function NibTweaks:SetupOptions()
	--Setup options panel
	self.optionsPanel = CreateFrame("Frame")
	self.optionsPanel.name = "NibTweaks"
	
	y = -20
	for key, option in pairs(self.options) do
		--Set defualt value
		if NibTweaksDB[key] == nil then
			NibTweaks[key] = option.default
		end
	
		--add option to interface
		local cb = CreateFrame(
			"CheckButton",
			nil,
			self.optionsPanel,
			"InterfaceOptionsCheckButtonTemplate"
		)
		cb:SetPoint("TOPLEFT", 20, y)
		cb.Text:SetText(option.description)
		cb:SetChecked(NibTweaksDB[key])
		cb:SetScript(
			"OnClick",
			function(self)
				NibTweaksDB[key] = self:GetChecked()
				NibTweaks:SetTweaks()
			end
		)
		y = y - 40
	end

	--Add options panel to main menu
	InterfaceOptions_AddCategory(self.optionsPanel)
end

function NibTweaks:SetTweaks()
	if NibTweaksDB.TooltipAnchorCursor then
		hooksecurefunc(
			"GameTooltip_SetDefaultAnchor", 
			function(s,p)
				s:SetOwner(p,"ANCHOR_CURSOR")
			end
		)
	end
	C_Container.SetSortBagsRightToLeft(NibTweaksDB.SortBagsRightToLeft)
	C_Container.SetInsertItemsLeftToRight(NibTweaksDB.InsertItemsLeftToRight)
end

function NibTweaks:CleanupInventory()
	if NibTweaksDB.VendorGreys then
		for bag = 0, 4 do
			for slot = 1, C_Container.GetContainerNumSlots(bag) do
				itemInfo = C_Container.GetContainerItemInfo(bag, slot)
				if itemInfo and itemInfo.quality == 0 then
					link = C_Container.GetContainerItemLink(bag, slot)
					DEFAULT_CHAT_FRAME:AddMessage("Selling: "..link.."x"..tostring(itemInfo.stackCount))
					C_Container.UseContainerItem(bag, slot)
				end
			end
		end
	end
	if NibTweaksDB.AutoRepair then
		DEFAULT_CHAT_FRAME:AddMessage("Repairing All Items")
		RepairAllItems()
	end
end

NibTweaks:RegisterEvent("ADDON_LOADED")
NibTweaks:RegisterEvent("MERCHANT_SHOW")
NibTweaks:SetScript("OnEvent", NibTweaks.OnEvent)
