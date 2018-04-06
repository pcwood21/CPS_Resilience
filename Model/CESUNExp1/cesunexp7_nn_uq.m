
load('UQData_Sample7.mat');

x=[UQData.latencies UQData.failedDevices]';
%x=[mean(UQData.latencies'); mean(UQData.failedDevices')];
%x=[UQData.latencyMean'; mean(UQData.failedDevices')];
t=[UQData.performance; UQData.resilience; UQData.reliability];

trainRatio=0.75;
testRatio=0.25;
valRatio=0;

[trainInd,valInd,testInd] = dividerand(size(t,2),trainRatio,valRatio,testRatio);

trainx=x(:,trainInd);
traint=t(:,trainInd);

numNetsInSet=15;
netSet={};
trSet={};
for i=1:numNetsInSet
    for j=1:3
        while true
            trainFcn = 'trainbr'; %bayesian regularization
            if j==3
                hiddenLayerSize=[7 3];
            else
                hiddenLayerSize = [7 3];
            end
            net = fitnet(hiddenLayerSize,trainFcn);
            net.input.processFcns = {'mapminmax'};
            net.output.processFcns = {'mapminmax'};
            net.divideParam.trainRatio = 85/100;
            net.divideParam.valRatio = 0/100; %With regularizer, no need to stop on validation
            net.divideParam.testRatio = 15/100;
            net.trainParam.epochs=200; %set a fixed number of iterations, better to use a diff on mu but this is here for running time
            %net.trainParam.max_fail=4;
            [net,tr] = train(net,trainx,traint(j,:));
            netSet{i,j}=net; %#ok<SAGROW>
            trSet{i,j}=tr;
            if tr.gamk(end) > 1
                break;
            end
            disp('Got stuck training');
        end
    end
end

testx=x(:,testInd);
testt=t(:,testInd);

save('exp7_uq_nn.mat','netSet','traint','trainx','testt','testx','numNetsInSet');
return;


load('exp7_uq_nn.mat');
cesun_nn_func(testx(:,1),netSet,1); %Generate the functions
%Calculate the errors and standard deviations from the net set
numPredictedElements=size(testt,1);
predictedValue=zeros(size(testt,2),numPredictedElements);
predictedStd=zeros(size(testt,2),numPredictedElements);
for i=1:size(testt,2)
    %predictedTSet=zeros(numNetsInSet,numPredictedElements);
    %for j=1:numNetsInSet
    %    for k=1:numPredictedElements
    %    net=netSet{j,k};
    %    predictedTSet(j,k)=net(testx(:,i));
    %    end
    %end
    %predictedValue(i,:)=mean(predictedTSet);
    %predictedStd(i,:)=std(predictedTSet);
    [meanVals,stds]=cesun_nn_func(testx(:,i),netSet);
    predictedValue(i,:)=meanVals;
    predictedStd(i,:)=stds;
end
errors=testt-predictedValue';
sigmaRatios=(errors)'./predictedStd;
sigmaRatios=sigmaRatios';
errorPct=errors./testt;

save('exp5_uq_nn_errors.mat','netSet','traint','trainx','testt','testx','numNetsInSet','errors','sigmaRatios','errorPct','predictedValue','predictedStd');

%}
load('exp5_uq_nn_errors.mat');

%Plot the Error Histogram, Fig 4 in the paper currently
plotStrings={'Performance','Resilience','Robustness'};
figure('Position',[500 500 1000 300]);
for i=1:numel(plotStrings)
    subplot(2,3,i);
    edges=[-1000 -100:10:-30 -20:5:20 30:10:100 1000];
    hist(errorPct(i,:)*100,edges); xlabel(['Error (%)']); ylabel(['Count']);
    xlim([-120 120]);
    title(plotStrings{i});
    subplot(2,3,3+i);
    edges=[-1000 -5:0.5:5 1000];
    hist(sigmaRatios(i,:),edges);
    xlim([-7 7]);
    ylabel('Count');
    xlabel(['Error/Std']);
end


%predictive uncertainty test
metricIndex=1;
Z=quantile(predictedValue(:,metricIndex),0.1); %About 10% of tests should fail
tenPctSigma=-1.2815;
passed=testt(metricIndex,:)>Z;
failFixedZ=zeros(size(predictedValue,1),1);
Zten=zeros(size(predictedValue,1),1);
for i=1:size(predictedValue,1)
    failFixedZ(i)=normcdf((Z-predictedValue(i,metricIndex))/predictedStd(i,metricIndex));
    Zten(i)=tenPctSigma*predictedStd(i,metricIndex)+predictedValue(i,metricIndex);
end


%Plot the frequencies for the ideal and actual UQ, figure 5 in the paper
figure('Position',[500 500 1000 200]);
for k=1:3
    metricIndex=k;
    normMu=0;
    normSigma=0.8;
    numSigmas=-1.7:0.1:0;
    expectedPct=normcdf(numSigmas,normMu,normSigma);
    passedPct=zeros(numel(numSigmas),1);
    for i=1:numel(numSigmas)
        targetSigma=numSigmas(i);
        passedConfidence=zeros(size(predictedValue,1),1);
        for j=1:size(predictedValue,1)
            targetThreshold=targetSigma*predictedStd(j,metricIndex)+predictedValue(j,metricIndex);
            passedConfidence(j)=testt(metricIndex,j)>targetThreshold;
        end
        passedPct(i)=1-sum(passedConfidence)/numel(passedConfidence);
    end
    
    %figure('Position',[500 500 500 275]);
    subplot(1,3,k);
    hold all;
    plot(expectedPct,passedPct,'LineWidth',2);
    plot(expectedPct,expectedPct,'--');
    hold off;
    legend({'Actual','Ideal'},'Location','NorthWest');
    xlabel('Expected Cases Failed');
    ylabel('Actual Cases Failed');
    title(plotStrings{k});
