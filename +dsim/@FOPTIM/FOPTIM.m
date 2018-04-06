classdef FOPTIM < handle
    % FOPTIM simple feedback controller
    
    properties
        Kp=0.1;
        Ki=0.0;
        Kd=0.05;
        lastError=0;
        targetError=0;
        integralError=0;
        dError=0;
        lastTarget=0;
    end
    
    methods
        function obj=FOPTIM()
        end
        
        function putObjective(obj,value)
            error=value-obj.targetError;
            obj.integralError=obj.integralError+error;
            obj.dError=obj.lastError-error;
            obj.lastError=error;
        end
        
        function target=getTarget(obj)
            gain=obj.Kp*obj.lastError;
            gain=gain+obj.Ki*obj.integralError;
            gain=gain+obj.Kd*obj.dError;
            target=obj.lastTarget+gain;
            obj.lastTarget=target;
        end
    end
    
end

