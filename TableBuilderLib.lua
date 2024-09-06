local lib = LibStub:NewLibrary("TableBuilderLib", 1)
local _ = LibStub("LibLodash-1"):Get()




if not lib then
   return	-- already loaded and no upgrade necessary
end






--lib:Setup("TableBuilderLibHeaderTemplate", "TableBuilderLibLineTemplate", "TableBuilderLibCellTemplate")

function lib:Setup(name, headerTemplate, rowTemplate, cellTemplate)
   local l = CopyTable(self)
   l.name = name
   l.frameCounter = 0
   l.headerTemplate = headerTemplate
   l.rowTemplate = rowTemplate
   l.cellTemplate = cellTemplate

   return l
end


local function getTable(name, sname)
   local name = "TableBuilderLibFrames_" .. sname .. "_" .. name
   local table = _G[name]
   assert(table, string.format("%s table not found", name));
   assert(table.TableBuilderLib, string.format("%s is not a valid TableBuilderLib table", name));
   return table
end











function lib:New(name, parentFrame, config, columnsConfig, data)
   assert(self.headerTemplate, string.format("Header Template '%s' not found", self.headerTemplate or ""));
   assert(self.rowTemplate, string.format("Row Template '%s' not found", self.rowTemplate or ""));
   assert(self.cellTemplate, string.format("Cell Template '%s' not found", self.cellTemplat or ""));


   config = CopyTable(config) or {}
   columnsConfig = CopyTable(columnsConfig) or {}
   data = CopyTable(data) or {}

   local function getTableName(name)
      local tableName = "TableBuilderLibFrames_" .. self.name .. "_" .. name
      local check = _G[tableName]
      assert(check == nil, string.format("Table with the name '%s' already exits", name));
      if check then return nil end

      if name then return tableName end

      
   
      self.frameCounter =  self.frameCounter + 1
      return "TableBuilderLibFrames_" .. self.name .. "_" .. self.frameCounter
   end

   parentFrame = parentFrame or UIParent
   local headerHeight = config.headerHeight or 19


   local f = CreateFrame("Frame", getTableName(name), parentFrame)
   f:SetAllPoints()
   f.HeaderContainer = CreateFrame("Frame", nil, f)
   f.HeaderContainer:SetPoint("TOPLEFT", 0, 0)
   f.HeaderContainer:SetPoint("TOPRIGHT", -26, 0)
   f.HeaderContainer:SetHeight(headerHeight)
   f.ScrollBox = CreateFrame("Frame", nil, f, "WowScrollBoxList")
   f.ScrollBox:SetPoint("TOPLEFT", f.HeaderContainer, "BOTTOMLEFT", 0, -6)
   f.ScrollBox:SetPoint("RIGHT", f.HeaderContainer, "RIGHT", 0,0)
   f.ScrollBox:SetPoint("BOTTOM",  0,0)
   f.ScrollBar = CreateFrame("EventFrame", nil, f, "MinimalScrollBar")
   f.ScrollBar:SetPoint("TOPLEFT", f.ScrollBox, "TOPRIGHT", 9, 0)
   f.ScrollBar:SetPoint("BOTTOMLEFT", f.ScrollBox, "BOTTOMRIGHT", 9,4)
   f = Mixin(f, TableBuilderLibTableMixin)

   f:OnLoad()
  
   f.headerTemplate = self.headerTemplate
   f.rowTemplate = self.rowTemplate
   f.cellTemplate = self.cellTemplate

   
   _.forEach(config, function(value, key)
      if f[key] then
         f[key] = value
      end
   end)

   f.data = data
   f.columnsConfig = columnsConfig
   f:Init()
   f:RefreshScrollFrame()



   if self.name == "Dev" then
      f.dev = CreateFrame("Frame", nil, f, "TableBuilderLibDev")
      DevTools_Dump( f.dev)
      f.dev:SetPoint("TOPLEFT", f, "TOPRIGHT", 0, 0)
      f.dev.name = name 
   end

   return f
end


function lib:SetData(name, config)
   local table = getTable(name, self.name)
   table:SetData(config)
end


function lib:AddColumn(name, config)
   local table = getTable(name, self.name)
   table:AddColumn(config)
end


function lib:RemoveColumn(name, id)
   local table = getTable(name, self.name)
   table:RemoveColumn(id)
end


function lib:GetColumns(name)
   local table = getTable(name, self.name)
   return table.columIdMap
end



function lib:ReorderColumns(name, cols)
   local table = getTable(name, self.name)
   table:ReorderColumns(CopyTable(cols))
end




function lib:GetWidth(name)
   local table = getTable(name, self.name)
   return table:GetWidth()
end


