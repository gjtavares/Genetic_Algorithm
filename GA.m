function [SolucoesFinal, CustoManutencaoFinal, CustoFalhaFinal] = EA()
    %% Dados do problema
      
    load Dados_Problema

    %% População Inicial

    Probabilidades = [0.07;0.2;0.3;0.4;0.55;0.7;0.85;0.32;0.2;0.05];
    Limites = [0;100;200;300;400;500;600;700;800;900;1000];
    for Intervalo=1:10
        N = 150;
        X = zeros(N,500);

        if Intervalo < 8
            for j=1:N
                for i=1:500
                    X(j,i) = 1;
                end
            end
            for j=1:N
                for i=1:500
                    if rand() <= Probabilidades(Intervalo);
                        X(j,i) = randi([2 3],1);     
                    end
                end
            end
        else
             for j=1:N
                for i=1:500
                    X(j,i) = 3;
                end
            end
            for j=1:N
                for i=1:500
                    if rand() <= Probabilidades(Intervalo);
                        X(j,i) = randi([1 2],1);     
                    end
                end
            end       
        end


        CM = zeros(N,1);
        CF = zeros(N,1);
        CustoManutencaoTotal = zeros(1,1);
        CustoFalhaTotal = zeros(1,1);
        Populacao = zeros(1,500);
        a=1;
        for i=1:N
               [CM(i,1),CF(i,1)] = FuncoesObjetivo(X(i,:),Dados_Problema);
               if CM(i,1) > Limites(Intervalo) && CM(i,1) <= Limites(Intervalo+1)
                   CustoManutencaoTotal(a,1) = CM(i,1);
                   CustoFalhaTotal(a,1) = CF(i,1);
                   Populacao(a,:) = X(i,:);
                   a = a+1;
               end
        end
        N = length(CustoManutencaoTotal);

        for Geracoes=1:3000
        %% Mecanismo de Seleção - Torneio

            IndicesSelecionados = randperm(N,randi(N));
            IndividuosSelecionados = CustoFalhaTotal(IndicesSelecionados,:);

            [M1, MelhorIndividuo] = min(IndividuosSelecionados);
            IndividuosSelecionados(MelhorIndividuo) = NaN;
            MelhorIndividuo = IndicesSelecionados(MelhorIndividuo);
            [M2, SegundoMelhorIndividuo] = min(IndividuosSelecionados);
            SegundoMelhorIndividuo = IndicesSelecionados(SegundoMelhorIndividuo);

            Pai_1 = Populacao(MelhorIndividuo,:);
            Pai_2 = Populacao(SegundoMelhorIndividuo,:);

        %% Recombinação

            Filhos = zeros(2,500);
            Corte = randi(500);
            if rand() <= 0.8
                Filhos(1,1:Corte) = Pai_1(1,1:Corte);
                Filhos(1,Corte+1:500) = Pai_2(1,Corte+1:500);
                Filhos(2,1:Corte) = Pai_2(1,1:Corte);
                Filhos(2,Corte+1:500) = Pai_1(1,Corte+1:500);
            else
                Filhos(1,1:Corte) = Pai_1(1,1:Corte);
                Filhos(1,Corte+1:500) = Pai_1(1,Corte+1:500);
                Filhos(2,1:Corte) = Pai_2(1,1:Corte);
                Filhos(2,Corte+1:500) = Pai_2(1,Corte+1:500);
            end

        %% Mutação 
        
            for j=1:2
                for i=1:500
                    if rand() <= 0.01
                        Filhos(j,i) = randi(3);     
                    end
                end
            end         

        %% Seleção dos sobreviventes
        
            CustoManutencaoFilho = zeros(2,1);
            CustoFalhaFilho = zeros(2,1);
            for i=1:2
                [CustoManutencaoFilho(i,1),CustoFalhaFilho(i,1)] = FuncoesObjetivo(Filhos(i,:),Dados_Problema);
            end

            for i=1:2
                IndIgual = 0;
                for j=1:N
                    if CustoFalhaFilho(i,1) == CustoFalhaTotal(j,1)
                        IndIgual=1;
                        break
                   end
                end

                if IndIgual == 0
                    %[P1, PiorIndividuo] = max(CustoFalhaTotal);
                    if  CustoManutencaoFilho(i,1) <=Limites(Intervalo+1) && CustoManutencaoFilho(i,1) > Limites(Intervalo) && CustoFalhaFilho(i,1) < CustoFalhaTotal(MelhorIndividuo,1) 
                        Populacao(MelhorIndividuo,:) = Filhos(i,:);
                        CustoFalhaTotal(MelhorIndividuo) = CustoFalhaFilho(i,1);
                        CustoManutencaoTotal(MelhorIndividuo) = CustoManutencaoFilho(i,1);
                        ia=1;
                    elseif  CustoManutencaoFilho(i,1) <=Limites(Intervalo+1) && CustoManutencaoFilho(i,1) > Limites(Intervalo) && CustoFalhaFilho(i,1) < CustoFalhaTotal(SegundoMelhorIndividuo,1) 
                        Populacao(SegundoMelhorIndividuo,:) = Filhos(i,:);
                        CustoFalhaTotal(SegundoMelhorIndividuo) = CustoFalhaFilho(i,1);
                        CustoManutencaoTotal(SegundoMelhorIndividuo) = CustoManutencaoFilho(i,1);
                        ib=1;
                    end
                end
            end

        end

        %% Elimina Soluções Dominadas
        PosDom = zeros(1,1);
        ND=1;

        for x=1:N
            Dom = 0;
            for z=1:N
                if CustoManutencaoTotal(x,1) > CustoManutencaoTotal(z,1) && CustoFalhaTotal(x,1) > CustoFalhaTotal(z,1)
                    CustoManutencaoTotal(x,1) = NaN;
                    CustoFalhaTotal(x,1) = NaN;
                    Dom = 1;
                end    
            end
            if Dom == 0;
                PosDom(1,ND) = x;
                ND = ND + 1;
            end        
        end

        %% Retorna Parametros
        switch Intervalo
            case 1
                Solucoes_1 = Populacao(PosDom,:);
                CustoManutencaoFinal_1 = CustoManutencaoTotal(PosDom);
                CustoFalhaFinal_1 = CustoFalhaTotal(PosDom);
            case 2
                Solucoes_2 = Populacao(PosDom,:);
                CustoManutencaoFinal_2 = CustoManutencaoTotal(PosDom);
                CustoFalhaFinal_2 = CustoFalhaTotal(PosDom);
             case 3
                Solucoes_3 = Populacao(PosDom,:);
                CustoManutencaoFinal_3 = CustoManutencaoTotal(PosDom);
                CustoFalhaFinal_3 = CustoFalhaTotal(PosDom);
             case 4
                Solucoes_4 = Populacao(PosDom,:);
                CustoManutencaoFinal_4 = CustoManutencaoTotal(PosDom);
                CustoFalhaFinal_4 = CustoFalhaTotal(PosDom);
            case 5
                Solucoes_5 = Populacao(PosDom,:);
                CustoManutencaoFinal_5 = CustoManutencaoTotal(PosDom);
                CustoFalhaFinal_5 = CustoFalhaTotal(PosDom);
            case 6
                Solucoes_6 = Populacao(PosDom,:);
                CustoManutencaoFinal_6 = CustoManutencaoTotal(PosDom);
                CustoFalhaFinal_6 = CustoFalhaTotal(PosDom);
            case 7
                Solucoes_7 = Populacao(PosDom,:);
                CustoManutencaoFinal_7 = CustoManutencaoTotal(PosDom);
                CustoFalhaFinal_7 = CustoFalhaTotal(PosDom);
            case 8
                Solucoes_8 = Populacao(PosDom,:);
                CustoManutencaoFinal_8 = CustoManutencaoTotal(PosDom);
                CustoFalhaFinal_8 = CustoFalhaTotal(PosDom);
            case 9
                Solucoes_9 = Populacao(PosDom,:);
                CustoManutencaoFinal_9 = CustoManutencaoTotal(PosDom);
                CustoFalhaFinal_9 = CustoFalhaTotal(PosDom);
            case 10
                Solucoes_10 = Populacao(PosDom,:);
                CustoManutencaoFinal_10 = CustoManutencaoTotal(PosDom);
                CustoFalhaFinal_10 = CustoFalhaTotal(PosDom);
        end


    end
    SolucoesFinal = [Solucoes_1;Solucoes_2;Solucoes_3;Solucoes_4;Solucoes_5;Solucoes_6;Solucoes_7;Solucoes_8;Solucoes_9;Solucoes_10];
    CustoManutencaoFinal = [CustoManutencaoFinal_1;CustoManutencaoFinal_2;CustoManutencaoFinal_3;CustoManutencaoFinal_4;CustoManutencaoFinal_5;CustoManutencaoFinal_6;CustoManutencaoFinal_7;CustoManutencaoFinal_8;CustoManutencaoFinal_9;CustoManutencaoFinal_10];
    CustoFalhaFinal = [CustoFalhaFinal_1;CustoFalhaFinal_2;CustoFalhaFinal_3;CustoFalhaFinal_4;CustoFalhaFinal_5;CustoFalhaFinal_6;CustoFalhaFinal_7;CustoFalhaFinal_8;CustoFalhaFinal_9;CustoFalhaFinal_10];

end


