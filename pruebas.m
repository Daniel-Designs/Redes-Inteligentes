clc 
clear all
close all 
 
%Proyecto de redes Neuronales

% - - - - - - - - - - - - - CONDICIONES INICIALES - - - - - - - - - - - - -
nTc = 100000; % Numero de ciclos de simulación

DIFS = 10;  %[ms]
SIFS = 5;   %[ms]
durRTS = 11;    %[ms]
durCTS = 11;    %[ms]
durACK = 11;    %[ms]
durDATA = 43;   %[ms]
sigma = 1;  %[ms]

I = 7;  % Numero de grados en la red
K = 15; % Tamaño del buffer
xi = 18;    % Numero de ranuras de Sleeping
N = 5;  % Numero de nodos en un grado - [5, 10, 15, 20]
W = 16; % Tamaño de ña ventana de contención - [16, 32, 64, 128, 256]
lambda = 0.0005;    % Tasa de paquetes generados por cada nodo [paquetes/seg.] - [0.0005, 0.001, 0.005, 0.03]

T = sigma*W + DIFS + 3*SIFS + durRTS + durACK + durCTS + durDATA; % Duración de una ranura
Tc = (2 + xi) * T;  % Duración de un ciclo de trabajo [ms]
TsimTotal = nTc * Tc;   % Duración total de la simulación [ms]
lambda2 = lambda * N * I;   % Tasa de paquetes generados a nivel de red [paquetes/seg.]

Tsim = 0; % Tiempo actual de la simulación
Ta = 0; % Tiempo asignado para el siguiente arribo
nRanura = 0;    % Numero de la ranura actual


% - - - - - - - - - - - - - VARIABLES DE CADA GRADO - - - - - - - - - - - - -
estadoGrados = zeros(1, I); % Estado que tiene actualmente cada grado en la red - [0: Rx, 1: Tx]
bufferNodoPorGrado = strings(I, N, K);  % Buffer para cada Nodo por Grado (Grado, Nodo, Tamaño del Buffer)


% - - - - - - - - - - - - - VARIABLES PARA ESTADISTICAS - - - - - - - - - - - - -
noPaquetesPerdidosPorGrado = zeros(1, I);   % Registro para paquetes perdidos por cada Grado
noPaquetesRecibidosPorGrado = zeros(1, I);  % Registro para paquetes recibidos exitosamente por cada Grado

retardoPaquetesPorGrado = zeros(I, 1);  % Registro para el retardo de todos los paquetes recibidos por cada Grado
retardoPromedioPorGrado = zeros(1, I);  % Registro del retardo promedio por Grado




% - - - - - - - - - - - - - PRUEBAS - - - - - - - - - - - - -
%  - Desplazamiento en el buffer  -
    bufferNodoPorGrado(1, 3, 1) = "G1 N3 P1";   % Estructura del paquete [Grado, Nodo, NoPaquete]
    bufferNodoPorGrado(1, 3, 2) = "G1 N3 P2";

    bufferNodoPorGrado(2, 3, 1) = "G2 N3 P1";

    bufferNodoPorGrado(2, 5, 1) = "G2 N5 P1";
    bufferNodoPorGrado(2, 5, 2) = "G2 N5 P2";
    

    bufferNodoPorGrado1 = bufferNodoPorGrado;
    bufferNodoPorGrado1(2, 5, 1) = "";  % Se borra el paquete en la primera posicion
    bufferNodoPorGrado1(2, 5, :) = circshift(bufferNodoPorGrado1(2, 5, :), [-1]) % Se recorre la cola del buffer
    

% - Determinar si el buffer del nodo en el grado especificado esta vacio [1: Si, 0: No]
    isemp = isempty(find((bufferNodoPorGrado1(2, 5, :) == "") == 0))
    
    
% - Determinar si el buffer del nodo en el grado especificado esta vacio [1: Si, 0: No]
    for i= 1:K
        bufferNodoPorGrado(2, 4, i) = "G2 N4 P";
    end
    noemp = isempty(find((bufferNodoPorGrado(1, 3, :) ~= "") == 0, 1))
    

% - Determinar que Nodos de un Grado tienen paquetes por transmitir
    find((bufferNodoPorGrado1(2, :, 1) == "") == 0)


% - Determinar la siguiente posicion con valor cero para agregar retardo a un Grado
    retardoPaquetesPorGrado(1,1) = 1;   % Llenar con valores los del grado 1
    retardoPaquetesPorGrado(1,2) = 1;

    pos = find(retardoPaquetesPorGrado(2,:) == 0, 1)  %Obtener la posicion del primer zero
    retardoPaquetesPorGrado(2,pos) = 2; %Agregar nuevoo retardo
    % Si lo que se obtiene del find es un array vacio, se calcula el largo del array para ese Grado y 
    % se le suma uno para colocar el nuevo retardo al final
    length(retardoPaquetesPorGrado(1,:));


% - Calcular promedio de retardo para cada Grado sin contar ceros
    pos = find(retardoPaquetesPorGrado(2,:) == 0, 1)
    mean1 = mean( retardoPaquetesPorGrado(2,1:pos-1) )
    %Si pos es empty se coloca ":" para el calculo

    
%% Links utiles
%{

- String a double
https://www.mathworks.com/help/matlab/ref/str2double.html

- Hacer split a una string
https://www.mathworks.com/help/matlab/ref/strsplit.html

- Desplazamiento de matriz
https://es.mathworks.com/help/matlab/math/reshaping-and-rearranging-arrays.html

- Ampliar Matriz
https://es.mathworks.com/help/matlab/math/creating-and-concatenating-matrices.html


%}