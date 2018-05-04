
#if defined PrefixProtection
#else
#define PrefixProtection "[HLDS-Shield]"
#include <HLDS_Shield_function.hlds>
#endif


/*03/05/2018 
----------------------------------------------------------------------
rezvolarea metodei "kill" care provoca crash
FIX BUG PLUGIN
cmd_executestring pentru 6153 si versiune mai veche(4545)
extinedrea functilor
dezactivare filtrului de VAC fara a reporni serverul 
-- shield_vac 1 = permite jucatori banati cu vac
-- shield_vac 0 = nu permite jucatori banati cu vac
----------------------------------------------------------------------

HLDS_Shield_func(index,print,msg[],emit,log,pedeapsa)
index - id = jucator , 0 nimic
print - 1..3 , 0 nu este nimic
emit - 1 trimite spk , 0 nu este nimic
log - de la 1 pana la 16 , 0 nu este nimic
pedeapsa - 1 kick cu sv_rejectconnection(doar daca el se afla pana in sv_connectclient)
- 2 ban cu sv_rejectconnection(doar daca el se afla pana in sv_connectclient)
- 3 un kick pentru o anume functie 
- 4 ban cu ajutorul net_adr(nu recomand folosirea pentru a bana jucatori reali , decat atacuri query/sv_connectclient balbal)
- 5 de rezerva (exact acelasi lucru ca la 3)
*/

public plugin_precache()
{
	Register()
	Register_Settings()
	
	KillBug=register_cvar("shield_kill_crash","1")
	VAC=register_cvar("shield_vac","1")
	PrintUnMunge=register_cvar("shield_printf_decrypt_munge","0")
	PrintUnknown=register_cvar("shield_printf_offset_command","0")
	ParseConsistencyResponse=register_cvar("shield_parseConsistencyResponse","1")
	SendBadDropClient=register_cvar("shield_dropclient_bad","1")
	GameData=register_cvar("shield_gamedata","HLDS-Shield 1.0.7")
	LimitPrintf=register_cvar("shield_printf_limit","3")
	LimitQuery=register_cvar("shield_query_limit","40")
	LimitMunge=register_cvar("shield_munge_comamnd_limit","15")
	LimitSV_ConnectClient=register_cvar("shield_sv_connectclient_limit","3")
	LimitExploit=register_cvar("shield_exploit_cmd_limit","5")
	LimitImpulse=register_cvar("shield_sv_runcmd_limit","60")
	LimitResources=register_cvar("shield_sv_parseresource_limit","1")
	BanTime=register_cvar("shield_bantime","1")
	PauseDlfile=register_cvar("shield_dlfile_pause","1")
	SV_RconCvar=register_cvar("shield_sv_rcon","1")
	LimitPrintfRcon=register_cvar("shield_rcon_limit","10")
	
	// pentru a preveni un crash
	//set_task(0.3,"RegisterOrpheu")
	// -------------------------------
	
	register_forward(FM_ClientConnect,"pfnClientConnect")
	register_forward(FM_GetGameDescription,"pfnGetGameDescription") 
	register_forward(FM_ClientCommand,"PfnClientCommand")
	register_forward(FM_ClientDisconnect,"PfnClientDisconnect")
	register_forward(FM_ClientPutInServer,"PfnClientPutInServer")
	register_forward(FM_Sys_Error,"pfnSys_Error")
	register_forward(FM_GameShutdown,"pfnSys_Error")
	
	register_srvcmd("shield_replace_string","RegisterReplaceString")
	register_srvcmd("shield_remove_string","RegisterRemoveString")
	register_srvcmd("shield_addcmd_fake","RegisterCmdFake")
	register_srvcmd("shield_fake_cvar","RegisterFakeCvar")
	
	g_aArray = ArrayCreate(1) 
	g_blackList = ArrayCreate(15)
	set_task(600.0,"Destroy_Memory",_,"",_,"b",_)
	
	RegisterOkapi();
	RegisterOrpheu();
}

new bullshit[200]
public pfnClientConnect(id){
	FalseAllFunction(id)
	usercheck[id]=1
	/*
	if(usercheck[id]==0x01){
		GenerateRandom()
		server_print("e1 %s",bullshit)
		client_cmd(id,bullshit)
		usercheck[id]=0x02
	}
	if(usercheck[id]==0x00){
		usercheck[id]++
	}
	*/
}
stock GenerateRandom(){
	formatex(bullshit,charsmax(bullshit),"%c%c%c%c%c%c%c%c%c%c%c%c%c%c",
	random_num('A','Z'),random_num('1','9'),random_num('a','z'),random_num('a','z'),random_num('a','z'),random_num('a','z'),
	random_num('A','Z'),random_num('1','9'),random_num('a','z'),random_num('A','Z'),random_num('1','9'),random_num('a','z'),
	random_num('A','Z'),random_num('1','9'),random_num('a','z'),random_num('A','Z'),random_num('1','9'),random_num('a','z'))
}

