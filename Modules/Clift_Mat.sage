##############################################################################################################
# MANIPULATIONS OF CLIFTON MATRICES ##########################################################################
##############################################################################################################

def create_Cliftons(list_elements):
    '''
    Return a dictionnary with all couple of partitions as keys and the corresponding Clifton matrices as elements.
    list_elements needs to be a list of elements, which are lists of [Graph, coef]'s, with all graphs having the same arity.
    '''
    #Get ids
    
    arity = list_elements[0][0][0].arity

    ids = []
    list_shapes = []
    list_shapes_ext = []
    for element in list_elements:
        el_id = []
        for graph in element:
            shape = graph[0].shape()
            if shape not in list_shapes:
                list_shapes_ext.append(graph[0])
                list_shapes.append(shape)
            el_id.append([[list_shapes.index(shape), graph[0].perm_outputs, graph[0].perm_inputs], graph[1]])
        ids.append(el_id)

    #Getting rid of dups

    keep = []
    for el in ids:
        verif = True
        for el2 in keep:
            if el == el2:
                verif = False
        if verif:
            keep.append(el)
    ids = [keep, list_shapes_ext]

    #Get Cliftons

    dic_matrix = {}
    list_shapes = ids[1]
    list_rel = ids[0]
    partitions_outputs = Partitions(arity[0])
    partitions_inputs = Partitions(arity[1])
    couples_partitions = []
    for part_out in partitions_outputs:
        for part_in in partitions_inputs:
            couples_partitions.append((part_out, part_in))
    m = len(list_shapes) #nb of cols
    n = len(list_rel) #nb of rows
    for couple in couples_partitions:
        size_matrices = len(all_standard_tableaux_part(couple[0], arity[0])) * len(all_standard_tableaux_part(couple[1], arity[1]))
        Mat_couple = []
        for i in range(m):
            shape = list_shapes[i]
            rowi = []
            for rel in list_rel:
                Mat_ij = Matrix([[0 for i in range(size_matrices)] for j in range(size_matrices)])
                for graph in rel:
                    if graph[0][0] == i:
                        Mat_ij = Mat_ij + graph[1] * tensor_product(Clifton(couple[0], graph[0][1]), Clifton(couple[1], graph[0][2]))
                rowi = rowi + [Mat_ij]
            Mat_couple = Mat_couple + [block_matrix([rowi]).transpose()]
        Mat_couple = block_matrix([Mat_couple])
        dic_matrix[couple] = Mat_couple
        
    return dic_matrix

def Clifton_partial_smith(dic_matrix):
    dic_matrix_smith = {}
    for couple in dic_matrix:
        print("Couple : " + str(couple))
        dic_matrix_smith[couple] = partial_smith(dic_matrix[couple])
    return dic_matrix_smith

def Clifton_matrix_simple(dic_matrix):
    #A refaire en prenant en supprimant les doubles lignes/colonnes....
    dic_matrix_smith = Clifton_partial_smith(dic_matrix)
    dic_matrix_simple = {}
    for couple in dic_matrix_smith:
        mat = dic_matrix_smith[couple][1]
        list_rows = []
        for i in range(mat.nrows()):
            verif = True
            for j in list_rows:
                if mat.row(i) == mat.row(j) or mat.row(i) == -1 * mat.row(j):
                    verif = False
            if mat.row(i) != 0 and verif:
                list_rows.append(i)
        list_cols = []
        for i in range(mat.ncols()):
            verif = True
            for j in list_cols:
                if mat.column(i) == mat.column(j) or mat.column(i) == -1 * mat.column(j):
                    verif = False
            if mat.column(i) != 0 and verif:
                list_cols.append(i)
        print("Couple : " + str(couple))
        print("Removed " + str(mat.nrows() - len(list_rows)) + " rows and " + str(mat.ncols() - len(list_cols)) + " columns")
        print("Rank is in " + str([0, min(len(list_rows), len(list_cols))]))
        dic_matrix_simple[couple] = [dic_matrix_smith[couple][0], mat.matrix_from_rows_and_columns(list_rows, list_cols)]
    return dic_matrix_simple

def save_matrices_csv(dic_matrix_simple, prefix, suffix):
    for couple in dic_matrix_simple:
        np.savetxt("Files/Matrices/" + prefix + str(couple) + suffix + ".csv", list(dic_matrix_simple[couple][1]), delimiter =", ", fmt ='% s')

def evaluate(dic_matrix, x, y, z, t):
    dic_evaluated = {}
    for couple in dic_matrix:
        dic_evaluated[couple] = [dic_matrix[couple][0], dic_matrix[couple][1](x, y, z, t)]
        print("Couple : " + str(couple))
        print("Rank : " + str(dic_evaluated[couple][0] + dic_evaluated[couple][1].rank()))
        
