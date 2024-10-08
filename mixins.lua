local _ = LibStub("LibLodash-1"):Get()




local columnConfigDefault = {
    id = nil,
    width = "fill",
    headerText = "",
    padding = 0,
    template = nil,
    sortable = false
 }
 



TableBuilderLibTableMixin = {}

function TableBuilderLibTableMixin:OnLoad()
    self.isInitialized = false
    self.TableBuilderLib = true

    self.headerTemplate = nil
    self.cellTemplate = nil
    self.rowTemplate = nil

    self.data = {}
    self.columnsConfig = {}
    self.columnsConfigObj = {}
    self.columIdMap = {}
    self.tableData = {}

    self.sort = 1
    self.sortReverse = false


    -- self:Init()
end

function TableBuilderLibTableMixin:Init()

    
 
    local tableBuilder = CreateTableBuilder({});
    self.tableBuilder = tableBuilder;
 
   
    function self.getNumElements(index)
          return #self.tableData;
      end;
     function self.getElement(index)
         return self.tableData[index];
     end;
 
    self.tableBuilder:SetDataProvider(self.getElement);
    -- self.tableBuilderLayoutFunction(self:GetTableLayout(f, self.data));
 
 
    self.tableBuilder:SetColumnHeaderOverlap(2);
    self.tableBuilder:SetHeaderContainer(self.HeaderContainer);

    _.forEach(self.columnsConfig, function(columnConfigObj, idx)
        assert(columnConfigObj.id, "ColumnConfig id need to be set");
        table.insert(self.columIdMap,  columnConfigObj.id)
        self:AddColumn(columnConfigObj, true)
    end)


 
    local view = CreateScrollBoxListLinearView();
    view:SetElementFactory(function(factory, elementData)
        local function Initializer(button, elementData)
            if self.highlightCallback then
                local rowData = button.rowData;
                elementData = self.highlightCallback(rowData, self.selectedRowData, elementData);
            end
        end
        factory(self.rowTemplate, Initializer);
    end);
 
    ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);
     
    local function ElementDataTranslator(elementData)
        return elementData;
    end;
    ScrollUtil.RegisterTableBuilder(self.ScrollBox, self.tableBuilder, ElementDataTranslator);
 
    self:SetData(self.data, true)
 
     
    self:CreateHeaders()

    self.tableBuilder:SetTableWidth(self.ScrollBox:GetWidth());
    self.tableBuilder:Arrange();
    self:RefreshScrollFrame()


    self.isInitialized = true
end




function TableBuilderLibTableMixin:SetData(data, internal)
    if not data then return end

    
    -- DevTool:AddData(data, "SetData")

    self.data = data
    

    self:UpdateTableData()
   

    -- stop here if internal add
    if internal then return end 
    --self.tableBuilder:Arrange();
    self:RefreshScrollFrame()
end

function TableBuilderLibTableMixin:addColumnToMap(colId)
    local check = _.find(self.columIdMap, function(e) return e == colId end)
    if not check then 
        table.insert(self.columIdMap, colId)
    end

end


function TableBuilderLibTableMixin:UpdateTableData()
    local data = self.data
    local newData = {}

   local columns = self.tableBuilder:GetColumns();

    _.forEach(columns, function(column)
        self:addColumnToMap(column.config.id)
    end)

    _.forEach(data, function(row)
        local newRow = {}
        _.forEach(self.columIdMap, function(key)
            table.insert(newRow, row[key])
        end)
        table.insert(newData, newRow)
    end)

	self.tableData = newData
end


