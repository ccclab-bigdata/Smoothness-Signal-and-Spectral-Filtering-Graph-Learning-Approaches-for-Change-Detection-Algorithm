%基于3-D图的遥感图像变化检测程序
%------------------------------------
%作者：余田田
%----------------------------------------
clc;
clear all;
close all;
addpath('C:/Users/ASUS/Documents/David Universidad/IX SEMESTRE/TRABAJO DE GRADO/Smoothness/Codes/GBF-CD/Data');
addpath('C:/Users/ASUS/Documents/David Universidad/IX SEMESTRE/TRABAJO DE GRADO/Costo computacional/graphAlve/graph cut');
addpath('C:/Users/ASUS/Documents/David Universidad/IX SEMESTRE/TRABAJO DE GRADO/Costo computacional/graphAlve/unlocbox');
addpath('C:/Users/ASUS/Documents/David Universidad/IX SEMESTRE/TRABAJO DE GRADO/Costo computacional/graphAlve/minf');
%addpath('C:/Users/ASUS/Documents/David Universidad/IX SEMESTRE/TRABAJO DE GRADO/Costo computacional/graphAlve/gspbox');
%addpath('C:/Users/ASUS/Documents/David Universidad/IX SEMESTRE/TRABAJO DE GRADO/Smoothness/Codes/gspbox');
%addpath('C:/Users/ASUS/Documents/David Universidad/IX SEMESTRE/TRABAJO DE GRADO/Costo computacional/graphAlve/data');
%%%%%1K clases 11 datasets %%%%%%%%%%
% datasets = {'Wenchuan_dataset','sardania_dataset','alaska_dataset','canada_dataset','dique_dataset','katios_dataset','Madeirinha_dataset','omodeo_dataset','SF_dataset','contest_dataset','california_flood'};
% stop=[0.043,0.016,0.0265,0.007,0.0188,0.012,0.027,0.02,0.0345,0.0022,0.0026];%1Kclases
% scales=[1,1,1,1,1,1,1,1,1,0.64,0.802]; %Scaling to canada size
% kmin=[2,3,2,2,2,2,3,2,137,2,4];%1K clases
%%%%3K clases 11 datasets %%%%%%%%%%
% datasets = {'Wenchuan_dataset','sardania_dataset','alaska_dataset','canada_dataset','dique_dataset','katios_dataset','Madeirinha_dataset','omodeo_dataset','SF_dataset','contest_dataset','california_flood'};
% stop=[0.025,0.025,0.025,0.0122,0.032,0.025,0.025,0.025,0.025,0.003,0.005];%3K clases para algunos
% scales=[1,1,1,1,1,1,1,1,1,1,1];
% kmin=[2,3,2,2,2,2,2,2,65,2,2];
% step=[2,2,2,5,5,5,1,1,1,5,5];
%%%%%%%%%%%%%%%%

%%%%%% P 500 clases 9 datasets %%%%
% datasets = {'Wenchuan_dataset','sardania_dataset','alaska_dataset','dique_dataset','katios_dataset','Madeirinha_dataset','omodeo_dataset','SF_dataset','canada_dataset'};
% stop=[0.031,0.011,0.018,0.013,0.0083,0.017,0.0135,0.0235,0.005];%500clases
% scales=[1,1,1,1,1,1,1,1,1];
% kmin=[2,3,2,2,2,3,2,137,2];
%%%%%%%%%%
%%%%%% Prior X clases 14 datasets %%%%
datasets = {'Wenchuan_dataset','sardania_dataset','alaska_dataset','dique_dataset',...
    'katios_dataset','Madeirinha_dataset','omodeo_dataset','SF_dataset','canada_dataset',...
    'contest_dataset','california_flood','Bastrop_dataset','gloucester_dataset',...
    'toulouse_dataset'};
stop=[0.00060,0.00005,0.001,0.00013,...
    0.000083,0.0017,0.0070,0.000235,0.0001,...
    0.000095,0.0001,0.002,0,0];%XclasesQueBordean
scales=[1,1,1,1,1,1,1,1,1];
kmin=[2,3,2,2,2,3,2,137,2];

%gsp_start();

