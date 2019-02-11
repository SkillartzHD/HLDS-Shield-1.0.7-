
#if defined _okapi_included
	#endinput
#endif
#define _okapi_included

#if AMXX_VERSION_NUM >= 175
 #pragma reqlib okapi
 #if !defined AMXMODX_NOAUTOLOAD
  #pragma loadlib okapi
 #endif
#else
 #pragma library okapi
#endif

#include <okapi_const>

/**
 * Gets the address of the function that best matches the treemap
 * 
 * @param treemap		the treemap
 * @param any			a sequence of pairs (function_address, relation_number) to refine the search
 * @return				the address of the best matching function
 *						0 if no address is found
 *						
 *    Function address means the actual address, not the offset in the library.
 *	  This function deals with actual addresses, not offsets.
 *	  When you provide pairs function_address/relation_number, only addresses with the right relation_number
 * 	to the function are considered
 *
 */
native okapi_get_treemap_ptr(const treemap[],any:...)

/**
 *   Gets the base address of where the engine library is allocated in memory
 *  
 * @return					the base address
 *
 */
native okapi_engine_get_base_ptr()

/**
 *   Gets the base address of where the mod library is allocated in memory
 *  
 * @return					the base address
 *
 */
native okapi_mod_get_base_ptr()

/**
 *   Searches for a signature in the mod library, starting at 'ptr' address
 *	For bytes to ignore, use "𐌻" or any number above 0xFF like:
 *
 *	{0x51,0x56,"𐌻","𐌻",0x8B,0x86}
 *	{0x51,0x56,0xDEF,0xDEF,0x8B,0x86}
 *
 *	I chose the character 𐌻 because it looks like a lambda but it is made of 4 chars
 *	so, it only "forbids" using the sequence {0xF0,0x90,0x8C,0xBB,0x00} in signatures
 *  
 * @param ptr				the start address
 * @param sig[]				the signature to find
 * @param size				the size of the signature
 * @return					the address where the sig was first found
 *							0 if none was found
 *
 */
native okapi_mod_find_sig_at(ptr,const sig[],count)

stock okapi_mod_find_sig(const sig[],count)
{
	return okapi_mod_find_sig_at(okapi_mod_get_base_ptr(),sig,count)
}

/** Same as above, for the engine library
*  
 * @param ptr				the start address
 * @param sig[]				the signature to find
 * @param size				the size of the signature
 * @return					the address where the sig was first found
 *							0 if none was found
 *
 */
native okapi_engine_find_sig_at(ptr,const sig[],count)

stock okapi_engine_find_sig(const sig[],count)
{
	return okapi_engine_find_sig_at(okapi_engine_get_base_ptr(),sig,count)
}

/**
 *  Attaches okapi to a method (class member function) so you can hook it and call it
 *  
 * @param ptr				the address of the method
 * @param okapi_arg:ret		the return type of the method
 * @param okapi_arg:arg		the type of the method class
 * @param okapi_arg:...		the rest of the types for the arguments of the function
 *
 * @return					an handler to the function attached
 *
 */
native okapi_func:okapi_build_method(ptr,okapi_arg:ret,okapi_arg:class,okapi_arg:...)

/**
 *  Attaches okapi to a function so you can hook it and call it
 *  
 * @param ptr				the address of the method
 * @param okapi_arg:ret		the return type of the method
 * @param okapi_arg:...		the rest of the types for the arguments of the function
 *
 * @return					an handler to the function attached
 *
 */
native okapi_func:okapi_build_function(ptr,okapi_arg:ret,okapi_arg:...)


/**
 *  Attaches okapi to a virtual function of an entity so you can hook it and call it
 *
 * Note: you don't need to pass arg_cbase in the argument list for the entity itself 
 *
 * @id						the id of the entity
 * @offset					the offset of the function in the virtual table
 * @param okapi_arg:ret		the return type of the method
 * @param okapi_arg:...		the rest of the types for the arguments of the function
 *
 * @return					an handler to the function attached
 *
 */
