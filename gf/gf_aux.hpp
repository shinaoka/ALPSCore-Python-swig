#include <complex>
#include <alps/gf/gf.hpp>
#include <alps/gf/mesh.hpp>

template<typename G>
void load_gf_cxx(G& gf, const std::string& file_name, const std::string& path) {
    alps::hdf5::archive iar(file_name, "r");
    gf.load(iar, path); 
}

template<typename G>
void save_gf_cxx(G& gf, const std::string& file_name, const std::string& path) {
    alps::hdf5::archive oar(file_name, "w");
    gf.save(oar, path); 
}

/*
template<typename T, typename M1, typename M2, typename M3>
void load_gf_cxx(alps::gf::three_index_gf<T, M1, M2, M3>& gf, const std::string& file_name, const std::string& path) {
    alps::hdf5::archive iar(file_name, "r");
    gf.load(iar, path); 
}

template<typename T, typename M1, typename M2, typename M3>
void save_gf_cxx(alps::gf::three_index_gf<T, M1, M2, M3>& gf, const std::string& file_name, const std::string& path) {
    alps::hdf5::archive oar(file_name, "w");
    gf.save(oar, path); 
}

template<typename T, typename M1, typename M2, typename M3, typename M4, typename M5, typename M6, typename M7>
void load_gf_cxx(alps::gf::three_index_gf<T, M1, M2, M3, M4, M5, M6, M7>& gf, const std::string& file_name, const std::string& path) {
    alps::hdf5::archive iar(file_name, "r");
    gf.load(iar, path); 
}

template<typename T, typename M1, typename M2, typename M3, typename M4, typename M5, typename M6, typename M7>
void save_gf_cxx(alps::gf::three_index_gf<T, M1, M2, M3, M4, M5, M6, M7>& gf, const std::string& file_name, const std::string& path) {
    alps::hdf5::archive oar(file_name, "w");
    gf.save(oar, path); 
}
*/
