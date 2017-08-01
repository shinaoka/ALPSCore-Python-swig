
inline Eigen::Tensor<double,6>
crossing_symmetry(
    const alps::gf_extension::fermionic_ir_basis &basis_f,
    const alps::gf_extension::bosonic_ir_basis &basis_b,
    double ratio = 1.02,
    int max_n_exact_sum = 1000
    ) {
    Eigen::Tensor<double,6> C_tensor;
    alps::gf_extension::compute_C_tensor(basis_f, basis_b, C_tensor, ratio, max_n_exact_sum);
    return C_tensor;
}