native okapi_func:okapi_build_vfunc_cbase(id,offset,okapi_arg:ret,okapi_arg:...)

/**
 *  Attaches okapi to a virtual function of an entity (using its class) so you can hook it and call it
 *
 * Note: you don't need to pass arg_cbase in the argument list for the entity itself 
 *
 * @classname[]				the name of the class
 * @offset					the offset of the function in the virtual table
 * @param okapi_arg:ret		the return type of the method
 * @param okapi_arg:...		the rest of the types for the arguments of the function
 *
 * @return					an handler to the function attached
 *
 */
native okapi_func:okapi_build_vfunc_class(classname[],offset,okapi_arg:ret,okapi_arg:...)

/**
 *  Attaches okapi to a virtual function of an object so you can hook it and call it
 *
 *
 * @ptr						the address of the object
 * @offset					the offset of the function in the virtual table
 * @param okapi_arg:ret		the return type of the method
 * @param okapi_arg:...		the rest of the types for the arguments of the function
 *
 * @return					an handler to the function attached
 *
 */
native okapi_func:okapi_build_vfunc_ptr(ptr,offset,okapi_arg:ret,okapi_arg:...)


/**
 *  Adds a hook to a previously attached function
 *  
 * @param okapi_func:func	a handler to the function returned by an attach function
 * @param callback[]		the name of the public function in the code that will be 
 *
 * @return					an handler to the hook
 *
 */
native okapi_hook:okapi_add_hook(okapi_func:func,callback[],post=0)

/**
 *  Removes a hook from the function
 *  
 * @param hook				the handler to the hook
 *
 */
native okapi_del_hook(&okapi_hook:hook)

/**
 *  Modifies a parameter that will be passed in the call to the original function
 *  
 * @param param_id			the index of the parameter. First is 1
 * @param any:...			the value of the parameter
 *
 */
native okapi_set_param(param_id,any:...)

/**
 *  Modifies the return of the function
 *  
 * @param any:...			the value of the return
 *
 */
native okapi_set_return(any:...)

/**
 *  Retrieves the value that the hooked function retrieved
 *  
 * @param any:...			the value of the original return, if passed by ref
 * @return					the value of the original return, if passed by value
 *
 */
native okapi_get_orig_return(any:...)

/**
 *  Calls a function without calling its hooks
 *  
 * @param any:...			the arguments to the function and return variables, if the function returns byref
 * @return					the value that the function returned, if the function doesn't return by ref
 *
 */
native okapi_call(okapi_func:func,any:...)

/**
 *  Calls a function and its hooks
 *  
 * @param any:...			the arguments to the function and return variables, if the function returns byref
 * @return					the value that the function returned, if the function doesn't return by ref
 *
 */
native okapi_call_ex(okapi_func:func,any:...)

/**
 *    Gets the hook that is currently being called.
 *	This is meant to be used inside a hook (when you want to remove it there)
 *  
 * @return					the handler to the hook
 *
 */
native okapi_hook:okapi_current_hook()

/**
 * Gets the offset of an address relative to the engine library
 * 
 * @param ptr			an address
 * @return				the offset of the address in the engine library
 *						0 if the address is not located in the engine library
 */
native okapi_engine_get_ptr_offset(ptr)

/**
 * Gets the offset of an address relative to the mod library
 * 
 * @param ptr			an address
 * @return				the offset of the address in the mod library
 *						0 if the address is not located in the mod library
 */
native okapi_mod_get_ptr_offset(ptr)


/**
 * Gets the address of an offset relative to the engine library
 * 
 * @param offset		an offset
 * @return				the address of the offset in the engine library
 *						0 if the offset is not located in the engine library
 */
native okapi_engine_get_offset_ptr(offset)

/**
 * Gets the address of an offset relative to the mod library
 * 
 * @param offset		an offset
 * @return				the address of the address in the mod library
 *						0 if the offset is not located in the mod library
 */
