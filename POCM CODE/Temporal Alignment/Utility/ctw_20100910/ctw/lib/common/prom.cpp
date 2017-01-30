#include "mex.h"
#include "string.h"

#define MAX_LEN 200

/*
 * function prom(level, form, varargin)
 *
 * History
 *   create  -  Feng Zhou, 08-21-2009
 *   modify  -  Feng Zhou, 08-21-2009
 */
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {

    // level
    char tmp[MAX_LEN];
    mxGetString(prhs[0], tmp, MAX_LEN);
    char level = *tmp;
    printf("level %c\n", level);

    // global promL
    mxArray *promLArr = mexGetVariable("global", "promL");
    if (promLArr == NULL) {
        promLArr = mxCreateString("m");
        mexPutVariable("global", "promL", promLArr);
    }
    mxGetString(promLArr, tmp, MAX_LEN);
    char promL = *tmp;
    printf("promL %c\n", promL);

    // testify level
    if (level != 't' && level != 'm' && level != 'b') {
        mexErrMsgTxt("unknown level");
    }

    // form
    char form[MAX_LEN];
    mxGetString(prhs[1], form, MAX_LEN);
    
    // varargin
    for (int i = 2; i < nrhs; ++i) {
        
    }
}
