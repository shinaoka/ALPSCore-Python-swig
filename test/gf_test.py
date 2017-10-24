import sys
if sys.version_info < (2,7):
    import unittest2 as unittest
else:
    import unittest

import numpy 
import gf, gf_transform

class TestMethods(unittest.TestCase):
    def __init__(self, *args, **kwargs):
        super(TestMethods, self).__init__(*args, **kwargs)

    def test_mesh(self):
        beta = 10.0
        mp_mesh = gf.matsubara_positive_mesh(beta, 1000)
        it_mesh = gf.itime_mesh(beta, 1000)

        self.assertIsNotNone(mp_mesh)
        self.assertIsNotNone(it_mesh)

    def test_gf_transform_tau_to_iw(self):
        beta = 10.0
        niw = 1000
        ntau = 1000
        mp_mesh = gf.matsubara_positive_mesh(beta, niw)
        it_mesh = gf.itime_mesh(beta, ntau)

    def test_gf_io(self):
        mp_mesh = gf.matsubara_positive_mesh(10.0, 1000)
        idx_mesh = gf.index_mesh(6)
        g = gf.gf()
        g.load('data.h5', 'gf')
        g.save('tmp.h5', 'gf')
        g2 = gf.gf()
        g2.load('tmp.h5', 'gf')
        assert g == g2

if __name__ == '__main__':
    unittest.main()
