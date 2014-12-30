#ifndef VEC_DIM
#error "must define the dimension of vectors."
#endif

#include <avr/pgmspace.h>

/*
 * Evaluates whether the given measurements in `sensors` belongs to the given class.
 * Computes:
 *
 *     \sum_{i=0}^{n_sv} (coeffs_{i} K(x_i, x)) - \rho
 *
 * \param n_sv     the number of support vectors for this class
 * \param coeffs   an array of `n_sv` coefficients in program memory.
 * \param sv_class an program memory `n_sv` x `VEC_DIM`-array of the support vectors' coordinates in column-major order, i.e. the coordinates of a SV are consecutive values in the array.
 * \param rho      a scalar offset
 * \param sensors  an VEC_DIM array in main memory of the sensor measurements to be evaluated.
 *
 * \pre the CPP-constant VEC_DIM defines the dimension of support vectors and sensors.
 */

inline float svm_evaluate(int n_sv, float* coeffs, float* sv_class, float* sensors){
  float result= 0;
  float* sv_current = sv_class;
  for (int i=0; i<n_sv; i++, sv_current += VEC_DIM){
    float coeff = pgm_read_float(coeffs + i);


    result += coeff * rbf_kernel(sv_current, sensors);

  }

  return result;

}
