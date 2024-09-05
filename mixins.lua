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
    self.TableBuilderLib = true

    self.headerTemplate = "TableBuilderLibTableHeaderTemplate"
    self.cellTemplate = "TableBuilderLibTableCellTemplate"
    self.rowTemplate = "TableBuilderLibTableLineTemplate"

    self.data = {}
    self.columnsConfig = {}
    self.columnsConfigObj = {}
    self.columIdMap = {}

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
         end
         factory(self.lineTemplate or self.rowTemplate, Initializer);
     end);
 
    ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);
     
    local function ElementDataTranslator(elementData)
        return elementData;
     end;
     ScrollUtil.RegisterTableBuilder(self.ScrollBox, self.tableBuilder, ElementDataTranslator);
 



     self:SetData(self.data, true)
 
     
    self:CreateHeaders()
 
    -- tableBuilder:AddRow(self.tableBuilder, self.data[1]);
 
    -- self.tableBuilder:AddRow(self.rows, 1)
    -- _.forEach(self.data, function(row, idx)
    --       self.tableBuilder:AddRow(1, idx)
 
    --       DevTool:AddData(row, "row")
    -- end)
 
    self.tableBuilder:SetTableWidth(self.ScrollBox:GetWidth());
    self.tableBuilder:Arrange();
 
    self:RefreshScrollFrame()
end




function TableBuilderLibTableMixin:SetData(data, internal)
    if not data then return end

    
    DevTool:AddData(data, "SetData")

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
            table.insert(newRow, row[key] or key)
        end)
        table.insert(newData, newRow)
    end)

	self.tableData = newData
end


function TableBuilderLibTableMixin:AddColumn(columnConfigObj, internal)
    local columnConfig = {}
    _.forEach(columnConfigDefault, function(entry, key)
        columnConfig[key] = columnConfigObj[key] and columnConfigObj[key] or entry
    end)


    if not internal then

        local test = _.find(self.columIdMap, function(e) return e == columnConfigObj.id end)
        assert(test == nil, string.format("ColumnConfig %s already exits", columnConfigObj.id));
        assert(columnConfigObj.id, "ColumnConfig id need to be set");

    end
	
    
	
    columnConfig.id = columnConfigObj.id
    
    columnConfig.template = columnConfig.template or self.cellTemplate
    columnConfig.sortable = columnConfig.sortable and true or false

  

    if type(columnConfig.width) == "number" then 
        self:AddFixedWidthColumn(self, 0, columnConfig.width, columnConfig.padding, columnConfig.padding, columnConfig.sortable, columnConfig.template, columnConfig, columnConfig.headerText);
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
        self:AddFillColumn(self, 0, columnConfig.width, columnConfig.padding, columnConfig.padding, columnConfig.sortable, columnConfig.template, columnConfig, columnConfig.headerText);
    end


    table.insert(self.columnsConfigObj, columnConfig)

    -- stop here if internal add
    if internal then return end 
    self:UpdateTableData()
    
    --self.tableBuilder:SetTableWidth(self.ScrollBox:GetWidth());
    self.tableBuilder:Arrange();

    self:RefreshScrollFrame()
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
        print("columns",idx)
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
	local numResults = self.getNumElements();
	local dataProvider = CreateIndexRangeDataProvider(numResults);
	self.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition);
end



function TableBuilderLibTableMixin:ReorderColumns(cols)
    self.columIdMap = CopyTable(cols)
    self.tableBuilder:Arrange()
    self:CreateHeaders()
    self.tableBuilder:CalculateColumnSpacing();
    self.tableBuilder:ArrangeHeaders();

end
function TableBuilderLibTableMixin:CreateHeaders()
   DevTool:AddData(self.columIdMap, "self.columIdMap")

    local columns = self.tableBuilder:GetColumns()
    self.tableBuilder.headerPoolCollection:ReleaseAll()
   _.forEach(self.columIdMap, function(id, idx)
        local config =  _.find(self.columnsConfigObj, function(e) return e.id == id end)
        DevTool:AddData(self.columIdMap, "self.columIdMap")

        if config.sortable then
            columns[idx]:ConstructHeader("BUTTON", self.headerTemplate, self, idx,  config.id,  config.headerText, config.sortable);
        else
            columns[idx]:ConstructHeader("Frame", self.headerTemplate, self, idx,  config.id, config.headerText, config.sortable);
        end
   end)

end





function TableBuilderLibTableMixin:AddColumnInternal(owner, sortable, cellTemplate, config,  headerText,  ...)
	local column = owner.tableBuilder:AddColumn();
    column.config = config

	column:ConstructCells("FRAME", cellTemplate, owner, ...);
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






TableBuilderLibTableLineMixin = CreateFromMixins(TableBuilderRowMixin);

function TableBuilderLibTableLineMixin:GetRowData()
	return self.rowData;
end





TableBuilderLibTableBuilderMixin = {}



TableBuilderLibTableCellMixin = CreateFromMixins(TableBuilderCellMixin);


function TableBuilderLibTableCellMixin:Populate(data,index)
    self.Text:SetText(data[index])
end










TableBuilderLibTableHeaderMixin = CreateFromMixins(TableBuilderElementMixin);



function TableBuilderLibTableHeaderMixin:OnClick()
    if not self.sortable  then return end
    self.owner:SetSortOrder(self.sortOrder);
end

function TableBuilderLibTableHeaderMixin:Init(owner, sortOrder, id, headerText, sortable)
    self.sortOrder = sortOrder
    self.id = id
	self:SetText(headerText);
    self.sortable = sortable
    self:EnableMouse(sortable)
    self.owner = owner

    self.Arrow:Hide();

    self:UpdateArrow(owner.sortReverse)
end

function TableBuilderLibTableHeaderMixin:UpdateArrow(reverse)
	if self.owner.sort == self.sortOrder then 
		self:SetArrowState(reverse)
		self.Arrow:Show();
	else 
		self.Arrow:Hide();
	end
end

function TableBuilderLibTableHeaderMixin:SetArrowState(reverse)
	if reverse then
		self.Arrow:SetTexCoord(0, 1, 1, 0);
	else 
		self.Arrow:SetTexCoord(0, 1, 0, 1);
	end
end
