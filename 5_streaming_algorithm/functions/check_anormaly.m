function [anormaly, mean, cov_max, point_num, new_label ] = check_anormaly( anormaly_old, mean, cov_max, point_num, label )
% check if anormaly becomes normal
% @author: Wenlong Wu
% @date: 05/15/2018
    eta = 0;
    anormaly = [];
    new_label = label;
    
    for i = 1:size(anormaly_old,1)
        for j =1: size(mean, 1)
            dist(j)=pdist2(mean(j,:), anormaly_old(i,:), 'mahalanobis', cov_max(:,:,j));
        end
        [min_dist, win_index] = min(dist);
        if(min_dist < eta )
            % update the winnning mean and covariance
            point_num(win_index) = point_num(win_index) + 1;
            cov_max(:,:,win_index) = ((point_num(win_index)-1) * cov_max(:,:,win_index) + transpose(anormaly_old(i,:) - mean(win_index,:)) * (anormaly_old(i,:) - mean(win_index,:))) / point_num(win_index);
            mean(win_index,:) = mean(win_index,:) + (anormaly_old(i,:) - mean(win_index,:))/ point_num(win_index);
            plot3(anormaly_old(i,1),anormaly_old(i,2),anormaly_old(i,3), 'xb');hold on;drawnow;
            new_label = change_label(i, new_label, label, win_index);
        else
            anormaly = [anormaly; anormaly_old(i,:)];
        end
    end
    
end

