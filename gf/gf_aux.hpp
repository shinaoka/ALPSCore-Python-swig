#include <complex>
#include <alps/gf/gf.hpp>
#include <alps/gf/mesh.hpp>

template<typename T, typename M1, typename M2, typename M3>
void load_gf_cxx(alps::gf::three_index_gf<T, M1, M2, M3>& gf, const std::string& file_name, const std::string& path) {
    alps::hdf5::archive iar(file_name, 'r');
    gf.load(iar, path); 
}

template<typename T, typename M1, typename M2, typename M3>
void save_gf_cxx(alps::gf::three_index_gf<T, M1, M2, M3>& gf, const std::string& file_name, const std::string& path) {
    alps::hdf5::archive oar(file_name, 'w');
    gf.save(oar, path); 
}
