
#if defined _okapi_const_included
	#endinput
#endif
#define _okapi_const_included

enum okapi_arg
{
	arg_void,
	arg_int,
	arg_cbase,
	arg_float,
	arg_vec,
	arg_entvars,
	arg_string,
	arg_edict,
	arg_vec_ptr
}

enum MemProtect
{
	PAGE_READ=1,
	PAGE_WRITE=2,
	PAGE_EXEC=4
}

enum okapi_ret
{
	okapi_ret_ignore,
	okapi_ret_override,
	okapi_ret_supercede
}
