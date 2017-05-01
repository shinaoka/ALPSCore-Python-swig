import numpy as np

import alps.hdf5
import alps.gf
import alps.gf_extension
a = alps.gf_extension.fermionic_ir_basis(100.0, 10)
print(a.dim())
print(a(0).compute_value(0.1))

Tnl = np.zeros((4,4), dtype=complex)
niw = 1000
a.compute_Tnl(0, niw-1, Tnl)

print Tnl.shape
print np.sum(np.abs(Tnl))
dim = a.dim()

#for i in xrange(niw):
    #.[for j in xrange(dim):
        #print i,j, Tnl[i,j].real, Tnl[i,j].imag
for i in xrange(niw):
  print i, Tnl[i,0].real, Tnl[i,0].imag
