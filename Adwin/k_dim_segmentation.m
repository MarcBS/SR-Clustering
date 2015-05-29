function [w3, indexes]=k_dim_segmentation(data,fi, p, flag)
%
% INPUT:
%   data   -> n x k data stream (each data in [0, 1]).
%   fi -> segmentation parameter
%   p -> norm parameter
%   flag 0 or 1 -> bound type
%
% OUTPUT:
%   w3    -> n x k data streams with means. 
%   idx   -> idx inside a stream with detected change.


[n_tot,k]=size(data);
w3=zeros(n_tot, k);
w=zeros(1, n_tot);

len=5;
W=data(1:len,1:k);

for t=len+1:n_tot

    W=[W; data(t,1:k)] ;
    pNorm = sum(abs(W).^p,2).^(1/p);
    pNorm=pNorm./((k)^(1/p));
    variance=var(pNorm);
    
    % Drop elements for the tail of W
    % while all splits of W (||mu_w0-mu_w1||)>=ecut)
    cut=false;
    
    while(cut==false)
        
        r1=zeros(1,size(W,1)-1);
        r2=zeros(1,size(W,1)-1);
        
        z=cumsum(W);
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
%             ecut2
            mu_w0=(z(i,:))/i;
            mu_w1=(z(end,:)-z(i,:))/(n_frames+1-i);
            r1(i)=norm(mu_w0 - mu_w1, p);
            r2(i)=ecut2;
        end
        if(max(r1-r2)<0)
            cut=true;
        end
        if(cut==false)
            %disp(ecut2)
            %disp(max(r1))
                        %disp(max(r1-r2))
            [aa bb]=max(r1-r2);
%                 aa
%                 bb
            W_tmp=W(bb+1:end,1:k);
            clear W;
            W=W_tmp;
            clear W_tmp;
        end
    end
    w(t)=size(W,1);
end


x=w(2:end)-w(1:end-1);
indexes=abs(x(find(x<0)))+1;
indexes=cumsum(indexes);
indexes=[1 indexes length(w)];

for i=1:length(indexes)-1
    w3(indexes(i):indexes(i+1), 1:k)=(repmat(mean(data(indexes(i):indexes(i+1), 1:k)), [length([indexes(i):indexes(i+1)]) 1]));
end
