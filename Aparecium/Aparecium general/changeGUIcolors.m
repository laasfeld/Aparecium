function [ output_args ] = changeGUIcolors(filename, buttoncolor, panelcolor, tablecolor)
hgS_070000 = importdata(filename);
hgS_070000 = changeColor(hgS_070000, buttoncolor, panelcolor, tablecolor)
save(filename, 'hgS_070000');
end

function data = changeColor(data, buttoncolor, panelcolor, tablecolor)
    if strcmp(data.type, 'uipanel') || strcmp(data.type, 'uibuttongroup')
        
        data.properties.BackgroundColor = panelcolor;
    elseif strcmp(data.type, 'figure')
        data.properties.color = panelcolor;
    elseif strcmp(data.type, 'uitable')
            %changeTableColor(data, tablecolor);
            return
    elseif strcmp(data.type, 'uicontrol')
        
        try
            ['Type: ' , get(data.handle, 'Type')]
            ['Style:', get(data.handle, 'Style')]
        catch
        end
        
            if strcmp(get(data.handle, 'Style'), 'pushbutton')
                set(data.handle, 'BackgroundColor', buttoncolor);
                data.properties.BackgroundColor = buttoncolor;
                return
            elseif strcmp(get(data.handle, 'Style'), 'edit') || strcmp(get(data.handle, 'Style'), 'popupmenu')
                return
            else
                set(data.handle, 'BackgroundColor', panelcolor);
                data.properties.BackgroundColor = panelcolor;
                return;

            end
    
    end
    
    for childIndex = 1 : numel(data.children)
       data.children(childIndex) = changeColor(data.children(childIndex), buttoncolor, panelcolor, tablecolor); 
    end
    
        
    
end

function changeTableColor(table, color)
            object = findjobj(table.handle);
            viewport = get(object, 'Viewport');
            set(viewport, 'Background', color)
            comp = get(viewport, 'Components');
            header = get(comp(1), 'TableHeader');
            set(header, 'Background',color);
            rowHeader = get(object, 'RowHeader');
            set(rowHeader, 'Background', color);
end

