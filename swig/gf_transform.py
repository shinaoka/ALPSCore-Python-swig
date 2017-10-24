import alps.gf
import alps.transform

class gf_transform:
    def __init__(self, mesh_in, mesh_out):
        assert mesh_in.statistics() == mesh_out.statistics()
        assert mesh_in.extents() == mesh_out.extents()
        assert mesh_in.beta() == mesh_out.beta()

        # TODO dispatch
        self.__transform = alps.transform.tau_to_iw_real(mesh_in.extents(), mesh_out.extents(), mesh_in.beta(), mesh_in.statistics())

    def operator(self, gtau):
        in_size = self.__transform.in_size()
        out_size = self.__transform.out_size()

        extents = gtau.extents()
        assert extents[0] == self.__transform.in_size()
        extetns[0] = self.__transform.out_size()

        giw = alps.gf.gf(extents)
        giw.data += __transform(in_size, gtau.data.real, out_size)
        giw.data += 1J*__transform(in_size, gtau.data.imag, out_size)

    def __transform(self, in_size, data_in, out_size):
        n_data_set = data_in.size()/in_size
        view_in = data_in.reshape((in_size, n_data_set))
        data_out = numpy.zeros((out_size, n_data_set), dtype=complex)
        for i in range(n_data_set):
            self.__transform(view_in[:,i], data_out[:,i])
        return data_out
