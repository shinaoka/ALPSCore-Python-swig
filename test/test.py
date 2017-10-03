import numpy as np

import alps.gf
#import alps.gf_extension


#Create an gf object (with positive-only Matsubara mesh, index mesh, index mesh)
#Assignment of a value to gf is not supported yet
mp_mesh = alps.gf.matsubara_positive_mesh(10.0, 1000)
idx_mesh = alps.gf.index_mesh(6)
#g = alps.gf.ALPSGF3ComplexMatsubaraPIndexIndex(mp_mesh, idx_mesh, idx_mesh)

g = alps.gf.gf()

g.load('data.h5', 'gf')
g.save('tmp.h5', 'gf')

g2 = alps.gf.gf()
g2.load('tmp.h5', 'gf')

#print g.mesh(0)
#print g2.mesh(0)
assert g == g2
#print(help(alps.gf.gf))
#print(help(alps.gf))

#Load a gf from data.h5
#g1 = alps.gf.load_gf('data.h5', 'gf')
#print g1.to_array()
#print g1.mesh1()
#print g1.mesh2()

#alps.gf.save_gf(g1, 'tmp.h5', 'gf')