function TableBuilderLibTableMixin:AddColumn(columnConfigObj, internal)
    -- local columnConfig = columnConfigObj
    -- _.forEach(columnConfigDefault, function(entry, key)
    --     columnConfig[key] = columnConfigObj[key] and columnConfigObj[key] or entry
    -- end)

    -- table.insert(self.columnsConfigObj, columnConfig)

    local columnConfig = self:SetColumnsConfigEntry(columnConfigObj)


    if not internal then

        local test = _.find(self.columIdMap, function(e) return e == columnConfigObj.id end)
        assert(test == nil, string.format("ColumnConfig %s already exits", columnConfigObj.id));
        assert(columnConfigObj.id, "ColumnConfig id need to be set");

    end
	
    
	
    columnConfig.id = columnConfigObj.id
    
    columnConfig.cellTemplate = columnConfig.cellTemplate or self.cellTemplate
    columnConfig.sortable = columnConfig.sortable and true or false

  

    if type(columnConfig.width) == "number" then 
        self:AddFixedWidthColumn(self, 0, columnConfig.width, columnConfig.padding, columnConfig.padding, columnConfig.sortable, columnConfig.cellTemplate, columnConfig, columnConfig.headerText);
    else 
        if columnConfig.width == "double" then 
            columnConfig.width = 2
        elseif columnConfig.width == "half" then 
            columnConfig.width = 0.5
        elseif columnConfig.width == "triple" then 
            columnConfig.width = 3
        else 
            columnConfig.width = 1
        end

        self:AddFillColumn(self, 0, columnConfig.width, columnConfig.padding, columnConfig.padding, columnConfig.sortable, columnConfig.cellTemplate, columnConfig, columnConfig.headerText);
    end


    self.columnsConfigObj[#self.columnsConfigObj] = columnConfig


    

    -- stop here if internal add
    if internal then return end 
    self:UpdateTableData()

    self:CreateHeaders()
    
    --self.tableBuilder:SetTableWidth(self.ScrollBox:GetWidth());
    self.tableBuilder:Arrange();

    self:RefreshScrollFrame()
end


function TableBuilderLibTableMixin:SetColumnsConfig(ColumnConfig)
    ColumnConfig = ColumnConfig and CopyTable(ColumnConfig) or {}

    self.columnsConfigObj = {}
    self.columIdMap = {}
    _.forEach(ColumnConfig, function(entry, idx)
        table.insert(self.columIdMap,  entry.id)
        self:AddColumn(entry, true)
    end)

   self:UpdateTableData()
   self:CreateHeaders()    
   self.tableBuilder:Arrange();
   self:RefreshScrollFrame()
end

function TableBuilderLibTableMixin:SetColumnsConfigEntry(columnConfigEntry, idx)

    local columnConfig = columnConfigEntry
    _.forEach(columnConfigDefault, function(entry, key)
        columnConfig[key] = columnConfigEntry[key] and columnConfigEntry[key] or entry
    end)

    columnConfig = CopyTable(columnConfig)

    if idx then 
        self.columnsConfigObj[idx] = columnConfig
    else 
        table.insert(self.columnsConfigObj, columnConfig)
    end

    return columnConfig
end



function TableBuilderLibTableMixin:RemoveColumn(ID)
    local id = _.findIndex(self.columIdMap, function(e) return e == ID end)
    assert(id ~=-1, string.format("Column with id %s not found", ID));
    if id == -1 then return end

    local columns = self.tableBuilder:GetColumns()

    table.remove(self.columIdMap, id)
    local rcol = table.remove(columns, id)
    rcol:Reset()
    local rheader = rcol:GetHeaderFrame()
    self.tableBuilder.headerPoolCollection:Release(rheader)

    local newColumns = {}

    _.forEach(columns, function(col, idx)
        table.insert(newColumns, col)
    end)

    self.tableBuilder.columns = newColumns

    if columns and #columns > 0 then
        self.tableBuilder:CalculateColumnSpacing();
        self.tableBuilder:ArrangeHeaders();
    end

    for index, row in ipairs(self.tableBuilder.rows) do
        self.tableBuilder:ArrangeCells(row);
    end


end

function TableBuilderLibTableMixin:RefreshScrollFrame()
    print("RefreshScrollFrame")
	local numResults = self.getNumElements();
	local dataProvider = CreateIndexRangeDataProvider(numResults);
	self.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition);