for n=5:5
    load(datasets{n});
    [rowOrg , colOrg]=size(before);
    p1=imresize(before,scales(n));
    p2=imresize(after,scales(n));
    disp(['Min before: ',num2str(min(p1(:)))])
    disp(['Max before: ',num2str(max(p1(:)))])
    disp(['Min after: ',num2str(min(p2(:)))])
    disp(['Max after: ',num2str(max(p2(:)))])
    cankao=gt;
    f1=p1(:,:,1);
    f1=im2double(f1);
    f2=p2(:,:,1);
    f2=im2double(f2);
    [N C]=size(f1);
    
    %---------------------初始化------------------------------%

    ff1=reshape(f1,N*C,1);
    ff2=reshape(f2,N*C,1);
    p=abs(f1-f2);%Recomend: Usar norma L2, no L1
    prior1  = (f2(:,:,1) - f1)./((f2(:,:,1) + f1));
    prior2  = (f1 - f2(:,:,1))./((f2(:,:,1) + f1));
    prior = imbinarize(prior1) + imbinarize(prior2);
    [A B D biaoji]=imgsegment(prior,20,stop(n));     %Segmentaci髇
    %load('rescate');
    max(biaoji)
    figure(1);
    imshow(B,[]);

    feature1=ff1;
    feature2=ff2;
    feature3=reshape(prior,N*C,1);
    for j=min(biaoji):max(biaoji)                  %每块的每个特征值的平均值
        tmp=find(biaoji==j);
          b1=feature1(tmp,:);
          b2=feature2(tmp,:);
          b3=feature3(tmp,:);
          region1(j-min(biaoji)+1,1:size(feature1,2))=mean(mean(b1));
          region2(j-min(biaoji)+1,1:size(feature1,2))=mean(mean(b2));  %使变化前后图像的分块标签一致
          region3(j-min(biaoji)+1,1:size(feature1,2))=mean(mean(b3));
          dian(j-min(biaoji)+1,1:length(tmp))=tmp;

    end
    kuai=dian;
    region3=imbinarize(region3);
    prior=region3;
    %%

    %---------------------------pujulei-------------------------------------%
    KappaBest=0;
    metrics=[];
    %cankao=cankao(:,:,1)==255;
    %cankao=logical(cankao);
    %for k=kmin(n):step(n):max(biaoji)-2
    %for k=kmin(n):step(n):kmin(n)+step(n)*3
    sigma_d = 2; 
    %sigma_f = 10/255;
    wsz = 5; % Window size is (2*wsz + 1). For e.g wsz=5 --> 11x11 window
    %for sigma_f=0.00001:0.00001:0.001
    for sigma_f=0.001:0.001:1
    %for sigma_f=0.007:0.007
    close all
    %W=graph_cut(region1,region2,k);% Grafo fusionado Smoothness
    W = graph_learning_BF(region1,region2,wsz,sigma_f, sigma_d);%Bilateral Filter
    disp('Fusion done')
    [U_s,D_s] = eig(W);
    MI = zeros(1,max(biaoji));
    %Descomposici髇 espectral, manejo de clases, se define si cambiaron
    for d = 2 : max(biaoji)
        %disp(['Vector propio ',num2str(d)])
        labels = U_s(:,d)*sqrt(D_s(d,d));
        %%%%Imagen del vector propio
%         figure, imshow(labels,[]);
%         title(['Eigenvector sample ' , num2str(d) ])
%         set(gca,'FontSize',12)
%         drawnow
        %%%%
        %Iaux = ((reshape(Iaux,m_c,n_c)));
        labels = imbinarize(abs(labels));
  
        MI(d) =  mi(prior,labels);
        clear Iaux;
    end
    i = find(MI == max(MI),1,'first');
    labels = U_s(:,i)*sqrt(D_s(i,i));
    labels = imbinarize(abs(labels));
    %Expansi髇 del elegido
    for j=1:max(biaoji)-min(biaoji)+1
        tmp=find(kuai(j,:)~=0);
        l=length(tmp);
        if labels(j)==1
            for i=1:l
                   g(kuai(j,i))=1;
            end
        else
           for i=1:l
                   g(kuai(j,i))=0;
           end
        end
    end
    CH=reshape(g,N,C);
    Change_Map=reshape(CH,N,C);
    Change_Map=logical(Change_Map);
    Change_Map=imresize(Change_Map,[rowOrg colOrg]);
    figure, imshow(Change_Map,[]);
    title('Change_map')
    set(gca,'FontSize',12)
    drawnow
    %% Metrics and error map
    %all available datasets has the gt
    [MA, FA, Precision, recall, kappa, OE] = cohensKappa(cankao,Change_Map);
    if kappa>KappaBest
        KappaBest=kappa;
        sigma_fBest=sigma_f;
    end
%         if kappa>0.5
%             KappaBetter(end+1)=kappa;
%             kBetters(end+1)=k;
%         end
    metrics(end+1,:)=[sigma_f,MA, FA, Precision, recall, kappa, OE];
    
    end
filename = strcat('NNK_',datasets{n},'_',num2str(stop(n)),'.xlsx');
writematrix(metrics,filename);
clearvars -except datasets scales stop kmin step
end

