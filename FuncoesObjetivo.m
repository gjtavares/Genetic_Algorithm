function [CustoManutencaoTotal, CustoFalhaTotal] = FuncoesObjetivo(Solucoes,Data)

CustoManutencao = 0;
CustoFalha = 0;
%-------------------------------------------------------------------------
for i = 1:length(Solucoes),
    CustoManutencao = CustoManutencao + Data.MP(Solucoes(i)).Cost;
    %---------------------------------------------------------------------
    Transf = Data.Transf(i);
    %- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    eta = Data.ClusterPar(Transf.Cluster,1);
    beta = Data.ClusterPar(Transf.Cluster,2);
    %- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    DeltaAge = Data.TimeHorizon * Data.MP(Solucoes(i)).AgingFactor;
    %- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    Ft = wblcdf(Transf.CurrentAge+DeltaAge,eta,beta);
    Ft0 = wblcdf(Transf.CurrentAge,eta,beta);
    Risco = (Ft - Ft0) / (1 - Ft0);
    CustoF = Risco * Transf.FailCost;
    %- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    CustoFalha = CustoFalha + CustoF;    
end

CustoManutencaoTotal = CustoManutencao;
CustoFalhaTotal = CustoFalha;

end

