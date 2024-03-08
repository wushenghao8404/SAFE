function [best_found_assignment,best_found_cost,time]=GA_SAFE(param)
% GA_SAFE
filename=param('path');
[Cost, Depot, Capacity, Demand, Location, NearestCustomerIds] = ReadInstance(filename);
N=param('n');                    % number of customers
param('run_time')=0;             % record the running time
param('n_stag_EM')=0;            % number of stagnating generations of an EM
param('n_stag_best')=0;          % number of stagnating generations of the best cost
param('depot')=Depot;
param('capacity')=Capacity;
param('C2C')=NearestCustomerIds;

EM=1;               % evaluation method (EM) id
iteration=1;        % iteration counter
cr=0.7;             % crossover probability
pm=0.1;             % mutation probability
pop_size=param('pop_size');        % population size
Assignments=ones(pop_size,N);       % record current population of individual assignments
Fitnesses=zeros(pop_size,1);        % record current fitness of each assignment                 
Routes=cell(pop_size,1);            % record route of each assignment
solver_pool=param('solver_pool');

RouteBest=cell(param('n_EM'),1);
AssignmentBest=zeros(param('n_EM'),N);
FitnessBest=zeros(param('n_EM'),1);

ArchiveSize=50;
ArchiveAssignments=cell(param('n_EM'),1);
ArchiveFitnesses=cell(param('n_EM'),1);
ArchiveRoutes=cell(param('n_EM'),1);
for i=1:param('n_EM')
    ArchiveRoutes{i}={};
end

termination=false;
%%
% population initialization
itic=tic;
for i=1:pop_size
    Assignments(i,:)=binornd(1,0.5,[1 N]);
    Assignments(i,Depot)=1;
    solver_pool=param('solver_pool');
    [total_cost, route]=BasicEvaluation(solver_pool{EM},Assignments(i,:),Cost,Demand,param);    % total cost of a given assignment
    Fitnesses(i,:)=1/total_cost;
    Routes{i} = route;
end
[~,id_best]=max(Fitnesses);
AssignmentBest(EM,:)=Assignments(id_best,:);
FitnessBest(EM,:)=Fitnesses(id_best,:);
RouteBest{EM}=Routes{id_best};
ArchiveAssignments{EM}=[ArchiveAssignments{EM};AssignmentBest(EM,:)];
ArchiveFitnesses{EM}=[ArchiveFitnesses{EM};FitnessBest(EM,:)];
ArchiveRoutes{EM}=[ArchiveRoutes{EM};RouteBest{EM}];

