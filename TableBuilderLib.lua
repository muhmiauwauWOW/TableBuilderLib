local lib = LibStub:NewLibrary("TableBuilderLib", 1)
local _ = LibStub("LibLodash-1"):Get()




if not lib then
   return	-- already loaded and no upgrade necessary
end

local i = 0
local function getTableName(name)
   if name then return "TableBuilderLibTableFrame" .. name end

   i = i + 1
   return "TableBuilderLibTableFrame" .. i
end





--lib:Setup("TableBuilderLibTableHeaderTemplate", "TableBuilderLibTableLineTemplate", "TableBuilderLibTableCellTemplate")

function lib:Setup(headerTemplate, rowTemplate, cellTemplate)
   self.headerTemplate = headerTemplate--"TableBuilderLibTableHeaderTemplate"
   self.rowTemplate = rowTemplate--"TableBuilderLibTableLineTemplate"
   self.cellTemplate = cellTemplate--"TableBuilderLibTableCellTemplate"
end





function lib:New(name, parentFrame, config, columnsConfig, data)
   assert(self.headerTemplate, string.format("Header Template '%s' not found", self.headerTemplate or ""));
   assert(self.rowTemplate, string.format("Row Template '%s' not found", self.rowTemplate or ""));
   assert(self.cellTemplate, string.format("Cell Template '%s' not found", self.cellTemplat or ""));

   parentFrame = parentFrame or UIParent





--    <Frame name="TableBuilderLibTableFrame" mixin="TableBuilderLibTableMixin" enableMouse="true"  virtual="true">
--    <Frames>
--       <Frame parentKey="HeaderContainer" >
--          <Size x="0" y="19"/>
--          <Anchors>
--             <Anchor point="TOPLEFT" x="0" y="0"/>
--             <Anchor point="TOPRIGHT" x="-26" y="0"/>
--          </Anchors>
--       </Frame>
--       <Frame parentKey="ScrollBox" inherits="WowScrollBoxList">
--          <Anchors>
--             <Anchor point="TOPLEFT" relativeKey="$parent.HeaderContainer" relativePoint="BOTTOMLEFT" x="0" y="-6"/>
--             <Anchor point="RIGHT" relativeKey="$parent.HeaderContainer" relativePoint="RIGHT"/>
--             <Anchor point="BOTTOM" x="0" y="0"/>
--          </Anchors>
--       </Frame>
--       <EventFrame parentKey="ScrollBar" inherits="MinimalScrollBar">
--          <Anchors>
--             <Anchor point="TOPLEFT" relativeKey="$parent.ScrollBox" relativePoint="TOPRIGHT" x="9" y="0"/>
--             <Anchor point="BOTTOMLEFT" relativeKey="$parent.ScrollBox" relativePoint="BOTTOMRIGHT" x="9" y="4"/>
--          </Anchors>
--       </EventFrame>
--    </Frames>
--    <Scripts>
--       <OnLoad method="OnLoad"/>
--    </Scripts>
-- </Frame>



   local f = CreateFrame("Frame", getTableName(name), parentFrame)-- "TableBuilderLibTableFrame")
   f:SetAllPoints()


   f.HeaderContainer = CreateFrame("Frame", nil, f)
   f.HeaderContainer:SetPoint("TOPLEFT", 0, 0)
   f.HeaderContainer:SetPoint("TOPRIGHT", -26, 0)
   f.HeaderContainer:SetHeight(19)
   
   f.ScrollBox = CreateFrame("Frame", nil, f, "WowScrollBoxList")
   f.ScrollBox:SetPoint("TOPLEFT", f.HeaderContainer, "BOTTOMLEFT", 0, -6)
   f.ScrollBox:SetPoint("RIGHT", f.HeaderContainer, "RIGHT", 0,0)
   f.ScrollBox:SetPoint("BOTTOM",  0,0)

   f.ScrollBar = CreateFrame("EventFrame", nil, f, "MinimalScrollBar")
   f.ScrollBar:SetPoint("TOPLEFT", f.ScrollBox, "TOPRIGHT", 9, 0)
   f.ScrollBar:SetPoint("BOTTOMLEFT", f.ScrollBox, "BOTTOMRIGHT", 9,4)

   f = Mixin(f, TableBuilderLibTableMixin)
   f:OnLoad()
  
   f:SetAllPoints()

   f.headerTemplate = self.headerTemplate
   f.rowTemplate = self.rowTemplate
   f.cellTemplate = self.cellTemplate

   
   _.forEach(config, function(value, key)
      if f[key] then 
         f[key] = value
      end
   end)


   f.data = data or {}
   f.columnsConfig = columnsConfig or {}
   f:Init()
   f:RefreshScrollFrame()

   return f
end


function lib:SetData(name, config)
   local name = getTableName(name)
   local table = _G[name]
   assert(table.TableBuilderLib, string.format("%s is not a valid TableBuilderLib table", name));
   table:SetData(config)
end


function lib:AddColumn(name, config)
   local name = getTableName(name)
   local table = _G[name]
   assert(table.TableBuilderLib, string.format("%s is not a valid TableBuilderLib table", name));
   table:AddColumn(config)
end


function lib:RemoveColumn(name, id)
   local name = getTableName(name)
   local table = _G[name]
   assert(table.TableBuilderLib, string.format("%s is not a valid TableBuilderLib table", name));
   table:RemoveColumn(id)
end


function lib:GetColumns(name)
   local name = getTableName(name)
   local table = _G[name]
   assert(table.TableBuilderLib, string.format("%s is not a valid TableBuilderLib table", name));
   return table.columIdMap
end



function lib:ReorderColumns(name, cols)
   local name = getTableName(name)
   local table = _G[name]
   assert(table.TableBuilderLib, string.format("%s is not a valid TableBuilderLib table", name));
   table:ReorderColumns(CopyTable(cols))
end