end


%Optimization trial
cesun_nn_func(testx(:,1),netSet,1); %Generate the functions
requiredReliability=-26;
requiredConfidence=0.1;
latTest=testx(1:120,1);
score=cesun_nn_multiObjFcn(latTest,netSet,requiredReliability,requiredConfidence);

performances=[];
reliabilities=[];
sumLatencies=[];
parfor i=1:4*8
    for j=1:2
        useConfidence=j-1;
        [latencyResults,~,testPerformance,testReliability] = cesun_nn_optimize(latTest,netSet,requiredReliability,requiredConfidence,useConfidence);
        disp([num2str(testReliability) ' ' num2str(j)]);
        performances(i,j)=testPerformance;
        reliabilities(i,j)=testReliability;
        sumLatencies(i,j)=sum(latencyResults);
    end
end

figure('Position',[500 500 500 250]);
hold all;
scatter(reliabilities(:,1),performances(:,1),48,'o','LineWidth',1.5);
scatter(reliabilities(:,2),performances(:,2),48,'+','LineWidth',1.5);
plot([requiredReliability requiredReliability],[min(performances(:)) max(performances(:))],':k','LineWidth',3);
legend('Naive','UQ','Threshold','Location','NorthWest');
xlabel('Robustness');
ylabel('Performance');
hold off;


% gaObjFcn=@(x) -1*cesun_nn_multiObjFcn(x',netSet,requiredReliability,requiredConfidence);
% gaOptimOptions=optimoptions('ga','FunctionTolerance',0.01,'PlotFcns',@gaplotscorediversity);
% lb=ones(size(testx,1)/2,1)*0.5;
% ub=ones(size(testx,1)/2,1)*3;
% [bestLat,score]=ga(gaObjFcn,size(testx,1)/2,[],[],[],[],lb,ub,[],gaOptimOptions);
% 
% [profits,~,~,residualHist,~,~]=cesunexp5_runscenario(300,0,0,0,bestLat);
% testPerformance=sum(profits)-sum(residualHist(residualHist>0))*100;
% testReliaiblity=-1*max(abs(residualHist));


%Plot the data for the paper fig 3; currently just plotted test data in the
%paper because the combined is a bit dense
figure('Position',[500 500 1000 160]);
for i=1:3
    subplot(1,3,i);
    x=mean(testx(1:120,:));
    y=testt(i,:);
    %x=mean([testx(1:120,:) trainx(1:120,:)]);
    %y=[testt(i,:) traint(i,:)];
    scatter(x,y);
    xlabel('Mean Latency (s)');
    ylabel(plotStrings{i});
end

figure('Position',[500 500 1000 160]);
for i=1:3
    subplot(1,3,i);
    x=sum(testx(121:end,:));
    y=testt(i,:);
    %x=sum([testx(121:end,:) trainx(121:end,:)]);
    %y=[testt(i,:) traint(i,:)];
    scatter(x,y);
    xlabel('Number of Outages');
    ylabel(plotStrings{i});
end




%Old plots, ignore:
%{

figure;
testIndex=1;
x=mean(testx(1:120,:));
y=testt(testIndex,:);
ypred=predictedValue(:,testIndex);
y2p=ypred'+4*predictedStd(:,testIndex)';
y2n=ypred'-4*predictedStd(:,testIndex)';
hold all;
scatter(x,y);
scatter(x,y2p);
scatter(x,y2n);
hold off;

figure;
subplot(2,1,1);
title('Centered, some bars not shown');
hist(errorPct*100,30); xlabel('Error (%)'); ylabel('Count-Performance');
xlim([-4 4]);
subplot(2,1,2);
hist(sigmaRatios,30);
xlabel('Error/Std');
xlim([-4 4]);


figure;
subplot(4,1,1);
hist(abs(errors)); xlabel('Error (Absolute Value)'); ylabel('Count-Performance');
subplot(4,1,2);
hist(predictedValue);
xlabel('Predicted Performance');
subplot(4,1,3);
hist(predictedStd);
xlabel('Standard Deviation, Unadjusted');
subplot(4,1,4);
hist(predictedValue./predictedStd,30);
xlabel('Prediction/Std');


figure;
hold all;
scatter(abs(errors),abs(predictedStd));
maxAny=max([max(abs(errors)) max(abs(predictedStd))]);
plot([0 maxAny],[0 maxAny]);
xlabel('Actual Error');
ylabel('Standard Deviation');


figure;
hold all;
scatter(abs(predictedValue),abs(predictedStd));
%maxAny=max([max(abs(predictedValue)) max(abs(predictedStd))]);
%plot([0 maxAny],[0 maxAny]);
xlabel('Predicted Value');
ylabel('Standard Deviation');
%}