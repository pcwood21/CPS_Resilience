function [meanTargets,stDevs] = cesun_nn_func(x,netSet,generateFlag) %#ok<INUSL>

if nargin >= 3 && ~isempty(generateFlag) && generateFlag == 1
    mkdir('./+netSetFcn');
    for i=1:size(netSet,1)
        for j=1:size(netSet,2)
            funcName=['./+netSetFcn/netFcn' num2str(i) '_' num2str(j) '.m'];
            genFunction(netSet{i,j},funcName);
        end
    end
end

targets=zeros(size(netSet,1),size(netSet,2));
for i=1:size(netSet,1)
    for j=1:size(netSet,2)
        funcName=['netSetFcn.netFcn' num2str(i) '_' num2str(j) '(x);'];
        targets(i,j)=eval(funcName);
    end
end

meanTargets=mean(targets);
stDevs=std(targets);

end