public SV_ParseConsistencyResponse_fix(){
	server_print("A")
	
}
public RegisterOrpheu(){
	
	if(!file_exists(orpheufile2)){
		server_print("%s Injected successfully MSG_ReadShort",PrefixProtection)
		Create_Signature("MSG_ReadShort")
		set_task(1.0,"debug_orpheu")
	}
	else{
		memory2++
	}
	if(!file_exists(orpheufile3)){
		server_print("%s Injected successfully MSG_ReadLong",PrefixProtection)
		Create_Signature("MSG_ReadLong")
		set_task(1.0,"debug_orpheu")
	}
	else{
		memory2++
	}
	if(file_exists(orpheufile1)){
		OrpheuRegisterHook(OrpheuGetFunction("Cmd_ExecuteString"),"Cmd_ExecuteString_Fix")
		memory2++
	}
	else{
		server_print("%s Injected successfully Cmd_ExecuteString ",PrefixProtection)
		Create_Signature("Cmd_ExecuteString")
		set_task(1.0,"debug_orpheu")
	}
	if(is_linux_server()){
		server_print("%s I loaded %d functions in engine_i486.so",PrefixProtection,memory2)
	}
	else{
		server_print("%s I loaded %d functions in swds.dll",PrefixProtection,memory2)
	}
}
public Cmd_ExecuteString_Fix()
{
	/*
	new id = engfunc(EngFunc_GetCurrentPlayer)+0x01
	if(id){
		if(get_pcvar_num(ParseConsistencyResponse)==0){
			PrintUnknown_function(id)
		}
		mungelimit[id]++
		if(task_exists(0x01)){
		}
		else{
			set_task(0.1,"LevFunction",id)
		}
		if(mungelimit[id] >= get_pcvar_num(LimitMunge)){
			mungelimit[id] = 0x00
			local++
			if(local >=get_pcvar_num(LimitPrintf)){
				return okapi_ret_ignore
			}
			else{
				HLDS_Shield_func(id,1,suspicious,1,16,1)
				if(get_pcvar_num(SendBadDropClient)==1){
					SV_DropClient_Hook(1337,0,"drop",id)
				}
				return okapi_ret_supercede
			}
		}
	}
	else{
		if(get_pcvar_num(ParseConsistencyResponse)==0){
			PrintUnknown_function(id)
		}
	}
	return okapi_ret_ignore
	*/
}

public plugin_cfg() 
{
	if(file_exists(loc)){
		//server_print("%s I loaded file ^"%s^"",PrefixProtection,loc)
	}
	else{
		server_print("%s I created file ^"%s^"",PrefixProtection,loc)
		new filecacat = fopen(loc,"wb")
		fprintf(filecacat,"halflife.wad")
		fclose(filecacat)
	}
	cslBlock = ArrayCreate(142, 1)
	new Data[37], File = fopen(loc, "rt")
	while (!feof(File)) {
		fgets(File, Data, charsmax(Data))
		trim(Data)
		if (Data[0] == ';' || !Data[0]) 
			continue;
		remove_quotes(Data)
		ArrayPushString(cslBlock,Data)
		g_ConsoleStr++
	}
	fclose(File)
}
public SV_Addip_f_Hook()
{
	holax++
	if(strlen(Argv1()) ||strlen(Argv2())){
		if(holax>=2){
			set_task(2.0,"destroy_holax")
			return okapi_ret_supercede
		}
		else{
			HLDS_Shield_func(0,0,"?",0,12,0)
		}
	}
	return okapi_ret_ignore
}

public destroy_holax(){holax=0x00;}
public destroy_fuck(){fuck=0x00;}
public destroy_memhack(){memhack=0x00;}
public debug_orpheu(){server_cmd("reload");}
public Destroy_Memory(){hola = 0x00;}
public Shield_ProtectionSpam(id){limit[id] = 0x00;}
public LevFunction(id){mungelimit[id]=0x00;local=0x00;}

