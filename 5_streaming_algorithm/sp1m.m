function [ model, anormaly] = sp1m( data )
% Use current data to find prototype (mean and covariance)
% @author: Wenlong Wu
% @date: 08/16/2018

%% some hyper-parameters
N =size(data, 1); % number of data
C=2; % cluster number, infinite
fzr=1.5; % fuzzifier
epsilon=1; % epsilon threshold
Uall=[]; % membership matrix collection
Vall=[]; % cluster matrix collection
cov_max=[]; % covariance maxtrixs
point_num=[]; % each cluster points number
label=zeros(1,N);
U_count=zeros(1,C);
stop_count=0;
stop_code=0;
seed=2018;
eta = ones(1, C) * 10000;

%% Keep searching for clusters until all clusters are found
for iter=1:C
    %-------------------------loop 2---------------------------------------
    while(1)
    seed=seed+1;
    selected_v = random_select(data, iter, Uall, seed);
    v(iter, :) = selected_v;

    %% ---------------------------loop 1 < P1M >------------------
    while(1)
        % compute d
        for m=1:N
            d(iter,m)=pdist2(data(m,:),v(iter,:))^2;
        end

%         eta(iter)=300;

        % compute u(v,X)
        for m=1:N
           u(iter,m)=1/(1+(d(iter,m)/eta(iter))^(1/(fzr-1)));
        end

        % compute v(u,X) / for 3 dimensions
        dim = 3;
        v_up=zeros(1,dim);
        v_down=0;
        for m=1:N
            v_up(1,:)=v_up(1,:)+u(iter,m)^fzr*data(m,:);
            v_down=v_down+u(iter,m)^fzr;
        end
        v_new(iter,:)=v_up(1,:)/v_down;
        v_diff=pdist2(v(iter,:), v_new(iter,:))^2;
        v(iter,:)=v_new(iter,:);

        % if cluster center doesn`t move, break the while
        if v_diff<epsilon^2
            break;
        end
    end
    
    %% ----------------------------loop 1 < P1M > end-------------------

    % termination calculation
    stop_count=stop_count+1;
    for m=1:N
        if iter>1 && max(Uall(:,m))>0.5
            U_count(iter)=U_count(iter)+1;
        end
    end
    
    if stop_count>N*0.9-U_count(iter)
        stop_code=1;
        break;
    end
    
    % remove the coincident cluster center
    vw=zeros(1,iter-1);
    if iter>1
        for j=1:iter-1
           vw(j)=pdist2(v(iter,:),Vall(j,:))^2;
        end
        vw_min=min(vw);
        if vw_min>(sum(eta(1:iter))/iter)^1.2  % this need to be discussed, 2*eta
            break;
        end
    else
        break;
    end
    
    U_count(iter)=0;
    end
    %-----------------------------loop 2 end-------------------------------
    if stop_code == 1
        stop_code=0;
        break;
    end
    Uall=[Uall;u(iter,:)];
    Vall=[Vall;v(iter,:)];
    points=[];
    stop_count=0;
    for s=1:N
        if(u(iter,s)>0.02)
            points=[points;data(s,:)];
            label(s)=iter;
        end
    end
    point_num=[point_num,size(points,1)];
    cov_tmp=cov(points);
    cov_max=cat(3,cov_max,cov_tmp);
end

mean=Vall;
c_num=size(mean,1);

anormaly=[];
for iter=1:N
     u_max=max(Uall(:,iter));
     if(u_max<0.1)
         anormaly=[anormaly;data(iter,:)];
     end
end
if(size(anormaly) > 0)
    figure(1);plot3(anormaly(:,1), anormaly(:,2), anormaly(:,3), '.c', 'MarkerSize', 10); hold on;
end

model.mean=mean;
model.cov_max=cov_max;
model.c_num=c_num;
model.point_num=point_num;
model.label=label;
% plot3(mean(:,1), mean(:,2), mean(:,3), '.r', 'MarkerSize', 32); hold on;

% h1 = plot_gaussian_ellipsoid(mean(1,:), cov_max(:,:,1) * 10);
% h2 = plot_gaussian_ellipsoid(mean(2,:), cov_max(:,:,2) * 10);
% h3 = plot_gaussian_ellipsoid(mean(3,:), cov_max(:,:,3) * 10);
end

