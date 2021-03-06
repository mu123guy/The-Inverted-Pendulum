%% Housekeeping
clear, clc
syms M m l g b B x theta xdot thetadot xddot thetaddot Force Moment real
createBus
%X = [x theta xdot thetadot]
X0 = [0 deg2rad(0) 0 deg2rad(0)];

%% EOM
eq1 = (M+m)*xddot-m*l*thetaddot*cos(theta)+m*l*thetadot^2*sin(theta)...
        == Force-B*xdot;
eq2 = l*thetaddot - g*sin(theta) - xddot*cos(theta)...
        == Moment-b*thetadot;
[xddot,thetaddot] = solve([eq1;eq2],[xddot,thetaddot]);

%% Model Parameters
M = 0.75;
m = 0.15;
l = 1;
g = 9.81;
b = 0.3;
B = 0.3;

%% Controllable Variables
tau = 0.01;

%% Linearization
jac = jacobian([xdot,thetadot,xddot,thetaddot],...
                [x,theta,xdot,thetadot,Force,Moment]);
x = 0; xdot = 0; theta = 0; thetadot = 0;Moment = 0;Force = 0;
jac = eval(jac);
sys.A = jac(:,1:4);
sys.B = jac(:,5:6);
sys.B_real = sys.B(:,1);
sys.C = eye(4);
sys.C_real = [1 0 0 0; 0 1 0 0 ];
sys.D = zeros(4,2);
sys.D_real = zeros(2,1);
stateNames = ["x";"theta";"x_dot";"theta_dot"];
inputNames = ["F"; "M"];
%inputNames_R = ["F"];
fullSys = c2d(ss(sys.A,sys.B,sys.C,sys.D,...
                'StateName',stateNames,'InputName',inputNames),tau);
realSys = c2d(ss(sys.A,sys.B_real,sys.C_real,sys.D_real),tau);

%% State Estimation

%% Design LQR controller
Q = diag([10 10 1 1]);
R = 1;
K = lqr(sys.A,sys.B_real,Q,R);
%% Choose a model to work with in Simulink
linearModel = 0;
fullKnowledge = 0;
results = sim('Simulation');
max_torque = max(results.torque)
max_rpm = max(abs(results.rpm))