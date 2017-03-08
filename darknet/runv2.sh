
## images directory
path_folder="/media/marcvaldivia/HDD/EDUB-Seg/images/SubjectR_SetR_min/"

## declare an array variable
declare -a arr=( $(ls $path_folder*.jpg) )

## results
ret=$(./darknet detector test cfg/combine9k.data cfg/yolo9000.cfg yolo9000.weights $i)
echo $ret
