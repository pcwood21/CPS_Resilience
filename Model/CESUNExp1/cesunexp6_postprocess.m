clear all;

load('cesunexp7_results.mat');

seeds=run7_input.v1;
mu_targets=run7_input.v2;
sigma_logs=run7_input.v3;
numFailures=run7_input.v4;

[~,~,DSim,~]=cesunexp1_runscenario(1,0,0);
%baselineProfits=sum(baselineProfits)-sum(residualHist(residualHist>0))*100;

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
latencyMuUnshaped=[];
latencySigmaUnshaped=[];
meanLatencyUnshaped=[];
numFailuresUnshaped=[];
stdDevLatencyUnshaped=[];
allProfits=[];
dataFailed=[];
performanceUnshaped=[];
resilienceUnshaped=[];
reliabilityUnshaped=[];
for i=1:numel(seeds)
    for j=1:numel(mu_targets)
        for k=1:numel(sigma_logs)
            for l=1:numel(numFailures)
                data=run7_data{i,j,k,l};
                if ~isstruct(data)
                    dataFailed(end+1)=data;
                    continue;
                end
                %performance(i,j,k)=baselineProfits-sum(data.profits);
                performance(i,j,k,l)=sum(data.profits)-sum(data.residualHist(data.residualHist>0))*100;
                performanceUnshaped(end+1)=performance(i,j,k,l);
                allProfits(end+1,:)=data.profits;
                resilience(i,j,k,l)=-1*mean(abs(data.residualHist));
                resilienceUnshaped(end+1)=resilience(i,j,k,l);
                reliability(i,j,k,l)=-1*max(abs(data.residualHist));
                reliabilityUnshaped(end+1)=reliability(i,j,k,l);
                latencies(i,j,k,l,:)=data.latencies;
                latenciesUnshaped(end+1,:)=data.latencies;
                fails=zeros(numel(data.latencies),1);
                fails(data.failedClients)=1;
                failedDevices(i,j,k,l,:)=fails;
                failedDevicesUnshaped(end+1,:)=fails;
                priceUnshaped(end+1,:)=data.priceHist;
                residualUnshaped(end+1,:)=data.residualHist;
                latencyMuUnshaped(end+1)=mu_targets(j);
                latencySigmaUnshaped(end+1)=sigma_logs(k);
                meanLatencyUnshaped(end+1)=mean(data.latencies);
                stdDevLatencyUnshaped(end+1)=std(data.latencies);
                numFailuresUnshaped(end+1)=numFailures(l);
            end
        end
    end
end

agentData=[];
aList=DSim.getAgentsByName('dsim.MktPlayer');
for i=1:numel(aList)
    agent=aList{i};
    agentData(i,:)=[agent.Pmin agent.Pmax agent.PrMin agent.PrMax];
end

UQData.performance=performanceUnshaped;
UQData.resilience=resilienceUnshaped;
UQData.reliability=reliabilityUnshaped;
UQData.latencies=latenciesUnshaped;
UQData.failedDevices=failedDevicesUnshaped;
UQData.staticDeviceParams=agentData;
UQData.priceByTime=priceUnshaped;
UQData.residualByTime=residualUnshaped;
UQData.latencyMu=latencyMuUnshaped';
UQData.latencySigma=latencySigmaUnshaped';
UQData.latencyMean=meanLatencyUnshaped';
UQData.latencyStd=stdDevLatencyUnshaped';
UQData.numberOfFailures=numFailuresUnshaped';
%UQData.baselineProfit=baselineProfits;
UQData.individualProfits=allProfits;

save('UQData_Sample7.mat','UQData');

xlsFile='./UQData_Sample7.xlsx';
fNames=fieldnames(UQData);
for i=1:numel(fNames)
    fName=fNames{i};
    xlswrite(xlsFile,UQData.(fName),fName);
end

return;
figure('Position',[500 500 1280/2.5 720/2.5]); hold all;  scatter(mean(UQData.latencies'),UQData.performance); plot(latencyMagnitude/2,mean(performance(:,:,1)),'-x','LineWidth',2,'MarkerSize',16); hold off; xlabel('Latency (s)'); ylabel('Performance');
saveas(gcf,'LatencyPerformance.png');
figure('Position',[500 500 1280/2.5 720/2.5]); hold all;  scatter(mean(UQData.latencies'),UQData.reliability); plot(latencyMagnitude/2,mean(reliability(:,:,1)),'-x','LineWidth',2,'MarkerSize',16); hold off; xlabel('Latency (s)'); ylabel('Reliability');
saveas(gcf,'LatencyReliability.png');
figure('Position',[500 500 1280/2.5 720/2.5]); hold all;  scatter(mean(UQData.latencies'),UQData.resilience); plot(latencyMagnitude/2,mean(resilience(:,:,1)),'-x','LineWidth',2,'MarkerSize',16); hold off; xlabel('Latency (s)'); ylabel('Resilience');
saveas(gcf,'LatencyResilience.png');
figure('Position',[500 500 1280/2.5 720/2.5]); hold all;  scatter(mean(UQData.failedDevices')*120,UQData.performance); plot(numFailures,mean(squeeze(performance(:,1,:))),'-x','LineWidth',2,'MarkerSize',16); hold off; xlabel('Failures (#)'); ylabel('Performance');
%ylim([-1e4 300]);
saveas(gcf,'OutagePerformance.png');
figure('Position',[500 500 1280/2.5 720/2.5]); hold all;  scatter(mean(UQData.failedDevices')*120,UQData.reliability); plot(numFailures,mean(squeeze(reliability(:,1,:))),'-x','LineWidth',2,'MarkerSize',16); hold off; xlabel('Failures (#)'); ylabel('Reliability');
%ylim([-30 -20]);
saveas(gcf,'OutageReliability.png');
figure('Position',[500 500 1280/2.5 720/2.5]); hold all;  scatter(mean(UQData.failedDevices')*120,UQData.resilience); plot(numFailures,mean(squeeze(resilience(:,1,:))),'-x','LineWidth',2,'MarkerSize',16); hold off; xlabel('Failures (#)'); ylabel('Resilience');
%ylim([-7 -2]);
saveas(gcf,'OutageResilience.png');
