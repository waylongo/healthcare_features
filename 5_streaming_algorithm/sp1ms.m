function [ model, anormaly ] = sp1ms( stream, model, anormaly )
% Sequential Possibilistic One-Means to update prototype
% @author: Wenlong Wu
% @revised: 08/17/2018

dataFile=importdata('features.csv');
textData= dataFile.textdata;
days=textData(:,2);days(1)=[];days=string(days); % Date

mean = model.mean;
cov_max = model.cov_max;
c_num = model.c_num;
point_num = model.point_num;
label = model.label;
cov_plot=[];
anormaly=[];

figure(1);hold on; title('Early prediction in Healthcare data of Resident #3003');
grid on; view(3);
% xlim([-10,40]);ylim([-10,40]);zlim([-25,20]);
for cov_i =1:c_num
     means(cov_i) = plot3(mean(cov_i,1),mean(cov_i,2),mean(cov_i,3), '.k', 'MarkerSize', 25); 
     cov_plot(cov_i) = plot_gaussian_ellipsoid(mean(cov_i,:),cov_max(:,:,cov_i)*3);
end

early_pred=zeros(1, size(stream,1)); % max typicality
early_pred_avg = early_pred; % average max typicality
trend=zeros(1, size(stream,1)); % trend of stream data, cos value

for i=1:size(stream,1)
    figure(1);
    title(['User 3003 ', days(159+i)]);
    if(abs(stream(i,1) + 543.8959) < 1)
        continue;
    end
    [inPrototype, win_index, typicality] = cal_dis(stream(i,:), mean, cov_max); % 1 for normal; 0 for outliers
    if(inPrototype == true) 
        % early prediction of health changes
        [early_pred, early_change, priority, trend] = early_check(stream, early_pred, i, typicality, mean(win_index,:), trend);
        early_pred_avg(i) = early_pred_avg3(early_pred, i);
        
%         trend_alert = trend_check(trend, i);
%         if(trend_alert == true)
%             plot3(stream(i,1),stream(i,2),stream(i,3),'dr');hold on;drawnow;
%         else
%             plot3(stream(i,1),stream(i,2),stream(i,3),'.b');hold on;drawnow;
%         end
        
        if(early_change == true && trend(i) < 0)
            switch priority 
                case 1 % weak warning
                    plot3(stream(i,1),stream(i,2),stream(i,3), 'db','LineWidth',2,'MarkerSize',6,'MarkerEdgeColor','b','MarkerFaceColor',[0.5,0.5,0.5]);hold on;drawnow;
                case 2 % medium warning
                    plot3(stream(i,1),stream(i,2),stream(i,3),'dm','LineWidth',2,'MarkerSize',6,'MarkerEdgeColor','m','MarkerFaceColor',[0.5,0.5,0.5]);hold on;drawnow;
                case 3 % strong warning
                    plot3(stream(i,1),stream(i,2),stream(i,3),'dr','LineWidth',2,'MarkerSize',6,'MarkerEdgeColor','r','MarkerFaceColor',[0.5,0.5,0.5]);hold on;drawnow;
                otherwise % no warning
                    plot3(stream(i,1),stream(i,2),stream(i,3),'.b');hold on;drawnow;
            end  
        else
            plot3(stream(i,1),stream(i,2),stream(i,3),'.b');hold on;drawnow;
        end
        
        % update the winnning mean and covariance
        point_num(win_index) = point_num(win_index) + 1;
        cov_max(:,:,win_index) = ((point_num(win_index)-1) * cov_max(:,:,win_index) + transpose(stream(i,:) - mean(win_index,:)) * (stream(i,:) - mean(win_index,:))) / point_num(win_index);
        mean(win_index,:) = mean(win_index,:) + (stream(i,:) - mean(win_index,:))/ point_num(win_index);
        delete(means(win_index));
        means(win_index) = plot3(mean(win_index,1), mean(win_index,2), mean(win_index,3), '.k', 'MarkerSize', 25); hold on; 
        delete(cov_plot(win_index));
%         for cov_i =1:c_num
         cov_plot(win_index) = plot_gaussian_ellipsoid(mean(win_index,:),cov_max(:,:,win_index)*3);
%         end