native okapi_mod_get_offset_ptr(offset)

/**
 * Gets the address of a function, given it's symbolic name
 * 
 * @param symbol		the symbolic name of a function
 * @return				the address of the function
 *						0 if it doesn't exist
 */
native okapi_engine_get_symbol_ptr(const symbol[])

/**
 * Gets the address of a function, given it's symbolic name
 * 
 * @param symbol		the symbolic name of a function
 * @return				the address of the function
 *						0 if it doesn't exist
 */
native okapi_mod_get_symbol_ptr(const symbol[])

/**
 * Sets the value of the location pointed by the address with the entvars relative to an entity represented by id
 *  
 * @param ptr			the address
 * @param id			the entity id
 *
 */
native okapi_set_ptr_ent(ptr,id)

/**
 * Retrieves the entvars located in an address as an entity id
 *  
 * @param ptr			the address
 * @return				the entity id
 *
 */
native okapi_get_ptr_ent(ptr)

/**
 * Sets the value of the location pointed by the address with the edict relative to an entity represented by id
 *  
 * @param ptr			the address
 * @param id			the entity id
 *
 */
native okapi_set_ptr_edict(ptr,id)

/**
 * Retrieves the edict located in an address as an entity id
 *  
 * @param ptr			the address
 * @return				the entity id
 *
 */
native okapi_get_ptr_edict(ptr)

/**
 * Sets the value of the location pointed by the address with the cbase relative to an entity represented by id
 *  
 * @param ptr			the address
 * @param id			the entity id
 *
 */
native okapi_set_ptr_cbase(ptr,id)

/**
 * Retrieves the cbase located in an address as an entity id
 *  
 * @param ptr			the address
 * @return				the entity id
 *
 */
native okapi_get_ptr_cbase(ptr)

/**
 * Writes an integer value at the location pointed by the address
 *  
 * @param ptr			the address
 * @param value			the value
 *
 */
native okapi_set_ptr_int(ptr,value)

/**
 * Retrieves an integer value in the location pointed by the address
 *  
 * @param ptr			the address
 * @return				the value
 *
 */
native okapi_get_ptr_int(ptr)

/**
 * Writes a byte value at the location pointed by the address
 *  
 * @param ptr			the address
 * @param value			the value
 *
 */
native okapi_set_ptr_byte(ptr,value)

/**
 * Retrieves a byte value in the location pointed by the address
 *  
 * @param ptr			the address
 * @return				the value
 *
 */
native okapi_get_ptr_byte(ptr)

/**
 * Writes a float value at the location pointed by the address
 *  
 * @param ptr			the address
 * @param value			the value
 *
 */
native okapi_set_ptr_float(ptr,Float:value)

/**
 * Retrieves a float value in the location pointed to by the address
 *  
 * @param ptr			the address
 * @return				the value
 *
 */
native Float:okapi_get_ptr_float(ptr)

/**
 * Retrieves an array of bytes in the location pointed to by the address
 *  
 * @param ptr			the address
 * @param holder		the array where the bytes will be stored
 * @param count			the number of bytes to retrieve
 *
 */
native okapi_get_ptr_array(ptr,holder[],count)

/**
 * Writes an array of bytes to the location pointed to by the address
 *  
 * @param ptr			the address
 * @param holder		the array with the bytes to write
 * @param count			the number of bytes to write
 *
 */
native okapi_set_ptr_array(ptr,holder[],count)

/**
 * Retrieves an string from the location pointed to by the address
 *  
 * @param ptr			the address
 * @param str[]			the variable where the string will be stored
 * @param len			the limit of chars to retrieve 
 * @return				the number of chars retrieved
 *
 */
native okapi_get_ptr_string(ptr,str[],len)

/**
 * Writes a string to the location pointed to by the address
 *  
 * @param ptr			the address
 * @param str[]			the string to write
 *
 */
native okapi_set_ptr_string(ptr,str[])

