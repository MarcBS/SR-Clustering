function [w3_global, w3_concepts, indexes]=k_dim_segmentation_concepts(data_global, data_concepts,fi, p, flag)
%
% INPUT:
%   data   -> n x k data stream (each data in [0, 1]).
%   fi -> segmentation paramete
%   p -> norm parameter
%   flag 0 or 1 -> bound type
%   Lcnn is the lenght of the vector coding the global cnn
%
% OUTPUT:
%   w3    -> n x k data streams with means. 
%   idx   -> idx inside a stream with detected change.


[n_tot,k]=size(data_global);%n_tot is the number of images, kis the dimension of the data
w3_global=zeros(n_tot, k);
w3_concepts=zeros(size(data_concepts,1),k, n_tot);
w=zeros(1, n_tot);
len=5;%de los  primeros 5 hacer la media
W=data_global(1:len,1:k);
WC=data_concepts(:,:,1:len);%this is three dimensional
%293
for t=len+1:n_tot

    W=[W; data_global(t,1:k)];%let suppose that the matrix at the entry is the given by the the vector with the CNN global + the concept vector
    WC(:,:,t) =  data_concepts(:,:,t);
    zc=cumsum(WC,3);
    wc = zc(:,:,end);
    wc = [wc;W];
    pNorm = sum(abs(wc).^p,2).^(1/p);
    clearvars zc;
    pNorm=pNorm./((k)^(1/p));
    variance=var(pNorm);
 
    % Drop elements for the tail W
    % while all splits of W (||mu_w0-mu_w1||)>=ecut)
    cut=false;
    
    while(cut==false)
        
        r1=zeros(1,size(W,1)-1);
        r2=zeros(1,size(W,1)-1);
        
        z=cumsum(W);%sum over the columns
        %for the concept vectors I need to sum over the images the corresponding concepts 
        zc=cumsum(WC,3);%sum over the images, this is also three dimensional
        n_frames=size(W,1)-1;
        for i=1:n_frames
            n0=i;
            n1=size(W,1)-i;
      
            m=(n0*n1)/((sqrt(n0)+sqrt(n1))^2);
            fi_prime=fi/(k*(n0+n1));
            
            
            if flag ==1
                ecut2=(k)^(1/p)*sqrt( (2/m) * variance * log(2/fi_prime) ) + (2/(3*m))*log(2/fi_prime);
            elseif flag==0             
                ecut2=(k)^(1/p)*((1/(2*m)) * log((4)/fi_prime) )^(1/2);
            end
            
%ecut2: 30
            mu_w0_global=(z(i,:))/i;
            mu_w1_global=(z(end,:)-z(i,:))/(n_frames+1-i);
            %do the mean of the concepts 
            mu_w0_concepts=(zc(:,:,i))/i;
            mu_w1_concepts=(zc(:,:,end)-zc(:,:,i))/(n_frames+1-i);  
      
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%          
            r1(i) = compute_distance_adwin(mu_w0_global,mu_w1_global,mu_w0_concepts,mu_w1_concepts);
             
            %compute distance between the means in two different windows
            r2(i)=ecut2;
        end
        if(max(r1-r2)<0)
            cut=true;
        end
        max(r1-r2)
        if(cut==false)
            %disp(ecut2)
            %disp(max(r1))
                        %disp(max(r1-r2))
            [aa bb]=max(r1-r2);
           % aa
           % bb
          

           
            W_tmp=W(bb+1:end,1:k);
            clear W;
            W=W_tmp;
            clear W_tmp;
  
            
                      
            WC_tmp=WC(:,:,bb+1:end);
            clear WC;
            WC=WC_tmp;
            clear WC_tmp; 
        end
    end%ed  while false
    w(t)=size(W,1);
end

indexes=[];
x=w(2:end)-w(1:end-1);
indexes=abs(x(find(x<0)))+1;
indexes=cumsum(indexes);
indexes=[1 indexes length(w)];

for i=1:length(indexes)-1
    w3_global(indexes(i):indexes(i+1), 1:k)=(   repmat(    mean(data_global(indexes(i):indexes(i+1), 1:k)), [length([indexes(i):indexes(i+1)]) 1] )      );
    w3_concepts(:,:,indexes(i):indexes(i+1))=(repmat(mean(data_concepts(:,:,indexes(i):indexes(i+1)),3),  [1 1 length([indexes(i):indexes(i+1)])]));
end
