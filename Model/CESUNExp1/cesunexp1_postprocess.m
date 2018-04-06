clear all;

load('cesunexp1_results.mat');

seeds=run1_input.v1;
latencyMagnitude=run1_input.v2;
numFailures=run1_input.v3;

[baselineProfits,~,DSim]=cesunexp1_runscenario(400,0,0);
baselineProfits=sum(baselineProfits);

performance=[];
resilience=[];
reliability=[];
latencies=[];
latenciesUnshaped=[];
latencyMagnitudes=[];
failedDevices=[];
priceUnshaped=[];
residualUnshaped=[];
failedDevicesUnshaped=[];
for i=1:numel(seeds)
    for j=1:numel(latencyMagnitude)
        for k=1:numel(numFailures)
            data=run1_data{i,j,k};
            performance(i,j,k)=baselineProfits-sum(data.profits);
            resilience(i,j,k)=-1*mean(abs(data.residualHist));
            reliability(i,j,k)=-1*max(abs(data.residualHist));
            latencies(i,j,k,:)=data.latencies;
            latenciesUnshaped(end+1,:)=data.latencies;
            fails=zeros(numel(data.latencies),1);
            fails(data.failedClients)=1;
            failedDevices(i,j,k,:)=fails;
            failedDevicesUnshaped(end+1,:)=fails;
            priceUnshaped(end+1,:)=data.priceHist;
            residualUnshaped(end+1,:)=data.residualHist;
        end
    end
end

agentData=[];
aList=DSim.getAgentsByName('dsim.MktPlayer');
for i=1:numel(aList)
    agent=aList{i};
    agentData(i,:)=[agent.Pmin agent.Pmax agent.PrMin agent.PrMax];
end

UQData.performance=performance(:);
UQData.resilience=resilience(:);
UQData.reliability=reliability(:);
UQData.latencies=latenciesUnshaped;
UQData.failedDevices=failedDevicesUnshaped;
UQData.staticDeviceParams=agentData;
UQData.priceByTime=priceUnshaped;
UQData.residualByTime=residualUnshaped;

xlsFile='./UQData_Sample1.xlsx';
fNames=fieldnames(UQData);
for i=1:numel(fNames)
    fName=fNames{i};
    xlswrite(xlsFile,UQData.(fName),fName);
end
