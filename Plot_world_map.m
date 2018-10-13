%%%%Plot lidar data map, reflector and lidar trace
function []=Plot_world_map(Lidar_update_Table,match_reflect_pool,matched_reflect_ID,detected_reflector,detected_ID,Lidar_trace)

figure(103)
xlabel('x(cm)')
ylabel('y(cm)')
hold on;
plot(Lidar_update_Table(:,1),Lidar_update_Table(:,2),'+','Color',[rand(),rand(),rand()]);
hold on;
plot(match_reflect_pool(matched_reflect_ID,1),match_reflect_pool(matched_reflect_ID,2),'+k')
color='b';
hold on;
color='g';
plot_reflector(detected_reflector,detected_ID,color)
hold on;
plot(Lidar_trace(:,1),Lidar_trace(:,2),'o-k')
