function [ mean, covaraince, c_num, point_num, newFound, anormaly, new_label, means, cov_plot] = check_newcluster( anormaly_old, point, mean, covaraince, c_num, point_num, label, means, cov_plot)
% Check anormaly history to see if new cluster is produced
% @author: Wenlong Wu
% @date: 04/24/2018

    M = 15; % the min value for a cluster to be formed
    newFound = false; % symbol of if new cluster is formed
    eta = 250;
    dim=3;

    while(1)
        count = 1;
        new_sum = zeros(1,dim);
        new_mean = zeros(1,dim);
        new_cluster = [];
        for i = 1:size(anormaly_old,1)
            dist = pdist2(point, anormaly_old(i,:));
            if(dist < eta )
                new_sum = new_sum+anormaly_old(i,:);
                new_cluster = [new_cluster; anormaly_old(i,:)];
                count = count + 1;
            end
        end
        new_mean = new_sum / ( count - 1);
        if(pdist2(point, new_mean) < 0.1 || sum(new_sum) == 0)
            break;
        end
        point = new_mean;
    end

    anormaly = anormaly_old;
    new_label = label;

    if(count > M)
        newFound = true;
        cov_new = cov(new_cluster);
        mean = [mean;new_mean];
        covaraince = cat(3,covaraince,cov_new);
        c_num = c_num + 1;
        point_num = [point_num,count];
        figure(1);plot3(new_cluster(:,1),new_cluster(:,2),new_cluster(:,3),'xb');hold on;drawnow;
        means(c_num) = plot3(new_mean(1,1), new_mean(1,2),new_mean(1,3), '.k', 'MarkerSize', 25); hold on;
        cov_plot(c_num) = plot_gaussian_ellipsoid(new_mean,cov_new*3);
        
%         set(cov_plot,'color','k');
        anormaly = [];
        for i = 1:size(anormaly_old,1)
            if(pdist2(new_mean, anormaly_old(i,:)) > eta * 2 )
                anormaly = [anormaly; anormaly_old(i,:)];
            else
                new_label = change_label(i, new_label, label, c_num);
                plot3(anormaly_old(i,1),anormaly_old(i,2),anormaly_old(i,3) ,'xb');hold on;drawnow;
            end
        end
    end

end