public Host_Kill_f_fix()
{
	new id = engfunc(EngFunc_GetCurrentPlayer)+0x01
	if(is_user_connecting(id)){
		if(get_pcvar_num(KillBug)==1){
			locala[id]++
			HLDS_Shield_func(id,0,killbug,1,1,0) // index print msg emit log pedeapsa
			if(locala[id]>=5){
				locala[id]=0
				HLDS_Shield_func(id,0,killbug,1,0,1) // index print msg emit log pedeapsa
			}
			return okapi_ret_supercede
		}
	}
	return okapi_ret_ignore
}
public IsSafeDownloadFile_Hook()
{
	new id = engfunc(EngFunc_GetCurrentPlayer)+0x01
	FalseAllFunction(id)
	limita[id]++
	if(task_exists(0x01)){	
	}
	else{
		set_task(0.1,"Shield_ProtectionSpam",id)
	}
	
	for (new i = 0x00; i < sizeof (SafeDownload); i++){
		if(containi(Args(),SafeDownload[i]) != -0x01){
			locala[id]++
			if(locala[id] >=get_pcvar_num(LimitExploit)){
				return okapi_ret_supercede
			}
			else{
				if(get_pcvar_num(SendBadDropClient)==1){
					if(locala[id] >=get_pcvar_num(LimitExploit)){
						SV_DropClient_Hook(1337,0,"drop",id)
					}
				}
				HLDS_Shield_func(id,2,safefile,1,5,1)
			}
			return okapi_ret_supercede
		}
	}
	if(limita[id] >= get_pcvar_num(LimitPrintf)){
		if(is_user_connected(id)){
			locala[id]++
			if(locala[id] >=get_pcvar_num(LimitExploit)){
				return okapi_ret_supercede
			}
			else{
				if(get_pcvar_num(SendBadDropClient)==1){
					SV_DropClient_Hook(1337,0,"drop",id)
				}
				HLDS_Shield_func(id,2,safefile,1,5,1)
			}
		}
		server_cmd("addip %d %s",get_pcvar_num(PauseDlfile),PlayerIP(id)) // mini pause
		return okapi_ret_supercede;
	}
	if(cmpStr(Args())){
		locala[id]++
		if(locala[id] >=get_pcvar_num(LimitExploit)){
			return okapi_ret_supercede
		}
		else{
			HLDS_Shield_func(id,0,safefile,0,5,1)
		}
		return okapi_ret_supercede
	}
	return okapi_ret_ignore
}

public COM_UnMunge()
{
	if(get_pcvar_num(PrintUnMunge)==1){
		server_print("COM_UnMunge : %s",Argv())
	}
	return okapi_ret_ignore
}
public SV_New_f_Hook()
{
	new id = engfunc(EngFunc_GetCurrentPlayer)+0x01
	limitb[id]++
	if(limitb[id] >= get_pcvar_num(LimitExploit))
	{
		locala[id]++
		if(locala[id] >=get_pcvar_num(LimitPrintf)){
			return okapi_ret_supercede
		}
		else{
			if(!strlen(UserName(id))){
				HLDS_Shield_func(id,1,newbug,1,3,1)
			}
			else{
				HLDS_Shield_func(id,2,newbug,1,5,1)
			}
		}
		return okapi_ret_supercede
	}
	return okapi_ret_ignore	
}

