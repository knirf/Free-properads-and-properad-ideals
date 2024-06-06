##############################################################################################################
# CLASS COPROPERAD_DUAL ######################################################################################
##############################################################################################################
    
class Coproperad_Dual:
    '''
    WIP
    Class for coproperad dual of a properad for given generators and relations.
    '''
    
    def __init__(self, prop, relations, name):
        #Here we try to get a save for this ideal, if there is no save file, we create a new coproperad via initiate.
        self.prop = prop
        self.relations = relations
        self.name = name
        try:
            with open("Files/Coproperads/" + name, 'rb') as file:
                coproperad = pickle.load(file)
                if type(coproperad) == Coproperad_Dual and coproperad.relations == relations and coproperad.name == self.name:
                    self.by_weight = coproperad.by_weight
                    self.generated_weights = coproperad.generated_weights
                    self.storage = coproperad.storage
                    print('Weights generated from file : ' + str(self.generated_weights))
                else:
                    if type(coproperad) != Coproperad_Dual:
                        print('Type doesn\'t match, generating new coproperad.')
                    if coproperad.relation != relation:
                        print('Relations don\'t match, generating new coproperad.')
                    if coproperad.name != self.name:
                        print('Name doesn\'t match, generating new coproperad.')
                    self.initiate()
        except FileNotFoundError as e:
            print('Generating new coproperad (error FilNotFoundError) : ' + self.name)
            self.initiate()
        except IOError as e:
            print('Generating new coproperad (error IOError) : ' + self.name)
            self.initiate()
            
    def initiate(self):
        '''
        Intialize new coproperad.
        '''
        self.by_weight = [identity, [[graph, 1] for graph in self.prop.by_weight[1]], self.relations]
        self.generated_weights = [0, 1, 2]
        self.storage = [None, None, None]
        
    #def generate_weight(self, weight):
        '''
        Generated the given weight of self.
        '''
        #We want to generate every element by two elements of weights n and m with n + m = weight and n, m > 1, then
        #compute intersection of all the spaces generated.
        #Question is, how do we generate intersection of such space. We can do 2 by 2, generate the matrix (A, -B) and 
        #look for the kernel, but we may have polynomial matrices and computing such kernel... well i need to think about it.
        
    
    def TEST_generate_weight_3(self, weight):
        '''
        Just a test to see if what i think can work for weight 3, the first one. The goal is to use Zassenhaus algorithm.
        '''
        RE = [] 
        ER = []
        for element in self.relations:
            new_graphs_RE = [] # This list will have as components one list by graph in element, which is the list of all new graphs from this one.
            new_graphs_ER = []
            for graph in element:
                coef = graph[1]
                list_temp_RE = []
                list_temp_ER = []
                for gen in self.prop.generators:
                    list_temp_RE += gen.do_all_links_above(graph[0])
                    list_temp_ER += graph[0].do_all_links_above(gen)
                new_graphs_RE.append([[g, coef] for g in list_temp_RE])
                new_graphs_ER.append([[g, coef] for g in list_temp_ER])
            RE += [[new_graphs_RE[j][i] for j in range(len(new_graphs_RE))] for i in range(len(new_graphs_RE[0]))]
            ER += [[new_graphs_ER[j][i] for j in range(len(new_graphs_ER))] for i in range(len(new_graphs_ER[0]))]
        
        E2E = []
        EE2 = []
        E2 = []
        for gen1 in self.prop.generators:
            for gen2 in self.prop.generators:
                E2.append([[gen1 + gen2, 1]])
        for element in E2:
            new_graphs_E2E = [] # This list will have as components one list by graph in element, which is the list of all new graphs from this one.
            new_graphs_EE2 = []
            for graph in element:
                coef = graph[1]
                list_temp_E2E = []
                list_temp_EE2 = []
                for gen in self.prop.generators:
                    list_temp_E2E += gen.do_all_links_above(graph[0])
                    list_temp_EE2 += graph[0].do_all_links_above(gen)
                new_graphs_E2E.append([[g, coef] for g in list_temp_E2E])
                new_graphs_EE2.append([[g, coef] for g in list_temp_EE2])
            E2E += [[new_graphs_E2E[j][i] for j in range(len(new_graphs_E2E))] for i in range(len(new_graphs_E2E[0]))]
            EE2 += [[new_graphs_EE2[j][i] for j in range(len(new_graphs_EE2))] for i in range(len(new_graphs_EE2[0]))]
        #for element in E2E:
         #   for graph in element:
          #      if not graph[0].is_connected():
           #         graph[1] = 0
        #for element in EE2:
         #   for graph in element:
          #      if not graph[0].is_connected():
           #         graph[1] = 0
        
        list_spaces = [RE + E2E, ER + EE2]
        
        n = len(list_spaces)
        print("generated " + str(n) + " spaces")
        try:
            with open("Files/backup_coprop", 'rb') as file:
                backup = pickle.load(file)
                if list_spaces != backup[0]:
                    print("Backup doesn't match, ereasing previous backup and starting a new one.")
                    i_init = 0
                    compared_spaces = [0 for i in range(n)]
                    list_new_spaces = [[] for i in range(n)]
                else:
                    print("Backup found : " + str(backup[2]))
                    i_init = backup[1]
                    compared_spaces = backup[2]
                    list_new_spaces = backup[3]
        except FileNotFoundError as e:
            print("No backup found, comparing from start.")
            i_init = 0
            compared_spaces = [0 for i in range(n)]
            list_new_spaces = [[] for i in range(n)]
        start = time.time()
        i = i_init
        for k in range(n):
            if compared_spaces[k] == 0:
                l = len(list_spaces[k])
                for element in list_spaces[k][i_init:]:
                    new_el = []
                    for graph in element:
                        for graph_prop in self.prop.by_weight[graph[0].weight]:
                            if graph[0].compare(graph_prop):
                                new_el.append([graph_prop.copy(), graph[1]])
                                break
                    if new_el != []:
                        list_new_spaces[k].append(new_el)
                    timetemp = time.time()
                    i += 1
                    print("Space number " + str(k+1) + ", " + str(i) + "/" + str(l) + " : took " + str(int((timetemp - start)/60)) + " minutes and " + str(int(((timetemp - start)/60 - int((timetemp - start)/60))*60)) + " seconds.")
                    # We create a backup every 100 graphs
                    if i%100 == 0:
                        with open("Files/backup_coprop", 'wb') as file:
                            pickle.dump([list_spaces, i, compared_spaces, list_new_spaces], file)
                            print("created backup from i = " + str(i))
                i = 0
                i_init = 0
                compared_spaces[k] = 1
                print("Compared space number " + str(k+1) + "/" + str(n))
        if os.path.isfile('Files/backup_coprop'):
            os.remove('Files/backup_coprop')    
        
        print("Computing arity by arity.")
        list_dic_spaces = [{} for i in range(n)]
        for i in range(n):
            list_arities = []
            for element in list_new_spaces[i]:
                arity = element[0][0].arity
                if arity not in list_arities:
                    list_dic_spaces[i][arity] = [element]
                    list_arities.append(arity)
                else:
                    list_dic_spaces[i][arity].append(element)
            print("Done space " + str(i+1))
            
        print("Computing matrices.")
        list_dic_matrices = [{} for i in range(n)]
        for i in range(n):
            for arity in list_dic_spaces[i]:
                k = len(list_dic_spaces[i][arity])
                l = len(self.prop.by_arity(weight, arity))
                matrix_by_list = [[0 for a in range(l)] for b in range(k)]
                for j in range(k):
                    element = list_dic_spaces[i][arity][j]
                    for graph in element:
                        for m in range(l):
                            graph_prop = self.prop.by_arity(weight, arity)[m]
                            if graph[0].compare(graph_prop):
                                matrix_by_list[j][m] += graph[1]
                                break
                list_dic_matrices[i][arity] = Matrix(matrix_by_list)
            print("Done space " + str(i+1))
        
        print("Gathering arities.")
        list_arities = []
        for space in list_dic_matrices:
            for arity in space:
                if arity not in list_arities:
                    list_arities.append(arity)
        print(list_arities)
        
        print("Regrouping by arity")
        dic_list_matrices = {}
        for arity in list_arities:
            list_matrices = []
            for i in range(n):
                if arity in list_dic_matrices[i]:
                    list_matrices.append(list_dic_matrices[i][arity])
            dic_list_matrices[arity] = list_matrices
            print("Done arity " + str(arity))
            
        print("Computing intersections.")
        result = {}
        for arity in dic_list_matrices:
            result[arity] = intersection(dic_list_matrices[arity])
            print("Done arity " + str(arity))
                
        return result