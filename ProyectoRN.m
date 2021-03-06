clc 
clear all
close all 
 
%Proyecto de redes Neuronales

% - - - - - - - - - - - - - CONDICIONES INICIALES - - - - - - - - - - - - -
nTc = 10000; % Numero de ciclos de simulación

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
W = 16; % Tamano de la ventana de contencion - [16, 32, 64, 128, 256]
lambda = 0.0005;    % Tasa de paquetes generados por cada nodo [paquetes/seg.] - [0.0005, 0.001, 0.005, 0.03]

T = sigma*W + DIFS + 3*SIFS + durRTS + durACK + durCTS + durDATA; % Duración de una ranura
Tc = (2 + xi) * T;  % Duracion de un ciclo de trabajo [ms]
TsimTotal = nTc * Tc;   % Duracion total de la simulacion [ms]
lambda2 = lambda * N * I;   % Tasa de paquetes generados a nivel de red [paquetes/seg.]

Tsim = 0; % Tiempo actual de la simulación
Ta = 0; % Tiempo asignado para el siguiente arribo


% - - - - - - - - - - - - - VARIABLES DE CADA GRADO - - - - - - - - - - - - -
estadoGrados = zeros(1, I); % Estado que tiene actualmente cada grado en la red - [0: Rx, 1: Tx]
bufferNodoPorGrado = strings(I, N, K);  % Buffer para cada Nodo por Grado (Grado, Nodo, Tamano del Buffer)


% - - - - - - - - - - - - - VARIABLES PARA ESTADISTICAS - - - - - - - - - - - - -
noPaquetesPerdidosPorGrado = zeros(1, I);   % Registro para paquetes perdidos por cada Grado
noPaquetesRecibidosPorGrado = zeros(1, I);  % Registro para paquetes recibidos exitosamente por cada Grado

retardoPaquetesPorGrado = zeros(I, 1);  % Registro para el retardo de todos los paquetes recibidos por cada Grado
retardoPromedioPorGrado = zeros(1, I);  % Registro del retardo promedio por Grado


% - - - - - - - - - - - - - - - - SIMULACION - - - - - - - - - - - - - - - - 
% Generación del primer arribo
%Ta = Tsim + ( -(1/lambda2) * log(1 - 1e6*rand/1e6) );
U = 1e6*rand/1e6;
nuevot = -(1/lambda2) * log(1 - U);
Ta = Tsim + nuevot;

