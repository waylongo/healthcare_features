function [ early_pred_avg3_value ] = early_pred_avg3( early_pred, index )
% previous 5 average early_pred value
% @author: Wenlong Wu
% @date: 05/15/2018

    if(index - 2 < 1)
        early_pred_avg3_value = early_pred(index);
        return;
    end

    early_pred_avg3_value=0;
    for i = index: -1: (index - 2)
        early_pred_avg3_value=early_pred_avg3_value + early_pred(i);
    end

    early_pred_avg3_value = early_pred_avg3_value / 3;
end

