% Generate 2/3-d PCA data using health care data
% @author: Wenlong Wu
% @date: 08/13/2018

close all;
clear;clc;

dataFile=importdata('features.csv');
% extract data information
data=dataFile.data;
label = data(:,31);data=data(:,1:30);
[N, dim] = size(data);

% extract text information
textData= dataFile.textdata;
days=textData(:,2);days(1)=[];days=string(days); % Date
feature=textData(1,:);feature(1) = [];feature(1) = [];feature = string(feature); % feature

% % visualize each feature plot
% for i=1:dim
%     figure;plot(data(:,i));
%     title(feature(i));
%     pause(2);
% end

% scale some features
data(:,6) = data(:,6) / 100;
data(:,8) = data(:,8) / 100;

% normalization
% for i=1:dim
%     data(:,i) = (data(:,i) - nanmean(data(:,i)))/nanstd(data(:,i));
% end

[COEFF, SCORE, latent]=pca(data);
reduced_dim = 3;
reduced_dim_data=SCORE(:,1:reduced_dim);

figure;hold on;grid on
switch reduced_dim
    case 2
        view(2); 
%         plot(reduced_dim_data(:,1),reduced_dim_data(:,2), '.b');
        % streaming 2-d visualization
        for i =1: N
            title(days(i));
            title(['User 3003 ', days(i)]);
            if(sum(data(i,:)) ~= 0)
                if(label(i) == 1)
                    plot(reduced_dim_data(i,1),reduced_dim_data(i,2), '.b', 'MarkerSize',10);
                elseif(label(i) == 2)
                    plot(reduced_dim_data(i,1),reduced_dim_data(i,2), '.c', 'MarkerSize',10);
                elseif(label(i) == 3)
                    plot(reduced_dim_data(i,1),reduced_dim_data(i,2), '.r', 'MarkerSize',10);
                elseif(label(i) == 4)
                    plot(reduced_dim_data(i,1),reduced_dim_data(i,2), '.g', 'MarkerSize',10);
                elseif(label(i) == 5)
                    plot(reduced_dim_data(i,1),reduced_dim_data(i,2), '.', 'Color',[255/255 191/255 0/255], 'MarkerSize',10);
                elseif(label(i) == 6)
                    plot(reduced_dim_data(i,1),reduced_dim_data(i,2), '.m', 'MarkerSize',10);
                end
            end
%             pause(0.1);
        end
    case 3
        view(3); 
%         plot3(reduced_dim_data(:,1),reduced_dim_data(:,2),reduced_dim_data(:,3), '.b', 'MarkerSize',10);
        % streaming 3-d visualization
        for i =1: N
            title(days(i));
            title(['User 3003 ', days(i)]);
            if(sum(data(i,:)) ~= 0)
                if(label(i) == 1)
                    plot3(reduced_dim_data(i,1),reduced_dim_data(i,2),reduced_dim_data(i,3), '.b', 'MarkerSize',10);
                elseif(label(i) == 2)
                    plot3(reduced_dim_data(i,1),reduced_dim_data(i,2),reduced_dim_data(i,3), '.c', 'MarkerSize',10);
                elseif(label(i) == 3)
                    plot3(reduced_dim_data(i,1),reduced_dim_data(i,2),reduced_dim_data(i,3), '.r', 'MarkerSize',10);
                elseif(label(i) == 4)
                    plot3(reduced_dim_data(i,1),reduced_dim_data(i,2),reduced_dim_data(i,3), '.g', 'MarkerSize',10);
                elseif(label(i) == 5)
                    plot3(reduced_dim_data(i,1),reduced_dim_data(i,2),reduced_dim_data(i,3), '.', 'Color',[255/255 191/255 0/255], 'MarkerSize',10);
                elseif(label(i) == 6)
                    plot3(reduced_dim_data(i,1),reduced_dim_data(i,2),reduced_dim_data(i,3), '.m', 'MarkerSize',10);
                end
            end
        %     pause(0.1);
        end
end

title('User 3003 data [10/10/2015 - 1/28/2007]');