i = I;  % Variable que guarda el Grado actual
nRanura = 0;    % Numero de la ranura actual
pktTx = "";     % Paquete transmitido en la ranura Tx

    
while Tsim < TsimTotal
    % * * * * * Generacion de Paquete y Siguiente Arribo * * * * * 
    if Ta <= Tsim
        gR = randi([1, I]); % Grado aleatorio al que se le asiganara el paquete
        nR = randi([1, N]); % Nodo aleatorio al que se le asiganara el paquete

        pktNuevo = num2str(gR) + ", " + num2str(nR) + ", " + num2str(Ta);   % Generación del paquete
        %pktNuevo
        if isempty(find((bufferNodoPorGrado(gR, nR, :) ~= "") == 0, 1)) % Checar si el buffer esta lleno
            % El paquete se descarta
            pktNuevo = "";
            %disp("Se descarto paquete")
            % >> Proceso de Conteo de Paquetes Perdidos <<
            noPaquetesPerdidosPorGrado(gR) = noPaquetesPerdidosPorGrado(gR) + 1;
        else
            % El paquete se agrega a la cola del buffer
            % disp("El paquete esta en el buffer");
            p = find(bufferNodoPorGrado(gR, nR, :) == "", 1);
            bufferNodoPorGrado(gR, nR, p) = pktNuevo;
        end

        % Generacion de un nuevo arribo
        U = 1e6*rand/1e6;
        nuevot = -(1/lambda2) * log(1 - U);
        Ta = Tsim + nuevot;


    % * * * * * Ciclo de Trabajo del Sistema * * * * * 
    else        
        % ° ° ° ° Estado de Sleeping del Sistema ° ° ° °
        if nRanura >= I + 1  
            Tsim = Tsim + T;    % Aumento del tiempo de simulación
            nRanura = nRanura + 1;  % Aumento de la ranura del Ciclo de Trabajo

            if nRanura >= 20
               nRanura = 0;
            end


        % ° ° ° ° Estado de Transmisión y Recepcion del Sistema ° ° ° °   
        else
            % ' ' ' Proceso de Recepcion del Nodo Sink ' ' '
            if i == 0
                if any(pktTx ~= "")
                % Hay un paquete para recibir
                    payload = strsplit(pktTx, ", ");
                    pktTx = "";

                    gTx = str2double( payload(1) ); % Grado de origen del Paquete
                    tGenerado = str2double( payload(3) );   % Tiempo en que se Genero el Paquete

                    % >> Calculo del retardo del paquete <<
                    pktDelay = Tsim - tGenerado;    % Calculo del retardo
                    sig = find(retardoPaquetesPorGrado(gTx,:) == 0, 1); % Buscar espacio libre para guardar Delay

                    if isempty(sig)
                        sig = length(retardoPaquetesPorGrado(gTx,:)) + 1;   % Aumentar el tamaño del array de Retardo
                    end

                    retardoPaquetesPorGrado(gTx, sig) = pktDelay;   % Guardar el retardo en el siguiente espacio libre


                    % >> Proceso de Conteo de Paquetes Recibido <<
                    noPaquetesRecibidosPorGrado(gTx) = noPaquetesRecibidosPorGrado(gTx) + 1;

                end

                Tsim = Tsim + T;    % Aumento del tiempo de simulación
                nRanura = nRanura + 1;  % Aumento de la ranura del Ciclo de Trabajo
                i = I;  % Volver a simular red desde el Grado I


            % ' ' ' Proceso de Recepción y Transmision para cada Grado ' ' '    
            else
                % ^ ^ Proceso de Recepción ^ ^
                if estadoGrados(i) == 0
                    % disp("Grado: ")
                    % disp(i)
                    % disp("Estado Recepcion")

                    if any(pktTx ~= "")
                    % Hay algun paquete para recibir
                        % disp("Hay un paquete")
                        payload = strsplit(pktTx, ", ");

                        gRx = str2double( payload(1) ); % Grado de origen del paquete
                        nTx = str2double( payload(2) ); % Nodo de origen del Paquete

                        if isempty(find((bufferNodoPorGrado(i, nTx, :) ~= "") == 0, 1)) % Checar si el buffer esta lleno
                            % El paquete se descarta
                            % disp("Estado Recepcion - Descarte");

                            % >> Proceso de Conteo de Paquetes Perdidos <<
                            noPaquetesPerdidosPorGrado(gRx) = noPaquetesPerdidosPorGrado(gRx) + 1;
                        else
                            % El paquete se agrega a la cola del buffer
                            % disp("Estado Recepcion - Exito")
                            p = find(bufferNodoPorGrado(i, nTx, :) == "", 1);
                            bufferNodoPorGrado(i, nTx, p) = pktTx;
                        end
                        
                        pktTx = "";

                    end

                    estadoGrados(i) = 1;    % Cambio al siguiente estado (TX)
                    Tsim = Tsim + T; % Aumento del tiempo de simulación
                    nRanura = nRanura + 1;  % Aumento de la ranura del Ciclo de Trabajo


                % ^ ^ Proceso de Transmisión ^ ^
                else
                    % disp("Estado Transmision")
                    % Cuantos nodos tienen paquetes para enviar
                    if ~isempty(find((bufferNodoPorGrado(i,:, 1) == "") == 0, 1)) % Hay nodos con paquetes que enviar ------>>>>>  checar
                    %Hay uno o mas paquete para transmitir
                        % disp("Si hay paquetes que enviar ") 
                        v = find((bufferNodoPorGrado(i, :, 1) == "") == 0);              % Nodos con paquetes por transmitir
                        sz = size(v);                                                    % Numero de nodos con paquetes por transmitir
                        ranuraContension = zeros(sz);                               

                        for j = 1:sz(2)
                            ranuraContension(j) = randi([1, W]);                        % Asignacion de ranura de contension de 1 a W.
                        end
                        %ranuraContension
                        bufferSalida = find(ranuraContension == min(ranuraContension)); % Se seleccionan Ganadores
                        %bufferSalida
                        if length(bufferSalida) > 1 

                            % Hay colision
                            for j = 1:length(bufferSalida) 

                                % Se eliminan los paquetes que colisionarion de los buffers
                                pktCol = bufferNodoPorGrado(i, v(bufferSalida(j)), 1);  % Obtnemos el paquete que colisiono
                                bufferNodoPorGrado(i, v(bufferSalida(j)), 1) = "";  % Se borra el paquete en la primera posicion
                                bufferNodoPorGrado(i, v(bufferSalida(j)), :) = circshift(bufferNodoPorGrado(i, v(bufferSalida(j)), :), [-1]);  % Se recorre la cola del buffer

                                % >> Proceso de Conteo de Paquetes Perdidos <<
                                payload = strsplit(pktCol, ", ");   % Obtenemos el contenido del paquete colisionado         
                                gTx = str2double( payload(1) ); % Grado de origen del paquete
                                noPaquetesPerdidosPorGrado(gTx) = noPaquetesPerdidosPorGrado(gTx) + 1;  %Aumenta el contador de paquetes perdidos por grado

                            end

                            pktTx = "";

                        else
                        % Transmisión del paquete
                            pktTx = bufferNodoPorGrado(i, v(bufferSalida), 1);                 %Se asigna el paquete a la variable de salida.
                            %pktTx
                            %disp("Paquete enviado")
                            bufferNodoPorGrado(i, v(bufferSalida), 1) = "";                    % Se borra el paquete en la primera posicion
                            bufferNodoPorGrado(i, v(bufferSalida), :) = circshift(bufferNodoPorGrado(i, v(bufferSalida), :), [-1]); % Se recorre la cola del buffer

                        end

                    end

                    estadoGrados(i) = 0; % Cambio al siguiente estado (RX)
                    i = i - 1;  % Bajamos un grado en el sistema

                end
            end
        end
    end

