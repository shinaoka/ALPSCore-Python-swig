import alps.gf
import alps.transform

def transform_tau_to_iw:
    def __init__(self, ntau, niw, beta, stat):
        self.__transform = alps.transform.tau_to_iw_real(ntau, niw, beta, stat)

    def operator(self, gtau):
        giw = alps.gf.gf()

alps.transform.tau_to_iw_real(1000, 1000, 100.0, alps.gf.FERMIONIC)