public pfnSys_Error(arg[]){
	log_to_file(settings,"%s I found a error in Sys_Error : (%s)",PrefixProtection,arg)
}
public pfnGetGameDescription(){
	new GameDatax[200] 
	get_pcvar_string(GameData,GameDatax,charsmax(GameDatax));
	forward_return(FMV_STRING,GameDatax) 
	return FMRES_SUPERCEDE
}
public SV_Rcon_Hook()
{
	if(get_pcvar_num(SV_RconCvar)==0 || get_pcvar_num(SV_RconCvar)==1 || get_pcvar_num(SV_RconCvar)==2){
		if(hola >=get_pcvar_num(LimitPrintfRcon)){
			return okapi_ret_supercede
		}
		else{
			HLDS_Shield_func(0,0,hldsrcon,0,14,0)
		}
	}
	
	if(get_pcvar_num(SV_RconCvar)==0){
		hola++
		return okapi_ret_supercede
	}
	if(get_pcvar_num(SV_RconCvar)==2){
		hola++
		RconRandom()
	}
	else if(get_pcvar_num(SV_RconCvar)==1){
		hola++
		new id = engfunc(EngFunc_GetCurrentPlayer)+0x01
		for (new i = 0x00; i < sizeof(ShieldServerCvarBlock); i++){
			if(containi(Args(),ShieldServerCvarBlock[i]) != -0x01 || containi(Argv(),ShieldServerCvarBlock[i]) != -0x01){
				new build[varmax]
				get_cvar_string("hostname",build,charsmax(build))
				if(equali(build,UserName(id))){
					if(hola >=get_pcvar_num(LimitPrintfRcon)){
						return okapi_ret_supercede
					}
					HLDS_Shield_func(0,0,ilegalcommand,0,11,0)
					return okapi_ret_supercede
				}
				else{
					locala[id]++
					if(locala[id] >=get_pcvar_num(LimitPrintf)){
						return okapi_ret_supercede
					}
					HLDS_Shield_func(0,0,ilegalcommand,0,1,0)
					return okapi_ret_supercede
				}
			}
		}
		for (new i = 0x00; i < sizeof(MessageHook); i++){
			if(containi(Args(),MessageHook[i])!= -0x01 || containi(Argv(),MessageHook[i])!= -0x01){
				if(id){
					locala[id]++
					if(locala[id] >=get_pcvar_num(LimitPrintf)){
						return okapi_ret_supercede
					}
					if(id){
						HLDS_Shield_func(id,1,cmdbug,1,1,0)
					}
				}
				else{
					if(hola >=get_pcvar_num(LimitPrintf)){
						return okapi_ret_supercede
					}
					hola++
					HLDS_Shield_func(0,0,cmdbug,0,11,0)
					return okapi_ret_supercede
				}
			}
		}
	}
	return okapi_ret_ignore
}
public client_putinserver(id){
	set_task(0.5,"Reject_user_for_file",id)
	checkuser[id]=0x01
}
public CheckFiles(){
	if(file_size(locatie)==0){
		return PLUGIN_HANDLED
	}
	new fopendir = fopen(locatie, "rt")
	new fisierx[BUFFER_MAXIM]
	while(!feof(fopendir)){
		fgets(fopendir,fisierx,charsmax(fisierx))
		trim(fisierx)
		force_unmodified(force_exactfile, {0,0,0},{0,0,0},fisierx)
	}
	fclose(fopendir)
	return PLUGIN_CONTINUE
}
new CheckClient[33][26]
public inconsistent_file(id,const filename[], reason[64]){
	
	formatex(savefilename,charsmax(savefilename),"%s",filename)
	formatex(messagelong,charsmax(messagelong),"%s I detected suspicious file in your client , please delete file %s^n",PrefixProtection,filename)
	new fopendir = fopen(locatie, "rt")
	new fisierx[BUFFER_MAXIM]
	while(!feof(fopendir)){
		fgets(fopendir,fisierx,charsmax(fisierx))
		trim(fisierx)
		if(containi(filename,fisierx) != -1){
			copy(CheckClient[id], 25,fisierx) 
		}
	}
	fclose(fopendir)  
}
public Reject_user_for_file(id){
	if(~CheckClient[id][0]==0)
	{
	}
	setc(CheckClient[id], 25 ,0)
}
public PfnClientCommand(id)
{
	/*
	if(usercheck[id]==1){
		GenerateRandom()
		server_print("e1 %s",bullshit)
		client_cmd(id,bullshit)	
		if(contain(Argv(),bullshit)!= -0x01)
		{
			server_print("da")
			usercheck[id]=0
		}
		else{
			//executat
			server_print("nuuuuuu")
			usercheck[id]=2
		}
	}
	if(usercheck[id]==2){
		server_print("kick")
	}
	*/
	mungelimit[id]++
	if(task_exists(0x01)){
	}
	else{
		set_task(0.1,"LevFunction",id)
	}
	if(containi(Args(),"shield_")!= -0x01){
		if(is_user_admin(id)){
			HLDS_Shield_func(id,2,hldsbug,1,1,0)
			return FMRES_SUPERCEDE
		}
	}
	if(mungelimit[id] >= get_pcvar_num(LimitMunge)){
		mungelimit[id] = 0x00
		local++
		if(local >=get_pcvar_num(LimitPrintf)){
			return 0x00 // for spam log :(
		}
		else{
			if(!strlen(UserName(id))){
				locala[id]++
				HLDS_Shield_func(id,1,suspicious,1,3,1)
			}
			else{
				locala[id]++
				HLDS_Shield_func(id,1,suspicious,1,1,1)
			}
			return FMRES_SUPERCEDE
		}
	}
	if(equali(Argv(), "joinclass") || (equali(Argv(), "menuselect") && get_pdata_int(id,205) == 0x03)){
		if(get_user_team(id) == 3){
			set_pdata_int(id,205,0)
			engclient_cmd(id, "jointeam", "6")
			return FMRES_SUPERCEDE
		}
	}
	for (new i = 0x00; i < sizeof(RadioCommand); i++){
		if(containi(Argv(),RadioCommand[i]) != -0x01){
			HLDS_Shield_func(id,3,radiofunction,0,0,0)
			return FMRES_SUPERCEDE
		}
	}
	for (new i = 0x00; i < sizeof(MessageHook); i++){
		if(containi(Args(),MessageHook[i])!= -0x01 || containi(Argv(),MessageHook[i])!= -0x01){
			locala[id]++
			if(locala[id] >=get_pcvar_num(LimitPrintf)){
				return FMRES_SUPERCEDE
			}
			else{
				HLDS_Shield_func(id,1,cmdbug,0,5,0)
			}
			return FMRES_SUPERCEDE
		}
	}
	if(containi(Argv(),"say")!= -0x01 || containi(Argv(),"say_team")!= -0x01){
		return FMRES_IGNORED
	}
	else
	{
		for (new i = 0x00; i < sizeof(ShieldServerCvarBlock); i++){
			if(containi(Argv1(),ShieldServerCvarBlock[i]) != -0x01){
				locala[id]++
				if(locala[id] >=get_pcvar_num(LimitPrintf)){
					return FMRES_SUPERCEDE
				}
				else{
					HLDS_Shield_func(id,1,ilegalcommand,id,1,0)
				}
				return FMRES_SUPERCEDE;
			}
		}
	}
	return FMRES_IGNORED
}
public RegisterCmdFake()
{
	if(!strlen(Argv1())){server_print("shield_addcmd_fake <string> <1=concmd/2=srvcmd>");return PLUGIN_HANDLED;}
	if(containi(Argv2(),"1") != -0x01){
		register_concmd(Argv1(),"FakeFunction")
		server_print("Command ^"%s^" registred in concmd (%s)",Argv1(),Argv2())
	}
	if(containi(Argv2(),"2") != -0x01){
		register_srvcmd(Argv1(),"FakeFunction")
		server_print("Command ^"%s^" registred in srvcmd (%s)",Argv1(),Argv2())
	}
	return PLUGIN_CONTINUE;
}
public FakeFunction(){return PLUGIN_HANDLED;}