end


% - - - - - - - - - - - - - - - - RESULTADOS - - - - - - - - - - - - - - - - 

noPaquetesPerdidosPorGrado
noPaquetesRecibidosPorGrado
% retardoPaquetesPorGrado

% Paquetes Perdidos
porcentajePP = zeros(1, I); % Porcentaje de paquetes perdidos
for c = 1:I
   porcentajePP(c) = 100*noPaquetesPerdidosPorGrado(c)/(noPaquetesPerdidosPorGrado(c) + noPaquetesRecibidosPorGrado(c));
end

figure();
plot(1:I, porcentajePP, 'r', 'linewidth', 2);
title('Porcentaje de Paquetes Perdidos por Grado');
xlabel('Grado [i]');
ylabel('Paquetes Perdidos [%]');
grid on


% Retardo
meanR = zeros(1, I);    % Retardo promedio por grado
for c = 1:I
    mp = find(retardoPaquetesPorGrado(c,:) == 0, 1);
    
    if isempty(mp)
        meanR(c) = mean( retardoPaquetesPorGrado(c,:) );
    else
        meanR(c) = mean( retardoPaquetesPorGrado(c, 1:mp-1) );
    end 
end

figure();
plot(1:I, meanR, 'm', 'linewidth', 2);
title('Retardo Promedio por Grado');
xlabel('Grado [i]');
ylabel('Retardo Promedio [ms]');
grid on


% Throughput
th = sum(noPaquetesRecibidosPorGrado) / nTc;  % Throughput del Sistema
fprintf('El Throughput del Sistema es %f [pkt/ciclo]\n', th);
