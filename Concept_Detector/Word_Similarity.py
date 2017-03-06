
# coding: utf-8

# ### Using NLTK and WordNet to get word pairs similarities

# Imports and parameters

from glob import glob
import ntpath
from operator import itemgetter
import re
from sklearn.cluster import SpectralClustering
from nltk.corpus import wordnet as wn


def getSimilarity(w1, w2, method='max'):
    meanings_1 = wn.synsets(w1)
    nm1 = len(meanings_1)

    meanings_2 = wn.synsets(w2)
    nm2 = len(meanings_2)

    if(method == 'max'):
        similarity = 0
        for i in range(nm1):
            m1 = wn.synset(meanings_1[i].name())
            for j in range(nm2):
                m2 = wn.synset(meanings_2[j].name())

                sim = wn.path_similarity(m1, m2)
                similarity = max(sim, similarity)
    elif(method == 'mean'):
        if(nm1*nm2 == 0):
            return 0

        similarities = [0 for i in range(nm1*nm2)]
        count = 0
        for i in range(nm1):
            m1 = wn.synset(meanings_1[i].name())
            for j in range(nm2):
                m2 = wn.synset(meanings_2[j].name())

                sim = wn.path_similarity(m1, m2)
                if(sim == None):
                    sim = 0
                similarities[count] = sim
                count += 1
        similarity = float(sum(similarities))/count

    return similarity

# ### Compute Clustering

# In[278]:

def normalize(M):
    length = len(M)
    for col in range(length):
        vals = [v for v in M[:][col]]
        maxval = max(vals)
        minval = min(vals)
        denom = (maxval-minval)
        if(denom == 0):
            denom = 0.00000000001
        normalized = [(e-minval)/float(denom) for e in vals]
        M[:][col] = normalized
    return M


# ### Calculate number of word pairs appearances in all the images and get top co-ocurrences

# In[274]:


# Data parameters
path_images = '%folder_path%'
folders = ['%folder_name%']
formats = ['%format%']

# Result parameters
path_result = '%input_path%'
path_output_lists = '%output_path%'

# Get list of jsons for each folder

nFolders = len(folders)

for f in range(nFolders):
	jsons_list = []
	result_dir = path_result + '/' + folders[f]
	list_imgs = glob(path_images + '/' + folders[f] + '/*' + formats[f])
	nList = len(list_imgs)

	for i in range(nList):
		img_name = ntpath.basename(list_imgs[i])
		jsons_list.append(result_dir + '/' + img_name + '.json')

	print "Processing folder " + folders[f]

	list_output = open(path_output_lists +'/list_'+ folders[f] +'.txt', 'w')

	# ### Find co-occurrences of words in all files


	nFiles = len(jsons_list)
	word_list = [] # list of words found
	word_count = [] # list of word counts for each element in word_list
	count_coocurrences = 0

	sim_mat = [[0 for i in range(5000)] for j in range(5000)] # matrix with similarities for each pair of words
	CO = [[0 for i in range(5000)] for j in range(5000)] # matrix with number of co-ocurrences for each pair of words



	# Open each file
	for f in range(nFiles):
	    # Get list of words of the current file
	    with open(jsons_list[f]) as data_file:
	        text = data_file.read()
	        pos = [m.span() for m in re.finditer(': "\w+"', text)]
	        words = [text[p[0]+3:p[1]-1] for p in pos]
	        words = words[1:]

	    # Find word positions in the whole list of words
	    positions = []
	    nW = len(words)
	    for i in range(nW):
	        w = words[i]
	        if w in word_list:
	            ind = word_list.index(w)
	            positions.append(ind)
	            word_count[ind] += 1
	        else:
	            word_list.append(w)
	            word_count.append(1)
	            positions.append(len(word_list)-1)

	    # For each pair of words, increment their co-ocurrences
	    for i in range(nW):
	        for j in range(i,nW):
	            maxp = max(positions[i], positions[j])
	            minp = min(positions[i], positions[j])
	            CO[maxp][minp] += 1
	            # If we find a new pair of words, we get their similarity
	            if(CO[maxp][minp] == 1):
	                sim = getSimilarity(word_list[maxp], word_list[minp], 'max')
	                sim_mat[maxp][minp] = sim
	                sim_mat[minp][maxp] = sim
	                count_coocurrences += 1

	nWords = len(word_list)
	# Reduce CO an sim_mat matrix sizes w.r.t. the total number of words found
	CO = [CO[i][0:nWords] for i in range(nWords)]
	sim_mat = [sim_mat[i][0:nWords] for i in range(nWords)]
	for i in range(nWords):
	    sim_mat[i][i] = 1

	print "Found " + str(nWords) + " different tags."
	print "Found " + str(count_coocurrences) + " co-ocurring pairs."


	sc = SpectralClustering(n_clusters=min(100, nWords-1), affinity='precomputed')
	clusters = sc.fit_predict(normalize(sim_mat))
	clusterIDs = sorted(set(clusters))

	nClusters = len(clusterIDs)

	# Find word with more connections in each cluster
	for cID in range(nClusters):
		words_cluster = [i for i, x in enumerate(clusters) if x == cID]
		nWords = len(words_cluster)

		conn_count = [0 for i in range(nWords)]
		# Count connections for each word
		for w in range(nWords):
			cluster_connections = [sim_mat[words_cluster[w]][x] for x in words_cluster[0:w] + words_cluster[w+1:]]
			conn_count[w] = sum([x for x in cluster_connections if x > 0])

		# Find word with max number of connections
		max_word = conn_count.index(max(conn_count))

		#print cID
		#print word_list[words_cluster[max_word]]
		#print max(conn_count)
		#print [word_list[w] for w in words_cluster]
		#print conn_count
		#print

		list_output.write(word_list[words_cluster[max_word]] + ' ' +  str([word_list[w] for w in words_cluster]) +'\n')

	list_output.close()

print 'Done'
