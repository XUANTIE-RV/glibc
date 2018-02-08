#ifdef	__CSKYABIV2__
#define csky_read_tp	\
	mov	a0, r31
#else
#define csky_read_tp	\
	trap	3
#endif
