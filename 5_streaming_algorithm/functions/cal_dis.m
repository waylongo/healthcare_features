function [ inPrototype, win_index, typicality ] = cal_dis( point, mean, covariance)
% Calculate the Mahalnobis distance (new data, existing cluster)
% Return 1 for normal, 0 for outlier
% @author: Wenlong Wu
% @date: 08/17/2018

    c=size(mean,1);
    eta = 3.25;
    distance=zeros(1,c);
    for i=1:c
        distance(i)=pdist2(point, mean(i,:), 'mahalanobis', covariance(:,:,i));
    end
    [mahal_min, win_index]=min(distance);
    typicality = 1 / (1 + (mahal_min / eta)^2);
    if(mahal_min < eta)
        inPrototype=true;
    else
        inPrototype=false;
    end

end

