whereToMove= 'D:\171123_160504_172311_D3 Kinetics kaheosaline\Dissoc2';% 
moveFromWhere = 'D:\171123_160504_172311_D3 Kinetics kaheosaline\Dissoc2\';
prestring='';
for number = 1:5
    try
        if number<10
            mkdir(whereToMove,[prestring,'00',num2str(number)]);
        cd(([whereToMove,'\', prestring, '00',num2str(number)]))
            movefile([moveFromWhere,'\*',prestring,'00',num2str(number),'.tif']);
        elseif number<100
            mkdir(whereToMove,[prestring,'0',num2str(number)]);
        cd([whereToMove,'\', prestring, '0',num2str(number)])
            movefile([moveFromWhere,'*',prestring,'0',num2str(number),'.tif']);
        else
            mkdir(whereToMove,prestring,num2str(number));
        cd([whereToMove,'\',prestring,num2str(number)])
            movefile([moveFromWhere,'*', prestring,num2str(number),'.tif']);  
        end
    catch
        continue;
    end
% 
%     try
%         if number<10
%             mkdir(whereToMove,[num2str(number)]);
%         cd(([whereToMove,'\',num2str(number)]))
%             movefile([moveFromWhere,'*',num2str(number),'.tif']);
%         elseif number<100
%             mkdir(whereToMove,[num2str(number)]);
%         cd([whereToMove,'\',num2str(number)])
%             movefile([moveFromWhere,'*',num2str(number),'.tif']);
%         else
%             mkdir(whereToMove,num2str(number));
%         cd([whereToMove,'\',num2str(number)])
%             movefile([moveFromWhere,'*',num2str(number),'.tif']);  
%         end
%     catch
%             continue;
%     end


end