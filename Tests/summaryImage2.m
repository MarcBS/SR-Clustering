
% Creates a summary image of all the events extracted from the set of
% images.
%
% props: final proportions of the images
% num_clusters: number of events extracted from the set
% n_summaryImages: number of images shown for each event
% result_data: cell structure with lists of images' ids for each event
% fileList: list of files where the images are stored or video loaded
% source: path to the directory where the images are ('' if using video)
% source_type: type of the source {images, video}
% ini: initial image for the video extraction (0 if source_type == images)
% labels_text: labels assigned to each of the events (leave empty [] for
%               not writing it).
function [ gen_image ] = summaryImage2( props, num_clusters, n_summaryImages, result_data, fileList, source, source_type, ini, labels_text )

    red_img=uint8(ones(props(1), props(2),3)*255);
    red_img(:,:,2)=0;
    red_img(:,:,3)=0;
    
    green_img=uint8(ones(props(1), props(2),3)*255);
    green_img(:,:,1)=0;
    green_img(:,:,3)=0;

    border = 8;
    
    disp(['aux_img created!']);
    
    %Leer .csv con segmentación de Florida. Nos interesa la última posición
    %de cada fila.
    gt_path='/media/lifelogging2/My Book/Datos_Lifelogging/Narrative/Nick_Florida/GT _segments';
    set=105;
    glob_path=[gt_path '/' num2str(set) '.csv'];
    fid=fopen(glob_path);
    out=textscan(fid,'%s%s','delimiter',',');
    bounds=out{1,1};
    
    counter_florida=1;
    
    disp(['GT readed!']);
    
    num_img_fila=30; %A cambio de n_summmaryImages

    if(isempty(labels_text))
        gen_image = uint8(ones((props(1)+border)*ceil((803+num_clusters+length(bounds))/num_img_fila), props(2)*num_img_fila, 3)*255);
    else
        gen_image = uint8(ones((props(1)+border)*ceil((803+num_clusters+length(bounds))/num_img_fila), props(2)*(num_img_fila+1), 3)*255);
    end
    
    countx=1; %Contador de les imatges que hi ha per fila
    county=1;
        
    for i = 1:num_clusters
        this_c = result_data{i};
        n_elems = length(this_c);
%         if(n_elems < n_summaryImages)
%             num_sum = n_elems;
%             jump = 1;
%         else
%             num_sum = n_summaryImages;
%             jump = floor(n_elems/n_summaryImages);
%         end
        
%         if(isempty(labels_text))
%             last = n_elems; %Vull que surtin tots els elements del cluster
%         else
%             last = n_elems+1;
%         end
        
        for j = 1:n_elems %last
%             if(j > num_sum)
%                 % Insert label at the end of the event
%                 x1 = ((i-1)*props(1));
%                 x2 = (i*props(1));
%                 y1 = ((j-1)*props(2)-props(2)/4);
%                 y2 = (j*props(2));
%                 htxtins = vision.TextInserter([labels_text(i) ' ' num2str(size(result_data{i},2))]);
%                 htxtins.Color = [0, 0, 0]; % [red, green, blue]
%                 htxtins.FontSize = 35;
%                 htxtins.Location = [((y2-y1)/3)+y1 ((x2-x1)/3)+x1]; % [x y]
%                 gen_image = step(htxtins, gen_image);
%                   
%             else
                if(strcmp(source_type, 'images'))
                    im = imread([source '/' fileList(this_c(j)).name]);
                elseif(strcmp(source_type, 'video'))
                    im = read(fileList, (ini + this_c(j*jump)));
                end
                
                im = imresize(im, props);
                x1 = ((countx-1)*(props(1)+border)+1);
                x2 = (countx*props(1)+(countx-1)*border);
                y1 = ((county-1)*props(2)+1);
                y2 = (county*props(2));
                gen_image( x1:x2, y1:y2, 1 ) = im(:,:,1);
                gen_image( x1:x2, y1:y2, 2 ) = im(:,:,2);
                gen_image( x1:x2, y1:y2, 3 ) = im(:,:,3);
                
                county=county+1;
                
                 if county==num_img_fila
                    county=1;
                    countx=countx+1;
                 end
                 
                  %Limitar amb el gt de Florida
                 for n=1:1:length(bounds)
                     
                     if strcmp(fileList(this_c(j)).name,cell2mat(bounds(n)))
                        im=green_img;
                        x1 = ((countx-1)*(props(1)+border)+1);
                        x2 = (countx*props(1)+(countx-1)*border);
                        y1 = ((county-1)*props(2)+1);
                        y2 = (county*props(2));
                        gen_image( x1:x2, y1:y2, 1 ) = im(:,:,1);
                        gen_image( x1:x2, y1:y2, 2 ) = im(:,:,2);
                        gen_image( x1:x2, y1:y2, 3 ) = im(:,:,3);

                        county=county+1;

                         if county==num_img_fila
                            county=1;
                            countx=countx+1;
                         end 

                        counter_florida=counter_florida+1;

                     end
                 end
        end 
        %end
        
                %Segment bound
                im=red_img;
                x1 = ((countx-1)*(props(1)+border)+1);
                x2 = (countx*props(1)+(countx-1)*border);
                y1 = ((county-1)*props(2)+1);
                y2 = (county*props(2));
                gen_image( x1:x2, y1:y2, 1 ) = im(:,:,1);
                gen_image( x1:x2, y1:y2, 2 ) = im(:,:,2);
                gen_image( x1:x2, y1:y2, 3 ) = im(:,:,3);
        
                county=county+1;
                
                 if county==num_img_fila
                    county=1;
                    countx=countx+1;
                 end
    end
    disp(['gen_image generated successfully!']);
end

