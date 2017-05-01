import numpy as np

import alps.hdf5
import alps.gf
import alps.gf_extension
a = alps.gf_extension.fermionic_ir_basis(1000.0, 10)
print(a.dim())
print(a(0).compute_value(0.1))

Tnl = np.zeros((4,4), dtype=complex)
a.compute_Tnl(0, 10, Tnl)

print Tnl.shape
print Tnl
