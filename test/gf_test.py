import sys
if sys.version_info < (2,7):
    import unittest2 as unittest
else:
    import unittest

import numpy 
import alps.gf
import alps.gf_transform

class TestMethods(unittest.TestCase):
    def __init__(self, *args, **kwargs):
        super(TestMethods, self).__init__(*args, **kwargs)

    def test_mesh(self):
        beta = 10.0
        mp_mesh = alps.gf.matsubara_positive_mesh(beta, 1000)
        it_mesh = alps.gf.itime_mesh(beta, 1000)

        self.assertIsNotNone(mp_mesh)
        self.assertIsNotNone(it_mesh)

    def test_gf_transform_tau_to_iw(self):
        beta = 1.0
        niw = 100
        ntau = 100000
        E = 10.0
        atol = 1e-4
        nindex = 2

        mesh_in = alps.gf.itime_mesh(beta, ntau)
        mesh_out = alps.gf.matsubara_positive_mesh(beta, niw)
        t = alps.gf_transform.gf_transform(mesh_in, mesh_out)

        mesh2 = alps.gf.index_mesh(nindex)

        g_in = alps.gf.gf([mesh_in, mesh2])
        tau = numpy.linspace(0, beta, ntau)
        for i in range(ntau):
            for j in range(nindex):
                g_in.data[i,j] = (j+1) * ( -numpy.exp(-tau[i]*E)/(1+numpy.exp(-beta*E)))

        g_out = t(g_in)

        g_out_ref = numpy.array([1.0/(1J*(2*n+1)*numpy.pi/beta - E) for n in range(niw)])

        for j in range(nindex):
            self.assertTrue(numpy.amax(numpy.abs((j+1)*g_out_ref-g_out.data[:,j])) < atol)

    def test_gf_io(self):
        mp_mesh = alps.gf.matsubara_positive_mesh(10.0, 1000)
        idx_mesh = alps.gf.index_mesh(6)
        g = alps.gf.gf()
        g.load('data.h5', 'gf')
        g.save('tmp.h5', 'gf')
        g2 = alps.gf.gf()
        g2.load('tmp.h5', 'gf')
        assert g == g2

if __name__ == '__main__':
    unittest.main()