%% begin iteration
while ~termination
%    disp(iteration);
    OffpsringRoutes=cell(pop_size,1);
    OffspringAssignments=zeros(pop_size,N);
    OffspringFitnesses=zeros(pop_size,1);
    % evaluation method (EM) adaption
    prev_EM=EM;
    % environment switch
    %% SAFE-I
    if strcmp(param('version'),'I')
        if param('n_stag_EM')>=param('n_stag_max')
            param('n_stag_EM')=0;
            next_EMs=[];
            if prev_EM==1
                next_EMs=2;
            elseif prev_EM==2
                next_EMs=[3 4];
            elseif prev_EM==3
                next_EMs=4;
            elseif prev_EM==4
                next_EMs=3;
            end
            % Archive migration: select two high-quality assignments and 
            % re-evaluate them with different candidate next EMs
            [ArchiveAssignments,ArchiveFitnesses,ArchiveRoutes,AssignmentBest,FitnessBest,RouteBest] = ...
                ArchiveMigration(ArchiveAssignments,ArchiveFitnesses,ArchiveRoutes,...
                                 AssignmentBest,FitnessBest,RouteBest,prev_EM,next_EMs,solver_pool,Cost,Demand,param);
            % pre-evaluation for calculating contribution factor of
            % different candidate next EMs
            contribution_factor=zeros(1,length(next_EMs));
            for k=1:length(next_EMs)
                next_EM = next_EMs(k);
                [ contribution_factor(k),~,~,~ ] = evalEMContribution( 'best-improvement',Assignments,Fitnesses,...
                    ArchiveAssignments{next_EM},ArchiveFitnesses{next_EM},ArchiveRoutes{next_EM}, Cost, Demand, next_EM, param );
            end
            if isempty(find(contribution_factor>0, 1))
                EM=prev_EM;
            else
                ki=find(contribution_factor==max(contribution_factor),1);
                EM=next_EMs(ki);
            end
        end
    %% SAFE-II
    elseif strcmp(param('version'),'II') 
        if param('n_stag_EM')>=param('n_stag_max')
            param('n_stag_EM')=0;
            next_EMs=[];
            if prev_EM==1
                next_EMs=[3 4];
            elseif prev_EM==2
                next_EMs=[3 4];
            elseif prev_EM==3
                next_EMs=[1 2];
            elseif prev_EM==4
                next_EMs=[1 2];
            end
            % Archive migration: select two high-quality assignments and 
            % re-evaluate them with different candidate next EMs
            [ArchiveAssignments,ArchiveFitnesses,ArchiveRoutes,AssignmentBest,FitnessBest,RouteBest] = ...
                ArchiveMigration(ArchiveAssignments,ArchiveFitnesses,ArchiveRoutes,...
                                 AssignmentBest,FitnessBest,RouteBest,prev_EM,next_EMs,solver_pool,Cost,Demand,param);
            % pre-evaluation for calculating contribution factor of
            % different candidate next EMs
            contribution_factor=zeros(1,length(next_EMs));
            for k=1:length(next_EMs)
                next_EM = next_EMs(k);
                % pre-evaluation
                if next_EM<=2
                    [ contribution_factor(k),~,~,~ ] = evalEMContribution( 'alignment',Assignments,Fitnesses,...
                        ArchiveAssignments{next_EM},ArchiveFitnesses{next_EM},ArchiveRoutes{next_EM},Cost,Demand,next_EM,param );
                else
                    [ contribution_factor(k),~,~,~ ] = evalEMContribution( 'best-improvement',Assignments,Fitnesses,...
                        ArchiveAssignments{next_EM},ArchiveFitnesses{next_EM},ArchiveRoutes{next_EM},Cost,Demand,next_EM,param );
                end
            end
            if prev_EM<=2
                ki=find(contribution_factor==max(contribution_factor),1);
                EM=next_EMs(ki);
            else
                ki=find(contribution_factor==min(contribution_factor),1);
                EM=next_EMs(ki);
            end
        end
    else
        error('INVALID VERSION');
    end
    %% selection
    prob_cum=cumsum(Fitnesses(:,1)/sum(Fitnesses(:,1)));
    % selection
    for i=1:pop_size
        selected_ids=find(prob_cum>=rand);
        OffspringAssignments(i,:)=Assignments(selected_ids(1),:);    
    end
    %% offspring reproduction
    % crossover
    for i=1:2:pop_size
        [OffspringAssignments(i,:),OffspringAssignments(i+1,:)]=...
            opCrossover( 'mpx',OffspringAssignments(i,:),OffspringAssignments(i+1,:),cr,param );
    end
    % single-point mutation
    for i=1:pop_size
       OffspringAssignments(i,:)=opMutation( 'spm',OffspringAssignments(i,:),pm,param );
    end
    %% evaluation
    replace_worst=true;  
    localImproved=false;
    globalImproved=false;
    for i=1:pop_size
        nbi=-1;
        mind=1e25;
        tA=ArchiveAssignments{EM};
        for j=1:size(tA,1)
            td=sum(abs(OffspringAssignments(i,:)-tA(j,:)));
            if td<mind
                mind=td;
                nbi=j;
            end
        end
        nbA=tA(nbi,:);
        nbC=1/ArchiveFitnesses{EM}(nbi,1);
        nbR=ArchiveRoutes{EM}{nbi};
        [total_cost,OffpsringRoutes{i}]=NeighborBestEvaluation( OffspringAssignments(i,:),EM,Cost,Demand,param,nbC,nbA,nbR );
        OffspringFitnesses(i,:)=1/total_cost;
        if OffspringFitnesses(i,1)>FitnessBest(EM,1)
            if OffspringFitnesses(i,1)>max(FitnessBest)
                globalImproved=true;
            end
            localImproved=true;
            replace_worst=false;
            FitnessBest(EM,1)=OffspringFitnesses(i,:);
            AssignmentBest(EM,:)=OffspringAssignments(i,:);
            RouteBest{EM}=OffpsringRoutes{i};
        end
    end
   %% archive management
   % archive insertion
   for i=1:pop_size
       [ ArchiveAssignments{EM},ArchiveFitnesses{EM},ArchiveRoutes{EM} ] = ArchiveInsertion( OffspringAssignments(i,:),OffspringFitnesses(i,:),OffpsringRoutes{i},ArchiveAssignments{EM},ArchiveFitnesses{EM},ArchiveRoutes{EM},param);
   end
    % archive reduction
    for i=1:param('n_EM')
        if size(ArchiveAssignments{i},1)>ArchiveSize
            [ ArchiveAssignments{i},ArchiveFitnesses{i},ArchiveRoutes{i} ] = ArchiveReduction( ArchiveAssignments{i},ArchiveFitnesses{i},ArchiveRoutes{i},ArchiveSize );
        end
    end
    %% environmental stagnation udpade
    if localImproved
        param('n_stag_EM')=0;
        if globalImproved
            param('n_stag_best')=0;
        else
            param('n_stag_best')=param('n_stag_best')+1;
        end
    else
        param('n_stag_EM')=param('n_stag_EM')+1;
    end
    %% elitlist strategy
    if replace_worst
        select_ids=find(OffspringFitnesses(:,1)==min(OffspringFitnesses(:,1)));
        worst_i=select_ids(1);
        OffspringAssignments(worst_i,:)=AssignmentBest(EM,:);
        OffspringFitnesses(worst_i,:)=FitnessBest(EM,1);
    end
    param('run_time')=toc(itic);
    if strcmp(param('stop_criterion'),'iteration')
        if iteration>=param('iter_max')
            break;
        end
    elseif strcmp(param('stop_criterion'),'run_time')
        if param('run_time')>param('run_time_max')
            break;
        end
    end
    %% intermediate output
    iteration=iteration+1;
    Fitnesses=OffspringFitnesses;
    Assignments=OffspringAssignments;
    Routes=OffpsringRoutes;
end
time=toc(itic);
[~, best_EM] = max(FitnessBest);
best_found_assignment=AssignmentBest(best_EM,:);
best_found_cost=1/FitnessBest(best_EM,:);
best_found_route=RouteBest{best_EM};
end