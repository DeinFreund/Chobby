--//=============================================================================

TabBar = LayoutPanel:Inherit{
  classname    = "tabbar",
  orientation  = "horizontal",
  resizeItems  = false,
  centerItems  = false,
  padding      = {0, 0, 0, 0},
  itemPadding  = {0, 0, 0, 0},
  itemMargin   = {0, 0, 0, 0},
  minItemWidth  = 70,
  minItemHeight = 20,
  tabs         = {},
  selected     = nil,
  preserveChildrenOrder = true,
  OnChange     = {},
}

local this = TabBar
local inherited = this.inherited

--//=============================================================================

function TabBar:New(obj)
	obj = inherited.New(self,obj)
	if (obj.tabs) then
		for i=1,#obj.tabs do
			obj:AddChild(
				TabBarItem:New{name = obj.tabs[i].name, caption = obj.tabs[i].caption or obj.tabs[i].name, defaultWidth = obj.minItemWidth, defaultHeight = obj.minItemHeight} --FIXME inherit font too
			)
		end
	end

	if obj.children[1] then
		obj:Select(obj.selected)
		self.selected = 1
	end

	return obj
end

--//=============================================================================

function TabBar:SetOrientation(orientation)
  inherited.SetOrientation(self,orientation)
end

--//=============================================================================
function TabBar:DisableHighlight()
	for i = 1, #self.children do
		local c = self.children[i]
		c.state.selected = false
		c:Invalidate()
	end
end

function TabBar:EnableHighlight()
	if self.selected_obj then
		self.selected_obj.state.selected = true
		self.selected_obj:Invalidate()
	end
end

function TabBar:Select(tabname)
	for i = 1, #self.children do
		local c = self.children[i]
		if c.name == tabname then
			if self.selected_obj then
				self.selected_obj.state.selected = false
				self.selected_obj:Invalidate()
			end
			c.state.selected = true
			self.selected = i
			self.selected_obj = c
			c:Invalidate()
			self:CallListeners(self.OnChange, tabname)
			return true
		end
	end

	if not self.selected_obj then
		local c = self.children[1]
		c.state.selected = true
		self.selected = 1
		self.selected_obj = c
		self.selected_obj:Invalidate()
		self:CallListeners(self.OnChange, c.name)
	end

	return false
end


function TabBar:Remove(tabname, updateSelection)
	for i = 1, #self.children do
		local c = self.children[i]
		if c.name == tabname then
			c:Dispose()
			-- selects next tab
			if updateSelection then
				c = self.children[math.min(i, #self.children)]
				self:Select(c.name)
			else
				self.selected_obj = nil
				self.selected = nil
			end
			return true
		end
	end

	return false
end
--//=============================================================================
