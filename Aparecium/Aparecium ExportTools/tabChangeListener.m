function tabChangeListener(OldValue, NewValue, Source, EventName)
guihandle = guihandles(NewValue.Source);
handles = guidata(guihandle.figure1);
switch(NewValue.NewValue.Tag)
    case 'SBPreview'
        handles.SBTable.setVisible(true);
        handles.excelTable.setVisible(false);
        handles.CopasiTable.setVisible(false);
        handles.PrismHeaderTable.setVisible(false);
        handles.PrismTable.setVisible(false);
    case 'ExcelPreview'
        handles.SBTable.setVisible(false);
        handles.excelTable.setVisible(true);
        handles.CopasiTable.setVisible(false);
        handles.PrismHeaderTable.setVisible(false);
        handles.PrismTable.setVisible(false);        
    case 'GraphicalPreview'
        handles.SBTable.setVisible(false);
        handles.excelTable.setVisible(false);
        handles.CopasiTable.setVisible(false);
        handles.PrismHeaderTable.setVisible(false);
        handles.PrismTable.setVisible(false);        
    case 'CopasiPreview'
        handles.SBTable.setVisible(false);
        handles.excelTable.setVisible(false);
        handles.CopasiTable.setVisible(true);
        handles.PrismHeaderTable.setVisible(false);
        handles.PrismTable.setVisible(false);        
    case 'PrismPreview'
        handles.SBTable.setVisible(false);
        handles.excelTable.setVisible(false);
        handles.CopasiTable.setVisible(false);
        handles.PrismHeaderTable.setVisible(true);
        handles.PrismTable.setVisible(true);        
end
end

