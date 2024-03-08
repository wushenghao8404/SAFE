function [ Route,CostPF ] = CVRP_solver( solver_type,Customer,Cost,depot,Capacity,Demand,param)
% CVRP_solver
Route=[];
CostPF=1e25;
if strcmp(solver_type,'acs+2opt')
    [ Route,CostPF,~ ] = solverACS( Customer,Cost,depot,Capacity,Demand,param,'2opt');
elseif strcmp(solver_type,'acs+3opt')
    [ Route,CostPF,~ ] = solverACS( Customer,Cost,depot,Capacity,Demand,param,'3opt');
elseif strcmp(solver_type,'acs')
    [ Route,CostPF,~ ] = solverACS( Customer,Cost,depot,Capacity,Demand,param,'none');
elseif strcmp(solver_type,'greed+2opt')
    ntrial=min(100,length(Customer));
    for i=1:ntrial
        [ tempRoute,tempCostPF,~ ] = solverGreedy(Customer,Cost,depot,Capacity,Demand,param,'2opt' );
        if tempCostPF<CostPF
            Route=tempRoute;
            CostPF=tempCostPF;
        end
    end
elseif strcmp(solver_type,'greed+2opt-1')
    [ Route,CostPF,~ ] = solverGreedy(Customer,Cost,depot,Capacity,Demand,param,'2opt' );
elseif strcmp(solver_type,'greed+2opt-10')
    for i=1:10
        [ tempRoute,tempCostPF,~ ] = solverGreedy(Customer,Cost,depot,Capacity,Demand,param,'2opt' );
        if tempCostPF<CostPF
            Route=tempRoute;
            CostPF=tempCostPF;
        end
    end
elseif strcmp(solver_type,'vns')
    [ Route,CostPF,~ ] = solverVNS( Customer,Cost,depot,Capacity,Demand,param,'none' );
elseif strcmp(solver_type,'vns+2opt')
    [ Route,CostPF,~ ] = solverVNS( Customer,Cost,depot,Capacity,Demand,param,'2opt' );
else
    error('UNEXPECTED SOLVER TYPE');
end
end