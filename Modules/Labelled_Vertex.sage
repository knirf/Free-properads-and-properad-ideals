##############################################################################################################
# CLASS LABELLED_VERTEX ######################################################################################
##############################################################################################################

class Labelled_Vertex:
    '''
    Just add a label to the class Vertex, to differenciate two vertices in a graph.
    '''
    
    def __init__(self, vertex, label):
        self.vertex = vertex
        self.label = label
        
        #We get the attributes of the vertex as attributes of self.
        self.nb_outputs = self.vertex.nb_outputs
        self.nb_inputs = self.vertex.nb_inputs
        self.name = self.vertex.name
        
    def graph(self):
        ''' 
        Return a graph formed by only the vertex self and no edge.
        '''
        return Graph([self], [])
        
    def is_external_input(self, i, graph):
        '''
        Check if the ith input of self is an external input of graph.
        '''
        if self not in graph.labelled_vertices:
            print(str(self) + " is not in the graph " + str(graph))
        elif i > self.nb_inputs:
            print(str(self) + " doesn't have enough inputs")
        else:
            verif = True # Verif is by default True, but if an edge of graph goes to this input, it turns to false.
            for edge in graph.edges:
                if edge.goal == self and edge.num_input == i:
                    verif = False
        return verif
    
    def is_external_output(self, i, graph):
        '''
        Check if the ith output of self is an external output of graph.
        '''
        if self not in graph.labelled_vertices:
            print(str(self) + " is not in the graph " + str(graph))
        elif i > self.nb_outputs:
            print(str(self) + " doesn't have enough outputs")
        else:
            verif = True # Verif is by default True, but if an edge of graph comes from this output, it turns to false.
            for edge in graph.edges:
                if edge.start == self and edge.num_output == i:
                    verif = False
        return verif
    
    def shifted(self, i):
        '''
        return the same labelled vertex but shifts the label.
        '''
        return Labelled_Vertex(self.vertex, self.label + i)
    
    def __eq__(self, other):
        '''
        Compare every attributes.
        '''
        return self.vertex == other.vertex and self.label == other.label
    
    def copy(self):
        '''
        Return a copy of self.
        '''
        return Labelled_Vertex(self.vertex, self.label)
                        
    def __str__(self):
        '''
        If self has no name, returns a string with the number of outputs and inputs, otherwise returns the name.
        '''
        if self.name == None:
            return "arity : [" + str(self.nb_outputs) + "," + str(self.nb_inputs) + "]"
        else:
            return str(self.name) + str(self.label)
        
    def __lt__(self, other):
        '''
        Compare the labels and names, used to sort lists of labelled vertices.
        '''
        if self.name == other.name:
            return self.label < other.label
        else:
            return self.name < other.name