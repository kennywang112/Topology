import os
import ripser

def compute_persistence(data_remove):
    print(f"進程 {os.getpid()} 開始計算")
    result = ripser.ripser(data_remove, distance_matrix=True, maxdim=0)['dgms'][0]
    print(f"進程 {os.getpid()} 完成計算")
    return result