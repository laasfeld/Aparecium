function setTableBackground(table, color)
    object = findjobj(table);
    viewport = get(object, 'Viewport');
    set(viewport, 'Background', color)
    comp = get(viewport, 'Components');
    header = get(comp(1), 'TableHeader');
    set(header, 'Background',color);
    rowHeader = get(object, 'RowHeader');
    set(rowHeader, 'Background', color);
end