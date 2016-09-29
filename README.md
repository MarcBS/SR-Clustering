# SR-Clustering
Semantic Segmentation of events in egocentric lifelogging photo streams.

Requirements:

	1) Caffe Deep Learning Framework and matcaffe wrapper (for global features calculation)
		Caffe main page: http://caffe.berkeleyvision.org/
		Good Linux installation tutorial: https://github.com/tiangolo/caffe/blob/ubuntu-tutorial-b/docs/install_apt2.md
		CaffeNet model: http://dl.caffe.berkeleyvision.org/bvlc_googlenet.caffemodel 
	2) IMAGGA account (for semantic features calculation)
		http://www.imagga.com/
	2) [ALTERNATIVE] if using LSDA instead of IMAGGA, download and install the needed files to ./LSDA from the GitHub repository
		[https://github.com/jhoffman/lsda](https://github.com/jhoffman/lsda)
	3) Compile files in GCMex for your system.
	4) MATLAB
	5) [IMAGGA only] Python 2.7 (with nltk libraries)


If you use this code, please cite the following papers:

        Dimiccoli, M., Bolaños, M., Talavera, E., Aghaei, M., Nikolov, S. & Radeva, P. (2015) 
        "SR-Clustering: Semantic Regularized Clustering for Egocentric Photo Streams Segmentation". 
        Submitted to Pattern Recognition. Pre-print: http://arxiv.org/abs/1512.07143

        Talavera, E., Dimiccoli, M., Bolaños, M., Aghaei, M., & Radeva, P. (2015).
        “R-Clustering for Egocentric Video Segmentation”. 
        In 7th Iberian Conference on Pattern Recognition and Image Analysis (IbPRIA).

Use code in Demo folder for a simple execution of our SR-Clustering algorithm (read Demo/README.txt before execution).
