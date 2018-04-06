function [bestLatency,score,testPerformance,testReliability] = cesun_nn_optimize(latTest,netSet,requiredReliability,requiredConfidence,useConfidence)

gaObjFcn=@(x) -1*cesun_nn_multiObjFcn(x',netSet,requiredReliability,requiredConfidence,useConfidence);
gaOptimOptions=optimoptions('ga','FunctionTolerance',0.01); %,'PlotFcns',@gaplotscorediversity);
lb=ones(size(latTest,1),1)*0.5;
ub=ones(size(latTest,1),1)*3;
[bestLatency,score]=ga(gaObjFcn,size(latTest,1),[],[],[],[],lb,ub,[],gaOptimOptions);

[profits,~,~,residualHist,~,~]=cesunexp5_runscenario(300,0,0,0,bestLatency);
testPerformance=sum(profits)-sum(residualHist(residualHist>0))*100;
testReliability=-1*max(abs(residualHist));

end

