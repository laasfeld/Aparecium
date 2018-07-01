Path=[cd,'\'];
if isempty(strfind(cd, 'Aparecium Java'))
    save('Aparecium Java\javapath','Path')
else
    save('javapath','Path')
end
disp('Java libraries installed')
disp('Java libraries are now searched form')
disp(Path)