##############################################################################################################
# CLASS IDEAL_PROPERAD #######################################################################################
##############################################################################################################    

class Ideal_Properad:
    '''
    Class for ideals in free properads, give the parent properad, the list of lists of elements generating the ideal, 
    a list of lists of coefficient for these elements and a name to save.
    '''
    
    def __init__(self, prop, elements_init, name):
        #Here we try to get a save for this ideal, if there is no save file, we create a new ideal via initiate.
        self.prop = prop
        self.elements_init = elements_init
        self.name = name
        try:
            with open("Files/Ideals/" + name, 'rb') as file:
                ideal = pickle.load(file)
                if type(ideal) == Ideal_Properad and ideal.elements_init == elements_init and ideal.name == self.name:
                    self.elements = ideal.elements
                    self.generated_steps = ideal.generated_steps
                    print('Steps generated from file : ' + str(self.generated_steps))
                else:
                    if type(ideal) != Ideal_Properad:
                        print('Type doesn\'t match, generating new ideal.')
                    if ideal.elements_init != elements_init:
                        print('Initial elements don\'t match, generating new ideal.')
                    if ideal.name != self.name:
                        print('Name doesn\'t match, generating new ideal.')
                    self.initiate(elements_init)
        except FileNotFoundError as e:
            print('Generating new ideal (error FilNotFoundError) : ' + self.name)
            self.initiate(elements_init)
        except IOError as e:
            print('Generating new ideal (error IOError) : ' + self.name)
            self.initiate(elements_init)
        
        
    def initiate(self, elements_init):
        '''
        Initiate the ideal if no backup has been found.
        '''
        self.elements = [elements_init]
        self.generated_steps = [0]
        
    def is_homogeneous(self):
        '''
        Check if self is an homogeneous ideal. Doesn't work for now
        '''
        for element in self.elements_init:
            first = element[0][0].weight
            for el in element:
                if el[0].weight != first:
                    return False
        return True
    
    def generate_next_weight(self):
        '''
        Generate the new weight in self.
        '''
        result = [] # Final result, the list of all new elements in self.
        for element in self.elements[-1]:
            new_graphs = [] # This list will have as components one list by graph in element, which is the list of all new graphs from this one.
            for graph in element:
                coef = graph[1]
                list_temp = []
                for gen in self.prop.generators:
                    list_temp += graph[0].do_all_links(gen)
                new_graphs.append([[g, coef] for g in list_temp])
            result += [[new_graphs[j][i] for j in range(len(new_graphs))] for i in range(len(new_graphs[0]))]
        print('Generated all graphs')
        try:
            with open("Files/backup_ideal", 'rb') as file:
                backup = pickle.load(file)
                if result != backup[0]:
                    print("backup doesn't match, ereasing previous backup and starting a new one")
                    i_init = 0
                    new_list = []
                else:
                    i_init = backup[1]
                    new_list = backup[2]
                    print("backup found, building from " + str(i_init))
        except FileNotFoundError as e:
            print("no backup found, building from start")
            i_init = 0
            new_list = []
        start = time.time()
        l = len(result)
        i = i_init
        for element in result[i_init:]:
            new_el = []
            for graph in element:
                for graph_prop in self.prop.by_weight[graph[0].weight]:
                    if graph[0].compare(graph_prop):
                        new_el.append([graph_prop.copy(), graph[1]])
                        break
            new_list.append(new_el)
            timetemp = time.time()
            i += 1
            print(str(i) + "/" + str(l) + " : took " + str(int((timetemp - start)/60)) + " minutes and " + str(int(((timetemp - start)/60 - int((timetemp - start)/60))*60)) + " seconds.")
            # We create a backup every 100 graphs
            if i%100 == 0:
                with open("Files/backup_ideal", 'wb') as file:
                    pickle.dump([result, i, new_list], file)
                    print("created backup from i = " + str(i))
        print('Compared all graphs')
        if os.path.isfile('Files/backup_ideal'):
            os.remove('Files/backup_ideal')
        self.elements.append(new_list)
        self.generated_steps.append(self.generated_steps[-1]+1)
        with open("Files/Ideals/" + self.name, 'wb') as file:
            pickle.dump(self, file)
            
    def generate_next_weight_only_identities(self):
        '''
        Generate the new weight in self but keep only first graph of each element with identities above and below.
        I still need to test this one but it should be way faster than the other one, but has a bit less information.
        '''
        result = [] # Final result, the list of all new elements in self.
        for element in self.elements[-1]:
            new_graphs = [] # This list will have as components one list by graph in element, which is the list of all new graphs from this one.
            for graph in element:
                coef = graph[1]
                list_temp = []
                for gen in self.prop.generators:
                    list_temp += graph[0].do_all_links(gen)
                new_graphs.append([[g, coef] for g in list_temp])
            result += [[new_graphs[j][i] for j in range(len(new_graphs))] for i in range(len(new_graphs[0]))]
        print('Generated all graphs')
        try:
            with open("Files/backup_ideal", 'rb') as file:
                backup = pickle.load(file)
                if result != backup[0]:
                    print("backup doesn't match, ereasing previous backup and starting a new one")
                    i_init = 0
                    new_list = []
                else:
                    i_init = backup[1]
                    new_list = backup[2]
                    print("backup found, building from " + str(i_init))
        except FileNotFoundError as e:
            print("no backup found, building from start")
            i_init = 0
            new_list = []
        start = time.time()
        l = len(result)
        i = i_init
        for element in result[i_init:]:
            ref = element[0]
            for graph_prop in self.prop.by_weight[ref[0].weight]:
                if ref[0].compare(graph_prop):
                    first_graph = [graph_prop.copy(), graph[1]]
                    break
            arity = first_graph[0].arity
            if first_graph[0].perm_outputs == Permutations(arity[0])[0] and first_graph[0].perm_inputs == Permutations(arity[1])[1]:
                new_el = [first_graph]
                for graph in element[1:]:
                    for graph_prop in self.prop.by_weight[graph[0].weight]:
                        if graph[0].compare(graph_prop):
                            new_el.append([graph_prop.copy(), graph[1]])
                            break
                new_list.append(new_el)
            timetemp = time.time()
            i += 1
            print(str(i) + "/" + str(l) + " : took " + str(int((timetemp - start)/60)) + " minutes and " + str(int(((timetemp - start)/60 - int((timetemp - start)/60))*60)) + " seconds.")
            # We create a backup every 100 graphs
            if i%100 == 0:
                with open("Files/backup_ideal", 'wb') as file:
                    pickle.dump([result, i, new_list], file)
                    print("created backup from i = " + str(i))
        print('Compared all graphs')
        if os.path.isfile('Files/backup_ideal'):
            os.remove('Files/backup_ideal')
        self.only_identities = new_list
        with open("Files/Ideals/" + self.name + "_only_identities", 'wb') as file:
            pickle.dump(self, file)
        
    def get_arity(self, step, arity):
        '''
        Return the list of elements of given step and arity.
        '''
        result = []
        for element in self.elements[step]:
            if element[0][0].arity == arity:
                result.append(element)
        return result
    
    def generate_arity(self, arity):
        '''
        Return the next step but only on given arity.
        '''
        result = [] # Final result, the list of all new elements in self.
        for element in self.elements[-1]:
            new_graphs = [] # This list will have as components one list by graph in element, which is the list of all new graphs from this one.
            for graph in element:
                coef = graph[1]
                list_temp = []
                for gen in self.prop.generators:
                    list_temp += graph[0].do_all_links(gen, arity)
                new_graphs.append([[g, coef] for g in list_temp])
            result += [[new_graphs[j][i] for j in range(len(new_graphs))] for i in range(len(new_graphs[0]))]
        print('Generated all graphs')
        try:
            with open("Files/backup_ideal", 'rb') as file:
                backup = pickle.load(file)
                if result != backup[0]:
                    print("backup doesn't match, ereasing previous backup and starting a new one")
                    i_init = 0
                    new_list = []
                else:
                    i_init = backup[1]
                    new_list = backup[2]
                    print("backup found, building from " + str(i_init))
        except FileNotFoundError as e:
            print("no backup found, building from start")
            i_init = 0
            new_list = []
        start = time.time()
        l = len(result)
        i = i_init
        for element in result[i_init:]:
            new_el = []
            for graph in element:
                for graph_prop in self.prop.by_arity(graph[0].weight, arity):
                    if graph[0].compare(graph_prop):
                        new_el.append([graph_prop, graph[1]])
                        break
            new_list.append(new_el)
            timetemp = time.time()
            i += 1
            print(str(i) + "/" + str(l) + " : took " + str(int((timetemp - start)/60)) + " minutes and " + str(int(((timetemp - start)/60 - int((timetemp - start)/60))*60)) + " seconds.")
            # We create a backup every 100 graphs
            if i%100 == 0:
                with open("Files/backup_ideal", 'wb') as file:
                    pickle.dump([result, i, new_list], file)
                    print("created backup from i = " + str(i))
        if os.path.isfile('Files/backup_ideal'):
            os.remove('Files/backup_ideal')
        print('Compared all graphs')
        with open("Files/Ideals/" + self.name + "_arity" + str(arity), 'wb') as file:
            pickle.dump(new_list, file)
        return new_list
    
    def generate_arity_only_identities(self, arity):
        '''
        Return the next step but only on given arity.
        '''
        result = [] # Final result, the list of all new elements in self.
        for element in self.elements[-1]:
            new_graphs = [] # This list will have as components one list by graph in element, which is the list of all new graphs from this one.
            for graph in element:
                coef = graph[1]
                list_temp = []
                for gen in self.prop.generators:
                    list_temp += graph[0].do_all_links(gen, arity)
                new_graphs.append([[g, coef] for g in list_temp])
            result += [[new_graphs[j][i] for j in range(len(new_graphs))] for i in range(len(new_graphs[0]))]
        print('Generated all graphs')
        try:
            with open("Files/backup_ideal", 'rb') as file:
                backup = pickle.load(file)
                if result != backup[0]:
                    print("backup doesn't match, ereasing previous backup and starting a new one")
                    i_init = 0
                    new_list = []
                else:
                    i_init = backup[1]
                    new_list = backup[2]
                    print("backup found, building from " + str(i_init))
        except FileNotFoundError as e:
            print("no backup found, building from start")
            i_init = 0
            new_list = []
        start = time.time()
        l = len(result)
        i = i_init
        for element in result[i_init:]:
            ref = element[0]
            for graph_prop in self.prop.by_weight[ref[0].weight]:
                if ref[0].compare(graph_prop):
                    first_graph = [graph_prop.copy(), ref[1]]
                    break
            arity = first_graph[0].arity
            if first_graph[0].perm_outputs == Permutations(arity[0])[0] and first_graph[0].perm_inputs == Permutations(arity[1])[1]:
                new_el = [first_graph]
                for graph in element[1:]:
                    for graph_prop in self.prop.by_weight[graph[0].weight]:
                        if graph[0].compare(graph_prop):
                            new_el.append([graph_prop.copy(), graph[1]])
                            break
                new_list.append(new_el)
            timetemp = time.time()
            i += 1
            print(str(i) + "/" + str(l) + " : took " + str(int((timetemp - start)/60)) + " minutes and " + str(int(((timetemp - start)/60 - int((timetemp - start)/60))*60)) + " seconds.")
            # We create a backup every 100 graphs
            if i%100 == 0:
                with open("Files/backup_ideal", 'wb') as file:
                    pickle.dump([result, i, new_list], file)
                    print("created backup from i = " + str(i))
        if os.path.isfile('Files/backup_ideal'):
            os.remove('Files/backup_ideal')
        print('Compared all graphs')
        with open("Files/Ideals/" + self.name + "_only_identities_arity" + str(arity), 'wb') as file:
            pickle.dump(new_list, file)
        return new_list
    
    def sort_by_arity(self, step):
        '''
        Return a dic describing given step of self by arity. Keys : arities, items : list of graphs.
        '''
        dic = {}
        for element in self.elements[step]:
            first = element[0][0]
            if first.arity not in dic:
                dic[first.arity] = [element]
            else:
                dic[first.arity].append(element)
        return dic
    
    def generate_matrices(self, step):
        '''
        Generate the matrices describing all elements of self in given step, one matrix by arity. 
        Returns a dic with arities as keys and matrices as items.
        '''
        dic = self.sort_by_arity(step)
        matrices = {}
        for arity in dic:
            rows = len(dic[arity])
            columns = len(self.prop.by_arity(dic[arity][0][0][0].weight, arity))
            M = [[0 for i in range(columns)] for j in range(rows)]
            for i in range(rows):
                element = dic[arity][i]
                for graph in element:
                    M[i][self.prop.by_arity(graph[0].weight, arity).index(graph[0])] = graph[1]
            matrices[arity] = Matrix(M)
        return matrices
    
    def generate_matrix(self, step, arity):
        '''
        Generate the matrix describing all elements of self in given step and arity.
        '''
        dic = self.sort_by_arity(step)
        rows = len(dic[arity])
        columns = len(self.prop.by_arity(dic[arity][0][0][0].weight, arity))
        M = [[0 for i in range(columns)] for j in range(rows)]
        for i in range(rows):
            element = dic[arity][i]
            for graph in element:
                M[i][self.prop.by_arity(graph[0].weight, arity).index(graph[0])] = graph[1]
        return Matrix(M)
    
    def only_one_per_orbite(self, step):
        '''
        Return only the elements of the ideal with identity permutations on outputs and inputs.
        '''
        dic = {}
        by_arity = self.sort_by_arity(step)
        for arity in by_arity:
            result = []
            for element in by_arity[arity]:
                if element[0][0].perm_outputs == Permutations(arity[0])[0] and element[0][0].perm_inputs == Permutations(arity[1])[0]:
                    result.append(element)
            dic[arity] = result
        return dic
        
    def get_ids(self, step):
        '''
        Return a list of elements but instead of graphs we have ids of shapes and permutations.
        '''
        dic = {}
        by_arity = self.only_one_per_orbite(step)
        for arity in by_arity:
            result = []
            list_shapes = []
            list_shapes_ext = []
            for element in by_arity[arity]:
                el_id = []
                for graph in element:
                    shape = graph[0].shape()
                    if shape not in list_shapes:
                        list_shapes_ext.append(graph[0])
                        list_shapes.append(shape)
                    el_id.append([[list_shapes.index(shape), graph[0].perm_outputs, graph[0].perm_inputs], graph[1]])
                result.append(el_id)
        #We potentially have some dups so we get rid of them.
            keep = []
            for el in result:
                verif = True
                for el2 in keep:
                    if el == el2:
                        verif = False
                if verif:
                    keep.append(el)
            dic[arity] = [keep, list_shapes_ext]
        return dic
    
    def get_Cliftons(self, step):
        '''
        Second shot... And it worked !
        '''
        
        ids = self.get_ids(step)
        result = {}
        for arity in ids:
            dic_matrix = {}
            list_shapes = ids[arity][1]
            list_rel = ids[arity][0]
            partitions_outputs = Partitions(arity[0])
            partitions_inputs = Partitions(arity[1])
            couples_partitions = []
            for part_out in partitions_outputs:
                for part_in in partitions_inputs:
                    couples_partitions.append((part_out, part_in))
            #dic_matrices = {}
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
            result[arity] = dic_matrix
        return result
    
    def get_ids_only_identities(self):
        '''
        Return a list of elements but instead of graphs we have ids of shapes and permutations. This one is for self.only_identities.
        '''
        dic = {}
        by_arity = self.by_arity_v2()
        for arity in by_arity:
            result = []
            list_shapes = []
            list_shapes_ext = []
            for element in by_arity[arity]:
                el_id = []
                for graph in element:
                    shape = graph[0].shape()
                    if shape not in list_shapes:
                        list_shapes_ext.append(graph[0])
                        list_shapes.append(shape)
                    el_id.append([[list_shapes.index(shape), graph[0].perm_outputs, graph[0].perm_inputs], graph[1]])
                result.append(el_id)
        #We potentially have some dups so we get rid of them.
            keep = []
            for el in result:
                verif = True
                for el2 in keep:
                    if el == el2:
                        verif = False
                if verif:
                    keep.append(el)
            dic[arity] = [keep, list_shapes_ext]
        return dic
    
    def get_Cliftons_only_identities(self, step):
        '''
        Return a dic with arities as keys and dic as items. Those dic have partitions as keys and matrices as items.
        This one is for self.only_identities.
        '''
        
        ids = self.get_ids_v2(step)
        result = {}
        for arity in ids:
            dic_matrix = {}
            list_shapes = ids[arity][1]
            list_rel = ids[arity][0]
            partitions_outputs = Partitions(arity[0])
            partitions_inputs = Partitions(arity[1])
            couples_partitions = []
            for part_out in partitions_outputs:
                for part_in in partitions_inputs:
                    couples_partitions.append((part_out, part_in))
            #dic_matrices = {}
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
            result[arity] = dic_matrix
        return result