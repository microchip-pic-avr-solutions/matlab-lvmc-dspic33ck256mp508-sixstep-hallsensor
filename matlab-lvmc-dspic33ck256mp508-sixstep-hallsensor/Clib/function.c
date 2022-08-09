#include "MCHP_modelInclude.h"

const unsigned int PWM_STATE3_CLKW[8]	=	{0x3000,0x1000,0x3000,0x1000,0x2700,0x3000,0x2700,0x3000};
const unsigned int PWM_STATE2_CLKW[8]	=	{0x3000,0x3000,0x2700,0x2700,0x1000,0x1000,0x3000,0x3000};
const unsigned int PWM_STATE1_CLKW[8]	=	{0x3000,0x2700,0x1000,0x3000,0x3000,0x2700,0x1000,0x3000};

void myPWMOverrideEnable(unsigned int sector)
{ 
    PG1IOCONL = PWM_STATE1_CLKW[sector];
    PG2IOCONL = PWM_STATE2_CLKW[sector];
    PG4IOCONL = PWM_STATE3_CLKW[sector];
}