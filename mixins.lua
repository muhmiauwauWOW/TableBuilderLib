local _ = LibStub("LibLodash-1"):Get()



TableBuilderLibTableMixin = {}

function TableBuilderLibTableMixin:OnLoad()
    -- self:Init()
end

function TableBuilderLibTableMixin:Init()
    

    self.headerTemplate = "TableBuilderLibTableHeaderTemplate"
    self.cellTemplate = "TableBuilderLibTableCellTemplate"
    self.rowTemplate = "TableBuilderLibTableLineTemplate"

    self.data = self.data or {}
 
    self.headers = self.headers or {"1", "2", "3"}
   
 
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
    _.forEach(self.headers, function(colName, idx)
 --       local width = _.get(selself.columnConfig, {colName, "width"})
 --       local headerText = _.get(selself.columnConfig, {colName, "header", "text"})
 --       local padding = _.get(selself.columnConfig, {colName, "padding"}, 14)
 --       local template = _.get(selself.columnConfig, {colName, "template"}, "GreatVaultListTableCellTextTemplate")
 
 -- 	local canSort = _.get(selself.columnConfig, {colName, "header", "canSort"}, false)
 -- 	if canSort then 
 -- 		table.insert(selself.sortHeaders, idx);
 -- 	end
 
       local width = 100
       local headerText = "test"
       local padding = "0"
       local template = self.cellTemplate
 
 
       local col = self:AddFixedWidthColumn(self, 0, width, padding, padding, idx, template);
       if not col then end
       col:GetHeaderFrame():SetText(self.headers[idx]);
            
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


function TableBuilderLibTableMixin:SetData(data)
    if not data then return end
	self.data = data
    self:RefreshScrollFrame()
end

function TableBuilderLibTableMixin:RefreshScrollFrame()
	

	local numResults = self.getNumElements();
	local dataProvider = CreateIndexRangeDataProvider(numResults);
	self.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition);
end



function TableBuilderLibTableMixin:AddColumnInternal(owner, sortOrder, cellTemplate, ...)
	local column = owner.tableBuilder:AddColumn();



	-- if sortOrder then
	-- 	local headerName = AuctionHouseUtil.GetHeaderNameFromSortOrder(sortOrder);
	-- 	column:ConstructHeader("BUTTON", "AuctionHouseTableHeaderStringTemplate", owner, headerName, sortOrder);
	-- end

  column:ConstructHeader("BUTTON", self.headerTemplate, owner, nil, sortOrder);

	column:ConstructCells("FRAME", cellTemplate, owner, ...);
	return column;
end

function TableBuilderLibTableMixin:AddFixedWidthColumn(owner, padding, width, leftCellPadding, rightCellPadding, sortOrder, cellTemplate, ...)
   local column = self:AddColumnInternal(owner, sortOrder, cellTemplate, ...);
   DevTool:AddData(column, "column")
	column:SetFixedConstraints(width, padding);
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
	-- selself.owner:SetSortOrder(selself.sortOrder);
end

function TableBuilderLibTableHeaderMixin:Init(owner, headerText, sortOrder)
	self:SetText(headerText);

	-- local find = _.find(owner.sortHeaders, function(entry) return entry == sortOrder; end)
	-- local interactiveHeader = owner.RegisterHeader and find;
	-- self:SetEnabled(interactiveHeader);
	-- selself.owner = owner;
	-- selself.sortOrder = sortOrder;

	-- if interactiveHeader then
	-- 	owner:RegisterHeader(self);
	-- 	self:UpdateArrow();
	-- else
	-- 	selself.Arrow:Hide();
	-- end
end

function TableBuilderLibTableHeaderMixin:UpdateArrow(reverse)
	if selself.owner.sort == selself.sortOrder then 
		self:SetArrowState(reverse)
		selself.Arrow:Show();
	else 
		selself.Arrow:Hide();
	end
end

function TableBuilderLibTableHeaderMixin:SetArrowState(reverse)
	if reverse then
		selself.Arrow:SetTexCoord(0, 1, 1, 0);
	else 
		selself.Arrow:SetTexCoord(0, 1, 0, 1);
	end
end