%         set(cov_plot,'color','k');
        label = [label, win_index];
        
        % check if anormaly becomes normal 
        [anormaly, mean, cov_max, point_num, label] = check_anormaly(anormaly, mean, cov_max, point_num, label);
        
    else % not in the model, maybe outliers
        early_pred(i) = typicality;
        early_pred_avg(i) = early_pred_avg3(early_pred, i);
        if(i<5)
            trend(i) = 0;
        else
            pre_points = stream(i:-1:i-4,:); % window = 5
            vec1s = stream(i,:) - pre_points;
            vec1 = sum(vec1s) /5;
            vec2 = mean(win_index,:) - stream(i,:) ;
            cos_alpha = vec1 * vec2' / (norm(vec1) * norm(vec2)); % [-1, 1]
            trend(i) = cos_alpha;
        end

        % check anomaly history to see if new cluster produced 
        [mean, cov_max, c_num, point_num, newFound, anormaly, label, means, cov_plot] = check_newcluster(anormaly,stream(i,:) ,mean, cov_max, c_num, point_num, label, means, cov_plot);
        % set this as outliers
        if(newFound == false)
            anormaly = [anormaly;stream(i,:)];
            plot3(stream(i,1),stream(i,2), stream(i,3), 'xr');hold on;drawnow;
            label = [label, 0];
        else
            plot3(stream(i,1),stream(i,2),stream(i,3), 'xb');hold on;drawnow;
            label = [label, c_num];
        end
    end
%     % plot the line between current and next point
%     if(i+1<size(stream,1))
%         lenth = stream(i+1,:) - stream(i,:);
%         quiver(stream(i,1),stream(i,2),lenth(1),lenth(2),'k-','MaxHeadSize',0.5);
%     end
end

title('User 3003 data [10/10/2015 - 1/28/2007]');
model.mean=mean;
model.cov_max=cov_max;
model.c_num=c_num;
model.point_num=point_num;
model.label=label;

%% --------------- testment ------------------------------------------
% max typicality plot
% figure;
% subplot(2,1,1);title('(avg3) max typicality value');hold on;
% plot(early_pred_avg); 
% subplot(2,1,2);title('stream data trend - cos value');hold on;
% plot(trend); 
% for i=1:size(stream)
%     switch label(i+71)
%         case 1
%             subplot(2,1,1);plot(i,early_pred_avg(i),'.r');hold on
%             subplot(2,1,2);plot(i, trend(i),'.r');hold on
%         case 2
%             subplot(2,1,1);plot(i,early_pred_avg(i),'.g');hold on
%             subplot(2,1,2);plot(i, trend(i),'.g');hold on
%         case 3
%             subplot(2,1,1);plot(i,early_pred_avg(i),'.b');hold on
%             subplot(2,1,2);plot(i, trend(i),'.b');hold on
%         otherwise 
%             subplot(2,1,1);plot(i,early_pred_avg(i),'xk');hold on
%             subplot(2,1,2);plot(i, trend(i),'xk');hold on
%     end
%     drawnow;pause(0.1);
% end

% % difference of max typicality plot
% typ_dif = early_pred_avg(i);
% for i = 1: size(stream, 1)-1
%     typ_dif(i) = early_pred_avg(i+1) - early_pred_avg(i);
% end

% average trend plot
% avg_trend = trend;
% for index=3: size(trend, 2)
%     avg_trend(index) = (trend(index)+trend(index-1)+trend(index-2)) /3;
% end
% figure;title('average trend cos value');
% plot(avg_trend);hold on;
% plot(avg_trend, 'x');

% % combination of above two methods
% avg_trend = (avg_trend+1)/2;
% comb=zeros(1,size(stream,1));
% for i=1: size(stream,1)
%     comb(i)=early_pred_avg(i) * avg_trend(i)*10;
% end
% figure;plot(comb);

end

% figure;plot(trend);hold on
% title('stream data trend - cos value');
% for i=1:size(stream)
%     switch label(i+71)
%         case 1
%             plot(i,trend(i),'.r');hold on
%         case 2
%             plot(i,trend(i),'.g');hold on
%         case 3
%             plot(i,trend(i),'.b');hold on
%         otherwise 
%             plot(i,trend(i),'xk');hold on
%     end
% end




