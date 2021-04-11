for i = 1:5
    disp(['Going through loop ', num2str(i)]);
    a = ones(20+i,20-i)*i;
    size(a)
    disp(a.*a);
    sum(sum(a))
    if sum(sum(a))>1000
        disp(['OMG the bill is too big, I need better scholarship. The bill is: ', num2str(sum(sum(a)))]);
    else
        disp('Yay, life is cheap');
    end
    mean(mean(a))
end
