##############################################################################################################
# MANIPULATION OF MATRICES ###################################################################################
##############################################################################################################

def partial_smith(M):
    n = M.nrows()
    m = M.ncols()
    k = 0
    verif = True
    while verif and k < min(n, m):
        #print("step " + str(k))
        verif = False
        for i in range(k, n):
            for j in range(k, m):
                if M[i, j] in QQ and M[i, j] != 0:
                    verif = True
                    keep = (i, j)
                    break
            if verif:
                break
        if verif:
            if keep[0] != k:
                M.swap_rows(k, keep[0])
            if keep[1] != k:
                M.swap_columns(k, keep[1])
            if M[k, k] != 1:
                M.rescale_row(k, 1/M[k, k])
            for i in range(k+1, n):
                M.add_multiple_of_row(i, k, -M[i, k])
            for j in range(k+1, m):
                M.add_multiple_of_column(j, k, -M[k, j])
            k += 1
    print("Minimal rank : " + str(k) + ", dimensions of remaining matrix : " + str([n-k, m-k]))
    return [k, M[k:, k:]]

def partial_smith_onlyrows(M):
    n = M.nrows()
    m = M.ncols()
    k = 0
    verif = True
    while verif and k < min(n, m):
        #print("step " + str(k))
        verif = False
        for i in range(k, n):
            for j in range(k, m):
                if M[i, j] in QQ and M[i, j] != 0:
                    verif = True
                    keep = (i, j)
                    break
            if verif:
                break
        if verif:
            if keep[0] != k:
                M.swap_rows(k, keep[0])
            if keep[1] != k:
                M.swap_columns(k, keep[1])
            if M[k, k] != 1:
                M.rescale_row(k, 1/M[k, k])
            for i in range(k+1, n):
                M.add_multiple_of_row(i, k, -M[i, k])
            k += 1
    print("Minimal rank : " + str(k) + ", dimensions of remaining matrix : " + str([n-k, m-k]))
    return [k, M[k:, k:]]

def tensor_product(M, N):
    '''
    For M in Mn1,m1 and N in Mn2,m2, return the image of M tens N in Mn1n2,m1m2.
    '''
    
    n1 = M.nrows()
    m1 = M.ncols()
    n2 = N.nrows()
    m2 = N.ncols()
    P = Matrix([[0 for i in range(m1 * m2)] for j in range(n1 * n2)])
    for i in range(n1):
        for j in range(m1):
            for k in range(n2):
                for l in range(m2):
                    P[k*n1+i, l*m1+j] = M[i, j] * N[k, l]
    return P

def print_rows(M):
    n = M.nrows()
    m = M.ncols()
    for i in range(n):
        display = "Row " + str(i) + " : "
        list_coef = []
        for j in range(m):
            if M[i, j] != 0:
                list_coef.append("col " + str(j) + " : " + str(M[i ,j]))
        display += str(list_coef)
        print(display)
        
##############################################################################################################
# ZASSENHAUS #################################################################################################
##############################################################################################################
        
def Zassenhaus(M, N):
    print(M.nrows(), M.ncols())
    print(N.nrows(), N.ncols())
    n = M.ncols()
    R = block_matrix([[M, M], [N, 0]]).echelon_form()
    maxi = R.nrows()
    half_R = R.matrix_from_columns(range(n))
    i = 0
    while i < maxi and half_R.matrix_from_rows(range(i, maxi)) != 0:
        i+=1
    print(i)
    second_half_R = R.matrix_from_rows_and_columns(range(i, maxi), range(n, 2*n))
    j = 0
    while j < maxi - i and second_half_R.matrix_from_rows(range(j, maxi - i)) != 0:
        j+=1
    print(j)
    return R.matrix_from_rows_and_columns(range(i, j + i), range(n, 2*n))

def intersection(list_matrices):
    if len(list_matrices) == 0:
        return []
    elif len(list_matrices) == 1:
        return list_matrices[0]
    elif len(list_matrices) == 2:
        return Zassenhaus(list_matrices[0], list_matrices[1])
    else:
        return intersection([Zassenhaus(list_matrices[0], list_matrices[1])] + list_matrices[2:])