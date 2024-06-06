##############################################################################################################
# CLASS GRAPH ################################################################################################
##############################################################################################################
        
class Graph:
    '''
    Class for graphs, with main attributes being a list of labelled vertices and a list of edges between these vertices.
    '''
    
    def __init__(self, labelled_vertices, edges, iden = None):
        self.labelled_vertices = labelled_vertices
        self.edges = edges
        self.weight = len(self.labelled_vertices)
        self.names = []
        for vert in self.labelled_vertices:
            if vert.name not in self.names:
                self.names.append(vert.name)
        self.generate_arity()
        self.id = iden
        
    def generate_arity(self):
        '''
        Get all external inputs and outputs of self, and then get the arity of the graph.
        '''
        self.external_inputs = []
        for vert in self.labelled_vertices:
            for i in range(1, vert.nb_inputs + 1): 
                if vert.is_external_input(i, self):
                    self.external_inputs.append((vert, i))
        self.external_outputs = []
        for vert in self.labelled_vertices:
            for i in range(1, vert.nb_outputs + 1):
                if vert.is_external_output(i, self):
                    self.external_outputs.append((vert, i))
        self.arity = (len(self.external_outputs), len(self.external_inputs))
        self.by_name = {}
        self.names = []
        self.nb_by_name = {}
        for vert in self.labelled_vertices:
            if vert.name not in self.names:
                self.names.append(vert.name)
                self.by_name[vert.name] = [vert]
                self.nb_by_name[vert.name] = 1
            else:
                self.by_name[vert.name].append(vert)
                self.nb_by_name[vert.name] += 1
                
    def is_connected(self):
        '''
        Return a boolean describing rather or not self is connected.
        '''
        
        vertices = self.labelled_vertices
        edges = self.edges
        checked_vertices = []
        new_checked_vertices = [vertices[0]]
        while new_checked_vertices != checked_vertices and len(new_checked_vertices) != len(vertices):
            checked_vertices = new_checked_vertices
            for vertex in checked_vertices:
                for edge in edges:
                    if edge.start == vertex and edge.goal not in new_checked_vertices:
                        new_checked_vertices.append(edge.goal)
                    elif edge.goal == vertex and edge.start not in new_checked_vertices:
                        new_checked_vertices.append(edge.start)
        return len(new_checked_vertices) == len(vertices)
        
    def shifted(self, dic_indices):
        '''
        Return a graph with same vertices and edges but with shifted labels by dic_indices (every item of the dic tells by how many we have to shift the corresponding type).
        '''
        labelled_vertices = []
        edges = []
        couples = []
        for name in self.names:
            for vert in self.by_name[name]:
                new_vert = Labelled_Vertex(vert.vertex, vert.label + dic_indices[name])
                labelled_vertices.append(new_vert)
                couples.append((vert, new_vert))
        for edge in self.edges:
            new_edge = Edge(None, edge.num_output, None, edge.num_input)
            for couple in couples:
                if edge.start == couple[0]:
                    new_edge.start = couple[1]
                if edge.goal == couple[0]:
                    new_edge.goal = couple[1]
            edges.append(new_edge)
        return Graph(labelled_vertices, edges)
        
    def links_above(self, other, arity = 'all'):
        '''
        Return a list of all possible links between self and other, putting self above other.
        A link is a list of 2-lists of the form [output, input]. 
        Yes, this returns a list of lists of lists.
        '''
        list_links = []
        outputs = self.external_outputs
        nbo = len(outputs)
        set_nbo = Set(range(nbo))
        inputs = other.external_inputs
        nbi = len(inputs)
        set_nbi = Set(range(nbi))
        nb_max = min(nbo, nbi)
        for i in range(1, nb_max + 1):
            if arity == 'all' or arity == (nbo + len(graph2.external_outputs) - i, nbi + len(graph1.external_inputs) - i):
                # Here the strategy is to link the two graphs by i edges, then i should be between 1 (if we want connectedness) and nb_max.
                for list_index_outputs in list(set_nbo.subsets(i)):
                    for list_index_inputs in list(set_nbi.subsets(i)):
                        list_perm = []
                        # list_perm will get every way of linking these i outputs with these i inputs.
                        for f in FiniteSetMaps(list_index_outputs, list_index_inputs):
                            if f.image_set() == list_index_inputs:
                                list_perm.append(f)
                        for perm in list_perm:
                            link = []
                            # link will be a list of every new edge we should create.
                            for j in list_index_outputs:
                                link.append([outputs[j], inputs[perm(j)]])
                            list_links.append(link)
        return list_links
    
    def links_below(self, other, arity = 'all'):
        '''
        Return a list of all possible links between self and other, putting self below other.
        This one is just using links_above.
        '''
        return other.links_above(self, arity)
    
    def links(self, other, arity = 'all'):
        '''
        Return a list of all possible links between self and other, using links_above and links_below.
        '''
        return self.links_above(other, arity) + self.links_below(other, arity)
    
    def do_all_links(self, other, arity = 'all'):
        '''
        Get all the links possible between self and other and returns the list of all graphs gotten by doing these links.
        '''
        graph1 = self.copy()
        for name in other.names:
            if name not in graph1.nb_by_name:
                graph1.nb_by_name[name] = 0
        graph2 = other.shifted(graph1.nb_by_name)
        links = graph1.links(graph2, arity)
        list_new_graphs = []
        labelled_vertices = graph1.labelled_vertices + graph2.labelled_vertices
        for link_list in links:
            edges = graph1.edges + graph2.edges
            for link in link_list:
                edge = Edge(link[0][0], link[0][1], link[1][0], link[1][1])
                edges.append(edge)
            list_new_graphs.append(Graph(labelled_vertices, edges))
        return list_new_graphs
    
    def shuffled(self, dic_perm):
        '''
        Return a graph with same vertices and edges but with shuffled labels by dic_indices (every item of the dic tells by how many we have to shuffle the corresponding type).
        '''
        labelled_vertices = []
        edges = []
        couples = []
        for name in self.names:
            for vert in self.by_name[name]:
                new_vert = Labelled_Vertex(vert.vertex, dic_perm[name][vert.label])
                labelled_vertices.append(new_vert)
                couples.append((vert, new_vert))
        for edge in self.edges:
            new_edge = Edge(None, edge.num_output, None, edge.num_input)
            for couple in couples:
                if edge.start == couple[0]:
                    new_edge.start = couple[1]
                if edge.goal == couple[0]:
                    new_edge.goal = couple[1]
            edges.append(new_edge)
        return Graph(labelled_vertices, edges)
    
    def __eq__(self, other):
        '''
        Compare sorted lists of vertices and edges (so they are kind of seen as sets)
        '''
        return sorted(self.labelled_vertices) == sorted(other.labelled_vertices) and sorted(self.edges) == sorted(other.edges)
    
    def compare(self, other):
        '''
        Shuffle in every possible way other and check if it is equal to self. This is used to compare two graph in the sense we want.
        '''
        w1 = self.weight
        w2 = other.weight
        e1 = len(self.edges)
        e2 = len(other.edges)
        if w1 != w2:
            print("The weights are not the same !")
            return False
        elif e1 != e2 or self.arity != other.arity or self.nb_by_name != other.nb_by_name:
            return False
        else:
            verif = False
            list_dic_perm = [{name : Permutation('()') for name in other.names}]
            for name in other.names:
                new_list_dic_perm = []
                for perm in Permutations(range(other.nb_by_name[name])):
                    for dic in list_dic_perm:
                        new_dic = dic.copy()
                        new_dic[name] = perm
                        new_list_dic_perm.append(new_dic)
                list_dic_perm = new_list_dic_perm
            for dic_perm in list_dic_perm:
                if self == other.shuffled(dic_perm):
                    verif = True
                    self.id = other.id
                    break
            return verif
        
    def get_perm(self, other):
        '''
        Same as compare but returns the permutation instead of a boolean.
        '''
        w1 = self.weight
        w2 = other.weight
        e1 = len(self.edges)
        e2 = len(other.edges)
        if w1 != w2:
            print("The weights are not the same !")
            return False
        elif e1 != e2 or self.arity != other.arity or self.nb_by_name != other.nb_by_name:
            return False
        else:
            verif = False
            list_dic_perm = [{name : Permutation('()') for name in other.names}]
            for name in other.names:
                new_list_dic_perm = []
                for perm in Permutations(range(other.nb_by_name[name])):
                    for dic in list_dic_perm:
                        new_dic = dic.copy()
                        new_dic[name] = perm
                        new_list_dic_perm.append(new_dic)
                list_dic_perm = new_list_dic_perm
            for dic_perm in list_dic_perm:
                if self == other.shuffled(dic_perm):
                    self.id = other.id
                    return dic_perm
            print('There was an issue.')
        
    def compare_with_perm(self, other):
        '''
        Same as compare but returns a tuple with the boolean and the permutation making it True, if it is True, or None if is it False.
        '''
        w1 = self.weight
        w2 = other.weight
        e1 = len(self.edges)
        e2 = len(other.edges)
        if w1 != w2:
            print("The weights are not the same !")
            return (False, None)
        elif e1 != e2 or self.arity != other.arity or self.nb_by_name != other.nb_by_name:
            return (False, None)
        else:
            verif = False
            list_dic_perm = [{name : Permutation('()') for name in other.names}]
            for name in other.names:
                new_list_dic_perm = []
                for perm in Permutations(range(other.nb_by_names)):
                    for dic in list_dic_perm:
                        new_dic = dic.copy()
                        new_dic[name] = new_dic[name] * perm
                        new_list_dic_perm.append(new_dic)
                        list_dic_perm = new_list_dic_perm
            for dic_perm in list_dic_perm:
                if self == other.shuffled(dic_perm):
                    self.id = other.id
                    return (True, dic_perm)
            return (False, None)
    
    def create_Graph_Perm(self, perm_outputs = None, perm_inputs = None):
        '''
        Return a Graph_Perm with given permutations, or identity if none are given.
        '''
        if perm_outputs == None:
            perm_outputs = Permutations(self.arity[0])[0]
        if perm_inputs == None:
            perm_inputs = Permutations(self.arity[1])[0]
        return Graph_Perm(self.labelled_vertices, self.edges, perm_outputs, perm_inputs)
    
    def all_Graph_Perm(self):
        '''
        Return a list of Graph_Perm, with cores being self and every possible permutations above and below.
        '''
        result = []
        for p in Permutations(len(self.external_outputs)):
            for q in Permutations(len(self.external_inputs)):
                result.append(self.create_Graph_Perm(p, q))
        return result
    
    def copy(self):
        '''
        Return a copy of self.
        '''
        return Graph(self.labelled_vertices, self.edges, iden = self.id)
    
    def __str__(self):
        '''
        Return a string describing self.
        '''
        l = self.weight
        if l > 0:
            string_vertices = "{"
            for vert in self.labelled_vertices:
                string_vertices += str(vert) + ", "
            string_vertices = string_vertices[0:-2] + "}"
        else:
            string_vertices = "{}"
        l = len(self.edges)
        if l > 0:
            string_edges = "{"
            for edge in self.edges:
                string_edges += str(edge) + ", "
            string_edges = string_edges[0:-2] + "}"
        else:
            string_edges = "{}"
        return "vertices : " + string_vertices + ", edges : " + string_edges + ", arity : " + str(self.arity)