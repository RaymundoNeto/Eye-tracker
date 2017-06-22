function [X_Gaze,Y_Gaze,TotalTime,IndStimuli,Stimuli,Pupil]=loadET(nomearquivo,colunas)
% Esta fun��o carrega os arquivos gerados no experimento da pesquisadora
% Thais Contencas (Doutorado)
% Sintaxe: 
% Input:[X_Gaze,Y_Gaze,TotalTime,IndStimuli,Stimuli]=loadThais(nomearquivo)
%   nomearquivo - nome do arquivo que ser� carregado (com ou sem caminho do diret?rio)
% Output:
%   X_Gaze - Vetor de dados de deslocamento do movimento dos olhos no eixo X.
%   Y_Gaze - Vetor de dados de deslocamento do movimento dos olhos no eixo Y. 
%   TotalTime - Vetor com os dados de tempo (cronometro).
%   IndStimuli - Vetor com os ?ndices de onde ocorreram os est�mulos no
%   experimento.
%   Stimuli - Vetor em Cell Array identificando qual est�mulo foi aplicado.
% 
% Autor: Raymundo Machado de Azevedo Neto, raymundo.neto@usp.br
% Data: 22-05-2012

% Abrir arquivo
col='%s';
for k=1:colunas-1    
    col=[col ' %s'];
end
    
fid=fopen(nomearquivo);
arq=textscan(fid,col);
% O arquivo � armezenado em 15 vari�veis de cell array. Cada cell array 
% possui uma coluna e todas as linhas dessa coluna do arquivo carregado. Os
% dados est�o em cell arrays, contendo characteres.

% Inicializar contador
m=1;
% La�o para criar os vetores com os indices de onde ocorreram os estimulos
% e quais estimulos foram apresentados em cada indice
for k=1:length(arq{1})-1
    if isequal(arq{1}{k},'16')
        inicio=k;
    end
    if isequal(arq{1}{k},'12') % Se a coluna 1 tiver o numero 12, h� est�mulo
        IndStimuli(m,1)=k; %#ok<*AGROW> % indicar em qual linha (k) foi encontrado o numero 12
        Stimuli{m,1}=arq{3}{k}; % indicar qual o est�mulo na linha k
        m=m+1; % atualizar contador
    end
    % alocar valores das colunas 2 (TotalTime), 4 (X_Gaze) , 5 (Y_Gaze), e 7(PupilWidth) 
    TotalTime(k,1)=str2double(arq{2}{k});
    X_Gaze(k,1)=str2double(arq{4}{k}); %#ok<*SAGROW> 
    Y_Gaze(k,1)=str2double(arq{5}{k});
    Pupil(k,1)=str2double(arq{7}{k});
end

% Eliminar tempo apresenta��o est�mulo

TotalTime(IndStimuli)=[];

% Eliminar linhas que n�o cont�m dados �teis
X_Gaze=X_Gaze(inicio+1:end);
Y_Gaze=Y_Gaze(inicio+1:end);
TotalTime=TotalTime(inicio+2:end-1);
Pupil=Pupil(inicio+1:end);

% Eliminar espa�os vazios (NaN) das variaveis X_Gaze e Y_Gaze
X_Gaze=X_Gaze(~isnan(X_Gaze));
Y_Gaze=Y_Gaze(~isnan(Y_Gaze)); 
Pupil=Pupil(~isnan(Pupil)); 

% Sincronizando o vetor IndStimuli com os demais
IndStimuli=IndStimuli-inicio; % Elimina as primeiras 25 linhas de cabe?alho na contagem
% Para evitar que o deslocamento dos vetores ao eliminar as c�lulas vazias
% dessincronize os dados, subtrair do � ndice do est�mulo o n�mero de vezes
% que o vetor foi deslocado + 1.
for k=2:length(IndStimuli)
    IndStimuli(k)=IndStimuli(k)-k+1;
end

% O Eye-tracker gera alguns zeros, aleatoriamente, na coluna TotalTime.
% Este trecho substitui esses zeros pela m?dia entre o valor anterior e o
% posterior � esse zero.
ind_zeros=find(TotalTime==0);% Acha os zeros
TotalTime(ind_zeros)=mean([TotalTime(ind_zeros+1) TotalTime(ind_zeros-1)],2); % Troca os zeros
TotalTime=[0;TotalTime];

% Fechar arquivo
fclose(fid);