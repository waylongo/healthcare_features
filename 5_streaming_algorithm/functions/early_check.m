function [ early_pred, early_change, priority, trend ] = early_check(stream, early_pred, index, typicality, win_mean, trend)
% Early check for streaming data
% @author: Wenlong Wu
% @date: 05/15/2018

    lowPriority = 3;
    mediumPriority = 4;
    highPriority = 5;
    starter = highPriority;
    early_pred(index) = typicality;
    priority = 0;
    window = 5;
    epsilon = 0.002; % a small threshold
    
    % at the beginning window, no warning
    if (index <= starter + 1)
        early_change = false;
        return;
    end

    %% trend of streaming data
    cur_point = stream(index,:);
%     pre_point = stream(index-1,:);
%     pre_pre_point = stream(index-2,:);
%     line = pre_point - pre_pre_point;
%     quiver(stream(index-1,1),stream(index-1,2),line(1),line(2),'LineWidth',1, 'MaxHeadSize',3, 'Color','k');

%     pre_point = sum(stream(index:-1: index - window + 1,:)) / window;
%     pre_point = stream(index -1, :);
%     vec1 = cur_point - pre_point;

%     pre_points = stream(index:-1:(index-window+1),:);
%     vec1s = cur_point - pre_points;
%     vec1 = sum(vec1s) / window;

    vec1s = zeros(window,3);
    for i=1:window
        vec1s(i,:) = stream(index+1-i,:) - stream(index-i,:);
    end
    vec1 = sum(vec1s,1) / window;
    
    vec2 = win_mean - cur_point;
    cos_alpha = vec1 * vec2' / (norm(vec1) * norm(vec2)); % [-1, 1]
    trend(index) = cos_alpha;

    if(cos_alpha > 0)
        %quiver(stream(index,1),stream(index,2),vec1(1)/(norm(vec1))/5 ,vec1(2)/(norm(vec1))/5,'LineWidth',1, 'MaxHeadSize',3, 'Color','b');
    else
        quiver(stream(index,1),stream(index,2),vec1(1)/(norm(vec1))/5 ,vec1(2)/(norm(vec1))/5,'LineWidth',1, 'MaxHeadSize',3, 'Color','k');
    end

    %% max typicality check
    % weak warning
    for i = index: -1: (index - lowPriority)
        if(early_pred_avg3(early_pred, i) - early_pred_avg3(early_pred, i-1) >  epsilon)
            early_change = false;
            return;
        end
    end

    % medium warning
    for i = index: -1: (index - mediumPriority)
        if(early_pred_avg3(early_pred, i) - early_pred_avg3(early_pred, i-1) >  epsilon)
            early_change = true;
            priority = 1;
            return;
        end
    end
    
    % strong warning
    for i = index: -1: (index - highPriority)
        if(early_pred_avg3(early_pred, i) - early_pred_avg3(early_pred, i-1) >  epsilon)
            early_change = true;
            priority = 2;
            return;
        end
    end

    early_change = true;
    priority = 3;
end