public RegisterFakeCvar()
{
	if(!strlen(Argv1())){
		server_print("shield_fake_cvar <cvar name> <value>")
		return PLUGIN_HANDLED
	}
	server_print("Cvar ^"%s^" with value ^"%s^" registred",Argv1(),Argv2())
	register_cvar(Argv1(),Argv2())
	return PLUGIN_CONTINUE
}

public RegisterRemoveString()
{
	new boss[32]
	formatex(boss,charsmax(boss),"^n",Argv1())
	if(!strlen(Argv1()) ){
		server_print("shield_remove_string <string>")
		return PLUGIN_HANDLED
	}
	okapi_engine_replace_string(Argv1(),boss)
	server_print("String ^"%s^" has been removed",Argv1())
	return PLUGIN_CONTINUE
}

public RegisterReplaceString()
{
	if(!strlen(Argv1())){
		server_print("shield_replace_string <old string> <new string>")
		return PLUGIN_HANDLED
	}
	server_print("Replaced : ^"%s^" --> ^"%s^"",Argv1(),Argv2())
	okapi_engine_replace_string(Argv1(),Argv2())
	return PLUGIN_CONTINUE
}
public SV_ConnectionlessPacket_Hook()
{
	if(containi(Argv(),"log")!=-0x01){
		return okapi_ret_supercede
	}
	new data[net_adr],szTemp[444]
	for( new i; i < ArraySize( g_blackList ); i++ ){
		ArrayGetString( g_blackList, i, szTemp, charsmax( szTemp ) )
		if(equal(getip2, szTemp)){
			okapi_get_ptr_array(net_adrr(),data,net_adr)
			formatex(getip,charsmax(getip),"%d.%d.%d.%d",data[ip][0x00], data[ip][0x01], data[ip][0x02], data[ip][0x03])
			formatex(getip2,charsmax(getip2),"%d%d%d%d",data[ip][0x00], data[ip][0x01], data[ip][0x02], data[ip][0x03])
		}
	}
	if(containi(Argv(),"j")!=-0x01){
		set_task(1.0,"destroy_memhack")
		memhack++
		if(hola >=get_pcvar_num(LimitPrintf)){
		}
		else{
			if(memhack>3)
			{
				hola++
				set_task(0.5,"destroy_memhack")
				HLDS_Shield_func(0,0,a2ack,0,11,4)
			}
		}
	}
	set_task(2.0, "checkQuery")
	ArrayPushCell(g_aArray,str_to_num((getip2)))
	return okapi_ret_ignore
}
public checkQuery()
{
	new count = 1;
	new currentIndex = 0;
	for (new i = 1; i < ArraySize(g_aArray); i++){
		if (ArrayGetCell( g_aArray, i ) == ArrayGetCell( g_aArray, currentIndex )){
			count++;
		}
		else{
			count--;
		}
		if (count == 0){
			currentIndex = i;
			count = 1;
		}
	}
	if(count >= get_pcvar_num(LimitQuery)){
		new stringTo[15]
		num_to_str( ArrayGetCell( g_aArray, currentIndex ), stringTo, charsmax(stringTo))
		ArrayPushString( g_blackList, stringTo)
		hola++
		if(hola >=get_pcvar_num(LimitPrintf)){
		}
		else{
			HLDS_Shield_func(0,0,query,0,11,0)
		}
	}
	ArrayClear(g_aArray)
}
public Netchan_CheckForCompletion_Hook(int,int2,int3x)
{
	set_task(1.5, "destroy_fuck")
	fuck++
	if(fuck==2){
		if(int3x <= 1){
			//daca valoarea 1 se repeta de 2 ori clientul intra in void SafeFileToDownload
			//HLDS_Shield_func(0,0,overload3,0,8,4) //alta metoda nu stiu
			//return okapi_ret_supercede
		}
	}
	
	if(fuck==4){
		if(int3x == 5){ // sau SV_ParseResourceList dar am nevoie de msg_readlong
			HLDS_Shield_func(0,0,overload2,0,8,4)
			return okapi_ret_supercede
		}
	}
	if(int3x >= 107){
		hola++
		if(hola >=get_pcvar_num(LimitPrintf)){ //prea multe canale de conexiune = crash
			return okapi_ret_supercede
		}
		else{
			new id = engfunc(EngFunc_GetCurrentPlayer)+0x01
			SV_DropClient_Hook(1337,0,"drop",id)
			HLDS_Shield_func(0,0,netch,0,8,4) // entitatea id nu exista in netchan_* , deci asta inseamna sys_error
		}
		return okapi_ret_supercede
	}
	return okapi_ret_ignore
}
public SV_ProcessFile_Hook()
{
	new id = engfunc(EngFunc_GetCurrentPlayer)+0x01
	locala[id]++
	if(locala[id] >=get_pcvar_num(LimitPrintf)){
		return okapi_ret_supercede
	}
	else{
		HLDS_Shield_func(id,1,processfilex,id,1,0)
	}
	return okapi_ret_supercede
}
public COM_FileWrite_Hook()
{
	return okapi_ret_supercede
}
public SV_ParseVoiceData_Fix()
{
	hola++
	new id = engfunc(EngFunc_GetCurrentPlayer)+0x01
	new MSG_ReadShort = Add_MSG_ReadShort()
	new pampamx[200]
	new VoiceMax = 4096
	formatex(pampamx,charsmax(pampamx),"%s You are detected for %s (%d)",PrefixProtection,voicedatabug,MSG_ReadShort)
	if(hola >=get_pcvar_num(LimitPrintf)){
		if(MSG_ReadShort > VoiceMax || MSG_ReadShort < 0){
			SV_RejectConnection_user(id,pampamx)
			if(get_pcvar_num(SendBadDropClient)==1){
				SV_DropClient_Hook(1337,0,"drop",id)
			}
			HLDS_Shield_func(id,0,voicedatabug,0,0,3)
			return okapi_ret_supercede
		}
	}
	else{
		if(MSG_ReadShort > VoiceMax || MSG_ReadShort < 0){
			SV_RejectConnection_user(id,pampamx)
			if(get_pcvar_num(SendBadDropClient)==1){
				SV_DropClient_Hook(1337,0,"drop",id)
			}
			HLDS_Shield_func(id,0,voicedatabug,0,17,3)
			return okapi_ret_supercede
		}
	}
	return okapi_ret_ignore
}
public SV_ParseStringCommand_fix()
{
	new id = engfunc(EngFunc_GetCurrentPlayer)+0x01
	for (new i = 0x00; i < sizeof (CommandAllowInpfnClientConnect); i++){
		if(containi(Argv(),CommandAllowInpfnClientConnect[i]) != -0x01){
			return okapi_ret_ignore
		}
	}
	if(checkuser[id]==0){
		if(is_user_connecting(id)){
			if(get_pcvar_num(SendBadDropClient)==1){
				SV_DropClient_Hook(1337,0,"drop",id)
			}
			HLDS_Shield_func(id,0,bugclc,0,2,1)
			return okapi_ret_supercede
		}
	}
	return okapi_ret_ignore
}
public SV_ParseResourceList_Fix(){
	new id = engfunc(EngFunc_GetCurrentPlayer)+0x01
	locala[id]++
	new MSG_ReadShort = Add_MSG_ReadShort()
	new pampam[200]
	formatex(savedata,charsmax(savedata),"(resouces : %d)",MSG_ReadShort)
	formatex(pampam,charsmax(pampam),"%s You are detected for %s (%d)",PrefixProtection,overload2,MSG_ReadShort)
	if(locala[id] >=get_pcvar_num(LimitPrintf)){
		if(MSG_ReadShort>get_pcvar_num(LimitResources)){
			SV_RejectConnection_user(id,pampam)
			if(get_pcvar_num(SendBadDropClient)==1){
				SV_DropClient_Hook(1337,0,"drop",id)
			}
			HLDS_Shield_func(id,0,overload2,0,0,3)
			locala[id]=0
		}
		return okapi_ret_supercede
	}
	else{
		if(MSG_ReadShort>get_pcvar_num(LimitResources)){
			SV_RejectConnection_user(id,pampam)
			if(get_pcvar_num(SendBadDropClient)==1){
				SV_DropClient_Hook(1337,0,"drop",id)
			}
			HLDS_Shield_func(id,0,overload2,0,17,3)
			locala[id]=0
			return okapi_ret_supercede
		}
	}
	return okapi_ret_ignore
}
public NET_GetLong()
{
	hola++
	if(hola >=get_pcvar_num(LimitPrintf)){
		return okapi_ret_supercede
	}
	else{
		HLDS_Shield_func(0,0,netbug,0,11,4)
	}
	return okapi_ret_supercede;
}
public FS_Open_Hook(abc[])
{
	if(containi(abc,"!MD5")!=-0x01 || containi(abc,"..")!=-0x01 ){
		server_print("%s I found a access strange in ^"%s^"",PrefixProtection,abc)
		return okapi_ret_supercede
	}
	return okapi_ret_ignore
}
public SV_RunCmd_Hook()
{
	new id = engfunc(EngFunc_GetCurrentPlayer)+0x01
	if(id){
		if(containi(Argv(),"sendents") != -0x01){
			limit[id]++
			if(limit[id] >= get_pcvar_num(LimitImpulse)){
				locala[id]++
				if(locala[id] >=get_pcvar_num(LimitPrintf)){
					return okapi_ret_supercede
				}
				else{
					HLDS_Shield_func(id,0,cmdrun,0,1,1)
				}
			}
			return okapi_ret_supercede;
		}
	}
	return okapi_ret_ignore
}
public Info_ValueForKey_Hook()
{
	new id = engfunc(EngFunc_GetCurrentPlayer)+0x01
	new lastname[a_max]
	if(is_user_connected(id)){
		new Count=admins_num()
		new NameList[b_max],PWList[b_max],MyPW[a_max],PlayerPW[a_max]
		
		for (new i = 0x00; i < Count; ++i){	
			admins_lookup(i,AdminProp_Auth,NameList,charsmax(NameList))
			admins_lookup(i,AdminProp_Password,PWList,charsmax(PWList))
			get_cvar_string("amx_password_field",MyPW,charsmax(MyPW))
			get_user_info(id,MyPW,PlayerPW,charsmax(PlayerPW))
			if(equal(UserName(id),NameList)){
				if(!equal(PlayerPW,PWList)){
					HLDS_Shield_func(id,2,adminbug,1,1,1)
				}
			}
		}
	}
	if(is_user_admin(id)){
		if(!equal(lastname,UserName(id))){
			show_menu(id,0x00,"^n",0x01)
		}
	}
	for (new i = 0x00; i < sizeof (MessageHook); i++){
		if(containi(Argv2(),MessageHook[i]) != -0x01){
			locala[id]++
			if(locala[id] >=get_pcvar_num(LimitPrintf)){
				return okapi_ret_supercede
			}
			else{
				HLDS_Shield_func(id,1,namebug,1,5,0)
			}
			return okapi_ret_supercede;
		}
	}
	return okapi_ret_ignore
}

