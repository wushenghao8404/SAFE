function [ArA,ArF,ArR,Ab,Fb,Rb] = ArchiveMigration(ArA,ArF,ArR,Ab,Fb,Rb,prev_EM,next_EMs,solver_pool,Cost,Demand,param)
% ArchiveMigration

% select two high-quality assignments for re-evaluation with
% different next EMs
prob_fitness=cumsum(ArF{prev_EM}/sum(ArF{prev_EM}));
elite_solution_id1 = find(prob_fitness>=rand,1);
elite_solution_id2 = find(ArF{prev_EM}==max(ArF{prev_EM}),1);
selected_ids=[elite_solution_id1 elite_solution_id2];


for k=1:length(next_EMs)
    next_EM = next_EMs(k);
    
    for i=1:length(selected_ids)
        next_EM_str = solver_pool{next_EM};
        selected_assignment = ArA{prev_EM}(selected_ids(i),:);
        [total_cost,route] = BasicEvaluation( next_EM_str, selected_assignment,Cost,Demand,param);

        if 1/total_cost>Fb(next_EM,1)
            Ab(next_EM,:)=selected_assignment;
            Fb(next_EM,1)=1/total_cost;
            Rb{next_EM}=route;
        end
        
        [ ArA{next_EM}, ArF{next_EM}, ArR{next_EM} ] = ...
            ArchiveInsertion( selected_assignment, 1/total_cost, route,...
                              ArA{next_EM}, ArF{next_EM}, ArR{next_EM},param);
    end
end
end

