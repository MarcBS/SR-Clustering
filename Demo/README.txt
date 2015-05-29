The script demoRClustering.m offers an example of the results obtained by the R-Clustering algorithm.

Just run to test it on the demo dataset, or change the parameters (in loadParamatersDemo.m) 
consequently to run it for your own datasets.

The input data folder structure is the following:
    Camera_Name         ('Narrative' in the demo)
    >   imageSets       (all sets to process, 'Subject1' in the demo)
    >   GT              (.xls ground truth files, each starting with the 
                        prefix 'GT_'. Only for results evaluation)