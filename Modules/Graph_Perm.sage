##############################################################################################################
# CLASS GRAPH_PERM ###########################################################################################
##############################################################################################################
    
class Graph_Perm(Graph):
    '''
    Class of graphs with permutations on external outputs and inputs.
    '''
    
    def __init__(self, labelled_vertices, edges, perm_outputs, perm_inputs, iden = None):
        self.perm_outputs = perm_outputs
        self.perm_inputs = perm_inputs
        Graph.__init__(self, labelled_vertices, edges, iden)
        
    def get_graph(self, prop):
        '''
        Check in a prop if self is similare to an element, and returns the element as it is written in prop.
        May be broken for now because i didn't test it yet (not useful in the rest of the code yet, so it may be broken).
        '''
        for graph1 in prop.by_weight[self.weight]:
            comparison = graph1.compare_with_perm(self)
            if comparison[0]:
                list_outputs_graph1 = graph1.external_outputs
                list_inputs_graph1 = graph1.external_inputs
                graph2 = self.shuffled(comparison[1])
                list_outputs_graph2 = graph2.external_outputs
                list_inputs_graph2 = graph2.external_inputs
                n = self.arity[0]
                list_perm_outputs = []
                for i in range(n):
                    list_perm_outputs.append(list_outputs_graph1.index(list_outputs_graph2[i]))
                new_perm_outputs = Permutation(list_perm_outputs) * self.perm_outputs
                m = self.arity[1]
                list_perm_inputs = []
                for i in range(m):
                    list_perm_inputs.append(list_inputs_graph1.index(list_inputs_graph2[i]))
                new_perm_inputs = self.perm_inputs * Permutation(list_perm_inputs).inverse()
                return Graph_Perm(self.labelled_vertices, self.edges, new_perm_outputs, new_perm_inputs)
            
    def __add__(self, other):
        '''
        Return the horizontal product of self and other.
        '''
        
        graph1 = self.copy()
        for name in other.names:
            if name not in graph1.nb_by_name:
                graph1.nb_by_name[name] = 0
        graph2 = other.shifted(graph1.nb_by_name)
        
        outputs1 = graph1.external_outputs
        inputs1 = graph1.external_inputs
        outputs2 = graph2.external_outputs
        inputs2 = graph2.external_inputs
        
        vertices = graph1.labelled_vertices + graph2.labelled_vertices
        edges = graph1.edges + graph2.edges
        
        perm_out1 = graph1.perm_outputs
        perm_in1 = graph1.perm_inputs
        perm_out2 = graph2.perm_outputs
        perm_in2 = graph2.perm_inputs
        perm_out = Permutation([perm_out1(i + 1) for i in range(graph1.arity[0])] + [perm_out2(i + 1) + graph1.arity[0] for i in range(graph2.arity[0])])
        perm_in = Permutation([perm_in1(i + 1) for i in range(graph1.arity[1])] + [perm_in2(i + 1) + graph1.arity[1] for i in range(graph2.arity[1])])
        
        new_graph = Graph_Perm(vertices, edges, perm_out, perm_in)
        
        new_graph.external_outputs = outputs1 + outputs2
        new_graph.external_inputs = inputs1 + inputs2
        
        return new_graph
    
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
        # Now we ask for the list of outputs and inputs to be in the same order as before, otherwize it can cause issues.
        order_outputs = []
        for outp in self.external_outputs:
            for couple in couples:
                if outp[0] == couple[0]:
                    order_outputs.append((couple[1], outp[1]))
        order_inputs = []
        for inp in self.external_inputs:
            for couple in couples:
                if inp[0] == couple[0]:
                    order_inputs.append((couple[1], inp[1]))
        new_graph = Graph_Perm(labelled_vertices, edges, self.perm_outputs, self.perm_inputs)
        new_graph.external_outputs = order_outputs
        new_graph.external_inputs = order_inputs
        return new_graph
    
    def shuffled(self, dic_perm):
        '''
        Return a graph with same vertices and edges but with shuffled labels by perm.
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
        # Now we ask for the list of outputs and inputs to be in the same order as before, otherwize it can cause issues.
        order_outputs = []
        for outp in self.external_outputs:
            for couple in couples:
                if outp[0] == couple[0]:
                    order_outputs.append((couple[1], outp[1]))
        order_inputs = []
        for inp in self.external_inputs:
            for couple in couples:
                if inp[0] == couple[0]:
                    order_inputs.append((couple[1], inp[1]))
        new_graph = Graph_Perm(labelled_vertices, edges, self.perm_outputs, self.perm_inputs)
        new_graph.external_outputs = order_outputs
        new_graph.external_inputs = order_inputs
        return new_graph
    
    def do_all_links_above(self, other, arity = 'all'):
        '''
        Get all the links possible between self and other and returns the list of all graphs gotten by doing these links, putting self above other.
        '''
        graph1 = self.copy()
        for name in other.names:
            if name not in graph1.nb_by_name:
                graph1.nb_by_name[name] = 0
        graph2 = other.shifted(graph1.nb_by_name)
        list_new_graphs = []
        outputs = graph1.external_outputs
        nbo = len(outputs)
        inputs = graph2.external_inputs
        nbi = len(inputs)
        nb_max = min(nbo, nbi)
        #Here the differences with the graph one are because of the fact we have to consider the permutation above and belove.
        #But we only have to consider some sort of links because the other ones are reached by other graphs.
        labelled_vertices = graph1.labelled_vertices + graph2.labelled_vertices
        for i in range(1, nb_max + 1):
            new_arity = (nbo + len(graph2.external_outputs) - i, nbi + len(graph1.external_inputs) - i)
            if arity == 'all' or arity == new_arity:
                edges = graph1.edges + graph2.edges
                for j in range(i):
                    edge = Edge(outputs[graph1.perm_outputs.inverse()(j+1)-1][0], outputs[graph1.perm_outputs.inverse()(j+1)-1][1], inputs[graph2.perm_inputs(j+1)-1][0], inputs[graph2.perm_inputs(j+1)-1][1])
                    edges.append(edge)
                list_ext_out = [graph2.external_outputs[graph2.perm_outputs.inverse()(k+1)-1] for k in range(len(graph2.external_outputs))] + [outputs[graph1.perm_outputs.inverse()(k+1)-1] for k in range(i, nbo)] 
                list_ext_in = [graph1.external_inputs[graph1.perm_inputs(k+1)-1] for k in range(len(graph1.external_inputs))] + [inputs[graph2.perm_inputs(k+1)-1] for k in range(i, nbi)]
                for perm_out in perm_modulo_left(len(graph2.external_outputs), new_arity[0]):
                    for perm_in in perm_modulo_right(len(graph1.external_inputs), new_arity[1]):
                        new_graph = Graph_Perm(labelled_vertices, edges, perm_out, perm_in)
                        new_graph.external_outputs = list_ext_out 
                        new_graph.external_inputs = list_ext_in
                        list_new_graphs.append(new_graph)
        return list_new_graphs
    
    def do_all_links_connected_above(self, other, arity = 'all'):
        result = []
        for graph in self.do_all_links_above(other, arity):
            if graph.is_connected():
                result.append(graph)
        return result
                               
    def do_all_links(self, other, arity = 'all'):
        '''
        Get all the links possible between self and other and returns the list of all graphs gotten by doing these links, putting self above other.
        '''
        return self.do_all_links_above(other, arity) + other.do_all_links_above(self, arity)
    
    def do_all_links_connected(self, other, arity = 'all'):
        '''
        Get all the links possible between self and other and returns the list of all graphs gotten by doing these links, putting self above other.
        '''
        return self.do_all_links_connected_above(other, arity) + other.do_all_links_connected_above(self, arity)
    
    def same_shape(self, other):
        '''
        Return self but with the shape and order of externals of other. It changes the permutations.
        '''
        
        dic_perm = other.shape().get_perm(self.shape())
        graph = self.shuffled(dic_perm)
        ext_outputs = other.external_outputs
        ext_inputs = other.external_inputs
        n = graph.arity[0]
        list_perm_outputs = []
        for i in range(n):
            list_perm_outputs.append(other.external_outputs.index(graph.external_outputs[i]) + 1)
        new_perm_outputs = Permutation(list_perm_outputs).inverse() * self.perm_outputs
        m = graph.arity[1]
        list_perm_inputs = []
        for i in range(m):
            list_perm_inputs.append(other.external_inputs.index(graph.external_inputs[i]) + 1)
        new_perm_inputs = self.perm_inputs * Permutation(list_perm_inputs)
        graph.external_outputs = ext_outputs
        graph.external_inputs = ext_inputs
        graph.perm_outputs = new_perm_outputs
        graph.perm_inputs = new_perm_inputs
        return graph
    
    def shape(self):
        '''
        Return the graph associated to self.
        '''
        return Graph(self.labelled_vertices, self.edges)
        
    def copy(self):
        '''
        Return a copy of self.
        '''
        new_graph = Graph_Perm(self.labelled_vertices, self.edges, self.perm_outputs, self.perm_inputs, iden = self.id)
        new_graph.external_outputs = self.external_outputs
        new_graph.external_inputs = self.external_inputs
        return new_graph
    
    def __eq__(self, other):
        '''
        Compare self and other.
        '''
        if self.shape() == other.shape():
            n = self.arity[0]
            list_perm_outputs = []
            for i in range(n):
                list_perm_outputs.append(other.external_outputs.index(self.external_outputs[i]) + 1)
            new_perm_outputs = Permutation(list_perm_outputs)
            m = self.arity[1]
            list_perm_inputs = []
            for i in range(m):
                list_perm_inputs.append(other.external_inputs.index(self.external_inputs[i]) + 1)
            new_perm_inputs = Permutation(list_perm_inputs)
            if new_perm_outputs * other.perm_outputs == self.perm_outputs and self.perm_inputs * new_perm_inputs == other.perm_inputs:
                return True
            else:
                return False
        else:
            return False
    
    def __str__(self):
        '''
        Return a string describing self
        '''
        string_ext_out = "["
        for ext_out in self.external_outputs:
            string_ext_out += str(ext_out[0]) + str(ext_out[1]) + ", "
        string_ext_out = string_ext_out[0:-2] + "]"
        string_ext_in = "["
        for ext_in in self.external_inputs:
            string_ext_in += str(ext_in[0]) + str(ext_in[1]) + ", "
        string_ext_in = string_ext_in[0:-2] + "]"
        return str(self.perm_outputs) + string_ext_out + str(self.shape()) + string_ext_in + str(self.perm_inputs.inverse())