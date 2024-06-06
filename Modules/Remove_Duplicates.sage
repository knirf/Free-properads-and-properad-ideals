##############################################################################################################
# FUNCTION TO REMOVE DUPLICATE IN A LIST OF GRAPHS ###########################################################
##############################################################################################################

def remove_duplicates(list_graph):
    '''
    Remove all graphs in list_graph that are the same as another (using the method compare).
    A backup is edited every 100 graphs to get back where it was when quitting in the middle of the process.
    '''
    # First we check if there is any backup for the same list_graph
    try:
        with open("Files/backup_prop", 'rb') as file:
            backup = pickle.load(file)
            if list_graph != backup[0]:
                print("backup doesn't match, ereasing previous backup and starting a new one")
                i_init = 1
                result = []
                iden = 0
            else:
                i_init = backup[1]
                result = backup[2]
                iden = backup[3]
                print("backup found, building from " + str(i_init))
    except FileNotFoundError as e:
        print("no backup found, building from start")
        i_init = 1
        result = []
        iden = 0
            
    start = time.time()
    l = len(list_graph)
    i = i_init
    for graph1 in list_graph[i_init-1:]:
        inlist = False
        for graph2 in result:
            if graph1.compare(graph2):
                inlist = True
                break
        if not inlist:
            graph1.id = iden
            iden +=1
            result.append(graph1)
            addition = " (Added id " + str(graph1.id) + " to the list)"
        else:
            addition = ""
        timetemp = time.time()
        print(str(i) + "/" + str(l) + " : took " + str(int((timetemp - start)/60)) + " minutes and " + str(int(((timetemp - start)/60 - int((timetemp - start)/60))*60)) + " seconds" + addition + ".")
        i += 1
        # We create a backup every 100 graphs
        if i%100 == 0:
            with open("Files/backup_prop", 'wb') as file:
                pickle.dump([list_graph, i, result, iden], file)
                print("created backup from i = " + str(i))
    if os.path.isfile('Files/backup_prop'):
        os.remove('Files/backup_prop')
    return result