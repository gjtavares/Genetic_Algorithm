function main()
clear all
close all
clc

[SolucoesFinal, CustoManutencaoFinal, CustoFalhaFinal] = GA();

 csvwrite('GabrielTavares.csv',SolucoesFinal)
 
end

