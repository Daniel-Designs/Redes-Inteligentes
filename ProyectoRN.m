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







