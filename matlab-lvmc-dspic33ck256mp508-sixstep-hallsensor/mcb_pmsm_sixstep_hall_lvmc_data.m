%% ************************************************************************
% Model         :   Field Oriented Control of PMSM Using Hall Sensor
% Description   :   Set Parameters for FOC of PMSM Using Hall Sensor
% File name     :   mcb_pmsm_foc_hall_lvmc_data.m
% Copyright 2022 Microchip Technology Inc.

%% Simulation Parameters

%% Set PWM Switching frequency
PWM_frequency 	= 20e3;    %Hz          // converter s/w freq
T_pwm           = 1/PWM_frequency;  %s  // PWM switching time period

%% Set Sample Times
Ts          	= T_pwm;        %sec        // simulation time step for controller
Ts_simulink     = T_pwm/2;      %sec        // simulation time step for model simulation
Ts_motor        = T_pwm/2;      %Sec        // Simulation sample time
Ts_inverter     = T_pwm/2;      %sec        // simulation time step for average value inverter
Ts_speed        = 30*Ts;        %Sec        // Sample time for speed controller

%% Set data type for controller & code-gen
dataType = fixdt(1,16,14);    % Fixed point code-generation
dataType2 = fixdt(1,16,12);    % Fixed point code-generation

%% System Parameters
% Set motor parameters
%bldc = mcb_SetPMSMMotorParameters('Teknic2310P');
bldc.model  = 'Hurst 300';      %           // Manufacturer Model Number
bldc.sn     = '123456';         %           // Manufacturer Model Number
bldc.p  = 5;                    %           // Pole Pairs for the motor
bldc.Rs = 0.285;                %Ohm        // Stator Resistor
bldc.Ld = 2.8698e-4;            %H          // D-axis inductance value
bldc.Lq = 2.8698e-4;            %H          // Q-axis inductance value
bldc.Ke = 7.3425;               %Bemf Const	// Vline_peak/krpm
bldc.Kt = 0.274;                %Nm/A       // Torque constant
bldc.J = 7.061551833333e-6;     %Kg-m2      // Inertia in SI units
bldc.B = 2.636875217824e-6;     %Kg-m2/s    // Friction Co-efficient
bldc.I_rated  = 3.42*sqrt(2);   %A      	// Rated current (phase-peak)
bldc.QEPSlits = 1000;           %           // QEP Encoder Slits
bldc.N_max    = 2000;           %rpm        // Max speed
bldc.FluxPM   = (bldc.Ke)/(sqrt(3)*2*pi*1000*bldc.p/60); %PM flux computed from Ke
bldc.T_rated  = (3/2)*bldc.p*bldc.FluxPM*bldc.I_rated;   %Get T_rated from I_rated

%% Inverter parameters

inverter.model         = 'dsPIC33CK_LVMC';          % 		// Manufacturer Model Number
inverter.sn            = 'INV_XXXX';         		% 		// Manufacturer Serial Number
inverter.V_dc          = 24;       					%V      // DC Link Voltage of the Inverter
inverter.ISenseMax     = 21.85; 					%Amps   // Max current that can be measured
inverter.I_trip        = 10;                  		%Amps   // Max current for trip
inverter.Rds_on        = 1e-3;                      %Ohms   // Rds ON
inverter.Rshunt        = 0.01;                      %Ohms   // Rshunt
inverter.R_board       = inverter.Rds_on + inverter.Rshunt/3;  %Ohms
inverter.MaxADCCnt     = 4095;      				%Counts // ADC Counts Max Value
inverter.invertingAmp  = -1;                        % 		// Non inverting current measurement amplifier
inverter.deadtime      = 1e-6;                      %sec    // Deadtime for the PWM 
inverter.OpampFb_Rf    = 4.02e3;                    %Ohms   // Opamp Feedback resistance for current measurement
inverter.opampInput_R  = 532;                       %Ohms   // Opamp Input resistance for current measurement
inverter.opamp_Gain    = inverter.OpampFb_Rf/inverter.opampInput_R; % // Opamp Gain used for current measurement

%% Hall Sequence Calibration
bldc.HallSequence = [5,4,6,2,3,1];

%% Derive Characteristics
bldc.N_base = mcb_getBaseSpeed(bldc,inverter); %rpm // Base speed of motor at given Vdc
pmsm.N_base = mcb_getBaseSpeed(pmsm,inverter); %rpm // Base speed of motor at given Vdc

%% PU System details // Set base values for pu conversion
PU_System = mcb_SetPUSystem(bldc,inverter);
%% Controller design // Get ballpark values!
% Get PI Gains
PI_params = mcb.internal.SetControllerParameters(bldc,inverter,PU_System,T_pwm,Ts,Ts_speed);

%Updating delays for simulation
PI_params.delay_Currents    = int32(Ts/Ts_simulink);
PI_params.delay_Position    = int32(Ts/Ts_simulink);
PI_params.delay_Speed       = int32(Ts_speed/Ts_simulink);
PI_params.delay_Speed1       = (PI_params.delay_IIR + 0.5*Ts)/Ts_speed;

PhaseIncCalc = (100e6/(PWM_frequency*64))*(16384);
SpeedMulti = (100e6/(5*64))*(60);
PhaseOffset = 2730;
