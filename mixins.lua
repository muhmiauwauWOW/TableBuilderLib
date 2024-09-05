local _ = LibStub("LibLodash-1"):Get()




local columnConfigDefault = {
    Id = nil,
    width = "fill",
    headerText = "",
    padding = 0,
    template = nil,
    sortable = false
 }
 



TableBuilderLibTableMixin = {}

function TableBuilderLibTableMixin:OnLoad()

    self.headerTemplate = "TableBuilderLibTableHeaderTemplate"
    self.cellTemplate = "TableBuilderLibTableCellTemplate"
    self.rowTemplate = "TableBuilderLibTableLineTemplate"

    self.data = {}
    self.columnsConfig = {}

    -- self:Init()
end

function TableBuilderLibTableMixin:Init()
    
 
    local tableBuilder = CreateTableBuilder(self.data);
    self.tableBuilder = tableBuilder;
 
   
    function self.getNumElements(index)
          return #self.data;
      end;
     function self.getElement(index)
         return self.data[index];
     end;
 
    self.tableBuilder:SetDataProvider(self.getElement);
    -- self.tableBuilderLayoutFunction(self:GetTableLayout(f, self.data));
 
 
    self.tableBuilder:SetColumnHeaderOverlap(2);
    self.tableBuilder:SetHeaderContainer(self.HeaderContainer);

    _.forEach(self.columnsConfig, function(columnConfigObj, idx)
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
 
 
    -- tableBuilder:AddRow(self.tableBuilder, self.data[1]);
 
    -- self.tableBuilder:AddRow(self.rows, 1)
    -- _.forEach(self.data, function(row, idx)
    --       self.tableBuilder:AddRow(1, idx)
 
    --       DevTool:AddData(row, "row")
    -- end)
 
    self.tableBuilder:SetTableWidth(self.ScrollBox:GetWidth());
    self.tableBuilder:Arrange();
 

end

function TableBuilderLibTableMixin:AddColumn(columnConfigObj, internal)
    DevTools_Dump(columnConfigObj)
    local columnConfig = {}
    _.forEach(columnConfigDefault, function(entry, key)
        columnConfig[key] = columnConfigObj[key] and columnConfigObj[key] or entry
    end)

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

    -- stop here if internal add
    if internal then return end 
    
    --self.tableBuilder:SetTableWidth(self.ScrollBox:GetWidth());
    self.tableBuilder:Arrange();

    self:RefreshScrollFrame()
end


function TableBuilderLibTableMixin:RemoveColumn(id)
    print("RemoveColumn")
   
    local cols = self.tableBuilder.columns 

    local rcol = cols[id]
    rcol:Reset()
    local rheader = rcol:GetHeaderFrame()

    rheader:Hide()
     table.remove(cols, id)
    self.tableBuilder.columns = cols


    -- self.tableBuilder:Arrange();



    function Arrange()
        self = self.tableBuilder
        local columns = self:GetColumns();
        if columns and #columns > 0 then
            self:CalculateColumnSpacing();
            self:ArrangeHeaders();
        end
    
        for index, row in ipairs(self.rows) do
            self:ArrangeCells(row);
        end
    end

     Arrange()



    -- self:RefreshScrollFrame()
end


function TableBuilderLibTableMixin:SetData(data)
    if not data then return end
	self.data = data
    --self:RefreshScrollFrame()
end

function TableBuilderLibTableMixin:RefreshScrollFrame()
	

	local numResults = self.getNumElements();
	local dataProvider = CreateIndexRangeDataProvider(numResults);
	self.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition);
end



function TableBuilderLibTableMixin:AddColumnInternal(owner, sortable, cellTemplate, config,  headerText,  ...)
	local column = owner.tableBuilder:AddColumn();
    column.config = config


    print(sortable)
    if sortable then
        column:ConstructHeader("BUTTON", self.headerTemplate, owner, headerText, sortable);
    else
       column:ConstructHeader("Frame", self.headerTemplate, owner, headerText);
    end

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
    print("Sort function not yet implemented")	
end

function TableBuilderLibTableHeaderMixin:Init(owner, headerText, sortable)
	self:SetText(headerText);
    self.sortable = sortable
    self:EnableMouse(sortable)
    if sortable then
        self.Arrow:Show();
    else
        self.Arrow:Hide();
    end
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
