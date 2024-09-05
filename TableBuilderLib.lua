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





function lib:New(name, parentFrame, columnsConfig, data)
   parentFrame = parentFrame or UIParent
   local f = CreateFrame("Frame", getTableName(name), parentFrame or UIParent, "TableBuilderLibTableFrame")
   f:SetAllPoints()
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