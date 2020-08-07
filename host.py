import qsharp

from GraphColoring import graphColoringMain

vertices = 7
edges = [(0, 1), (0, 2), (0, 3), (0, 4), (1, 2), (1, 3), (1, 4), (3, 5), (2, 6), (5, 6), (4, 6)]

check_array = []
for (a, b) in edges :
    if not a in check_array:
        check_array.append(a)
    if not b in check_array:
        check_array.append(b)
    if a == b:
        raise Exception("Edges is connected to the same vertex")

if len(check_array) != vertices:
    raise Exception("Number of vertices given does not correspond to the number of vertices in edges") 

coloring = graphColoringMain.simulate(V = vertices, edges = edges)

print(coloring)
