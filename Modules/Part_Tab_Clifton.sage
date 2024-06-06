##############################################################################################################
# FUNCTIONS FOR PARTITIONS, TABLEAUX AND CLIFTON #############################################################
##############################################################################################################

def all_tableaux_part(part, n):
    '''
    Return all tableaux of shape part for integer n.
    '''
    list_tableaux = []
    for p in Permutations(n):
        tab = []
        k = 0
        for j in part:
            tab.append([p(i+1) for i in range(k, k + j)])
            k += j
        list_tableaux.append(tab)
    return list_tableaux

def transpose(tab):
    '''
    Return the transpose of the tableau tab.
    '''
    n = sum(len(tab[i]) for i in range(len(tab)))
    new_tab = []
    for i in range(n):
        new_group = []
        for group in tab:
            if len(group) > i:
                new_group.append(group[i])
        if len(new_group) > 0:
            new_tab.append(new_group)
    return new_tab
        

def is_standard(tab):
    '''
    Check if tab is standard.
    '''
    verif = True
    for group in tab:
        if group != sorted(group):
            verif = False
    if verif:
        for group in transpose(tab):
            if group != sorted(group):
                verif = False
    return verif

def all_standard_tableaux_part(part, n):
    '''
    Return a list of all standard tableaux of shape part.
    '''
    list_standard_tableaux = []
    for tab in all_tableaux_part(part, n):
        if is_standard(tab):
            list_standard_tableaux.append(tab)
    return list_standard_tableaux

def Clifton(part, p): #Tableaux = liste des tableaux standards associés à une partition p = permutation
    n = len(p)
    Tableaux = all_standard_tableaux_part(part, n)
    T=[]
    for tablo in Tableaux:
        tablobis=[]
        for ligne in tablo:
            lignebis=[]
            for number in ligne:
                lignebis=lignebis+[number]
            tablobis=tablobis+[lignebis]
        T=T+[tablobis]
    pT=[]
    for tab in T:
        pt=[]
        for ligne in tab:
            pl=[]
            for j in ligne:
                pl=pl+[p(j)]
            pt=pt+[pl]
        pT=pT+[pt]
    #print(pT)
    #calcul de n
    n=0
    for u in T[0]:
        n=n+len(u)
    A=[]
    for j in range(len(T)):
        Aj=[]
        for i in range(len(T)):
            T=[]
            for tablo in Tableaux:
                tablobis=[]
                for ligne in tablo:
                    lignebis=[]
                    for number in ligne:
                        lignebis=lignebis+[number]
                    tablobis=tablobis+[lignebis]
                T=T+[tablobis]
            Ai=[]
            e=1
            k=0
            b=false
            while k<n and b==false:
                s=0
                si=0
                ti=0
                for l in T[i]:
                    for t in range(len(l)):
                        if l[t]==k:
                            si=s
                            ti=t
                        t=t+1
                    s=s+1
                #print(k,"se trouve dans T[i] à",si,ti)
                s=0
                sj=0
                tj=0
                for l in pT[j]:
                    for t in range(len(l)):
                        if l[t]==k:
                            sj=s
                            tj=t
                        t=t+1
                    s=s+1
                #print(k,"se trouve dans pT[j]",sj,tj)
                if si!=sj:
                    if ti>len(pT[i][sj])-1:
                        #print("required position does not exist")
                        e=0
                        b=True
                    else:
                        #print(k,"et",ti,"et",T[i][sj],len(T[i][sj]),ti>len(T[i][sj]))
                        if T[i][sj][ti]<T[i][si][ti]:
                            #print("required position already occupied")
                            e=0
                            b=True
                        else:
                            e=-e
                            x=T[i][si][ti]
                            T[i][si][ti]=T[i][sj][ti]
                            T[i][sj][ti]=x
                k=k+1
                s=0
                t=0
            Aj=Aj+[e]
        A=A+[Aj]
    return(matrix(A).transpose())