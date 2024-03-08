function [ total_cost,Route ] = BasicEvaluation( solver_type,Assignment,Cost,Demand,param )
depot=param('depot');
Capacity=param('capacity');
compensation_ratio=param('compensation_ratio');
costOC=compensation_ratio*sum(Cost(depot,find(Assignment==0)));
[ Route,costPF ] = CVRP_solver( solver_type,find(Assignment==1),Cost,depot,Capacity,Demand,param);
total_cost=costOC+costPF;
end

