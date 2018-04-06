classdef MktLogger < dsim.Agent
    %MKTLOGGER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        priceHist=[];
        optimalPriceHist=[];
        residualHist=[];
        timeHist=[];
        nextExec=0;
        execPeriod=1;
        MktList;
        ISO;
        profitList;
        test_profitHist;
        test_powerHist;
    end
    
    methods
        
        function obj=MktLogger()
        end
        
        function init(obj)
            DSim=dsim.DSim.getInstance();
            eTime=DSim.endTime;
            nHist=ceil(eTime/obj.execPeriod);
            obj.priceHist=zeros(nHist,1);
            obj.residualHist=zeros(nHist,1);
            obj.timeHist=zeros(nHist,1);
            obj.optimalPriceHist=zeros(nHist,1);
            nAgents=length(DSim.agentList);
            obj.MktList={};
            obj.ISO=[];
            for i=1:nAgents
                agent=DSim.agentList{i};
                if isa(agent,'dsim.ISO')
                    obj.ISO=agent;
                elseif isa(agent,'dsim.MktPlayer')
                    obj.MktList{end+1}=agent;
                end
            end
            obj.profitList=zeros(length(obj.MktList),1);
            obj.queueAtTime(0.1);
        end
        
        function execute(obj,time)
            if time>=obj.nextExec
                obj.nextExec=time+obj.execPeriod;
                obj.logEvents(time);
                obj.queueAtTime(obj.nextExec);
            end
        end
        
        function logEvents(obj,time)
            tidx=floor(time/obj.execPeriod)+1;
            obj.timeHist(tidx)=time;
            %price=obj.ISO.bestPrice;
            %if isempty(price)
                price=obj.ISO.lastX;
            %end
            
            powerLevel=0;
            for i=1:length(obj.MktList)
                agent=obj.MktList{i};
                p=agent.calcPower(agent.Lambda,time);
                if agent.PrMin==0 % Consumer
                    profit=p*(agent.PrMax-price);
                else
                    profit=p*(agent.PrMin-price);
                end
                obj.profitList(i)=obj.profitList(i)+profit;
                powerLevel=powerLevel+p;
                if i==1
                    %obj.test_profitHist(end+1)=profit;
                    %obj.test_powerHist(end+1)=p;
                end
            end
            
            
            
            obj.residualHist(tidx)=powerLevel;
            obj.priceHist(tidx)=price;
            
            optPrice=0;
            %optPrice=dsim.optimalPrice(obj.MktList,[],time);
            obj.optimalPriceHist(tidx)=optPrice;

            %fprintf(1,'%d : $%2.1f %2.1f W\n',floor(time),round(price,1),round(powerLevel,1));
        end
                
        
    end
    
end

