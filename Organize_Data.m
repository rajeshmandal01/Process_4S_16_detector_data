d = readmatrix('BH_5.txt');
s=cell(1,24);
[row,~]=size(d);
%% Organizing Data in "numSource position or source ×numDetectors×numWavelengths" format
for i=1:row 
    pwl=d(i,2); %source position wavelength indicator index in data set
    switch pwl
            case 1
                s{1}=[s{1};d(i,3:19)];
            case 2
                s{2}=[s{2};d(i,3:19)];
            case 3
                s{3}=[s{3};d(i,3:19)];
            case 4
                s{4}=[s{4};d(i,3:19)];
            case 5
                s{5}=[s{5};d(i,3:19)];
            case 6
                s{6}=[s{6};d(i,3:19)];
            case 7
                s{7}=[s{7};d(i,3:19)];
            case 8
                s{8}=[s{8};d(i,3:19)];
            case 9
                s{9}=[s{9};d(i,3:19)];
            case 10
                s{10}=[s{10};d(i,3:19)];
            case 11
                s{11}=[s{11};d(i,3:19)];
            case 12
                s{12}=[s{12};d(i,3:19)];
            case 13
                s{13}=[s{13};d(i,3:19)];
            case 14
                 s{14}=[s{14};d(i,3:19)];
            case 15
                 s{15}=[s{15};d(i,3:19)];
            case 16
                 s{16}=[s{16};d(i,3:19)];
            case 17
                 s{17}=[s{17};d(i,3:19)];
            case 18
                 s{18}=[s{18};d(i,3:19)];
            case 19
                 s{19}=[s{19};d(i,3:19)];
            case 20
                 s{20}=[s{20};d(i,3:19)];
            case 21
                 s{21}=[s{21};d(i,3:19)];
            case 22
                 s{22}=[s{22};d(i,3:19)];
            case 23
                 s{23}=[s{23};d(i,3:19)];
            case 24
                 s{24}=[s{24};d(i,3:19)];  % ignoring the 50 M gain data
%             case 25
%                  s{25}=[s{25};d(i,3:19)];
            otherwise
 
    end
end

data=cell2mat(s); % data with basline
d1={};
for i=1:24
    d1{i}=s{1,i}(:,1:16);
end
% d2={};
% for i=1:24
%     d2{i}=s{1,i}(:,1:16)-s{1,25}(:,1:16);
% end
% 
 detData=cell2mat(d1);     % detector data
% detData_BL_corr=cell2mat(d2); % base line corrected data
% 
% 
%  %% Save compiled data
 filename1 = 'org_bh_5.txt';
writematrix(detData, filename1, 'Delimiter', 'comma'); % Use tab as delimiter
% % filename2 = 'data_basline_corrected.txt';
% % writematrix(detData_BL_corr, filename2, 'Delimiter', 'comma'); % Use tab as delimiter
% 
