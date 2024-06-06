##############################################################################################################
# Groebner basis and primary decompositions ##################################################################
##############################################################################################################

def groebner_bas(M, n = None):
    if n == None:
        n = min(M.ncols(), M.nrows())
    print("Matrix size : " + str((M.nrows(), M.ncols())))
    minors = []
    list_ideals = []
    grob_basis = []
    for i in range(n):
        print("Minors of size " + str(i+1))
        list_minors = [M.matrix_from_rows_and_columns(rows, cols).det() for cols in Combinations(range(M.ncols()), i+1) for rows in Combinations(range(M.nrows()), i+1)]
        minors.append(list_minors)
        print("All minors calculated")
        I = ideal(list_minors)
        list_ideals.append(I)
        print("Ideal defined")
        B = I.groebner_basis()
        grob_basis.append(B)
        print("Groebner Basis calculated")
    return (minors, list_ideals, grob_basis)

def primary_dec(M, n = None):
    if n == None:
        n = min(M.ncols(), M.nrows())
    minors = []
    list_ideals = []
    prim_dec = []
    for i in range(n):
        print("Minors of size " + str(i+1))
        list_minors = [M.matrix_from_rows_and_columns(rows, cols).det() for cols in Combinations(range(M.ncols()), i+1) for rows in Combinations(range(M.nrows()), i+1)]
        minors.append(list_minors)
        print("All minors calculated")
        I = ideal(list_minors)
        list_ideals.append(I)
        print("Ideal defined")
        B = I.primary_decomposition()
        prim_dec.append(B)
        print("Primary decomposition calculated")
    return (minors, list_ideals, prim_dec)

def primary_dec_and_Groebner(M, n = None):
    if n == None:
        n = min(M.ncols(), M.nrows())
    print("Matrix size : " + str((M.nrows(), M.ncols())))
    minors = []
    list_ideals = []
    grob_basis = []
    prim_dec = []
    for i in range(n):
        print("Minors of size " + str(i+1))
        list_minors = [M.matrix_from_rows_and_columns(rows, cols).det() for cols in Combinations(range(M.ncols()), i+1) for rows in Combinations(range(M.nrows()), i+1)]
        minors.append(list_minors)
        print("All minors calculated")
        I = ideal(list_minors)
        list_ideals.append(I)
        print("Ideal defined")
        B = I.groebner_basis()
        grob_basis.append(B)
        print("Groebner Basis calculated")
        B = I.primary_decomposition()
        prim_dec.append(B)
        print("Primary decomposition calculated")
    return (minors, list_ideals, grob_basis, prim_dec)