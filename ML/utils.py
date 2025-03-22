import os
import gc
import time
import ripser
import cechmate as cm
from sklearn.decomposition import PCA
import gudhi.representations
import gudhi as gd 
import numpy as np
from joblib import Parallel, delayed
remove_infinity = lambda alpha_list: [alpha for alpha in alpha_list if alpha[1] != np.inf]
pca = PCA(n_components=2)

def Compute_persistence(data_remove):
    
    print(f"進程 {os.getpid()} 開始計算")
    result = ripser.ripser(data_remove, distance_matrix=True, maxdim=0)['dgms'][0]
    print(f"進程 {os.getpid()} 完成計算")
    
    return result

def Data_list(X_scaled):
    
    data_list = []
    for i in range(X_scaled.shape[0]):
        if (i + 1) % 500 == 0:
            print(f"Processing row {i + 1} out of {X_scaled.shape[0]}")
            gc.collect()
            
        data_remove = X_scaled.drop(index=i)
        data_list.append(data_remove)
        
    return data_list
    
def Compute_Alpha(data_remove):
    
    # print(f"進程 {os.getpid()} 開始計算")
    
    # PCA
    pca_result = pca.fit_transform(data_remove)
    # Alpha complex
    alpha_complex = gd.AlphaComplex(points = pca_result)
    st_alpha = alpha_complex.create_simplex_tree()
    alpha_filtration = st_alpha.get_filtration()
    alpha_list = list(alpha_filtration)
    # Filter
    filtered_alpha_list = remove_infinity(alpha_list)
    dgm = np.array([[0.0, value] for _, value in filtered_alpha_list])
    dgm_filtered = np.array([bar for bar in dgm if bar[1] - bar[0] != 0])
    ## entropy
    PE = gd.representations.Entropy()
    pe_normal = PE.fit_transform([dgm_filtered])
    
    # print(f"進程 {os.getpid()} 完成計算")
    return pe_normal

def Compute_DR(data_remove):
    
    # print(f"進程 {os.getpid()} 開始計算")
    
    # PCA
    pca_result = pca.fit_transform(data_remove)
    
    # DR complex
    del_rips = cm.DR(maxdim=1)
    filtration = del_rips.build(pca_result)
    dgms_del_rips = del_rips.diagrams(filtration, verbose=False)

    ## entropy
    PE = gd.representations.Entropy()
    pe_normal = PE.fit_transform([dgms_del_rips[0]])
    
    # print(f"進程 {os.getpid()} 完成計算")
    return pe_normal

def Compute_Alpha_from_Cechmate(data_remove):
    
    # print(f"進程 {os.getpid()} 開始計算")
    
    # PCA
    pca_result = pca.fit_transform(data_remove)
    
    # DR complex
    del_rips = cm.Alpha(maxdim=0)
    filtration = del_rips.build(pca_result)
    dgms_del_rips = del_rips.diagrams(filtration, verbose=False)

    ## entropy
    PE = gd.representations.Entropy()
    pe_normal = PE.fit_transform([dgms_del_rips[0]])
    
    # print(f"進程 {os.getpid()} 完成計算")
    return pe_normal

def Parrallel_compute(data_list, typeComplex='Alpha'):
    start_time = time.time()
    if typeComplex == 'Alpha':
        results = Parallel(n_jobs=-1)(delayed(Compute_Alpha)(data) for data in data_list)
    elif typeComplex == 'DR':
        results = Parallel(n_jobs=-1)(delayed(Compute_DR)(data) for data in data_list)
    elif typeComplex == 'AlphafromCechmate':
        results = Parallel(n_jobs=-1)(delayed(Compute_Alpha_from_Cechmate)(data) for data in data_list)
    end_time = time.time()
    print("平行運算時間: ", end_time - start_time)
    return results
