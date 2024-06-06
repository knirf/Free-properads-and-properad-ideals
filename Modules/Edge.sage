##############################################################################################################
# CLASS EDGE #################################################################################################
##############################################################################################################

class Edge:
    '''
    Class for edges, with four attributes : starting vertex, output, goal vertex, input.
    '''
    
    def __init__(self, start, num_output, goal, num_input):
        self.start = start
        self.num_output = num_output
        self.goal = goal
        self.num_input = num_input
        
    def __eq__(self, other):
        '''
        Compare every attributes.
        '''
        return self.start == other.start and self.num_output == other.num_output and self.goal == other.goal and self.num_input == other.num_input
        
    def copy(self):
        '''
        Return a copy of self.
        '''
        return Edge(self.start, self.num_output, self.goal, self.num_input)
        
    def __str__(self):
        '''
        Return a string describing the edge.
        '''
        return str(self.start.vertex) + str(self.start.label) + " " + str(self.num_output) + " --> " + str(self.num_input) + " " + str(self.goal.vertex) + str(self.goal.label)
     
    def __lt__(self, other):
        '''
        Compare the attributes, used to sort lists of edges.
        '''
        if self.start == other.start:
            if self.num_output == other.num_output:
                if self.goal == other.goal:
                    if self.num_input == self.num_input:
                        return False
                    elif self.num_input < self.num_input:
                        return True
                    else:
                        return False
                elif self.goal < other.goal:
                    return True
                else:
                    return False
            elif self.num_output < other.num_output:
                return True
            else:
                return False
        elif self.start < other.start:
            return True
        else:
            return False