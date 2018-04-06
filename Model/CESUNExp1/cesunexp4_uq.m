load('UQData_Sample4.mat');

x=[UQData.latencies UQData.failedDevices]';
%x=[mean(UQData.latencies'); mean(UQData.failedDevices')];
%x=[UQData.latencyMean'; mean(UQData.failedDevices')];
t=[(UQData.performance)]; % UQData.resilience UQData.reliability];

trainRatio=0.75;
testRatio=0.25;
valRatio=0;

[trainInd,valInd,testInd] = dividerand(size(t,2),trainRatio,valRatio,testRatio);

trainx=x(:,trainInd);
traint=t(:,trainInd);

netSet={};
for i=1:5

trainFcn = 'trainbr';
hiddenLayerSize = [6 4];
net = fitnet(hiddenLayerSize,trainFcn);
net.input.processFcns = {'removeconstantrows','mapminmax'};
net.output.processFcns = {'removeconstantrows','mapminmax'};
net.divideParam.trainRatio = 90/100;
net.divideParam.valRatio = 0/100;
net.divideParam.testRatio = 10/100;
net.trainParam.epochs=100;
[net,tr] = train(net,trainx,traint);
netSet{i}=net;

end

testx=x(:,testInd);
testt=t(:,testInd);

predictedValue=zeros(numel(testInd),1);
predictedStd=zeros(numel(testInd),1);
actualValue=zeros(numel(testInd),1);
for i=1:numel(testInd)
    predictedTSet=[];
    for j=1:numel(netSet)
        net=netSet{j};
        predictedTSet(end+1,:)=net(testx(:,i));
    end
    predictedValue(i)=mean(predictedTSet);
    predictedStd(i)=std(predictedTSet);
end
errors=testt-predictedValue';
sigmaRatios=(errors)'./predictedStd;
errorPct=errors./testt;

figure; 
subplot(2,1,1);
hist(errorPct*100,20); xlabel('Error (%)'); ylabel('Count-Performance');
subplot(2,1,2); 
hist(sigmaRatios,20);
xlabel('Error/Std');

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