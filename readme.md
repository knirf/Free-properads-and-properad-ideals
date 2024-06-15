# Free properads and properadic ideals

## TABLE OF CONTENTS :

* General informations
* How to use
* Details of modules
* Examples of use

## General information

This script is meant to be used to compute dimensions and multiplicities of free properads or properadic ideals, thus of properads of the form $\mathcal{F}(E)/(R)$. It may be hard to read at first, but hopefully this file will make it easier. 
Obviously, this is a work in progress, and eventually I will add more possibilities to this script, and optimize it.
Also, if something is hard to understand in this file or the script, do not hesitate to write at my email adress : silvere.nedelec@univ-nantes.fr.
So far, this script does not handle symmetries nicely, I am currently thinking on a fix for this.

At some point, I will transpose all this script to another language (probably Julia/Oscar).

## How to use

The user needs to have Sagemath installed, see https://www.sagemath.org, there are two possibilities :

- Either they have Windows (or maybe Mac) and use binaries (which are not kept up to date), like I do, and can run the following lines in a notebook :

```
import time
import pickle
import os
import numpy as np

%runfile Modules/Part_Tab_Clifton.sage
%runfile Modules/Clift_Mat.sage
%runfile Modules/Groebner.sage
%runfile Modules/Manip_Matrices.sage
%runfile Modules/Permutations.sage
%runfile Modules/Remove_Duplicates.sage
%runfile Modules/Vertex.sage
%runfile Modules/Labelled_Vertex.sage
%runfile Modules/Edge.sage
%runfile Modules/Graph.sage
%runfile Modules/Graph_Perm.sage
%runfile Modules/Free_Properad.sage
%runfile Modules/Ideal_Properad.sage
%runfile Modules/Coproperad_Dual.sage
%runfile Modules/First_Definitions.sage
```

If they use VScode to open notebook files, they probably want change the Scrolling and Text Line Limit settings (sometimes thousands of displayed lines).

- Either they have linux (or WSL) and can probably run the same lines, but I cannot confirm this yet.

## Details of modules

`Part_Tab_Clifton.sage` : Contains all the functions about tableaux and standard tableaux, with the Clifton algorithm which computes the matrix associated to a permutation and a partition.

`Clift_Mat.sage` : Contains the functions that allows us to compute representation (or Clifton) matrices, take their partial smith form, simplify them and save same in a .csv

`Groebner.sage` : One function for Gröbner basis, one for primary decompositions, and one for both. All for determinental ideals of polynomial matrices.

`Manip_Matrices.sage` : Diverse functions that manipulate matrices : tensor products, smith forms again, a function to print a matrix row by row, and some functions around Zassehaus that where supposed to be used for coproperads (abandonned for now).

`Permutations.sage` : Contains only two functions that compute permutations modulo pre or post composition with smaller permutations.

`Remove_Duplicates.sage` : Only one function that removes duplicates in a list of graph. This function can take a lot of time, that is why we save the progress in a backup file every 100 iterations. If the function is used two times in a row for the same list, it will start at the backup instead of the beginning. You can approximatively see how much time it will take, but be careful it is not linear, it slows as it goes on.

`Vertex.sage` : A class encoding vertices, with only numbers of inputs and outputs, and a name.

`Labelled_Vertex`.sage : A more complex class with more methods, the difference with Vertex being that it has a label to differenciate with other ones with the same name in a graph (for example two products).

`Edge.sage` : A class being naive in its construction, an edge is the data of two vertices and their input/output. 

`Graph.sage` : A first class encoding graphs, at first without any permutation of inputs and outputs. One can create the list of all possible graphs from composition of two graphs, or compare two graphs. Comparing two graphs shuffles that labelling in every possibility, and use __eq__ to check rather or not they are equal (this time not up to shuffling).

`Graph_Perm.sage` : The second class enconding graphs, but this time we add permutations. The methods are the same, just a bit harder to write and understand because of the permutations.

`Free_Properad.sage` : This class encodes a free properad over generators, which can be Graphs or Graph_Perms (I never tried to mix these two objects, but I do not think it is a good idea). One can generate the properad weight by weight, or get any subspace of the properad by biarity and weight. Warning : the time that it takes to generate a weight seems at least exponential (if not more…), but you can see how it advances in the console (remember it is getting slower and slower). We also define the Identity graph, it is useless for now but serves as a bugcheck.

`Ideal_Properad.sage` : This class encodes a properadic ideal in a free properad. It requires a free properad and a list of relations to start with, then one can generate the ideal step by step (or weight by weight if the ideal is homogeneous). There is a lot of alternate possibilities, one can partially generate a step in only one biarity, with only graphs encoded with identity permutations above and below, and so on. One can also generate matrices that encode generating families of the ideal in given biarity and weight, or Clifton matrices.

`Coproperad_Dual.sage` : This was a test to encode the coproperad dual of a properad with generators and relations, but this project seemed too hard thus it was abandonned.

`First_Definitions.sage` : This contains definitions of vertices, graphs, properads, ideals, that I used for my PhD thesis. if you plan to define your own properad, you can ignore this one.

## Example of use

For examples of how to use the code, see the file `tutorial.ipynb`.