end



function TableBuilderLibTableMixin:ReorderColumns(cols)
    self.columIdMap = CopyTable(cols)

    local columns = self.tableBuilder:GetColumns()
    local newColumns = {}
    local newTableData = {}

    _.forEach(self.tableData, function(row, rowIdx)
        local newRow = {}
        _.forEach(self.columIdMap, function(colId)
            local index =  _.findIndex(columns, function(e) return e.config.id == colId end)
            if not index then  return end
            table.insert(newRow, row[index])
        end)
        table.insert(newTableData, newRow)
    end)

    _.forEach(self.columIdMap, function(colId, idx)
        local index =  _.findIndex(columns, function(e) return e.config.id == colId end)
        if not index then  return end
        
        if columns[index] then 
            table.insert(newColumns, columns[index])
        end
    end)

   
    self.tableBuilder.columns = newColumns
    self.tableData = newTableData


    self:CreateHeaders()
    self.tableBuilder:CalculateColumnSpacing();
    self.tableBuilder:ArrangeHeaders();

    for index, row in ipairs(self.tableBuilder.rows) do
        self.tableBuilder:ArrangeCells(row);
    end
    self:RefreshScrollFrame()

end
function TableBuilderLibTableMixin:CreateHeaders()

    -- local headers = {}
    local columns = self.tableBuilder:GetColumns()
    self.tableBuilder.headerPoolCollection:ReleaseAll()
   _.forEach(self.columIdMap, function(id, idx)
        local config = _.find(self.columnsConfigObj, function(e) return e.id == id end)
        columns[idx]:ConstructHeader("Button", self.headerTemplate, self, idx,  config.id,  config.headerText, config.sortable);
        -- if columns[idx].headerFrame then 
        --      headers[idx] = columns[idx].headerFrame 
        -- end
    end)

    -- if _.size(headers) >0 then 
    --     self.tableBuilder:CalculateColumnSpacing();
    --     self.tableBuilder:ArrangeHeaders();
    -- end

end


function TableBuilderLibTableMixin:GetWidth()

    local width = 0
    for header in self.tableBuilder:EnumerateHeaders() do
        width = width + header:GetWidth() + 4
    end
    return width
end




function TableBuilderLibTableMixin:AddColumnInternal(owner, sortable, cellTemplate, config,  headerText,  ...)
	local column = owner.tableBuilder:AddColumn();
    column.config = config

	column:ConstructCells("FRAME", cellTemplate, owner, config, ...);
	return column;
end

function TableBuilderLibTableMixin:AddFixedWidthColumn(owner, padding, width, leftCellPadding, rightCellPadding, sortOrder, cellTemplate, ...)
   local column = self:AddColumnInternal(owner, sortOrder, cellTemplate, ...);
	column:SetFixedConstraints(width, padding);
	column:SetCellPadding(leftCellPadding, rightCellPadding);
	return column;
end


function TableBuilderLibTableMixin:AddFillColumn(owner, padding, fillCoefficient, leftCellPadding, rightCellPadding, sortOrder, cellTemplate, ...)
	local column = self:AddColumnInternal(owner, sortOrder, cellTemplate, ...);
	column:SetFillConstraints(fillCoefficient, padding);
	column:SetCellPadding(leftCellPadding, rightCellPadding);
	return column;
end







function TableBuilderLibTableMixin:SetSortOrder(sortOrder)
	if self.sort == sortOrder then 
		self.reverseSort = not self.reverseSort
	else
		self.sort = sortOrder
		self.reverseSort =  false
	end

    for frame in self.tableBuilder:EnumerateHeaders() do 
        frame:UpdateArrow(self.reverseSort);
    end

	local comp = (self.reverseSort) and _.gt or _.lt
	sort(self.tableData, function(a, b)
		return comp( a[self.sort], b[self.sort])
	end)
	self:RefreshScrollFrame();
