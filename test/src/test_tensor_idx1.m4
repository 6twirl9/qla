/* QLA test code */
/* for indexed tensor routines.  Part 2 */
/* C Code automatically generated from test_tensor_idx.2.m4 */

include(protocol_idx.m4)

`
#include <qla.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
#include "compare.h"

  /* Define test data */
'
#if ( QLA_Precision != 'Q' )  /* Q precision is limited to assignments */
static  int nc = QLA_Nc;
static  int ns = QLA_Ns;
static  int ic,jc,is,js;
#endif

include(tensor_idx_defs.m4);

#if ( QLA_Precision != 'Q' )  /* Q precision is limited to assignments */

  /* Matrix adjoint */
void do_mata(void) {
unarya(P,eq,P)
unarya(M,eq,M)
unarya(P,peq,P)
unarya(M,peq,M)
unarya(P,eqm,P)
unarya(M,eqm,M)
unarya(P,meq,P)
unarya(M,meq,M)
}

  /* Transpose */
void do_trans(void) {
unary(P,eq_transpose,P)
unary(M,eq_transpose,M)
unary(P,peq_transpose,P)
unary(M,peq_transpose,M)
unary(P,meq_transpose,P)
unary(M,meq_transpose,M)
unary(P,eqm_transpose,P)
unary(M,eqm_transpose,M)
}

  /* Local squared norm */
void do_lsn(void) {
alleqops(`unary(R,',`_norm2,H)')
alleqops(`unary(R,',`_norm2,D)')
alleqops(`unary(R,',`_norm2,V)')
alleqops(`unary(R,',`_norm2,P)')
alleqops(`unary(R,',`_norm2,M)')
}

  /* Complex conjugate */
void do_cc(void) {
alltensors2(`unary',eq_conj);
alltensors2(`unary',peq_conj);
alltensors2(`unary',eqm_conj);
alltensors2(`unary',meq_conj);
}

  /* Extracting elements */
void do_ee(void) {
unary_get_elem(C,eq_elem,H)
unary_get_elem(C,eq_elem,D)
unary_get_elem(C,eq_elem,V)
unary_get_elem(C,eq_elem,P)
unary_get_elem(C,eq_elem,M)
}

  /* Inserting elements */
void do_ie(void) {
unary_set_elem(H,eq_elem,C)
unary_set_elem(D,eq_elem,C)
unary_set_elem(V,eq_elem,C)
unary_set_elem(P,eq_elem,C)
unary_set_elem(M,eq_elem,C)
}

  /* Extracting color vectors */
void do_ecv(void) {
unary_get_colorvec(V,eq_colorvec,H)
unary_get_colorvec(V,eq_colorvec,D)
unary_get_colorvec(V,eq_colorvec,P)
unary_get_colorvec(V,eq_colorvec,M)
}

  /* Inserting color vectors */
void do_icv(void) {
unary_set_colorvec(H,eq_colorvec,V)
unary_set_colorvec(D,eq_colorvec,V)
unary_set_colorvec(P,eq_colorvec,V)
unary_set_colorvec(M,eq_colorvec,V)
}

  /* Extracting and inserting Dirac vectors */
void do_eidv(void) {
unary_get_diracvec(D,eq_diracvec,P)
unary_set_diracvec(P,eq_diracvec,D)
}

#endif
`
int test_tensor_idx1(){
  initialize_variables();
'
#if ( QLA_Precision != 'Q' )  /* Q precision is limited to assignments */

  /* Matrix adjoint */
  do_mata();

  /* Transpose */
  do_trans();

  /* Local squared norm */
  do_lsn();

  /* Complex conjugate */
  do_cc();

  /* Extracting elements */
  do_ee();

  /* Inserting elements */
  do_ie();

  /* Extracting color vectors */
  do_ecv();

  /* Inserting color vectors */
  do_icv();

  /* Extracting and inserting Dirac vectors */
  do_eidv();

#endif /* QLA_Precision != Q */
`
  return 0;
}
'
