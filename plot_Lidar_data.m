%%%
function []=plot_Lidar_data(measurement_data)

figure(102)
hold on;plot(measurement_data(:,1),measurement_data(:,2),'+g');
color='g';