end





















function TableBuilderLibTableMixin:SetLineOnEnterCallback(callback)
	self.lineOnEnterCallback = callback;
end

function TableBuilderLibTableMixin:OnEnterListLine(line, rowData)
	if self.lineOnEnterCallback then
		self.lineOnEnterCallback(line, rowData);
	end
end

function TableBuilderLibTableMixin:SetLineOnLeaveCallback(callback)
	self.lineOnLeaveCallback = callback;
end

function TableBuilderLibTableMixin:OnLeaveListLine(line, rowData)
	if self.lineOnLeaveCallback then
		self.lineOnLeaveCallback(line, rowData);
	end
end

function TableBuilderLibTableMixin:SetSelectedEntry(rowData)
	if self.selectionCallback then
		if not self.selectionCallback(rowData) then
			return;
		end
	end

	self.selectedRowData = rowData;
	self:DirtyScrollFrame();
end

function TableBuilderLibTableMixin:GetSelectedEntry()
	return self.selectedRowData;
end


function TableBuilderLibTableMixin:SetSelectionCallback(selectionCallback)
	self.selectionCallback = selectionCallback;
end

function TableBuilderLibTableMixin:SetHighlightCallback(highlightCallback)
	self.highlightCallback = highlightCallback;
end




function TableBuilderLibTableMixin:SetSelectedEntryByCondition(condition, scrollTo)
	if not self.getNumEntries then
		return;
	end

	local numEntries = self.getNumEntries();
	for i = 1, numEntries do
		local rowData = self.getEntry(i);
		if condition(rowData) then
			self:SetSelectedEntry(rowData);
			self:ScrollToEntryIndex(i);
			return;
		end
	end

	self:SetSelectedEntry(nil);
	self:RefreshScrollFrame();
end


function TableBuilderLibTableMixin:ScrollToEntryIndex(entryIndex)
	if not self.isInitialized then
		return;
	end
	self.ScrollBox:ScrollToElementDataIndex(entryIndex, ScrollBoxConstants.AlignCenter);
end

function TableBuilderLibTableMixin:GetScrollBoxDataIndexBegin()
	return self.ScrollBox:GetDataIndexBegin();
end




































--- Default mixins for Templates






TableBuilderLibLineMixin = CreateFromMixins(TableBuilderRowMixin);

function TableBuilderLibLineMixin:GetRowData()
	return self.rowData;
end






TableBuilderLibCellMixin = CreateFromMixins(TableBuilderCellMixin);


function TableBuilderLibCellMixin:Populate(data, index)
    assert( type(data[index]) ~= string, "Cell value should be string, Use custom 'TableBuilderCellMixin' for other types")
    self.Text:SetText(data[index])
end




TableBuilderLibHeaderMixin = CreateFromMixins(TableBuilderElementMixin);



function TableBuilderLibHeaderMixin:OnClick()
    if not self.sortable  then return end
    self.owner:SetSortOrder(self.sortOrder);
end

function TableBuilderLibHeaderMixin:Init(owner, sortOrder, id, headerText, sortable)
    self.sortOrder = sortOrder
    self.id = id
	self:SetText(headerText);
    self.sortable = sortable
    self:EnableMouse(sortable)
    self.owner = owner

    self.Arrow:Hide();

    self:UpdateArrow(owner.sortReverse)
end

function TableBuilderLibHeaderMixin:UpdateArrow(reverse)
	if self.owner.sort == self.sortOrder then 
		self:SetArrowState(reverse)
		self.Arrow:Show();
	else 
		self.Arrow:Hide();
	end
end

function TableBuilderLibHeaderMixin:SetArrowState(reverse)
	if reverse then
		self.Arrow:SetTexCoord(0, 1, 1, 0);
	else 
		self.Arrow:SetTexCoord(0, 1, 0, 1);
	end
end





