import copy
import alps.gf
import alps.transform

class gf_transform:
    def __init__(self, mesh_in, mesh_out):
        assert mesh_in.statistics() == mesh_out.statistics()
        assert mesh_in.extent() == mesh_out.extent()
        assert mesh_in.beta() == mesh_out.beta()

        # TODO dispatch
        self.__transform = alps.transform.tau_to_iw_real(mesh_in.extent(), mesh_out.extent(), mesh_in.beta(), mesh_in.statistics())

        self._mesh_out = copy.copy(mesh_out)

    def __call__(self, gtau):
        in_size = self.__transform.in_size
        out_size = self.__transform.out_size

        #extent = gtau.extent()
        #assert extent[0] == in_size
        #extetns[0] = out_size

        giw = alps.gf.gf([self.__mesh_out] + [gtau.mesh(i) for i in range(1,gtau.num_meshes())])
        giw.data += __transform(in_size, gtau.data.real, out_size)
        giw.data += 1J*__transform(in_size, gtau.data.imag, out_size)

        return giw

    def __transform(self, in_size, data_in, out_size):
        n_data_set = data_in.size()/in_size
        view_in = data_in.reshape((in_size, n_data_set))
        data_out = numpy.zeros((out_size, n_data_set), dtype=complex)
        for i in range(n_data_set):
            self.__transform(view_in[:,i], data_out[:,i])
        return data_out
