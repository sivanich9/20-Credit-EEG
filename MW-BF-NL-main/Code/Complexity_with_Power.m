
%% correlation analysis for the difference of Nonlinear metrics and the difference of power data
% fit and scatter plot //  note: here use 'Type'--'pearson'

Xlist={ 'Absolute theta','Absolute alpha','Relative theta','Relative alpha'};
Ylist={ 'HFD','LZC','SampEn'};

figure,
set(gcf,'outerposition',get(0,'screensize')); 

count=0;
 for ky=1:3
      Ystr=Ylist{ky};
      Y = NL(:,ky); % data from NL analysis
      
     for kx=1:4 
         Xstr=Xlist{kx};
         X = power(:,kx);    % power data from Rodriguez-Larios and Alaerts, 2021
         % corr:
         [coef, pval] = corr(X, Y,'Type','Pearson'); 
         p = polyfit(X, Y, 1); % fitted coeffcient p
         yFit = polyval(p, X); % estimate fitted Y with X and p.
         
         % plot
         count = count+1;
         subplot(3,4,count);
         scatter(X, Y, 25,'k','filled');
         hold on
         curve=plot(X,yFit,'k','linewidth',2);%,'LineWidth',1
         
         xlabel(Xstr);
         ylabel(Ystr);
         xlim([min(X)-0.1*(max(X)-min(X))  max(X)+0.1*(max(X)-min(X))]); 
         ylim([min(Y)-0.1*(max(Y)-min(Y))  max(Y)+0.1*(max(Y)-min(Y))]);
         title(['r = ',num2str(coef), ', p = ',num2str(pval)]); hold off
     end
 end