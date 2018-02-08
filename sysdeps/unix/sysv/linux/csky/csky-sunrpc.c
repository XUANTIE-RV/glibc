

#define u_long (unsigned long) 
#define u_int  (unsigned int)

struct sockaddr_in;
enum xdr_op;
xdrproc_t;

void *__libc_clntudp_bufcreate (struct sockaddr_in *raddr, u_long program,
                          u_long version, struct timeval wait, int *sockp,
                          u_int sendsz, u_int recvsz, int flags){}

unsigned long
xdr_sizeof (xdrproc_t func, void *data){}

void
xdrmem_create (XDR *xdrs, const caddr_t addr, u_int size, enum xdr_op op){}

void
xdr_free (xdrproc_t proc, char *objp){}

void
xprt_unregister (SVCXPRT *xprt){}

void xprt_unregister (SVCXPRT *__xprt){}

int
svc_register (SVCXPRT * xprt, rpcprog_t prog, rpcvers_t vers,
              void (*dispatch) (struct svc_req *, SVCXPRT *),
              rpcproc_t protocol){}
