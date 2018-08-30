% Sequential Possibilistic One-Means Clustering 
% For streaming clustering to detect outliers and trajectory trends
% @author: Wenlong Wu
% @revised: 08/16/2018

close all;
clear;clc;

% import data
addpath(genpath(pwd));
all_data = importdata('reduced_dim_data_id3003.dat'); N = size(all_data,1); piece = 3;
data = all_data(1:round(N/piece),:);
stream = all_data(round(N/piece)+1:N,:);


%% Use current data to find prototype
figure(1);view(3); plot3(data(:,1),data(:,2),data(:,3),'.b');hold on
[model, anormaly] = sp1m(data);

%% Use stream data to update prototype
 [model, anormaly] = sp1ms(stream, model, anormaly);

%  %% testment to see if the label is right
%  label = model.label;
%  figure;
%  for i =1: N
%      switch label(i)
%          case 1
%              plot3(all_data(i,1),all_data(i,2),all_data(i,3), '.r');hold on
%          case 2
%              plot3(all_data(i,1),all_data(i,2),all_data(i,3), '.g');hold on
%          case 3
%              plot3(all_data(i,1),all_data(i,2),all_data(i,3), '.b');hold on
%          otherwise
%              plot3(all_data(i,1),all_data(i,2),all_data(i,3), 'xk');hold on
%      end
%  end