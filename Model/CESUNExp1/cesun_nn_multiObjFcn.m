function [score] = cesun_nn_multiObjFcn(latency,netSet,reliabilityThreshold,reliabilityMinimumConfidence,useConfidence)
x=[latency; zeros(numel(latency),1)]; %Add outages
[meanTargets,stDevs]=cesun_nn_func(x,netSet);

if nargin < 5 || isempty(useConfidence)
    useConfidence=0;
end

normFactorLatency=600;
normFactorPerformance=1.6e6;
normMu=0;
normSigma=0.6;

perfIdx=1;
reliIdx=3;
%Assuming reliabilityConfidence comes in as fraction %
confidenceOnReliability=normcdf((reliabilityThreshold-meanTargets(reliIdx))/stDevs(reliIdx),normMu,normSigma);
if useConfidence==1
    score=meanTargets(perfIdx)/normFactorPerformance-1*(confidenceOnReliability/reliabilityMinimumConfidence)^4-1*(meanTargets(reliIdx)/reliabilityThreshold)^2+sum(latency)/normFactorLatency;
else
    score=meanTargets(perfIdx)/normFactorPerformance-1*(meanTargets(reliIdx)/reliabilityThreshold)^2+sum(latency)/normFactorLatency;
end

end

