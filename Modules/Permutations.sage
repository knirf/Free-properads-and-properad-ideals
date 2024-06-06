##############################################################################################################
# FUNCTIONS TO MANIPULATE PERMUTATIONS #######################################################################
##############################################################################################################

def perm_modulo_left(limit, i):
    '''
    Return all permutations of lengh i modulo permutation of the 'limit' first terms and the 'i - limit' last terms (on the left).
    '''
    result = []
    for_perm = [i for i in range(1, limit + 1)]
    list_perm = []
    for perm in Permutations(i-limit):
        list_perm.append(Permutation(for_perm + [perm(j) + limit for j in range(1, i - limit + 1)]))
    couples = []
    for perm1 in list_perm:
        for perm2 in Permutations(limit):
            couples.append(perm1 * perm2)
    for perm2 in Permutations(i):
        verif = True
        for perm3 in result:
            for couple in couples:
                if couple * perm3 == perm2:
                    verif = False
                    break
            if not verif:
                break
        if verif:
            result.append(perm2)
    return result

def perm_modulo_right(limit, i):
    '''
    Return all permutations of lengh i modulo permutation of the 'limit' first terms and the i - limit' last terms (on the right).
    '''
    result = []
    for_perm = [i for i in range(1, limit + 1)]
    list_perm = []
    for perm in Permutations(i-limit):
        list_perm.append(Permutation(for_perm + [perm(j) + limit for j in range(1, i - limit + 1)]))
    couples = []
    for perm1 in list_perm:
        for perm2 in Permutations(limit):
            couples.append(perm1 * perm2)
    for perm2 in Permutations(i):
        verif = True
        for perm3 in result:
            for couple in couples:
                if perm3 * couple == perm2:
                    verif = False
                    break
            if not verif:
                break
        if verif:
            result.append(perm2)
    return result