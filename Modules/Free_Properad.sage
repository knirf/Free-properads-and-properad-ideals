##############################################################################################################
# CLASS FREE_PROPERAD ########################################################################################
##############################################################################################################        

identity = Graph([Labelled_Vertex(Vertex(1, 1, "identity"), 0)], [])

class Free_Properad:
    '''
    Class for free properads, with or without permutations. Just give the generators and a name to save it.
    '''
    
    def __init__(self, generators, name):
        self.generators = generators
        self.name = name
        #Here we try to get a save for this properad, if there is no save file, we create a new properad.
        try:
            with open("Files/Properads/" + name, 'rb') as file:
                prop = pickle.load(file)
                if type(prop) == Free_Properad and self.generators == prop.generators:
                    self.generated_weights = prop.generated_weights
                    self.by_weight = prop.by_weight
                    self.by_weight_str = prop.by_weight_str
                    self.storage = prop.storage
                    print('Weights generated from file : ' + str(self.generated_weights))
                else:
                    print('Properad doesn\'t match, nothing has been done')
        except FileNotFoundError as e:
            print('Generating new properad (error FilNotFoundError) : ' + self.name)
            self.initiate()
        except IOError as e:
            print('Generating new properad (error IOError) : ' + self.name)
            self.initiate()
    def initiate(self):
        self.generated_weights = [0, 1]
        self.by_weight = [identity]
        self.by_weight_str = [str(identity)]
        weight1 = []
        for gen in self.generators:
            if type(gen) == Graph or type(gen) == Graph_Perm:
                weight1.append(gen)
            elif type(gen) == Vertex:
                weight1.append(gen.graph())
        self.by_weight.append(weight1)
        self.by_weight_str.append([str(gen) for gen in weight1])
        self.storage = [None, None]
    
    def generate_weight(self, weight):
        '''
        Method to generate the properad to the weight 'weight'.
        Previous weights have to be generated
        '''
        if weight - self.generated_weights[-1] < 1:
            print("This weight is already generated.")
        if weight - self.generated_weights[-1] > 1:
            print("You need to generate previous weights first.")
        if weight - self.generated_weights[-1] == 1:
            newlist = []
            for graph in self.by_weight[-1]:
                for gen in self.by_weight[1]:
                    newlist += graph.do_all_links(gen)
            self.storage.append(newlist)
            newlist = remove_duplicates(newlist)
            self.by_weight.append(newlist)
            print("All graphs compared, standardizing ?")
            if type(newlist[0]) == Graph_Perm:
                print("Yes.")
                self.standardize(weight)
                print("Standardized.")
            else:
                print("No need.")
            print("Standardized.")
            self.by_weight_str.append([str(element) for element in newlist])
            self.generated_weights.append(weight)
            with open("Files/Properads/" + self.name, 'wb') as file:
                pickle.dump(self, file)

    def generate_arity(self, weight, arity, string = True):
        '''
        Returns the weight 'weight' and arity of the properad.
        Previous weights have to be generated.
        '''
        if weight - self.generated_weights[-1] < 1:
            print("This weight is already generated.")
        if weight - self.generated_weights[-1] > 1:
            print("You need to generate previous weights first.")
        if weight - self.generated_weights[-1] == 1:
            newlist = []
            for graph in self.by_weight[-1]:
                for gen in self.by_weight[1]:
                    newlist += graph.do_all_links(gen, arity)
            newlist = remove_duplicates(newlist)
        if string:
            return [str(element) for element in newlist]
        else:
            return newlist
        
    def standardized(self, weight):
        '''
        Return the standardize version of self in the sense that it makes every graph with a same shape actually have the same shape and order of externals.
        '''
        ref = {}
        result = {}
        list_shapes = []
        i = 0
        n = len(self.by_weight[weight])
        start = time.time()
        for graph in self.by_weight[weight]:
            verif = True
            for shape in list_shapes:
                if graph.shape().compare(shape):
                    verif = False
                    keep = shape
                    break
            if verif:
                list_shapes.append(graph.shape())
                ref[str(graph.shape())] = graph
                result[str(graph.shape())] = [graph]
            else:
                result[str(keep)].append(graph.same_shape(ref[str(keep)]))
            step = time.time()
            i+=1
            print(str(i) + "/" + str(n) + " : took " + str(int((step - start)/60)) + " minutes and " + str(int(((step - start)/60 - int((step - start)/60))*60)) + " seconds.")
        return result
        
    def standardize(self, weight):
        '''
        Standardize self in the sense that it makes every graph with a same shape actually have the same shape and order of externals.
        '''
        
        list_graphs = []
        dic = self.standardized(weight)
        for shape in dic:
            list_graphs += dic[shape]
            
        self.by_weight[weight] = list_graphs
        
    def by_arity(self, weight, arity):
        '''
        Return the list of all graphs with these weight and arity.
        '''
        list_graphs = []
        for graph in self.by_weight[weight]:
            if graph.arity == arity:
                list_graphs.append(graph)
        return list_graphs
    
    def by_arity_str(self, weight, arity):
        '''
        Return the list of all graphs with these weight and arity, but there string description.
        '''
        return [str(graph) for graph in self.by_arity(weight, arity)]
    
    def sort_by_arity(self, weight):
        '''
        Return a dic with arities as keys and list of graphs of said arity as items.
        '''
        
        dic_arities = {}
        list_graphs = self.by_weight[weight]
        for graph in list_graphs:
            if graph.arity not in dic_arities:
                dic_arities[graph.arity] = [graph]
            else:
                dic_arities[graph.arity].append(graph)
        return dic_arities
    
    def by_shape(self, weight):
        '''
        Return a dic with Graph's as keys and a lists of Graph_Perm's as items. Every element of the list has the attribute
        graph being equal to the key.
        '''
        result = {}
        list_shapes = []
        for graph in self.by_weight[weight]:
            verif = True
            for shape in list_shapes:
                if shape == graph.shape():
                    verif = False
                    keep = shape
            if verif:
                list_shapes.append(graph.shape())
                result[str(graph.shape())] = [graph]
            else:
                result[str(keep)].append(graph)
        return result
    
    def by_shape_str(self, weight):
        '''
        Return a dic with Graph's as keys and a lists of str(Graph_Perm)'s as items.
        '''
        result = {}
        list_shapes = []
        for graph in self.by_weight[weight]:
            verif = True
            for shape in list_shapes:
                if shape == graph.shape():
                    verif = False
                    keep = shape
            if verif:
                list_shapes.append(graph.shape())
                result[str(graph.shape())] = [graph]
            else:
                result[str(keep)].append(graph)
        return result
        
    def __str__(self):
        '''
        Return a string describing self.
        '''
        message = str(self.generators[0])
        l = len(self.generators)
        if l > 0:
            for i in range(1, l-1):
                message += ", " + str(self.generators[i])
            message += " and " + str(self.generators[l-1])
        return("Free properad over " + message)