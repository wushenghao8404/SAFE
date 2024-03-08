function [ scenarios,filenames ] = ReadScenario( scale )
% ReadScenario
if strcmp(scale,'tiny-scale')
    scenarios=[32 5;31 5;13 4;22 4;23 3;16 8;19 2;20 2;22 2;22 8];
    filenames={'A-n32-k5','B-n31-k5','E-n13-k4','E-n22-k4','E-n23-k3','P-n16-k8','P-n19-k2','P-n20-k2','P-n22-k2','P-n22-k8'};
elseif strcmp(scale,'small-scale')
    scenarios=[37 6;39 6;48 7;39 5;41 6;44 7;45 4;40 5;45 5;50 7];
    filenames={'A-n37-k6','A-n39-k6','A-n48-k7','B-n39-k5','B-n41-k6','B-n44-k7','F-n45-k4','P-n40-k5','P-n45-k5','P-n50-k7'};
elseif strcmp(scale,'medium-scale')
    scenarios=[55 9;60 9;65 9;69 9;80 10;50 8;57 7;63 10;67 10;78 10;51 5;76 7;76 15;101 8;101 14;45 4;72 4;135 7;51 10;55 15;60 15;65 10;70 10;76 5;101 4];
    filenames={'A-n55-k9','A-n60-k9','A-n65-k9','A-n69-k9','A-n80-k10','B-n50-k8','B-n57-k7','B-n63-k10','B-n67-k10','B-n78-k10','E-n51-k5','E-n76-k7','E-n76-k15','E-n101-k8','E-n101-k14','F-n45-k4','F-n72-k4','F-n135-k7','P-n51-k10','P-n55-k15','P-n60-k15','P-n65-k10','P-n70-k10','P-n76-k5','P-n101-k4'};
elseif strcmp(scale,'large-scale')
    scenarios=[167 10;190 8;214 11;237 14;261 13;303 21;331 15;359 29;384 52;411 19];
    filenames={'X-n167-k10','X-n190-k8','X-n214-k11','X-n237-k14','X-n261-k13','X-n303-k21','X-n331-k15','X-n359-k29','X-n384-k52','X-n411-k19'};
elseif strcmp(scale,'supplementary-scale')
    scenarios=[60 9;69 9;50 8;63 10;67 10;76 7;45 4;51 10;65 10;76 5];
    filenames={'A-n60-k9','A-n69-k9','B-n50-k8','B-n63-k10','B-n67-k10','E-n76-k7','F-n45-k4','P-n51-k10','P-n65-k10','P-n76-k5'};
end
end