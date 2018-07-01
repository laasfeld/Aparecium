function handles = setTag(component, handles, tagname)
%   Set tag to a component in a structure
    handles.(tagname) = component;
    set(component, 'Tag', tagname);
end

