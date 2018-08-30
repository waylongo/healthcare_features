function [ selected_v ] = random_select( data, iter, U, seed )
% random select a data point to initialize cluster center
% @author: Wenlong Wu
% @revised: 08/17/2018

    % propabilities to choose cluster center
    N = size(data, 1);
    if iter==1 
        p_trans=ones(1,N)*1/N;
    else
        p = max(U, [], 1);
        p_trans = p;
        alpha_cut = 0.5;
        p_trans(p>alpha_cut) = 0;
        p_trans(p<=alpha_cut) = 1 - p(p<=alpha_cut);
        p_trans = p_trans / (sum(p_trans));
    end

    % pick v with possibilites
    rng(seed);
    order=1:N;
    random_v=randsrc(1,1,[order; p_trans]);
    selected_v = data(random_v,:);
end

