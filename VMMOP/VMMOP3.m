classdef VMMOP3 < PROBLEM
% <problem> <VMMOP>
% Benchmark VMMOP proposed by Mingli Shi

%------------------------------- Reference --------------------------------
% K. Deb, L. Thiele, M. Laumanns, and E. Zitzler, Scalable test problems
% for evolutionary multiobjective optimization, Evolutionary multiobjective
% Optimization. Theoretical Advances and Applications, 2005, 105-145.
%------------------------------- Copyright --------------------------------
% Copyright (c) 2018-2019 BIMK Group. You are free to use the PlatEMO for
% research purposes. All publications which use this platform or any code
% in the platform should acknowledge the use of "PlatEMO" and reference "Ye
% Tian, Ran Cheng, Xingyi Zhang, and Yaochu Jin, PlatEMO: A MATLAB platform
% for evolutionary multi-objective optimization [educational forum], IEEE
% Computational Intelligence Magazine, 2017, 12(4): 73-87".
%--------------------------------------------------------------------------

    methods
        %% Initialization
        function obj = VMMOP3()
            if isempty(obj.Global.M)
                obj.Global.M = 3;
            end
            if isempty(obj.Global.D)
                obj.Global.D = obj.Global.M + 9;
            end
             if isempty(obj.Global.LC)
                obj.Global.LC = round((obj.Global.D-obj.Global.M+1)/2)+obj.Global.M-1;
            end
             if isempty(obj.Global.LD)
                obj.Global.LD = obj.Global.D-obj.Global.LC;
            end
            obj.Global.lower    = zeros(1,obj.Global.D);
            obj.Global.upper    = ones(1,obj.Global.LC);
            obj.Global.upper    = [obj.Global.upper,ones(1,obj.Global.LD)*10];
            obj.Global.L    = ones(1,obj.Global.LD)*10;%每个离散变量的离散值个数
            obj.Global.encoding = 'mixed';
        end
        %% Calculate objective values
        function PopObj = CalObj(obj,PopDec)
            [N,D]  = size(PopDec);
            M      = obj.Global.M;
            objs = fliplr(cumprod([ones(N,1),cos(PopDec(:,1:M-1)*pi/2)],2)).*[ones(N,1),sin(PopDec(:,M-1:-1:1)*pi/2)];
            a    =  Cartesian2Polar(objs);%得到球坐标
            a=a(:,2:end);%取出球坐标的角度
            L1 = 1+floor(sum(sin(a),2)./(M-1)*(obj.Global.LC-M));
            L2 = 1+floor(sum(cos(a),2)./(M-1)*(obj.Global.LD-1));
             if ~isempty(obj.Global.L1)
                obj.Global.L1 = [obj.Global.L1(1:N,:),L1];
                obj.Global.L2 = [obj.Global.L2(1:N,:),L2];
            end
            for i = 1:N
                PopDec1 = PopDec(i,M:M-1+L1(i));
                PopDec2 = PopDec(i,obj.Global.LC+1:obj.Global.LC+L2(i));
                PopDec2 = PopDec2./obj.Global.L(1:L2(i));
                Dec     = [PopDec1,PopDec2];
                g(i,1)      = 100*(L1(i)+L2(i)+sum((Dec-0.5).^2-cos(20*pi*(Dec-0.5)),2));
            end
            PopObj = repmat(1+g,1,M).*objs;
        end
        %% Sample reference points on Pareto front
        function P = PF(obj,N)
            P = UniformPoint(N,obj.Global.M);
            P = P./repmat(sqrt(sum(P.^2,2)),1,obj.Global.M);
        end
    end
end