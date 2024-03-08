% main
addpath('core');
addpath('operator');
addpath('solver');
addpath('utils');
addpath(genpath('benchmark'));
problem_scale='medium-scale';
[ scenarios, filenames ] = ReadScenario( problem_scale );
param=containers.Map;
param('EM')=1;            % Evaluation Method (EM) for the PF-OC assignment plan in the CVRP-OC
% algorithm setting
param('alg_name')='SAFE'; 
param('version')='II';     % I or II, representing one-way and two-way switch mechanisms
param('n_run')=30;        % Number of independent runs
param('pop_size')=50;     % Population size
% problem setting
param('solver_pool')={'greed+2opt-1','greed+2opt','vns+2opt','acs+2opt'};  % each candidate in pool is treated as an EM
param('n_EM') = length(param('solver_pool'));
param('compensation_ratio')=0.8;

param('run_time_max')=300;           % maximum running time
param('run_time')=0;                % running time
param('iter_max')=100000;           % maximum allowed iterations
param('stop_criterion')='run_time'; % 'iteration' or 'run_time', stopping criterion of the algorithm
param('n_stag_max')=50;             % number of stagnating generations for triggering the EM switch

% data buffer for recording performance on every problem instance
n_prob_instances = length(scenarios);
MeanCost=nan(n_prob_instances,1);
WorstCost=nan(n_prob_instances,1);
BestCost=nan(n_prob_instances,1);
NumberOC=nan(n_prob_instances,2);
MeanTime=nan(n_prob_instances,1);
% begin running
for prob_id=1:length(scenarios)
    disp(['Running GA-', param('alg_name'), '-', param('version') ' on problem ' filenames{prob_id}]);
    param('case')=num2str(prob_id);
    param('n')=scenarios(prob_id,1);
    param('k')=scenarios(prob_id,2);
    param('path')=[filenames{prob_id},'.vrp'];
    [Cost,depot,Capacity,Demand,Location,C2C] = ReadInstance(param('path'));

    % data buffer for recording performance on every independent runs
    best_assignment=ones(param('n_run'), param('n'));  % the optimzied assignment
    best_cost=ones(1,param('n_run'));                  % total cost of the optimzied assignment
    n_OC=zeros(1,param('n_run'));                      % number of OC in the optimized assignment
    run_time=ones(1,param('n_run'));
    for run_id=1:param('n_run')
	    disp(['Run ' num2str(run_id)]);
        [best_assignment(run_id,:), best_cost(run_id), run_time(run_id)] = GA_SAFE(param);
        n_OC(run_id) = length(find(best_assignment(run_id,:)==0));
        fprintf('Time:%.2f,Cost:%.2f,#OC:%d\n', run_time(run_id), best_cost(run_id), n_OC(run_id));
    end
    MeanCost(prob_id)=mean(best_cost);
    WorstCost(prob_id)=max(best_cost);
    BestCost(prob_id)=min(best_cost);
    MeanTime(prob_id)=mean(run_time);
    NumberOC(prob_id,:)=[mean(n_OC),std(n_OC)];
end
