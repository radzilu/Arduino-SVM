#ifndef VEC_DIM
#error
#endif

#include <avr/pgmspace.h>


inline float svm_evaluate(int n_sv, float* coeffs, float* sv_class, float* sensors){
  float result= 0;
  float* sv_current = sv_class;
  for (int i=0; i<n_sv; i++, sv_current += VEC_DIM){
    float coeff = pgm_read_float(coeffs + i);


    result += coeff * rbf_kernel(sv_current, sensors);

  }

  return result;

}
