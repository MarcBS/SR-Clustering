addpath('../Code');

folders={'Petia1','Petia2','Estefania1','Estefania2','Mariella','Day1','Day2','Day3','Day4','Day6'};
formats={'.jpg', '.jpg', '.jpg', '.jpg', '.jpg', '.JPG','.JPG','.JPG','.JPG','.JPG'};


% For each folder we compute JI and FMeasure
for i_fold=1:length(folders)
    
    folder=folders{i_fold};
    fichero=(['/Users/estefaniatalaveramartinez/Desktop/LifeLogging/IbPRIA/Sets/' folder]);
    excel_filename=(['GT_' folder '.xls']);
    [events,clustersId,cl_limGT,sum]=analizarExcel_Narrative(excel_filename,fichero,formats{i_fold});
    sum

end