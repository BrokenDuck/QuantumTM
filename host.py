import qsharp

from GraphColoring import graphColoringMain

vertices = 5
edges = [(0, 1), (0, 2), (1, 4), (2, 4)]

coloring = graphColoringMain.simulate(V = vertices, edges = edges)

print(coloring)
