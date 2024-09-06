------
-- TableBuilderLib easy way to build performat tables
-- @script TableBuilderLib

--- module version.
local version = "@project-version@"
local versionObj = {}

for w in string.gmatch(version, "[0-9]*") do
    if w ~= "" then 
        table.insert(versionObj, w)
    end
end

if #versionObj == 0 then
    versionObj = {1, 1}
end

local LibLodash = LibStub:NewLibrary("LibLodash-" .. versionObj[1], versionObj[2])

local lib = LibStub:NewLibrary("TableBuilderLib-" .. versionObj[1], versionObj[2])
local _ = LibStub("LibLodash-1"):Get()

-- already loaded and no upgrade necessary
if not lib then
   return
end






--lib:Setup("TableBuilderLibHeaderTemplate", "TableBuilderLibLineTemplate", "TableBuilderLibCellTemplate")

-----
-- Setup function
-- @string name
-- @string headerTemplate
-- @string rowTemplate
-- @string cellTemplate
-- @treturn TableBuilderLibObj
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
   local tableName = "TableBuilderLibFrames_" .. sname .. "_" .. name
   local table = _G[tableName]
   assert(table, string.format("%s table not found", tableName));
   assert(table.TableBuilderLib, string.format("%s is not a valid TableBuilderLib table", tableName));
   return table
end




--- create an new table
-- @tparam string name  the descriptddddion of this parameter as verbose text
-- @tparam table parentFrame
-- @tparam table config
-- @tparam table columnsConfig
-- @tparam table data 
--
function lib:New(name, parentFrame, config, columnsConfig, data)
   assert(self.headerTemplate, string.format("Header Template '%s' not found", self.headerTemplate or ""));
   assert(self.rowTemplate, string.format("Row Template '%s' not found", self.rowTemplate or ""));
   assert(self.cellTemplate, string.format("Cell Template '%s' not found", self.cellTemplat or ""));


   config = config and CopyTable(config) or {}
   columnsConfig = columnsConfig and CopyTable(columnsConfig) or {}
   data = data and CopyTable(data) or {}

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


   local tableName =  getTableName(name)
   local f = CreateFrame("Frame", tableName, parentFrame)
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
      f.dev:SetPoint("TOPLEFT", f, "TOPRIGHT", 0, 0)
      f.dev.name = name 
   end

   return self
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


function lib:SetColumnsConfig(name, ColumnConfig)
   local table = getTable(name, self.name)
   return table:SetColumnsConfig(ColumnConfig)
end



function lib:ReorderColumns(name, cols)
   local table = getTable(name, self.name)
   table:ReorderColumns(CopyTable(cols))
end




function lib:GetWidth(name)
   local table = getTable(name, self.name)
   return table:GetWidth()
end



function lib:SetSelectedRow(name, row)
   local table = getTable(name, self.name)
   table:SetSelectedRow(row)
end



function lib:ScrollToEntryIndex(name, index)
   local table = getTable(name, self.name)
   table:ScrollToEntryIndex(index)
end





