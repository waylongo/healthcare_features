function [ trend_alert ] = trend_check( trend, index )
% Check trend to see if it is going away from the center
% @author: Wenlong Wu
% @date: 06/09/2018

    trend_alert = false;
    starter = 5;
    % at the beginning window, no warning
    if (index -starter <= 0)
        return;
    end
    
    window = 5;
    for i =index:-1:index - window + 1
        if(trend(i)> -0.5)
            return;
        end
    end
    trend_alert = true;
end