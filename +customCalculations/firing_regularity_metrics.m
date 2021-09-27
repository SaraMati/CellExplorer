
function cell_metrics = firing_regularity_metrics(cell_metrics,session,spikes,spikes_all)
% function to calculate firing rate regularity metrics defined by Shinomoto
% et al. 
% taken from Shinomot https://s-shinomoto.com/toolbox/msMAP/getfp.m

% input: spike times in seconds 
% returns: 
% fp_vec: 1*4 array containing firing characteristics
%        fp_vec(1): Firing rate log lambda
%        fp_vec(2): Firign regularity log kappa
%        fp_vec(3): ISI correlation rho
%        fp_vec(4): Local variation of ISIs Lv

% last edit: 2020 11 03
% by Sara Mahallati


N_cells = length(spikes{1}.ts);
small_n=20;


firing_rate_lamda = NaN(1,N_cells); 
firing_regularity_kappa = NaN(1,N_cells); 
ISI_correlation_rho = NaN(1,N_cells); 
Local_variation_Lv = NaN(1,N_cells); 


for icell=1:N_cells

    
spkt= spikes{1}.ts{icell};
ISI=diff(spkt);
ISI_num=max(size(ISI));

if small_n < ISI_num % n need to be smaller than the total number of Inter-spike intervals

itt_max=floor(ISI_num/small_n);
fp_mat=zeros(itt_max,3);

    %compute loglambda, logkappa and rho for every small_n ISIs.
    for itt=1:itt_max
    ISI_itt=ISI((itt-1)*small_n+1:itt*small_n);
    
    %Estimate rate and regularity
    gpar = gamfit(ISI_itt);
    fp_mat(itt,2)=log(gpar(1)); % a or shape parameter is k or firing regularity
    fp_mat(itt,1)=-log((gpar(1)*gpar(2))); % b or scale times k is firing rate lambda

    %Estimate ISI correlation
    [ISI_sort, ISI_rank]=sort(ISI_itt);
    Rho_mat = corrcoef(ISI_rank(1:end-1),ISI_rank(2:end));
    fp_mat(itt,3)=Rho_mat(1,2);
    end
    fp_vec=mean(fp_mat,1);
    
    %compute lv for the entire spike train
    sum_lv=0.0;  
    sum_lv = sum(((ISI(1:end-1) - ISI(2:end)).^2)./((ISI(1:end-1) + ISI(2:end)).^2));
    
    lv=3.0*sum_lv/(ISI_num-1);
%     fp_vec(4)=lv;
    
    firing_rate_lamda(icell) = fp_vec(1);
    firing_regularity_kappa(icell) = fp_vec(2);
    ISI_correlation_rho(icell) = fp_vec(3);
    Local_variation_Lv(icell) = lv;
end   
    
    
end

cell_metrics.firing_rate_lambda = firing_rate_lamda;
cell_metrics.firing_regularity_kappa = firing_regularity_kappa;
cell_metrics.ISI_correlation_rho = ISI_correlation_rho; 
cell_metrics.Local_variation_Lv = Local_variation_Lv; 
    
end
    