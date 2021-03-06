%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RLA flow design
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function is the top level code to implement matlab-to-C++
% verification platform
% RLA has options to generate test vectors to verify the algorithm.
% This program is developed and copyright owned by Soleilware LLC
% The code is writen to build the blocks for the localization
% algorithm process and efficiency.
% --------------------------------
% Created by Qi Song on 9/18/2018
%function [status]=RLA_toplevel(list_source_flag)% RLA top level function to convert Matlab code to C++ package and run C++ test code
function [mode,status,update_match_pool] = mode_manager(interrupt,scan_freq,reflector_map,reflector_source_flag,req_update_match_pool,num_ref_pool,num_detect_pool,Reflector_map,scan_data,amp_thres,angle_delta,dist_delta,thres_dist_match,thres_dist_large)
%% -interrupt:              interrupt from GUI console to control the Lidar computing engine
%% -reflector_source_flag:  flag to define the reflector source from GUI
%% -data_source_flag:       flag to define the data source from GUI
%% -req_update_match_pool:  request to ask match pool to update to include more reflectors 
%% -Reflector_map:          load Reflector map from GUI console
%% -scan_data:              load 3D Lidar data to module
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
data_source_flag=2;

if reflector_source_flag == 0 % read from file   
elseif reflector_source_flag == 2 % generate the 120 reflector matrix
    for i=1:2
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
%% Load Reflector map
[Reflector_map, Reflector_ID, load_ref_map_status] = load_reflector_map(reflector_map);
%%-- Only for test data
fname = ['Lidar_data_example2'];
Lidar_data = dlmread( fname, ' ', 3, 0)';
scan_data = Lidar_data;
%% convert polar data to rectangle data
[calibration_data,scan_data]=PolarToRect(Reflector_map,Lidar_data,data_source_flag);
%%-- Run calibration mode
[cali_status,Lidar_init_xy] = calibration_mode(Reflector_map,Reflector_ID,calibration_data,scan_data,thres_dist_match,thres_dist_large)

if cali_status==0
    disp('Calibration successful! Proceed to measurement mode....')
elseif cali_status>0
    disp('Calibration failed, please check Lidar data!!')
    %break
end
mode='Calibration';
Lidar_trace=0;
Lidar_trace=Lidar_init_xy;

%% Measurement mode
%-- need to read the scan data and process the data at each scan
%measurement
Loop_num=scan_freq;
for ll=1:Loop_num     % simulation loop start from here!!!
%% scan data is 2D data
%% measurement_data only need angle and distance;
% -- Could be replace by 2D scan data directly
measurement_data(:,1)=calibration_data(:,1);
measurement_data(:,2)=calibration_data(:,2);
%%-- Plot raw data
plot_Lidar_data(measurement_data)
%%-- Run measurement mode to find Robot location in the world coordinate
[mea_status,Lidar_update_xy,Lidar_update_Table,match_reflect_pool,match_reflect_ID,detected_reflector,detected_ID] = measurement_mode(num_ref_pool,num_detect_pool,Reflector_map,Reflector_ID,measurement_data,scan_data,amp_thres,angle_delta,dist_delta,Lidar_trace,thres_dist_match,thres_dist_large)
%% 
if mea_status==0
    disp('Measurement successful! continuing.....')
    status='good';
elseif mea_status==1
    disp('Measurement error found! Please check Lidar data!!')
    status='minor error';
elseif mea_status==2
    disp('Measurement large error found! Please stop test and check Lidar data!!')
    status='major error';
elseif mea_status==3
    disp('Measurement failed!')
    status='broken';
end
%% --Update Lidar trace
Lidar_trace=[Lidar_trace;Lidar_update_xy];
%% --Plot final result in the world coordinate
Plot_world_map(Lidar_update_Table,match_reflect_pool,match_reflect_ID,detected_reflector,detected_ID,Lidar_trace)
pause(1)
end
mode='navigation';
update_match_pool='true';
