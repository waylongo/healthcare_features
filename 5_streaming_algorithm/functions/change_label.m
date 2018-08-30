function [ new_label ] = change_label( index, new_label, label, win_index )
%label = change_label(anormaly_old, i, label, win_index);
% change label for anormaly becoming normal
% @author: Wenlong Wu
% @date: 05/21/2018

N = size(label, 2);
for i = 1:N
    if(label(i) == 0)
        index = index - 1;
    end
    if(index == 0)
        new_label(i) = win_index;
        return;
    end
end

end

