import copy
import numpy
import alps.gf
import alps.transform

class gf_transform:
    def __init__(self, mesh_in, mesh_out):
        assert mesh_in.statistics() == mesh_out.statistics()
        assert mesh_in.beta() == mesh_out.beta()

        # TODO dispatch
        self.__transform = alps.transform.tau_to_iw_real(mesh_in.extent(), mesh_out.extent(), mesh_in.beta(), mesh_in.statistics())

        self.__mesh_out = copy.copy(mesh_out)

    def __call__(self, gtau):
        in_size = self.__transform.in_size
        out_size = self.__transform.out_size

        giw = alps.gf.gf([self.__mesh_out] + [gtau.mesh(i) for i in range(1,gtau.dim())])
        giw.data[...] += self.__transform_real_data(in_size, gtau.data.real, out_size).reshape(giw.data.shape)
        giw.data[...] += 1J*self.__transform_real_data(in_size, gtau.data.imag, out_size).reshape(giw.data.shape)

        return giw

    def __transform_real_data(self, in_size, data_in, out_size):
        n_data_set = int(data_in.size/in_size)
        view_in = data_in.reshape((in_size, n_data_set))
        buffer_in = numpy.zeros((in_size,), dtype=float)
        buffer_out = numpy.zeros((out_size,), dtype=complex)
        data_out = numpy.zeros((out_size, n_data_set), dtype=complex)
        for i in range(n_data_set):
            buffer_in[:] = view_in[:,i]
            buffer_out[:] = 0.0 # __transform() does not erase existing values in buffer_out.
            self.__transform(buffer_in, buffer_out)
            data_out[:,i] = buffer_out
        return data_out
