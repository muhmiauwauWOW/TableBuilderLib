local lib = LibStub:NewLibrary("TableBuilderLib", 1)
local _ = LibStub("LibLodash-1"):Get()



if not lib then
   return	-- already loaded and no upgrade necessary
end





local i = 0

function lib:New(name, parentFrame, columnsConfig, data)
   i = i + 1
   name = name or ("TableBuilderLibTableFrame" .. i)
   parentFrame = parentFrame or parentFrame


   DevTool:AddData(data, "data")

   local f = CreateFrame("Frame", "TableBuilderLibTableFrame" .. name, parentFrame or UIParent, "TableBuilderLibTableFrame")
   f:SetAllPoints()
   f.data = data or {}
   f.columnsConfig = columnsConfig or {}
   f:Init()
   f:RefreshScrollFrame()

   return f
end




lib.columnConfigDefault = {
   -- Id = nil,
   -- width = 100,
   headerText = "",
   -- padding = 0,
   -- template = nil
}


function lib:getColumnConfig()
   return CopyTable(lib.columnConfigDefault)
end




