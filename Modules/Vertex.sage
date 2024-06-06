##############################################################################################################
# CLASS VERTEX ###############################################################################################
##############################################################################################################

class Vertex:
    '''
    Class for vertices, with only three attributes : number of outputs, number of inputs and a name. Two vertices with the same name should have same other attributes
    '''
    
    def __init__(self, nb_outputs, nb_inputs, name = None):
        self.nb_outputs = nb_outputs
        self.nb_inputs = nb_inputs
        self.name = name
                    
    def graph(self):
        ''' 
        Return a graph formed by only the vertex self and no edge.
        '''
        return Graph([Labelled_Vertex(self, 0)], [])
    
    def copy(self):
        '''
        Return a copy of self.
        '''
        return Vertex(self.nb_outputs, self.nb_inputs, self.name)
                        
    def __str__(self):
        '''
        If self has no name, returns a string with the number of outputs and inputs, otherwise returns the name.
        '''
        if self.name == None:
            return "arity : (" + str(self.nb_outputs) + "," + str(self.nb_inputs) + ")"
        else:
            return str(self.name)  
        
    def __eq__(self, other):
        '''
        Compare every attributes.
        '''
        return self.nb_outputs == other.nb_outputs and self.nb_inputs == other.nb_inputs and self.name == self.name