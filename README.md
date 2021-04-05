# SAMsalabim
AVR assembler implementation of the Square-And-Multiply (SAM) algorithm.  
Currently only the calculation of **a<sup>b</sup> mod 256** is supported because everything needs to fit in 8-bit registers, no consideraton of overflows.
This might change some time though.

## Usage
Just put the (8-bit) arguments in the SAM_BASE and SAM_EXP registers, call sam and simsalabim: SAM_RES contains the result.
