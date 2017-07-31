clear variables

file = 'Lift3.csv'; % Reads in csvfile of collected data

data = transpose(csvread(file));

ON = 1;
OFF = 0;

time = data(1,:);
gyro = data(2:4,:);
accel = data(5:7,:);
N = length(data);
n = 1:N;

Ax_RAW = data(5,:);
Ay_RAW = data(6,:);
Az_RAW = data(7,:);

fc = 6;
fs = 90;
[b,a] = butter(4,fc/(fs/2));

Ax = filtfilt(b,a,Ax_RAW);
Ay = filtfilt(b,a,Ay_RAW);
Az = filtfilt(b,a,Az_RAW);

accel_mag = sqrt(Ay.^2 + Az.^2);

accel_mag = accel_mag - accel_mag(1);

Gz = data(10,:);

Vert_Accel = (Az .* cosd(Gz)) - (Ay .* sind(Gz));

Hor_Accel = (Az .* sind(Gz)) + (Ay .* cosd(Gz));

%CAL_VERT = 9.81;
CAL_VERT = (Vert_Accel(100));

Vert_Accel = Vert_Accel - CAL_VERT;

MHA = find(Hor_Accel == max(Hor_Accel));

for i = MHA+1:N
    if Vert_Accel(i) < 0
        MBV = i - 1;
        break
    end
end

for i = MHA:N
    if Vert_Accel(i) > Vert_Accel(i+1)
        MBA = i;
        break
    end
end

for i = 1:MBV
    if Vert_Accel(i) > 1;
        RISE_EDGE = i;
        break
    end
end

for i = RISE_EDGE:-1:1
    if Vert_Accel(i) < 0;
        START = i + 1;
        break
    end
end

for i = MHA:-1:START+1
    if Vert_Accel(i-1) > Vert_Accel(i)
        MIN_BA = i;
        break
    end
end

for i = MHA:-1:START+1
    if Hor_Accel(i-1) > Hor_Accel(i)
        MIN_HA = i;
        break
    end
end
   

S = START;
E = MBV;

PULL_FRAMES = 1:(E-S + 1);
N_PULL = length(PULL_FRAMES);
Vert_Acceleration = Vert_Accel(S:E);
Hor_Acceleration = Hor_Accel(S:E);

PULL_INDEX = PULL_FRAMES * (100/N_PULL);
INT_INDEX = 1:100;

% Interpolate Data to 0-100% of the time to reach max bar velocity
VERT_ACCEL_INT = interp1(PULL_INDEX,Vert_Acceleration,INT_INDEX,'spline');
HOR_ACCEL_INT = interp1(PULL_INDEX,Hor_Acceleration,INT_INDEX,'spline');

MHA_INT = find(HOR_ACCEL_INT == max(HOR_ACCEL_INT));

for i = MHA_INT:-1:2
    if HOR_ACCEL_INT(i-1) > HOR_ACCEL_INT(i)
        MIN_HA_INT = i;
        break
    end
end

for i = MHA_INT:99
    if VERT_ACCEL_INT(i) > VERT_ACCEL_INT(i+1)
        MVA_INT = i;
        break
    end
end

for i = MHA_INT:-1:2
    if VERT_ACCEL_INT(i-1) > VERT_ACCEL_INT(i)
        MIN_VA_INT = i;
        break
    end
end


% Figures

S = START;
E = MBV;

if (ON)
figure(1)
plot(n,Ax_RAW,n,Ay_RAW,n,Az_RAW)
legend('X','Y','Z')
title('Raw Accelerometer Data')
xlabel('Frame')
ylabel('Acceleration')
end

if (ON)
figure(2)
plot(n,Ax,n,Ay,n,Az)
legend('X','Y','Z')
title('Filtered Acceleration Data')
xlabel('Frame')
ylabel('Acceleration')
end

figure(3)
plot(n,Vert_Accel,n,Hor_Accel)
title('Barbell Acceleration Full')
legend('Vertical','Horizontal')


if (ON)
figure(3)
plot(n(S:E),accel_mag(S:E))
title('Acceleration Magnitude')
xlabel('Frame')
end

if (ON)
figure(4)
plot(n(S:E),Vert_Acceleration,n(S:E),Hor_Acceleration)
title('Barbell Acceleration Profile')
legend('Vertical','Horizontal')
xlabel('Frame [Start - MBV]')
ylabel('Acceleration (m/s^2')
end


if (ON)
figure(5)
plot(n(S:E),Gz(S:E))
title('Sensor Orientation')
end

if (ON)
figure(6)
plot(PULL_INDEX,Vert_Acceleration)
title('Vertical Acceleration')
xlabel('Frame')
end

if (ON)
figure(7)
plot(INT_INDEX,VERT_ACCEL_INT,INT_INDEX,HOR_ACCEL_INT)
title('Normalized Acceleration Data')
xlabel('Normalized Time [0-100% of Pull]')
end

% Maximum Vertical Acceleration
MAX_VERTICAL_ACCEL = VERT_ACCEL_INT(MVA_INT);
% Maximum Horizontal Acceleration
MAX_HORIZONTAL_ACCEL = HOR_ACCEL_INT(MHA_INT);
% Minumum Vertical Acceleration
MIN_VERTICAL_ACCEL = VERT_ACCEL_INT(MIN_VA_INT);
% Minimum Horizontal Acceleration (Sweep back into the hips)
MIN_HORIZONTAL_ACCEL = HOR_ACCEL_INT(MIN_HA_INT);

% Time of Min Horizontal Accel
MIN_HA_INT;
% Time of Min Vertical Accel
MIN_VA_INT;
% Time of Max Vertical Accel
MVA_INT;
% TIme of Max Horizontal Accel
MHA_INT;