/**
 *   Replaces every string that occurs in the engine library with another one
 *	the replacement string should be of equal or shorter size than the original
 *	if you know what you are doing and want to skip this check, make force=1
 *  
 * @param str_orig[]		the original string
 * @param str_replace[]		the replacement string
 * @param force				1 will skip the restrition of the string replacement size
 * @return					the number of replacements ocurred
 *
 */
native okapi_engine_replace_string(str_orig[],str_replace[],force=0)

/**
 *   Replaces every string that occurs in the mod library with another one
 *	the replacement string should be of equal or shorter size than the original
 *	if you know what you are doing and want to skip this check, make force=1
 *  
 * @param str_orig[]		the original string
 * @param str_replace[]		the replacement string
 * @param force				1 will skip the restrition of the string replacement size
 * @return					the number of replacements ocurred
 *
 */
native okapi_mod_replace_string(str_orig[],str_replace[],force=0)

/**
 *   Replaces every ocurrence of the sequence of bytes given, in the engine library, with other sequence
 *  
 * @param arr_orig[]		the original string
 * @param arr_replace[]		the replacement string
 * @param count				number of bytes
 * @return					the number of replacements ocurred
 *
 */
native okapi_engine_replace_array(arr_orig[],arr_replace[],len)

/**
 *   Replaces every ocurrence of the sequence of bytes given, in the mod library, with other sequence
 *  
 * @param arr_orig[]		the original string
 * @param arr_replace[]		the replacement string
 * @param count				number of bytes
 * @return					the number of replacements ocurred
 *
 */
native okapi_mod_replace_array(arr_orig[],arr_replace[],len)

/**
 *   Replaces every ocurrence of the integer given, in the engine library, with other integer
 *  
 * @param val_search		the original value
 * @param val_replace		the replacement value
 * @return					the number of replacements ocurred
 *
 */
native okapi_engine_replace_int(val_search,val_replace)

/**
 *   Replaces every ocurrence of the integer given, in the mod library, with other integer
 *  
 * @param val_search		the original value
 * @param val_replace		the replacement value
 * @return					the number of replacements ocurred
 *
 */
native okapi_mod_replace_int(val_search,val_replace)

/**
 *   Replaces every ocurrence of the float given, in the engine library, with other float
 *  
 * @param val_search		the original value
 * @param val_replace		the replacement value
 * @return					the number of replacements ocurred
 *
 */
native okapi_engine_replace_float(Float:val_search,Float:val_replace)

/**
 *   Replaces every ocurrence of the integer given, in the mod library, with other integer
 *  
 * @param val_search		the original value
 * @param val_replace		the replacement value
 * @return					the number of replacements ocurred
 *
 */
native okapi_mod_replace_float(Float:val_search,Float:val_replace)

/**
 *   Searches for a string in the engine library, starting at 'ptr' address
 *  
 * @param ptr				the start address
 * @param str[]				the string to find
 * @return					the address where the first string was found
 *							0 if none was found
 *
 */
native okapi_engine_ptr_find_string_at(ptr,const str[])

stock okapi_engine_find_string(const str[])
{
	return okapi_engine_ptr_find_string_at(okapi_engine_get_base_ptr(),str)
}

/**
 *   Searches for a string in the mod library, starting at 'ptr' address
 *  
 * @param ptr				the start address
 * @param str[]				the string to find
 * @return					the address where the first string was found
 *							0 if none was found
 *
 */
native okapi_mod_ptr_find_string_at(ptr,const str[])

stock okapi_mod_find_string(const str[])
{
	return okapi_mod_ptr_find_string_at(okapi_mod_get_base_ptr(),str)
}

/**
 *   Searches for an int in the engine library, starting at 'ptr' address
 *  
 * @param ptr				the start address
 * @param val				the value to find
 * @return					the address where the first value was found
 *							0 if none was found
 *
 */
native okapi_engine_ptr_find_int_at(ptr,value)