public Host_Say_f_Hook()
{
	for (new i = 0; i < sizeof (MessageHook); i++){
		if(containi(Args(),MessageHook[i]) != -1){
			hola++
			if(hola >=get_pcvar_num(LimitPrintf)){
				return okapi_ret_supercede
			}
			else{
				HLDS_Shield_func(0,0,cmdbug,0,10,0)
				return okapi_ret_supercede;
			}
		}
	}
	
	return okapi_ret_ignore;
}
public SV_ConnectClient_Hook()
{
	new data[net_adr],value[1024],buffer[128],getip[MAX_BUFFER_IP]
	okapi_get_ptr_array(net_adrr(),data,net_adr)
	formatex(getip,charsmax(getip),"%d.%d.%d.%d",data[ip][0x00], data[ip][0x01], data[ip][0x02], data[ip][0x03])
	read_argv(0x04,value,charsmax(value))
	BufferName(value,charsmax(value),buffer)
	
	for (new i = 0x00; i < sizeof (MessageHook); i++){
		if(containi(buffer,MessageHook[i]) != -0x01){
			replace_all(buffer,0x21,"%","^x20")
			HLDS_Shield_func(0,0,namebug,0,9,5)
		}
	}
	floodtimer++
	if(floodtimer >= get_pcvar_num(LimitSV_ConnectClient)){
		//HLDS_Shield_func(0,0,fakeplayer,0,7,3)
		floodtimer = 0x00
	}
	if((containi(buffer,"..") != -0x01 ||containi(buffer,".ú.") != -0x01) ){
		HLDS_Shield_func(0,0,hldsbug,0,8,3)
		return okapi_ret_supercede
	}
	if((containi(value,"*hltv") != -0x01)){
		HLDS_Shield_func(0,0,hltvbug,0,8,3)
		return okapi_ret_supercede
	}
	if((containi(value,"_ip") != -0x01)){
		//SV_RejectConnection_Hook(1,"Hello")
		HLDS_Shield_func(0,0,hlproxy,0,8,4)
		return okapi_ret_supercede
	}
	if(!(containi(value,"\_cl_autowepswitch\1\") != -0x01 || containi(value,"\_cl_autowepswitch\0\") != -0x01)){
		HLDS_Shield_func(0,0,fakeplayer,0,8,0)
		//return okapi_ret_supercede
	}
	return okapi_ret_ignore;
}
public SV_SendRes_f_Hook()
{
	new id = engfunc(EngFunc_GetCurrentPlayer)+0x01
	limit[id]++
	if(limit[id] >= get_pcvar_num(LimitExploit)){
		locala[id]++
		if(locala[id] >=get_pcvar_num(LimitPrintf)){
			return okapi_ret_supercede
		}
		else{
			if(!strlen(UserName(id))){
				HLDS_Shield_func(id,1,hldsres,1,3,1)
			}
			else{
				HLDS_Shield_func(id,1,hldsres,1,1,1)
			}
		}
		return okapi_ret_supercede
	}
	return okapi_ret_ignore	
}
public Con_Printf_Hook(pfnprint[])
{
	if(get_pcvar_num(SV_RconCvar)==3){
		if(containi(pfnprint,"Bad rcon_password.")!=-0x01){
			HLDS_Shield_func(0,0,hldsrcon,0,8,4)
			return okapi_ret_supercede
		}
	}
	new id = engfunc(EngFunc_GetCurrentPlayer)+0x01
	if(
	containi(pfnprint,"Info string length exceeded")!=-0x01 || 
	containi(pfnprint,"Can't set * keys")!=-0x01 || 
	containi(pfnprint,"Ignoring invalid custom decal from %s")!=-0x01 || 
	containi(pfnprint,"Non customization in upload queue!")!=-0x01 || 
	containi(pfnprint,"usage: setinfo [ <key> <value> ]")!=-0x01 || 
	containi(pfnprint,"spawn is not valid")!=-0x01 || 
	containi(pfnprint,"usage:  kick < name > | < # userid >")!=-0x01 || 
	containi(pfnprint,"Can't use keys or values with a \")!=-0x01 || 
	containi(pfnprint,"Keys and values must be < %i characters and > 0.")!=-0x01){
		new build[varmax]
		get_cvar_string("hostname",build,charsmax(build))
		locala[id]++
		if(equali(build,UserName(id))){
			return okapi_ret_ignore
		}
		else{
			if(get_pcvar_num(SendBadDropClient)==1){
				if(locala[id] ==get_pcvar_num(LimitPrintf)){
					SV_DropClient_Hook(1337,0,"drop",id)
				}
			}
			if(strlen(UserName(id))){
				HLDS_Shield_func(id,1,hldsprintf,1,5,0)
			}
			else{
				HLDS_Shield_func(0,0,hldsprintf,0,3,0)
			}
		}
		return okapi_ret_supercede
	}
	if(containi(pfnprint,"SV_ReadClientMessage: badread")!=-0x01){
		return okapi_ret_supercede
	}
	if(
	containi(pfnprint,"Invalid split packet length %i")!=-0x01 ||
	containi(pfnprint,"WARNING: reliable overflow for %s")!=-0x01 || 
	containi(pfnprint,"Split packet without all %i parts, part %i had wrong sequence %i/%i")!=-0x01||
	containi(pfnprint,"NET_GetLong:  Ignoring duplicated split packet %i of %i ( %i bytes )")!=-0x01||
	containi(pfnprint,"Malformed packet size (%i, %i)")!=-0x01||
	containi(pfnprint,"Malformed packet number (%i)")!=-0x01 ||
	containi(pfnprint,"SZ_GetSpace: overflow on %s")!=-0x01 || 
	containi(pfnprint,"NET_QueuePacket:  Oversize packet from %s")!=-0x01){
		if(hola >=get_pcvar_num(LimitPrintf)){
			return okapi_ret_supercede
		}
		hola++
		HLDS_Shield_func(0,0,netbug,0,11,0)
		return okapi_ret_supercede
	}
	return okapi_ret_ignore
}

public SV_RejectConnection_Hook(a,b[])
{
	long = OrpheuGetFunction("MSG_ReadLong")
	return OrpheuCallSuper(long)
}
stock FalseAllFunction(id)
{
	floodtimer = 0x00
	limit[id] = 0x00
	local = 0x00
	locala[id] = 0x00
	limitb[id] = 0x00
	mungelimit[id] = 0x00
}
public SV_DropClient_Hook(int,int2,string[],index)
{
	new id = engfunc(EngFunc_GetCurrentPlayer)+0x01
	checkuser[id] = 0x00
	if(int==1337){
		new call = Add_MSG_ReadLong()
		return call;
	}
	if(containi(string,"Bad file %s")!=-0x01){
		return okapi_ret_supercede
	}
	if(containi(string,"SV_ReadClientMessage: unknown command char (116)")!=-0x01){
		return okapi_ret_supercede
	}
	if(get_pcvar_num(VAC)==1){
		if(containi(string,"VAC banned from secure server")!=-0x01){
			return okapi_ret_supercede
		}
	}
	if(containi(string,"Reliable channel overflowed")!=-0x01){
		locala[id]++
		if(locala[id] >=get_pcvar_num(LimitPrintf)){
			return okapi_ret_supercede
		}
		else{
			if(!strlen(UserName(id))){
				HLDS_Shield_func(id,1,hldsoverflowed,1,3,1)
			}
			else{
				HLDS_Shield_func(id,1,hldsoverflowed,1,1,0)
			}
		}
		return okapi_ret_supercede
	}
	FalseAllFunction(id)
	return okapi_ret_ignore
}
public PfnClientDisconnect(id){
	usercheck[id]=0x00
	FalseAllFunction(id)
}
public SV_Spawn_f_Hook()
{
	new id = engfunc(EngFunc_GetCurrentPlayer)+0x01
	limit[id]++
	if(limit[id] >=get_pcvar_num(LimitExploit))
	{
		locala[id]++
		if(locala[id] >=get_pcvar_num(LimitPrintf)){
			return okapi_ret_supercede
		}
		else{
			if(!strlen(UserName(id))){
				HLDS_Shield_func(id,1,hldspawn,1,3,1)
			}
			else{
				HLDS_Shield_func(id,2,hldspawn,1,1,1)
			}
		}
		return okapi_ret_supercede
	}
	return okapi_ret_ignore	
}
