clear all;

load('cnexp1_attacks1_results.mat');

targets=run1_input.v1;

profitMatrix=zeros(length(targets),length(targets));
for i=1:length(targets)
    profitMatrix(i,:)=run1_data{i,1}.profits;
end

%IM(target,client)

%Calculate Attacker's Incentive
runTime=300;
attackList=zeros(500,1);
[baselineProfits,DSim]=cnexp1_runscenario(attackList,runTime);

IM=[];
for i=1:size(profitMatrix,2)
    IM(i,:)=profitMatrix(i,:)-baselineProfits';
end

maxProfit=max(IM,[],2);

maxImpact=[];
for i=1:length(targets)
    maxImpact(i)=max(IM(i,IM(i,:)>0));
end
[vals,targets]=sort(maxImpact,'descend');

figure;
bh=bar(vals);
xlabel('Target');
ylabel('Impact');
set(gca,'FontSize',18);
set(gca,'XTick',[]);
%xlim([0.5 40.5]);

limitedImpact=[];
for i=1:length(targets)
    for k=1:length(targets)
        rowIM=IM(i,:);
        rowIM(rowIM<0)=0;
        rowIM=sort(rowIM,'descend');
        limitedImpact(i,k)=sum(rowIM(1:k));
    end
end

maxLimImpact=max(limitedImpact,[],1);

figure;
bh=plot(maxLimImpact,'linewidth',2);
xlabel('Collaborators');
ylabel('Profit Potential');
set(gca,'FontSize',18);
xlim([0 20]);