stock okapi_engine_find_int(value)
{
	return okapi_engine_ptr_find_int_at(okapi_engine_get_base_ptr(),value)
}

/**
 *   Searches for an int in the mod library, starting at 'ptr' address
 *  
 * @param ptr				the start address
 * @param val				the string to find
 * @return					the address where the first value was found
 *							0 if none was found
 *
 */
native okapi_mod_ptr_find_int_at(ptr,val)

stock okapi_mod_find_int(val)
{
	return okapi_mod_ptr_find_int_at(okapi_mod_get_base_ptr(),val)
}

/**
 *   Searches for a float in the engine library, starting at 'ptr' address
 *  
 * @param ptr				the start address
 * @param Float:val			the value to find
 * @return					the address where the first value was found
 *							0 if none was found
 *
 */
native okapi_engine_ptr_find_float_at(ptr,Float:value)

stock okapi_engine_ptr_find_float(Float:value)
{
	return okapi_engine_ptr_find_float_at(okapi_engine_get_base_ptr(),value)
}

/**
 *   Searches for a float in the mod library, starting at 'ptr' address
 *  
 * @param ptr				the start address
 * @param Float:val			the string to find
 * @return					the address where the first value was found
 *							0 if none was found
 *
 */
native okapi_mod_ptr_find_float_at(ptr,Float:val)

stock okapi_mod_find_float(Float:val)
{
	return okapi_mod_ptr_find_float_at(okapi_mod_get_base_ptr(),val)
}

/**
 *   Searches for a byte in the engine library, starting at 'ptr' address
 *  
 * @param ptr				the start address
 * @param val				the value to find
 * @return					the address where the first value was found
 *							0 if none was found
 *
 */
native okapi_engine_ptr_find_byte_at(ptr,value)

stock okapi_engine_find_byte(value)
{
	return okapi_engine_ptr_find_byte_at(okapi_engine_get_base_ptr(),value)
}

/**
 *   Searches for a byte in the mod library, starting at 'ptr' address
 *  
 * @param ptr				the start address
 * @param val				the string to find
 * @return					the address where the first value was found
 *							0 if none was found
 *
 */
native okapi_mod_ptr_find_byte_at(ptr,val)

stock okapi_mod_find_byte(val)
{
	return okapi_mod_ptr_find_byte_at(okapi_mod_get_base_ptr(),val)
}

/**
 *   Searches for an array of bytes in the engine library, starting at 'ptr' address
 *  
 * @param ptr				the start address
 * @param array_[]			the array to find
 * @param count				the number of bytes
 * @return					the address where the first array was found
 *							0 if none was found
 *
 */
native okapi_engine_ptr_find_array_at(ptr,const array_[],count)

stock okapi_engine_find_array(const array_[],count)
{
	return okapi_engine_ptr_find_array_at(okapi_engine_get_base_ptr(),array_,count)
}

/**
 *   Searches for an array of bytes in the mod library, starting at 'ptr' address
 *  
 * @param ptr				the start address
 * @param array_[]			the array to find
 * @param count				the number of bytes
 * @return					the address where the first array was found
 *							0 if none was found
 *
 */
native okapi_mod_ptr_find_array_at(ptr,const array_[],count)

stock okapi_mod_find_array(const array_[],count)
{
	return okapi_mod_ptr_find_array_at(okapi_mod_get_base_ptr(),array_,count)
}

/**
 *   Allocates n blocks of 4 bytes
 *  
 * @param n					number of blocks
 * @return					the address of the allocation (ptr)
 *
 */
native okapi_alloc(n)

/**
 *   Reads a vector from 
 *  
 * @param ptr				the ptr of the allocation
 * @param Float:vec[3]		the variable where the vector will be wrote to
 *
 *
 */
native okapi_get_ptr_vec(ptr,Float:vec[3])


/**
 *   Return a if server is windows, returns b if server is linux
 *  
 * @param a					value for windows
 * @param b					value for linux
 *
 * @return					a if windows, b if linux
 *
 */
native wl(a,b)