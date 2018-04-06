function [genList,conList] = genModel(nConsumer,nGen,targetPower,genVariance,consumerVariance)



avgGenPower=targetPower/nGen;
avgConsumerPower=targetPower*1.5/nConsumer;
minConsumerPower=avgConsumerPower/5;

ISOid=0;

conList={};
genList={};

for i=1:nGen
    Pmin=-avgGenPower*(1+genVariance*randn());
    Pmax=0;
    PrMin=30*(1+genVariance*randn());
    PrMax=80*(1+genVariance*randn());
    mkt=dsim.MktPlayer(Pmax,Pmin,PrMax,PrMin,ISOid);
    
    genList{i}=mkt;
end

for i=1:nConsumer
    Pmax=avgConsumerPower*(1+consumerVariance*randn());
    %Pmin=Pmax-1e-3;
    Pmin=minConsumerPower*(1+consumerVariance*randn());
    PrMin=0;
    PrMax=100*(1+consumerVariance*randn());
    mkt=dsim.MktPlayer(Pmax,Pmin,PrMax,PrMin,ISOid);
    
    conList{end+1}=mkt;
end


end