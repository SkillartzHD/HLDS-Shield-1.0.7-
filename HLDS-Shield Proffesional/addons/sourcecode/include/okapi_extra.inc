
#if defined _okapi_extra_included
	#endinput
#endif
#define _okapi_extra_included

/**
 *  Converts a cbase (that is, the address of the c++ object of an entity) to an id
 *  
 * @param cbase				the cbase of the entity
 * @return					the id of the entity
 *
 *
 */
native okapi_cbase_to_id(cbase)

/**
 *  Converts the id of an entity to its cbase (that is, the address of the c++ object of an entity) 
 *  
 * @param id				the id of the entity
 * @return					the cbase of the entity
 *
 *
 */
native okapi_id_to_cbase(id)

/**
 *   Gets the length of the engine library
 *  
 * @return					the base address
 *
 */
native okapi_engine_get_size()

/**
 *   Gets the length of the mod library
 *  
 * @return					the base address
 *
 */
native okapi_mod_get_size()

/**
 *  Retrieves a virtual function address located in the virtual table of an entity
 *  
 * @param id				the id of the entity
 * @param offset			the offset of the virtual function in the virtual table
 * @return					the address of the virtual function
 *
 *
 */
native okapi_cbase_get_vfunc_ptr(id,offset)

/**
 *  Retrieves a virtual function address located in the virtual table of an entity, created using it's classname
 *  
 * @param classname			the classname of the entity
 * @param offset			the offset of the virtual function in the virtual table
 * @return					the address of the virtual function
 *
 *
 */
native okapi_class_get_vfunc_ptr(classname[],offset)

/**
 *  Retrieves a virtual function address located in the virtual table of an object (can be a cbase or another one)
 *  
 * @param ptr				the address of the object
 * @param offset			the offset of the virtual function in the virtual table
 * @return					the address of the virtual function
 *
 *
 */
native okapi_ptr_get_vfunc_ptr(ptr,offset)


/**
 * Retrieves the memory protection of the location pointed to by the address
 *  
 * @param ptr			the address
 * @return				the protection value
 *
 */
native okapi_get_mem_protect(ptr)

/**
 * Changes the memory protection of the location pointed to by the address
 *  
 * @param ptr			the address
 * @param prot			the protection value
 * @return				if the operation was successful
 *
 */
native okapi_set_mem_protect(ptr,prot)


/**
 *  Retrieves the symbolic name of an address, if one exists
 *	This functions just works/makes sense on linux
 *  
 * @param ptr				the address of the function
 * @param str[]				the string to save the name
 * @param len				the max length that the string will hold
 * @return					1 or 0, depending on the sucess of the operation
 *
 *
 */
native okapi_get_ptr_symbol(ptr,str[],len)

/**
 *  Retrieves the address of an engfunc function
 *  
 * @param id				the id of the engfunc (a value from the enum defined in fakemeta_const like EngFunc_PrecacheModel)
 * @return					the address of the function
 *
 *
 */
native okapi_get_engfunc_ptr(id)

/**
 *  Retrieves the address of an dllfunc function
 *  
 * @param id				the id of the dllfunc (a value from the enum defined in fakemeta_const like DLLFunc_GameInit)
 * @return					the address of the function
 *
 *
 */
native okapi_get_dllfunc_ptr(id)

/**
 *  Retrieves the address of an engfunc function by its relative offset in the struct enginefuncs_t
 *  
 * @param offset			the offset of the engfunc
 * @return					the address of the function
 *
 *
 */
native okapi_get_engfunc_ptr_by_offset(offset)

/**
 *  Retrieves the address of a dllfunc function by its relative offset in the struct DLL_FUNCTIONS
 *  
* @param offset				the offset of the dllfunc
* @return					the address of the function
 *
 *
 */
native okapi_get_dllfunc_ptr_by_offset(offset)


