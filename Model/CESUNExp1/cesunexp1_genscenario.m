function [ DSim, numClients ] = cesunexp1_genscenario(~)

rng(1);

nConsumer=100;
nGen=20;
targetPower=100;

numClients=nConsumer+nGen;

genVariance=0.25;
consumerVariance=0.15;

[genList,conList]=dsim.genModel(nConsumer,nGen,targetPower,genVariance,consumerVariance);

deviation=0;%0.05;
genTC=60*60*2/(2*pi);
conTC=60*60*2/(2*pi);
genMag=0;%targetPower/nGen*0.1;
conMag=targetPower/nConsumer*0.35;
genTS=0;
conTS=60*60*0;

[genList,conList] = dsim.addTimeModel(genList,conList,genTC,conTC,genMag,conMag,genTS,conTS,deviation);

predictVariance=0.01;
predictOffset=-0.2; %Pct
predictLAConst=50;

[genList,conList] = dsim.addPredictModel(genList,conList,predictVariance,predictOffset,predictLAConst);

DSim=dsim.DSim.getInstance();
ISO=dsim.ISO();
ISO.OPT.a=1;
ISO.OPT.y=2; %Expansion y
ISO.OPT.p=0.5; %Contraction B
ISO.OPT.o=0.9; %Shrink coeff.
%ISO.OPT.Rw=Rw;
ISO.OPT.Rb=0.5;
ISO.nVar=5;
DSim.addAgent(ISO);


Bandwidth=1e9;
Latency=0;
%CommMtoISO=dsim.Comm(Bandwidth,Latency);
%DSim.addAgent(CommMtoISO);
%CommISOtoM=dsim.Comm(Bandwidth,Latency);
%DSim.addAgent(CommISOtoM);

%ISO.commAgentId=CommISOtoM.id;
cList={};
icList={};

for i=1:length(genList)
    agent=genList{i};
    agent.ISOid=ISO.id;
    commAgent=dsim.Comm(Bandwidth,Latency);
    DSim.addAgent(commAgent);
    cList{end+1}=commAgent;
    agent.commAgentId=commAgent.id;
    DSim.addAgent(agent);
    commAgent=dsim.Comm(Bandwidth,Latency);
    commAgent.availDestAgent=agent.id;
    DSim.addAgent(commAgent);
    ISO.commAgentId(end+1)=commAgent.id;
    icList{end+1}=commAgent;
end

for i=1:length(conList)
    agent=conList{i};
    agent.ISOid=ISO.id;
    commAgent=dsim.Comm(Bandwidth,Latency);
    DSim.addAgent(commAgent);
    cList{end+1}=commAgent;
    agent.commAgentId=commAgent.id;
    DSim.addAgent(agent);
    commAgent=dsim.Comm(Bandwidth,Latency);
    commAgent.availDestAgent=agent.id;
    DSim.addAgent(commAgent);
    ISO.commAgentId(end+1)=commAgent.id;
    icList{end+1}=commAgent;
end

logger=dsim.MktLogger();
DSim.addAgent(logger);




%DSim.run(300);

%{
figure;
pH=logger.priceHist(2:end);
rH=logger.residualHist(2:end);
tH=logger.timeHist(2:end);
plotyy(tH,pH,tH,rH);
%}



end


