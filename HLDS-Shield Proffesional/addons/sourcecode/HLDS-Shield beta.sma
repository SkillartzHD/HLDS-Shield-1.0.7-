/////////////////////////////Compatibility LINUX///////////////////////////
//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*
#define ReverseHLDS_Compatibility 0 // HLDS
//Value : 1 is only ReHLDS linux compatibility OKAPI functions
//Value : 0 (default) is only HLDS linux compatibility OKAPI functions
//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*//*
/////////////////////////////Compatibility LINUX///////////////////////////

#if defined PrefixProtection
#else
#define PrefixProtection "[HLDS-Shield]"
#include <HLDS_Shield_function.hlds>
#endif

/*
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

public plugin_init(){
	Register()
	Register_Settings()
	if(get_pcvar_num(OS_System)>EOS){
		RegisterOS_System()
	}
}
public plugin_precache(){
	is_server_compatibility()
	RegisterCvars()
	Hooks_init()
	Load_Settings()
}
public Hooks_init(){
	
	Registerforward()
	
	if(is_linux_server()){
		RegisterOkapiLinux()
	}
	else{
		if(ServerVersion == EOS){
			RegisterOkapiWindows()
		}
	}
	set_task(1.0,"RegisterOrpheu")
	set_task(2.0,"SV_PrintableInformation")
}

public RegisterOS_System(){
	//API _OS_Ban
	
	#define CommandNameExecute "amx_os_ban" // for shield_os_ban detect
	
	register_concmd("amx_os_unban","_OS_SendUnBan",ADMIN_BAN)
	register_concmd(CommandNameExecute,"CL_ProfileBan_RealTime",ADMIN_BAN)
	register_concmd("amx_os_addban","CL_ProfileBan_WriteBan",ADMIN_BAN)
	register_concmd("amx_os_ban2","CL_ProfileBan",ADMIN_BAN)
	//API _OS_Ban
	
	register_message(get_user_msgid("MOTD"),"CL_MotdMessage")
	
	_OS_MainSettings()
	_OS_CreateEmptyFile()
	
	if(file_exists(MainConfigfile)){
		server_cmd("exec ^"%s^"",MainConfigfile)
	}
	else{
		log_to_file(LogOSExecuted,"%s: I don't found file ^"%s^"",prefixos,MainConfigfile)
	}
	
	set_task(0.1,"SV_ExecuteMainConfig")
}

public Registerforward(){
	
	register_forward(FM_ClientConnect,"pfnClientConnect")
	register_forward(FM_ClientUserInfoChanged,"pfnClientUserInfoChanged")
	register_forward(FM_GetGameDescription,"pfnGetGameDescription") 
	register_forward(FM_ClientCommand,"PfnClientCommand")
	register_forward(FM_ClientDisconnect,"PfnClientDisconnect")
	register_forward(FM_ClientPutInServer,"PfnClientPutInServer")
	register_forward(FM_Sys_Error,"pfnSys_Error")
	register_forward(FM_GameShutdown,"pfnSys_Error")
	
}
public RegisterCvars(){
	GameData=register_cvar("shield_gamedata","HLDS-Shield 1.0.7")
	KillBug=register_cvar("shield_kill_crash","1")
	NameBugShowMenu = register_cvar("shield_namebug_showmenu","1")
	SpectatorVguiBug = register_cvar("shield_vgui_specbug","1")
	Radio = register_cvar("shield_radio","1")
	CommandBug=register_cvar("shield_cmdbug","1")
	IlegalCmd=register_cvar("shield_ilegalcmd","1")
	NameBug=register_cvar("shield_name_bug_on_server","1")
	NameSpammer=register_cvar("shield_name_spammer","1")
	RandomSteamid=register_cvar("shield_steamid_hack","1")
	DuplicateSteamid=register_cvar("shield_steamid_duplicate","1")
	BanTime=register_cvar("shield_bantime","1")
	UnicodeName = register_cvar("shield_unicode_name_filter","1")
	CmdLimitVar = register_cvar("shield_commandlimit_filter","1")
	CmdlimitDestroy = register_cvar("shield_commandlimit_destory_file","240")
	CmdLimitMax = register_cvar("shield_commandlimit_execute","5")
	TimeNameChange = register_cvar("shield_namechange_delay_seconds","5")
	NameCharFix = register_cvar("shield_name_char_fix","1") // 1 replaced with utf8 char , 2 replaced with * for old build
	ChatCharFix = register_cvar("shield_chat_char_fix","1") // 1 replaced with utf8 char , 2 replaced with * for old build
	AgresiveFunction = register_cvar("shield_ban_violation_function","0")
	NoFlood = register_cvar("shield_noflood","1")
	NoFloodTime = register_cvar("shield_noflood_time","0.75")
	CvarAutoBuyBug = register_cvar("shield_autobuybug","1")
	
	// OS_Ban
	OS_System = register_cvar("shield_os_system","1")
	CvarTableName = register_cvar("shield_os_username","SkillartzHD_PublicBan_List")
	CvarAdministratorServer = register_cvar("shield_os_contact","WwW.AlphaCS.Ro")
	CvarFindCvarBuffer = register_cvar("shield_os_userinfo_restrict_value","3958")
	CvarCreateBuffer = register_cvar("shield_os_userinfo_restrict_name","513")
	CvarVpnDetector = register_cvar("shield_vpn_detector","1")
	CvarVpnDetectorKey = register_cvar("shield_vpn_detector_key","70968l-0233p8-6115a0-92173c")
	CvarOSBanIPAddress = register_cvar("shield_os_ban_address","5")
	OSBanDetectedTime = register_cvar("shield_os_detected_bantime","1")
	// OS_Ban
	
	OptionSV_ConnectClient = register_cvar("shield_sv_connectclient_filter_option","1") // 1 - force return 2 - kick 3 - ban
	steamidgenerate=register_cvar("shield_steamid_generate_ip","1")
	steamidhash=register_cvar("shield_steamid_hash","1")
	RconSkippingCommand=register_cvar("shield_rcon_skipping_command","1")
	SV_RconCvar=register_cvar("shield_sv_rcon","1")
	ShutdownServer = register_cvar("shield_lost_connection","0") // warning but is 1 plugin returned host_servershutdown but is possbily not work correctly server
	LostConnectionSeconds = register_cvar("shield_lost_connection_seconds","15")
	DumpConnector = register_cvar("shield_dump_sv_connectclient","0")
	HLProxyFilter = register_cvar("shield_hlproxy_allow_server","1")
	HLTVFilter = register_cvar("shield_hltv_allow_server","1")
	FakePlayerFilter = register_cvar("shield_fakeplayer_filter","1")
	PrintErrorSysError = register_cvar("shield_syserror_print","1")
	UpdateClient = register_cvar("shield_update_vgui_client","1")
	NameProtector=register_cvar("shield_name_protector_sv_connect ","1")
	Queryviewer=register_cvar("shield_query_log","0")
	VAC=register_cvar("shield_vac","1")
	MaxOverflowed=register_cvar("shield_max_overflowed","1000")
	PrintUnMunge=register_cvar("shield_printf_decrypt_munge","0")
	PrintUnknown=register_cvar("shield_printf_offset_command","0")
	ParseConsistencyResponse=register_cvar("shield_parseConsistencyResponse","1")
	SendBadDropClient=register_cvar("shield_dropclient","1")
	LimitPrintf=register_cvar("shield_printf_limit","5")
	LimitQuery=register_cvar("shield_query_limit","80")
	LimitMunge=register_cvar("shield_munge_comamnd_limit","30")
	LimitExploit=register_cvar("shield_exploit_cmd_limit","5")
	LimitImpulse=register_cvar("shield_sv_runcmd_limit","100")
	LimitResources=register_cvar("shield_sv_parseresource_limit","1")
	PauseDlfile=register_cvar("shield_dlfile_pause","1")
	LimitPrintfRcon=register_cvar("shield_rcon_limit","10")
	
	if(ServerVersion == EOS){
		register_srvcmd("shield_remove_function","RegisterRemoveFunction")
	}
	register_srvcmd("shield_replace_string","RegisterReplaceString")
	register_srvcmd("shield_remove_string","RegisterRemoveString")
	register_srvcmd("shield_fake_cvar","RegisterFakeCvar")
	register_srvcmd("shield_addcmd_fake","RegisterCmdFake")
	register_srvcmd("shield_reload","Register_Settings")
	register_srvcmd("shield_drop","CL_CreateReject")
	register_srvcmd("shield_final","CL_CreateFinal")
	
	register_clcmd("usersid","SV_UsersID")
}

public Load_Settings(){
	new szError[64],iError;
	
	g_MaxClients = get_global_int(GL_maxClients)
	g_iPattern = regex_compile("[+]",iError,szError,charsmax(szError),"i")
	valutsteamid = nvault_open("SteamHackDetector")
	g_aArray = ArrayCreate(1) 
	g_blackList = ArrayCreate(15)
	set_task(600.0,"Destroy_Memory",_,"",_,"b",_)
	server_cmd("mp_consistency 1")
	ReadFileCheck(locatie)
	new getlimit = get_pcvar_num(CmdlimitDestroy)
	set_task(float(getlimit),"Destroy_Fileiplist",_,"",_,"b",_)
	
	if(get_pcvar_num(SV_RconCvar)==2){
		RconRandom()
	}
}

public SV_ForceFullClientsUpdate_api(index){
	SV_ForceFullClientsUpdate()
}

public SV_ExecuteMainConfig(){
	new varget[100],key[50]
	get_pcvar_string(CvarTableName,varget,charsmax(varget))
	get_pcvar_string(CvarVpnDetectorKey,key,charsmax(key))
	log_to_file(LogOSExecuted,"%s: CookieBan account: ^"User_%s^"",prefixos,varget)
	log_to_file(LogOSExecuted,"%s: VPNDetectorKey: ^"%s^"",prefixos,key)
	
}
public CL_MotdMessage(msgid,dest,id){
	new AddressHLDS[32],varget[100]
	get_cvar_string("net_address",AddressHLDS,charsmax(AddressHLDS))
	get_pcvar_string(CvarTableName,varget,charsmax(varget))
	replace_all(AddressHLDS,charsmax(AddressHLDS),".","+")
	replace_all(AddressHLDS,charsmax(AddressHLDS),":","+")
	formatex(stringbuffer2,charsmax(stringbuffer2),"%s/checkplayer.php?usertabel=%s&userserver=%s",urlcache,varget,AddressHLDS)
	show_motd(id,stringbuffer2)
}
public _OS_CreateEmptyFile(){
	if(!file_exists("motd.txt")){
		new MotdConfig = fopen("motd.txt","wb")
		fprintf(MotdConfig,"www.google.ro^x20")
		fclose(MotdConfig)
	}
}
public SV_UsersID(id){
	new players[a_max], num, tempid;
	get_players(players, num)
	for (new i=0; i<num; i++){
		tempid = players[i]
		new stringbuffer[255]
		formatex(stringbuffer,charsmax(stringbuffer),"|User : %s - #%d|^n",UserName(tempid),get_user_userid(tempid))
		SVC_PrintConsole(id,stringbuffer)
	}
	return PLUGIN_HANDLED
}
public client_authorized(id){
	
	if(get_pcvar_num(RandomSteamid)>EOS){
		Shield_CheckSteamID(id,1)
	}
	if(get_pcvar_num(DuplicateSteamid)>EOS){
		SV_CheckForDuplicateSteamID(id)
	}
}
public isCheckUserBanned(id){
	new stringurl[255]
	formatex(stringurl,charsmax(stringurl),"%s/%s",urlcache,CacheWebsite)
	HTTP_DownloadFile(stringurl,CacheFile)
	set_task(1.0,"_OS_DetectedUser",id)
}
public UTIL_ClientPrint_Hook(string,string2,stringmsg[]){
	VoidFunction(stringmsg,1)
}

public PF_WriteString_I_Hook(stringmsg[]){
	VoidFunction(stringmsg,2)
}
public ProtectAllPluginsChatReplaced(){
	if(strlen(Argv1())>=150){
		return 1; // fix possible crash in replace with unicode char for all plugins tags/replace chat
	}
	return 0
}
public UserImpulseFalse(id){
	UserCheckImpulse[id] = EOS
}
public pfnClientConnect(id){
	usercheck[id]=1
	DelaySpamBotStop[id] = get_gametime() + 5.0;
	DelaySpamBotStart[id] = 0.0
	FalseAllFunction(id)
	Info_ValueForKey_Hook(id)
	
	if(get_pcvar_num(OS_System)>EOS){
		new getipban[32],getsteam[32],getfileorg[255],getfileorgsteamid[255],szfile1[64],len
		new stringbuffer[255]
		get_user_ip(id,getipban,charsmax(getipban),1)
		get_user_authid(id,getsteam,charsmax(getsteam))
		
		replace_all(getipban,charsmax(getipban),".","_")
		new varget[50]
		get_pcvar_string(CvarTableName,varget,charsmax(varget))
		
		formatex(getfileorg,charsmax(getfileorg),"addons/amxmodx/configs/settings/OS_Ban/User_%s/%s.txt",varget,getipban)
		formatex(getfileorgsteamid,charsmax(getfileorgsteamid),"addons/amxmodx/configs/settings/OS_Ban/User_%s/%s.txt",varget,getsteam)
		
		if(file_exists(getfileorg)){
			read_file(getfileorg,EOS,szfile1,charsmax(szfile1),len)
		}
		Send_CalculationsTimeBan(EOS,1,getfileorg)
		
		new IntFileNumber = abs(str_to_num(szfile1)) // to int
		new RealClock = str_to_num(GetTimeReal) // to int
		
		if(RealClock<=IntFileNumber){
			formatex(stringbuffer,charsmax(stringbuffer),"^n%s Expire Data : ^"%d^"^n",prefixos,IntFileNumber)
			SVC_PrintConsole(id,stringbuffer)
			PlayerDisconnect(id)
			set_task(1.0,"ProtectPlayerDontExistSVC",id)
		}
		else{
			if(file_exists(getfileorg)){
				unlink(getfileorg)
			}
		}
		CheckOS_SteamID(id)
		if(get_pcvar_num(CvarVpnDetector)>EOS){
			if(is_user_bot(id) || is_user_hltv(id)) {
				return
			}
			else{
				if(containi(PlayerIP(id),"127.0.0.1") != -0x01){
					log_to_file(LogFileOS,"%s Address ^"%s^" is localhost",prefixos,PlayerIP(id))
					return
				}
				set_task(1.0,"_OS_VPNChecker",id)
				set_task(2.0,"_OS_VpnDetected",id)
			}
		}
	}
	
	if(ServerVersion == 1){ // rehlds
		if(get_pcvar_num(NameProtector)>EOS){
			for (new i = EOS; i < sizeof (MessageHook); i++){
				if(containi(UserName(id),MessageHook[i]) != -0x01){
					HLDS_Shield_func(EOS,EOS,namebug,EOS,9,1)
					SV_RejectConnection_user(id,"Rejected")
				}
			}
		}
	}
	set_task(1.0,"UserImpulseFalse",id)
	
}
public CheckOS_SteamID(index){
	new getsteam[32],getfileorgsteamid[255],szfile2[64],len
	
	get_user_authid(index,getsteam,charsmax(getsteam))
	
	replace_all(getsteam,charsmax(getsteam),":","_")
	new varget[50]
	get_pcvar_string(CvarTableName,varget,charsmax(varget))
	formatex(getfileorgsteamid,charsmax(getfileorgsteamid),"addons/amxmodx/configs/settings/OS_Ban/User_%s/%s.txt",varget,getsteam)
	
	if(file_exists(getfileorgsteamid)){
		read_file(getfileorgsteamid,EOS,szfile2,charsmax(szfile2),len)
	}
	
	Send_CalculationsTimeBan(EOS,1,getfileorgsteamid)
	
	new IntFileNumberSteamID = abs(str_to_num(szfile2)) // to int
	new RealClock = str_to_num(GetTimeReal) // to int
	
	if(RealClock<=IntFileNumberSteamID){
		new stringbuffer[255]
		formatex(stringbuffer,charsmax(stringbuffer),"^n%s Expire Data : ^"%d^"^n",prefixos,IntFileNumberSteamID)
		SVC_PrintConsole(index,stringbuffer)
		PlayerDisconnect(index)
		set_task(1.0,"ProtectPlayerDontExistSVC",index)
	}
	else{
		if(file_exists(getfileorgsteamid)){
			unlink(getfileorgsteamid)
		}
	}
}
new CheckOS = EOS
public RegisterOrpheu(){
	if(ServerVersion == EOS){
		RegisterFixChars()
		if(file_exists(orpheufile8)){
			global_msgReadBits = OrpheuGetFunction("MSG_ReadBits")
		}
		else{
			log_to_file(settings,"%s Injected successfully %s",PrefixProtection,orpheufile8)
			Create_Signature("MSG_ReadBits")
			set_task(1.0,"debug_orpheu")
		}
		if(file_exists(orpheufile9)){
			OrpheuRegisterHook(OrpheuGetFunction("SV_ParseConsistencyResponse"), "SV_ParseConsistencyResponse_fix", OrpheuHookPre)
			memory2++
		}
		else{
			log_to_file(settings,"%s Injected successfully %s",PrefixProtection,orpheufile9)
			Create_Signature("SV_ParseConsistencyResponse")
			set_task(1.0,"debug_orpheu")
		}
		if(!file_exists(orpheufile5)){
			log_to_file(settings,"%s Injected successfully %s",PrefixProtection,orpheufile5)
			Create_Signature("SV_ForceFullClientsUpdate")
			set_task(1.0,"debug_orpheu")
		}
		else{
			memory2++
		}
		if(!file_exists(orpheufile4)){
			log_to_file(settings,"%s Injected successfully %s",PrefixProtection,orpheufile4)
			Create_Signature("SV_Drop_f")
			set_task(1.0,"debug_orpheu")
		}
		else{
			memory2++
		}
		if(!file_exists(orpheufile2)){
			log_to_file(settings,"%s Injected successfully %s",PrefixProtection,orpheufile2)
			Create_Signature("MSG_ReadShort")
			set_task(1.0,"debug_orpheu")
		}
		else{
			memory2++
		}
		if(!file_exists(orpheufile3)){
			log_to_file(settings,"%s Injected successfully %s",PrefixProtection,orpheufile3)
			Create_Signature("MSG_ReadLong")
			set_task(1.0,"debug_orpheu")
		}
		else{
			memory2++
		}
		if(file_exists(orpheufile1)){
			executestringhook = OrpheuRegisterHook(OrpheuGetFunction("Cmd_ExecuteString"),"Cmd_ExecuteString_Fix")
			memory2++
		}
		else{
			log_to_file(settings,"%s Injected successfully %s",PrefixProtection,orpheufile1)
			Create_Signature("Cmd_ExecuteString")
			set_task(1.0,"debug_orpheu")
		}
		
		if(file_exists(orpheufile7)){
			new getcvar[a_max]
			if(get_cvar_string("dp_version",getcvar,charsmax(getcvar))){
				log_to_file(settings,"%s Function SteamIDHash dont work with dproto %s",PrefixProtection,getcvar)
			}
			else{
				set_task(5.0,"delay_install")
				memory2++
			}
		}
		else{
			log_to_file(settings,"%s Injected successfully %s",PrefixProtection,orpheufile7)
			Create_Signature("SV_GetIDString")
			set_task(1.0,"debug_orpheu")
		}
	}
	
}

public SV_PrintableInformation(){
	if(is_linux_server()){
		log_to_file(settings,"^n%s I loaded plugin with %d functions hooked in hlds [linux]^n",PrefixProtection,memory2)
	}
	else{
		log_to_file(settings,"^n%s I loaded plugin with %d functions hooked in hlds [windows]^n",PrefixProtection,memory2)
	}
	new AMXXVersion[a_max],RCONName[a_max],ServerInfo[a_max],Metamodinfo[a_max],get[a_max],DPName[a_max]
	
	get_amxx_verstring(AMXXVersion,charsmax(AMXXVersion))
	get_cvar_string("rcon_password",RCONName,charsmax(RCONName))
	get_cvar_string("dp_version",DPName,charsmax(DPName))
	get_cvar_string("sv_version",ServerInfo,charsmax(ServerInfo))
	get_cvar_string("metamod_version",Metamodinfo,charsmax(Metamodinfo))
	get_plugin(-1,get,charsmax(get))
	
	server_print("-------------------------------------------------------------------------")
	server_print("%s Amxx : %s",PrefixProtection,AMXXVersion)
	server_print("%s Plugin : %s",PrefixProtection,get)
	if(!strlen(RCONName)){	
		server_print("%s Rcon : No password set",PrefixProtection)
	}
	else{
		server_print("%s Rcon : %s",PrefixProtection,RCONName)	
	}
	if(strlen(DPName)){
		server_print("%s DProto : %s",PrefixProtection,DPName)	
	}
	if(!is_linux_server()){
		server_print("%s Engine : %s",PrefixProtection,ServerInfo[11])
	}
	else{
		server_print("%s Engine : %s",PrefixProtection,ServerInfo[17])
	}
	server_print("%s MetaMod : %s",PrefixProtection,Metamodinfo)
	SV_UpTime(1)
	server_print("--------------------------------------------------------------------------")
}
public RegisterFixChars(){
	
	register_message(get_user_msgid("SayText"),"ProtectAllPluginsChatReplaced")
	
	if(CheckOS== EOS){
		if(is_linux_server()){
			CheckOS = 2 // linux
		}
		else{
			CheckOS = 1 // windows
		}
	}
	
	if(CheckOS==1){
		if(!file_exists("addons/amxmodx/configs/orpheu/functions/UTIL_ClientPrint")){
			Create_Signature("UTIL_ClientPrint")
			set_task(1.0,"debug_orpheu")
		}
		else{
			new build[varmax]
			get_cvar_string("sv_version",build,charsmax(build))
			if(!equali(build,"1.1.2.6,48,4554")){
				OrpheuRegisterHook(OrpheuGetFunction("UTIL_ClientPrint"),"UTIL_ClientPrint_Hook")
				memory2++
			}
			else{
				log_to_file(settings,"%s Function ^"UTIL_ClientPrint^" not supported for your engine (is very old)",PrefixProtection)
			}
		}
	}
	
	if(CheckOS==2){
		if(!file_exists("addons/amxmodx/configs/orpheu/functions/PF_WriteString_I")){
			Create_Signature("PF_WriteString_I")
			set_task(1.0,"debug_orpheu")
		}
		else{
			OrpheuRegisterHook(OrpheuGetFunction("PF_WriteString_I"),"PF_WriteString_I_Hook")
			memory2++
		}
	}
}
public delay_install(){
	getidstringhook = OrpheuRegisterHook(OrpheuGetFunction("SV_GetIDString"),"SV_GetIDString_Hook",OrpheuHookPost)
}

public Cmd_ExecuteString_Fix()
{
	//all commands is blocked sended by sv_rcon
	if(get_pcvar_num(RconSkippingCommand)>EOS){
		if(cmpStr3(Argv3())){
			log_to_file(settings,"%s Cmd_ExecuetString : blocked this command ^"%s^"",PrefixProtection,Argv3())
			return okapi_ret_supercede
		}
	}
	if(get_pcvar_num(SV_RconCvar)==2){
		RconRandom()
	}
	if(is_linux_server()){
		if(containi(Argv3(),"say")!=-0x01 || containi(Argv3(),"say_team")!=-0x01){ 
			return okapi_ret_ignore
		}
		else{
			server_cmd("%s %s",Argv3(),Argv4())
		}
		
	}
	if(containi(Argv(),"dlfile")!=-0x01){
		return okapi_ret_ignore
	}
	else{
		new id = engfunc(EngFunc_GetCurrentPlayer)+0x01
		if(id){
			if(get_pcvar_num(PrintUnknown)>EOS){
				PrintUnknown_function(id)
			}
			mungelimit[id]++
			if(!task_exists(0x01)){
				set_task(0.1,"LevFunction",id+TASK_ONE)
			}
			if(mungelimit[id] >= get_pcvar_num(LimitMunge)){
				mungelimit[id] = EOS
				local++
				if(local >=get_pcvar_num(LimitPrintf)){
					return okapi_ret_ignore
				}
				else{
					if(is_user_connected(id)){
						HLDS_Shield_func(id,1,suspicious,1,16,1)
						if(get_pcvar_num(SendBadDropClient)>EOS){
							SV_Drop_function(id)
						}
					}
					return okapi_ret_supercede
				}
			}
		}
		else{
			if(get_pcvar_num(PrintUnknown)>EOS){
				PrintUnknown_function(id)
			}
		}
	}
	return okapi_ret_ignore
}

public plugin_cfg(){
	set_task(2.0,"RegisterConfigPlugin")
}
public _OS_VPNChecker(id){
	new CheckVPN[255],CookieFile[20],key[100]
	get_pcvar_string(CvarVpnDetectorKey,key,charsmax(key))
	formatex(CookieFile,charsmax(CookieFile),"addons/amxmodx/configs/settings/OS_Ban/vpn_detector/%s_stored",PlayerIP(id))
	
	if(get_pcvar_num(CvarVpnDetectorKey)>-1){ // free license
		formatex(CheckVPN,charsmax(CheckVPN),"%s/vpndetectorfree.php?address=%s&key=%s",urlcache,PlayerIP(id),key)
	}
	else{
		formatex(CheckVPN,charsmax(CheckVPN),"%s/vpndetector.php?address=%s&key=%s",urlcache,PlayerIP(id),key)
	}
	
	replace_all(CookieFile,charsmax(CookieFile),".","_")
	HTTP_DownloadFile(CheckVPN,CookieFile)
}
public HTTP_Download( const szFile[] , iDownloadID , iBytesRecv , iFileSize , bool:TransferComplete ) { 
	if(TransferComplete) { 
		server_print("%s: DEBUG_%x.",prefixos,iFileSize)
		CheckVPN = iFileSize
		checkusor = iFileSize
	} 
}
public _OS_VpnDetected(id){
	if(get_pcvar_num(CvarVpnDetector)>EOS){
		new CookieFile[90],CookieFile2[90]
		formatex(CookieFile,charsmax(CookieFile),"addons/amxmodx/configs/settings/OS_Ban/vpn_detector/%s_stored",PlayerIP(id))
		formatex(CookieFile2,charsmax(CookieFile2),"addons/amxmodx/configs/settings/OS_Ban/vpn_detector/%s",PlayerIP(id))
		
		replace_all(CookieFile,charsmax(CookieFile),".","_")
		replace_all(CookieFile2,charsmax(CookieFile2),".","_")
		
		new FileRestricted = file_exists(CookieFile)
		new FileIdIP =file_exists(CookieFile2)
		
		if(!FileIdIP){
			new MotdConfig = fopen(CookieFile2,"wb")
			fprintf(MotdConfig,"^x20")
			fclose(MotdConfig)
		}
		if(FileIdIP == FileRestricted){
			if(CheckVPN==3){
				PlayerGetPackets(id,2,EOS)
				PlayerGetPackets(id,1,EOS)
			}
			else{
				unlink(CookieFile)
				unlink(CookieFile2)
			}
		}
	}
}
public _OS_DetectedUser(id){
	if(checkusor==1){
		if(get_pcvar_num(OSBanDetectedTime)>=0){
			server_cmd("shield_ban %s ProtectOS_UserHaveBanned 1",UserName(id),get_pcvar_num(OSBanDetectedTime))
		}
		PlayerGetPackets(id,1,EOS)
		unlink(CacheFile)
	}
	else{
		if(get_pcvar_num(CvarFindCvarBuffer)==-1 && get_pcvar_num(CvarCreateBuffer)==-1){
			return 1
		}
		else{
			new varget[100],userinfo[50],varget4[50]
			get_pcvar_string(CvarCreateBuffer,varget4,charsmax(varget4))
			get_pcvar_string(CvarFindCvarBuffer,varget,charsmax(varget))
			
			get_user_info(id,varget4,userinfo,charsmax(userinfo))
			
			if(containi(userinfo,varget) != -0x01){
				if(get_pcvar_num(OSBanDetectedTime)>=0){
					server_cmd("shield_ban %s ProtectOS_UserHaveBanned 1",UserName(id),get_pcvar_num(OSBanDetectedTime))
				}
				PlayerGetPackets(id,1,EOS)
			}
		}
	}
	return 0
}
public CL_CreateFinal(){
	new id = engfunc(EngFunc_GetCurrentPlayer)+0x01
	
	new FirstArg[32],SecondArg[32]
	
	read_argv(1,FirstArg,sizeof(FirstArg) -1)
	read_argv(2,SecondArg,sizeof(SecondArg) -1)
	
	new player = cmd_target(id,FirstArg,(CMDTARGET_NO_BOTS))
	
	if(equal(FirstArg,"") || equal(SecondArg,"")){
		console_print(id,"%s: %s <name> <message>",PrefixProtection,Argv())
		return PLUGIN_HANDLED
	}
	if(!player){
		console_print(id,"%s: %s i don't found userid/name",PrefixProtection,Argv())
		return PLUGIN_HANDLED
	}
	CL_Final(player,SecondArg)
	
	return PLUGIN_HANDLED
}
public CL_CreateReject(){
	new id = engfunc(EngFunc_GetCurrentPlayer)+0x01
	
	new FirstArg[32],SecondArg[32]
	
	read_argv(1,FirstArg,sizeof(FirstArg) -1)
	read_argv(2,SecondArg,sizeof(SecondArg) -1)
	
	new player = cmd_target(id,FirstArg,(CMDTARGET_NO_BOTS))
	
	if(equal(FirstArg,"") || equal(SecondArg,"")){
		console_print(id,"%s: %s <name> <message>",PrefixProtection,Argv())
		return PLUGIN_HANDLED
	}
	if(!player){
		console_print(id,"%s: %s i don't found userid/name",PrefixProtection,Argv())
		return PLUGIN_HANDLED
	}
	SV_RejectConnection_user(player,SecondArg)
	
	return PLUGIN_CONTINUE
}
public _OS_SendUnBan(id,level,cid){
	if(get_pcvar_num(OS_System)>EOS){
		if (!cmd_access(id, level, cid, 1)){
			return PLUGIN_HANDLED
		}
		if(equal(Argv1(),"")){
			console_print(id,"%s: %s <ip/steamid>",prefixos,Argv())
		}
		if(strlen(Argv1())>130){
			return PLUGIN_HANDLED
		}
		new banid[70],getfileorg[255]
		read_argv(1,banid,charsmax(banid))
		
		replace_all(banid,charsmax(banid),".","_")
		replace_all(banid,charsmax(banid),":","_")
		new varget[50]
		get_pcvar_string(CvarTableName,varget,charsmax(varget))
		formatex(getfileorg,charsmax(getfileorg),"addons/amxmodx/configs/settings/OS_Ban/User_%s/%s.txt",varget,banid)
		
		if(file_exists(getfileorg)){
			unlink(getfileorg)
			client_print_color(EOS,EOS,"^4%s^1 Admin : ^4^"%s^"^1 successfully unbanned address ^4^"%s^"^1",
			prefixos,UserName(id),Argv1())
			console_print(id,"%s: I successfully unbanned address ^"%s^"",prefixos,banid)
		}
		else{
			console_print(id,"%s: This address ^"%s^" no't exist in banlist",prefixos,banid)
		}
	}
	return PLUGIN_HANDLED
}

public CL_ProfileBan_WriteBan(id,level,cid){
	new reason[32],FirstArg[32],SecondArg[32],StringArg[100],seconds
	
	if (!cmd_access(id, level, cid, 1)){
		return PLUGIN_HANDLED
	}
	read_argv(1,FirstArg,sizeof(FirstArg)-1)
	read_argv(2,SecondArg,sizeof(SecondArg)-1)
	read_argv(3,StringArg,sizeof(StringArg)-1)
	
	if(equal(FirstArg,"") || equal(SecondArg,"") || equal(StringArg,"")){
		console_print(id,"%s: %s <steamid/ip> <reason> <minutes>",prefixos,Argv())
		return PLUGIN_HANDLED
	}
	if(is_str_num(StringArg)){
		if(equal(StringArg,"-")){
			console_print(id,"%s: %s invalid argument",prefixos,Argv())
		}
		else{
			if(equal(StringArg,"0")){
				seconds = 9999999
				ConvertorInt(seconds)
			}
			else{
				seconds = abs(str_to_num(StringArg))
				ConvertorInt(seconds)
			}
		}
	}
	else{
		console_print(id,"%s: %s argument 3 is only numbers!",prefixos,Argv())
		return PLUGIN_HANDLED
	}	
	read_argv(2,reason,charsmax(reason))
	remove_quotes(reason)
	client_print_color(EOS,EOS,"^1 %s Admin : ^4^"%s^"^1 executed ^4^"%s^"^1",prefixos,UserName(id),Argv())
	client_print_color(EOS,EOS,"^1 %s Address: ^4^"%s^"^1 / ^1Reason :^4^"%s^"^1",prefixos,FirstArg,SecondArg)
	client_print_color(EOS,EOS,"^1 %s ID : ^4Simple Ban^1",prefixos)
	_OS_SendBanSteamID(EOS,1)
	return PLUGIN_HANDLED
}
public CL_ProfileBan_RealTime(id,level,cid){
	
	if(get_pcvar_num(OS_System)>EOS){
		if (!cmd_access(id, level, cid, 1)){
			return PLUGIN_HANDLED
		}
		new reason[32],FirstArg[32],SecondArg[32],StringArg[100],seconds
		
		read_argv(1,FirstArg,sizeof(FirstArg) -1)
		read_argv(2,SecondArg,sizeof(SecondArg) -1)
		read_argv(3,StringArg,sizeof(StringArg) -1)
		
		new player = cmd_target(id, FirstArg, CMDTARGET_OBEY_IMMUNITY | CMDTARGET_NO_BOTS | CMDTARGET_ALLOW_SELF)
		
		if(equal(FirstArg,"") || equal(SecondArg,"") || equal(StringArg,"")){
			console_print(id,"%s: %s <name> <reason> <minutes>",prefixos,Argv())
			return PLUGIN_HANDLED
		}
		if(!player || !is_user_connected(player)){
			console_print(id,"%s: %s i don't found userid/name",prefixos,Argv())
			return PLUGIN_HANDLED
		}
		if(is_str_num(StringArg)){
			if(equal(StringArg,"-")){
				console_print(id,"%s: %s invalid argument",prefixos,Argv())
			}
			else{
				if(equal(StringArg,"0")){
					seconds = 99999999
					ConvertorInt(seconds)
				}
				else{
					seconds = abs(str_to_num(StringArg))
					ConvertorInt(seconds)
				}
			}
		}
		else{
			console_print(id,"%s: %s argument 3 is only numbers!",prefixos,Argv())
			return PLUGIN_HANDLED
		}	
		read_argv(2,reason,charsmax(reason))
		remove_quotes(reason)
		
		_OS_SendBanIP(player)
		_OS_SendBanSteamID(player,EOS)
		replace_all(convertortime,charsmax(convertortime),"s","minutes")
		client_cmd(player,"spk doop")
		client_print_color(EOS,EOS,"^1 %s Admin : ^4^"%s^"^1 executed ^4^"%s^"^1 on User : ^4^"%s^"^1",prefixos,UserName(id),Argv(),UserName(player))
		client_print_color(EOS,EOS,"^1 %s Address: ^4^"%s^"^1 / SteamID: ^4^"%s^"^1",prefixos,PlayerIP(player),BufferSteamID(player))
		client_print_color(EOS,EOS,"^1 %s Reason :^4^"%s^"^1 / Time : ^4^"%s^"^1",prefixos,SecondArg,convertortime)
		client_print_color(EOS,EOS,"^1 %s ID : ^4Simple Ban^1",prefixos)
		
		log_to_file(LogOSExecuted,"----------------------------------------------------------------------")
		log_to_file(LogOSExecuted,"%s UserName: ^"%s^"",prefixos,UserName(player),PlayerIP(player))
		log_to_file(LogOSExecuted,"%s PlayerIP: ^"%s^"",prefixos,PlayerIP(player))
		log_to_file(LogOSExecuted,"%s SteamID:  ^"%s^"",prefixos,BufferSteamID(player))
		log_to_file(LogOSExecuted,"%s Reason:  ^"%s^"",prefixos,SecondArg)
		log_to_file(LogOSExecuted,"%s Time:  ^"%s^"",prefixos,convertortime)
		
		set_task(3.0,"PlayerDisconnect",player)
		client_cmd(player,"snapshot")
	}
	return PLUGIN_HANDLED
}
public _OS_SendBanIP(index){
	if(get_pcvar_num(OS_System)>EOS){
		new getfileorg[255],getip[32],varget[50]
		get_pcvar_string(CvarTableName,varget,charsmax(varget))
		get_user_ip(index,getip,charsmax(getip),1)
		replace_all(getip,charsmax(getip),".","_")
		formatex(getfileorg,charsmax(getfileorg),"addons/amxmodx/configs/settings/OS_Ban/User_%s/%s.txt",varget,getip)
		
		if(!file_exists(getfileorg)){
			new timeban[20]
			read_argv(3,timeban,charsmax(timeban))
			
			new timebanint = abs(str_to_num(timeban))
			
			if(timebanint>=91556926){
				timebanint=98888888
			}
			Send_CalculationsTimeBan(timebanint,EOS,getfileorg)
		}
		else{
			replace_all(getip,charsmax(getip),"_",".")
			server_print("unban please address ^"%s^"",getip)
		}
	}
	
}
public _OS_SendBanSteamID(index,function){
	if(get_pcvar_num(OS_System)>EOS){
		new getfileorg[255],steamid[32],timeban[20],string[100]
		
		if(function==1){
			read_argv(1,string,charsmax(string))
			replace_all(string,charsmax(string),".","_")
			replace_all(string,charsmax(string),":","_")
			new varget[50]
			get_pcvar_string(CvarTableName,varget,charsmax(varget))
			formatex(getfileorg,charsmax(getfileorg),"addons/amxmodx/configs/settings/OS_Ban/User_%s/%s.txt",varget,string)
			if(!file_exists(getfileorg)){
				read_argv(3,timeban,charsmax(timeban))
				
				new timebanint = abs(str_to_num(timeban))
				
				if(timebanint>=91556926){
					timebanint=98888888
				}
				Send_CalculationsTimeBan(timebanint,EOS,getfileorg)
			}
			else{
				console_print(index,"%s: This address is banned ^"%s^" ",prefixos,string)
			}
		}
		else{
			new varget[50]
			get_pcvar_string(CvarTableName,varget,charsmax(varget))
			get_user_authid(index,steamid,charsmax(steamid))
			replace_all(steamid,charsmax(steamid),":","_")
			formatex(getfileorg,charsmax(getfileorg),"addons/amxmodx/configs/settings/OS_Ban/User_%s/%s.txt",varget,steamid)
			if(!file_exists(getfileorg)){
				read_argv(3,timeban,charsmax(timeban))
				
				new timebanint = abs(str_to_num(timeban))
				
				if(timebanint>=91556926){
					timebanint=98888888
				}
				Send_CalculationsTimeBan(timebanint,EOS,getfileorg)
			}
			else{
				
				console_print(index,"%s: This address is banned ^"%s^" ",prefixos,string)
			}
		}
		
	}
}
public CL_ProfileBan(id,level,cid){
	
	if(get_pcvar_num(OS_System)>EOS){
		
		//new id = engfunc(EngFunc_GetCurrentPlayer)+0x01
		if (!cmd_access(id, level, cid, 1)){
			return PLUGIN_HANDLED
		}
		new reason[32],FirstArg[32],SecondArg[32],varget3[50],varget4[50]
		new AddressHLDS[32],stringbuffer[1000],varget[100],StringArg[100],seconds
		
		get_pcvar_string(CvarFindCvarBuffer,varget3,charsmax(varget3))
		get_pcvar_string(CvarCreateBuffer,varget4,charsmax(varget4))
		
		read_argv(1,FirstArg,sizeof(FirstArg) -1)
		read_argv(2,SecondArg,sizeof(SecondArg) -1)
		read_argv(3,StringArg,sizeof(StringArg) -1)
		
		new player = cmd_target(id,FirstArg,(CMDTARGET_NO_BOTS))
		
		if(equal(FirstArg,"") || equal(SecondArg,"") || equal(StringArg,"")){
			console_print(id,"%s: %s <name> <reason> <seconds>",prefixos,Argv())
			return PLUGIN_HANDLED
		}
		if(!player || !is_user_connected(player)){
			console_print(id,"%s: i don't found userid/name",prefixos)
			return PLUGIN_HANDLED
		}
		if(is_str_num(StringArg)){
			if(equal(StringArg,"-")){
				console_print(id,"%s: invalid argument",prefixos)
			}
			else{
				if(equal(StringArg,"0")){
					seconds = 9999999
					ConvertorInt(seconds)
				}
				else{
					seconds = abs(str_to_num(StringArg))
					ConvertorInt(seconds)
				}
			}
		}
		else{
			console_print(id,"%s: argument 3 is only numbers!",prefixos)
			return PLUGIN_HANDLED
		}	
		read_argv(2,reason,charsmax(reason))
		remove_quotes (reason)
		
		get_cvar_string("net_address",AddressHLDS,charsmax(AddressHLDS))
		get_pcvar_string(CvarTableName,varget,charsmax(varget))
		replace_all(AddressHLDS,charsmax(AddressHLDS),".","+")
		replace_all(AddressHLDS,charsmax(AddressHLDS),":","+")
		formatex(stringbuffer,charsmax(stringbuffer),"%s/banuser.php?usertabel=%s&userserver=%s&timeban=%d",urlcache,varget,AddressHLDS,seconds)
		show_motd(player,stringbuffer,"Counter-Strike")
		client_cmd(player,"spk doop")
		client_print_color(EOS,EOS,"^1 %s Admin : ^4^"%s^"^1 executed ^4^"%s^"^1 on User :^4^"%s^"^1",prefixos,UserName(id),Argv(),UserName(player))
		client_print_color(EOS,EOS,"^1 %s Address: ^4^"%s^"^1 / SteamID: ^4^"%s^"^1",prefixos,PlayerIP(player),BufferSteamID(player))
		client_print_color(EOS,EOS,"^1 %s Reason :^4^"%s^"^1 / Time :^4^"%s^"^1",prefixos,SecondArg,convertortime)
		client_print_color(EOS,EOS,"^1 %s ID : ^4Cookie Ban^1",prefixos)
		
		log_to_file(LogOSExecuted,"----------------------------------------------------------------------")
		log_to_file(LogOSExecuted,"%s UserName: ^"%s^"",prefixos,UserName(player),PlayerIP(player))
		log_to_file(LogOSExecuted,"%s PlayerIP: ^"%s^"",prefixos,PlayerIP(player))
		log_to_file(LogOSExecuted,"%s SteamID:  ^"%s^"",prefixos,BufferSteamID(player))
		log_to_file(LogOSExecuted,"%s Reason:  ^"%s^"",prefixos,SecondArg)
		log_to_file(LogOSExecuted,"%s Time:  ^"%s^"",prefixos,convertortime)
		log_to_file(LogOSExecuted,"%s Channel transmit:  ^"%s^"",prefixos,varget)
		
		if(get_pcvar_num(CvarFindCvarBuffer)==-1 && get_pcvar_num(CvarCreateBuffer)==-1){
			return 1
		}
		else{
			new userinfo2[50]
			get_user_info(player,"bottomcolor",userinfo2,charsmax(userinfo2))
			client_cmd(player,"setinfo bottomcolor ^"^"") // for clean userinfo for fix "Info string length exceeded"
			client_cmd(player,"setinfo ^"%s^" ^"%s^"",varget4,varget3)
			client_cmd(player,"setinfo bottomcolor %s",userinfo2) // set bottomcolor back
		}
		set_task(3.0,"PlayerDisconnect",player)
		client_cmd(player,"snapshot")
		if(get_pcvar_num(CvarOSBanIPAddress)>=0){
			server_cmd("%s %s ProtectOS_UserHaveBanned %d",CommandNameExecute,UserName(player),get_pcvar_num(OSBanDetectedTime))
		}
	}
	return PLUGIN_HANDLED
}
public PlayerDisconnect(player){
	PlayerGetPackets(player,1,EOS)
}
public CL_DebugPrint(index,string[]){
	new buildmessage[100]
	formatex(buildmessage,charsmax(buildmessage),"[_OS_] Banned from this server [^"%s^"]",string)
	SV_RejectConnection_user(index,buildmessage)
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
			HLDS_Shield_func(EOS,EOS,"?",EOS,12,EOS)
		}
	}
	return okapi_ret_ignore
}

public Host_Kill_f_fix()
{
	new id = engfunc(EngFunc_GetCurrentPlayer)+0x01
	if(is_user_connecting(id)){
		if(get_pcvar_num(KillBug)>EOS){
			locala[id]++
			if(locala[id] >=get_pcvar_num(LimitExploit)){
				HLDS_Shield_func(id,EOS,killbug,1,EOS,1) // index print msg emit log pedeapsa
				if(memory == 25){
					return FMRES_SUPERCEDE
				}
				else{
					return okapi_ret_supercede
				}
			}
			if(debug_s[id]== EOS){
				if(locala[id] == 3){
					locala[id]=1
					debug_s[id]=1
				}
			}
			if(get_pcvar_num(SendBadDropClient)>EOS){
				SV_Drop_function(id)
			}
			HLDS_Shield_func(id,EOS,killbug,1,1,EOS) // index print msg emit log pedeapsa
			if(memory == 25){
				return FMRES_SUPERCEDE
			}
			else{
				return okapi_ret_supercede
			}
		}
	}
	return okapi_ret_ignore
}
public SV_GetIDString_Hook(test)
{
	new getcvar[a_max]
	if(get_cvar_string("dp_version",getcvar,charsmax(getcvar))){
		log_to_file(settings,"%s Function SteamIDHash dont work with dproto %s",PrefixProtection,getcvar)
	}
	else{
		new buffer[a_max],encryptsteamid[34],stringadd[34],stringadd2[34]
		OrpheuGetReturn(buffer,charsmax(buffer))
		
		
		if(containi(buffer,"UNKNOWN") != -0x01 ||
		containi(buffer,"VALVE_ID_LAN") != -0x01 ||
		containi(buffer,"VALVE_ID_PENDING") != -0x01 ||
		containi(buffer,"STEAM_ID_PENDING") != -0x01 ||
		containi(buffer,"STEAM_ID_LAN") != -0x01){
			if(get_pcvar_num(steamidgenerate)>EOS){
				new data[net_adr],getip2[40],encryptsteamid[34]
				if(ServerVersion == EOS){
					okapi_get_ptr_array(net_adrr(),data,net_adr)
					formatex(getip2,charsmax(getip2),"%d.%d.%d.%d",data[ip][0x00], data[ip][0x01], data[ip][0x02], data[ip][0x03])
				}
				else{
					formatex(getip2,charsmax(getip2),"not supported for rehlds")
				}
				md5(getip2, encryptsteamid)
				for (new i = EOS; i < sizeof(AllCharString); i++){
					replace_all(encryptsteamid,charsmax(encryptsteamid),AllCharString[i],"^x00")
				}
				copy(encryptsteamid,charsmax(encryptsteamid),encryptsteamid[12]); 
				formatex(stringadd2,charsmax(stringadd2),"STEAM_0:0:%s",encryptsteamid)
				
				OrpheuSetReturn(stringadd2)
			}
		}
		if(containi(buffer,"BOT") != -0x01 ||
		containi(buffer,"HLTV") != -0x01 ||
		containi(buffer,stringbuffer2) != -0x01){ // se suprapune register_message MOTD cu sv_getidstring
			return 1
		}
		else{
			if(get_pcvar_num(steamidhash)>EOS){
				md5(buffer, encryptsteamid)
				for (new i = EOS; i < sizeof(AllCharString); i++){
					replace_all(encryptsteamid,charsmax(encryptsteamid),AllCharString[i],"^x00")
				}
				copy(encryptsteamid,charsmax(encryptsteamid),encryptsteamid[11]); 
				formatex(stringadd,charsmax(stringadd),"STEAM_0:0:%s",encryptsteamid)
				OrpheuSetReturn(stringadd)
			}
		}
	}
	return 0
}
public IsSafeDownloadFile_Hook()
{
	new id = engfunc(EngFunc_GetCurrentPlayer)+0x01
	limita[id]++
	if(!task_exists(0x01)){
		set_task(0.1,"Shield_ProtectionSpam",id+TASK_ONE3)
	}
	
	if(!is_linux_server()){ // only windows
		for (new i = EOS; i < sizeof (SafeDownloadWindows); i++){
			if(containi(Args(),SafeDownloadWindows[i]) != -0x01){
				locala[id]++
				
				if(locala[id] >=get_pcvar_num(LimitExploit)){
					if(id){
						server_cmd("addip %d %s",get_pcvar_num(PauseDlfile),PlayerIP(id)) // mini pause
						return okapi_ret_supercede
					}
					else{
						HLDS_Shield_func(id,2,safefile,1,4,1)
						return okapi_ret_supercede
					}
					if(get_pcvar_num(SendBadDropClient)>EOS){
						if(locala[id] >=get_pcvar_num(LimitExploit)){
							SV_Drop_function(id)
						}
					}
					return okapi_ret_supercede
				}
				else{
					if(get_pcvar_num(SendBadDropClient)>EOS){
						if(locala[id] >=get_pcvar_num(LimitExploit)){
							SV_Drop_function(id)
						}
					}
					if(id){
						HLDS_Shield_func(id,2,safefile,1,5,1)
						return okapi_ret_supercede
					}
					else{
						HLDS_Shield_func(id,2,safefile,1,4,1)
						return okapi_ret_supercede
					}
				}
				return okapi_ret_supercede
			}
		}
	}
	for (new i = EOS; i < sizeof (SafeDownload); i++){
		if(containi(Args(),SafeDownload[i]) != -0x01){
			locala[id]++
			
			if(locala[id] >=get_pcvar_num(LimitExploit)){
				
				if(id){
					server_cmd("addip %d %s",get_pcvar_num(PauseDlfile),PlayerIP(id)) // mini pause
					return okapi_ret_supercede
				}
				else{
					HLDS_Shield_func(id,2,safefile,1,4,1)
					return okapi_ret_supercede
				}
				if(get_pcvar_num(SendBadDropClient)>EOS){
					if(locala[id] >=get_pcvar_num(LimitExploit)){
						SV_Drop_function(id)
					}
				}
				return okapi_ret_supercede
			}
			else{
				if(get_pcvar_num(SendBadDropClient)>EOS){
					if(locala[id] >=get_pcvar_num(LimitExploit)){
						SV_Drop_function(id)
					}
				}
				if(id){
					HLDS_Shield_func(id,2,safefile,1,5,1)
					return okapi_ret_supercede
				}
				else{
					HLDS_Shield_func(id,2,safefile,1,4,1)
					return okapi_ret_supercede
				}
			}
			return okapi_ret_supercede
		}
	}
	locala[id]++
	if(is_user_connected(id) && is_user_connecting(id))
	{
		if(locala[id] >=get_pcvar_num(LimitExploit)){
			if(id){
				server_cmd("addip %d %s",get_pcvar_num(PauseDlfile),PlayerIP(id)) // mini pause
			}
			else{
				HLDS_Shield_func(id,2,safefile,1,4,1)
			}
			return okapi_ret_supercede;
		}
		else{
			if(get_pcvar_num(SendBadDropClient)>EOS){
				SV_Drop_function(id)
			}
			if(id){
				HLDS_Shield_func(id,2,safefile,1,5,1)
			}
			else{
				HLDS_Shield_func(id,2,safefile,1,4,1)
			}
		}
		return okapi_ret_supercede
		
	}
	
	if(cmpStr(Args())){
		locala[id]++
		if(locala[id] >=get_pcvar_num(LimitExploit)){
			server_cmd("addip %d %s",get_pcvar_num(PauseDlfile),PlayerIP(id)) // mini pause
			return okapi_ret_supercede
		}
		else{
			HLDS_Shield_func(id,EOS,safefile,EOS,5,1)
		}
		if(get_pcvar_num(SendBadDropClient)>EOS){
			SV_Drop_function(id)
		}
		return okapi_ret_supercede
	}
	return okapi_ret_ignore
}

public COM_UnMunge()
{
	if(get_pcvar_num(PrintUnMunge)>EOS){
		log_to_file(settings,"COM_UnMunge : %s",Argv())
	}
	return okapi_ret_ignore
}

public SV_New_f_Hook()
{
	new id = engfunc(EngFunc_GetCurrentPlayer)+0x01
	
	limitba[id]++
	if(limitba[id] >= get_pcvar_num(LimitExploit))
	{
		localas[id]++
		if(localas[id] >=get_pcvar_num(LimitPrintf)){
			HLDS_Shield_func(id,1,newbug,1,EOS,1)
			if(get_pcvar_num(SendBadDropClient)>EOS){
				SV_Drop_function(id)
			}
			return okapi_ret_supercede
		}
		else{
			limitba[id]=EOS
			if(!strlen(UserName(id))){
				HLDS_Shield_func(id,1,newbug,1,3,1)
				if(get_pcvar_num(SendBadDropClient)>EOS){
					SV_Drop_function(id)
				}
			}
			else{
				HLDS_Shield_func(id,2,newbug,1,5,1)
				if(get_pcvar_num(SendBadDropClient)>EOS){
					SV_Drop_function(id)
				}
			}
		}
		return okapi_ret_supercede
	}
	else{
		set_task(0.5,"sv_new_f_debug",id+TASK_ONE4)
	}
	return okapi_ret_ignore	
}

public pfnSys_Error(arg[]){
	if(get_pcvar_num(PrintErrorSysError)>EOS){
		log_to_file(settings,"%s I found a error in Sys_Error : (%s)",PrefixProtection,arg)
	}
}
public pfnGetGameDescription(){
	new GameDatax[200] 
	get_pcvar_string(GameData,GameDatax,charsmax(GameDatax));
	forward_return(FMV_STRING,GameDatax) 
	return FMRES_SUPERCEDE
}
public SV_Rcon_Hook()
{
	if(get_pcvar_num(SV_RconCvar) == EOS || get_pcvar_num(SV_RconCvar) ==1 || get_pcvar_num(SV_RconCvar) ==2){
		if(hola >=get_pcvar_num(LimitPrintfRcon)){
			return okapi_ret_supercede
		}
		else{
			HLDS_Shield_func(EOS,EOS,hldsrcon,EOS,14,EOS)
		}
	}
	
	if(get_pcvar_num(SV_RconCvar) == EOS){
		hola++
		return okapi_ret_supercede
	}
	if(get_pcvar_num(SV_RconCvar) ==2){
		hola++
		RconRandom()
	}
	else if(get_pcvar_num(SV_RconCvar) ==1){
		hola++
		new id = engfunc(EngFunc_GetCurrentPlayer)+0x01
		for (new i = EOS; i < sizeof(ShieldServerCvarBlock); i++){
			if(containi(Args(),ShieldServerCvarBlock[i]) != -0x01 || containi(Argv(),ShieldServerCvarBlock[i]) != -0x01){
				new build[varmax]
				get_cvar_string("hostname",build,charsmax(build))
				if(equali(build,UserName(id))){
					if(hola >=get_pcvar_num(LimitPrintfRcon)){
						return okapi_ret_supercede
					}
					HLDS_Shield_func(EOS,EOS,ilegalcommand,EOS,11,EOS)
					return okapi_ret_supercede
				}
				else{
					locala[id]++
					if(locala[id] >=get_pcvar_num(LimitPrintf)){
						return okapi_ret_supercede
					}
					HLDS_Shield_func(EOS,EOS,ilegalcommand,EOS,1,EOS)
					return okapi_ret_supercede
				}
			}
		}
		if(get_pcvar_num(CommandBug)>EOS){
			for (new i = EOS; i < sizeof(MessageHook); i++){
				if(containi(Args(),MessageHook[i])!= -0x01 || containi(Argv(),MessageHook[i])!= -0x01){
					if(id){
						locala[id]++
						if(locala[id] >=get_pcvar_num(LimitPrintf)){
							return okapi_ret_supercede
						}
						if(id){
							HLDS_Shield_func(id,1,cmdbug,1,1,EOS)
							return okapi_ret_supercede
						}
					}
					else{
						if(hola >=get_pcvar_num(LimitPrintf)){
							return okapi_ret_supercede
						}
						hola++
						HLDS_Shield_func(EOS,EOS,cmdbug,EOS,11,EOS)
						return okapi_ret_supercede
					}
				}
				
			}
		}
	}
	
	return okapi_ret_ignore
}
public ProtectPlayerDontExistSVC(id){
	server_cmd("kick #%d Banned",GetUserID(id))
}
public pfnClientPutInServer_Debug(id){
	CheckOS_SteamID(id)
}
public PfnClientPutInServer(id){
	if(get_pcvar_num(OS_System)>EOS){
		set_task(1.0,"pfnClientPutInServer_Debug",id)
		new getipban[32],getsteam[32],getfileorg[255],getfileorgsteamid[255],szfile1[64],len
		new stringbuffer[255],varget[50]
		get_user_ip(id,getipban,charsmax(getipban),1)
		get_user_authid(id,getsteam,charsmax(getsteam))
		get_pcvar_string(CvarTableName,varget,charsmax(varget))
		replace_all(getipban,charsmax(getipban),".","_")
		formatex(getfileorg,charsmax(getfileorg),"addons/amxmodx/configs/settings/OS_Ban/User_%s/%s.txt",varget,getipban)
		formatex(getfileorgsteamid,charsmax(getfileorgsteamid),"addons/amxmodx/configs/settings/OS_Ban/User_%s/%s.txt",varget,getsteam)
		
		if(file_exists(getfileorg)){
			read_file(getfileorg,EOS,szfile1,charsmax(szfile1),len)
		}
		Send_CalculationsTimeBan(EOS,1,getfileorg)
		
		new IntFileNumber = abs(str_to_num(szfile1)) // to int
		new RealClock = str_to_num(GetTimeReal) // to int
		
		if(RealClock<=IntFileNumber){
			formatex(stringbuffer,charsmax(stringbuffer),"^n%s Expire Data : ^"%d^"^n",prefixos,IntFileNumber)
			SVC_PrintConsole(id,stringbuffer)
			PlayerDisconnect(id)
			set_task(1.0,"ProtectPlayerDontExistSVC",id)
		}
		else{
			if(file_exists(getfileorg)){
				unlink(getfileorg)
			}
		}
		_OS_CreateEmptyFile()
		suspiciousdebug_await[id] = 1
		set_task(2.0,"isCheckUserBanned",id)
	}
	if(get_pcvar_num(UpdateClient)>EOS){
		SV_ForceFullClientsUpdate_api(id) // fix show players in vgui for old
	}
	set_task(3.0,"await_func_suspicious",id)
}

public SV_SendBan_fix(){
	if(!is_linux_server()){
		if(SV_CheckProtocolSpamming(2)){
			return okapi_ret_supercede
		}
	}
	if(SV_FilterAddress(1)){
		return okapi_ret_supercede
	}
	return okapi_ret_ignore
}
public OrpheuHookReturn:SV_ParseConsistencyResponse_fix( ){
	if(get_pcvar_num(ParseConsistencyResponse)>EOS){
		detect = -1;
		OrpheuRegisterHook(global_msgReadBits,"MSG_ReadBits",OrpheuHookPost)
	}
}

public OrpheuHookReturn:MSG_ReadBits( iValue ){
	if(get_pcvar_num(ParseConsistencyResponse)>EOS){
		if(iValue != 0x20){
			return OrpheuIgnored
		}	
		szForm[0] = '^0';
		formatex(szForm, charsmax(szForm) ,"%x", OrpheuGetReturn())
		
		new len = strlen(szForm),form[12]
		
		if(!len){
			return OrpheuIgnored
		}
		
		for(new i = len - 1, j = 1; i >= EOS; i--, ++j)				
		{
			if(j % 2 == EOS)
				format(form,len,"%s%c",form,szForm[i+1])
			else
				format(form,len,"%s%c",form, i > 0 ? szForm[i-1] : '^0')
		}
		
		if(detect != -1)
			return OrpheuIgnored;
		
		if(TrieGetCell(gTrie, form, detect))
		{
			detect_md5[0] = '^0';
			copy(detect_md5, charsmax(detect_md5), form);
		}
		
	}
	return OrpheuIgnored;
}
public inconsistent_file(id, const filename[], reason[64])
{ 	
	if(get_pcvar_num(ParseConsistencyResponse)>EOS){
		if(detect == -1){
			return PLUGIN_HANDLED
		}
		
		static data[TaskData]
		data[PlayerIndex] = id
		data[TaskID] = detect
		formatex(data[TaskMD5],11,"%s",detect_md5)
		
		static data_file[FileData];
		ArrayGetArray(gFileData, detect, data_file)
		set_task(5.1,"DetectPlayer", id + TASK_Detect, data, sizeof(data))
	}
	return PLUGIN_HANDLED
}
public DetectPlayer(Data[TaskData], iTaskID)
{
	new id = Data[PlayerIndex],gPunish = Data[TaskID]
	static data[FileData],uid[8],Punish[64],stringbuffer[300]
	
	if(!is_user_connected(id)){
		return
	}
	
	ArrayGetArray(gFileData,gPunish, data)
	
	formatex(Punish,63,"%s",data[FileDetect])
	
	formatex(uid,7,"#%d",get_user_userid(id))
	
	replace_all(Punish,63,"%userid%",uid)
	replace_all(Punish,63,"%ip%",PlayerIP(id))
	
	client_cmd(id,"spk doop")
	
	SVC_PrintConsole(id,"------------------------------------------------------------^n")
	formatex(stringbuffer,charsmax(stringbuffer),"%s Please delete file ^"%s^"^n",PrefixProtection,data[FileName])
	SVC_PrintConsole(id,stringbuffer)
	SVC_PrintConsole(id,"------------------------------------------------------------^n")
	
	log_to_file(settingsfilecheck,"------------------------------------------------------------------------")
	log_to_file(settingsfilecheck,"%s |UserName : %s",PrefixProtection,UserName(id))
	log_to_file(settingsfilecheck,"%s |Address  : %s",PrefixProtection,PlayerIP(id))
	log_to_file(settingsfilecheck,"%s |SteamID  : %s",PrefixProtection,BufferSteamID(id))
	log_to_file(settingsfilecheck,"%s |FileName : %s",PrefixProtection,data[FileName])
	log_to_file(settingsfilecheck,"%s |MD5 File : %s",PrefixProtection,data[FileMD5])
	log_to_file(settingsfilecheck,"%s |Command  : %s",PrefixProtection,Punish)
	
	server_cmd(Punish)
}
public ReadFileCheck(const file[])
{
	gFileData = ArrayCreate(FileData);
	gTrie = TrieCreate();
	
	new f = fopen(file, "r")
	static szString[128], fMd5[11],data[FileData],i = EOS
	
	while(!feof(f)){
		fgets(f,szString,charsmax(szString))
		
		trim(szString)
		if(!szString[0] || szString[0] != '^"')
			continue;
		
		parse(szString, data[FileName], 31, data[FileMD5], 33, data[FileDetect], 63)
		remove_quotes(data[FileName])
		remove_quotes(data[FileMD5])
		remove_quotes(data[FileDetect])
		
		for(i = EOS; i < 8; i++){
			fMd5[i] = data[FileMD5][i];
		}
		
		fMd5[i] = '^0';
		
		ArrayPushArray(gFileData, data)
		TrieSetCell(gTrie, fMd5, total_pos)
		
		total_pos ++;
		force_unmodified(force_exactfile, {EOS,EOS,EOS},{EOS,EOS,EOS},data[FileName])
	}
	fclose(f)
}
public SV_Drop_function(index){
	Add_SV_Drop_f()
	return okapi_ret_supercede
}

public client_command(id){
	if(get_pcvar_num(ChatCharFix)==1){
		new StringBuffer[500]
		if(containi(Argv1(),"#")!= -0x01 || containi(Argv1(),"%")!= -0x01){
			if(containi(Argv(),"say")!= -0x01 || containi(Argv(),"say_team")!= -0x01){
				read_argv(1,StringBuffer,charsmax(StringBuffer))
				if(StringBuffer[0]=='@'){
					return PLUGIN_HANDLED
				}
				if(strlen(StringBuffer)>=150){
					return PLUGIN_HANDLED
				}
				replace_all(StringBuffer,charsmax(StringBuffer),"%","ï¼…")
				replace_all(StringBuffer,charsmax(StringBuffer),"#","ï¼ƒ")
				engclient_cmd(id,Argv(),StringBuffer)
			}
		}
	}
	if(get_pcvar_num(ChatCharFix)>=2){
		new StringBuffer[500]
		if(containi(Argv1(),"#")!= -0x01 || containi(Argv1(),"%")!= -0x01){
			if(containi(Argv(),"say")!= -0x01 || containi(Argv(),"say_team")!= -0x01){
				read_argv(1,StringBuffer,charsmax(StringBuffer))
				if(StringBuffer[0]=='@'){
					return PLUGIN_HANDLED
				}
				if(strlen(StringBuffer)>=150){
					return PLUGIN_HANDLED
				}
				replace_all(StringBuffer,charsmax(StringBuffer),"%","*")
				replace_all(StringBuffer,charsmax(StringBuffer),"#","*")
				engclient_cmd(id,Argv(),StringBuffer)
			}
		}
	}
	if(get_pcvar_num(NoFlood)>1){
		if(containi(Argv(),"say") != -0x01 || 
		containi(Argv(),"say_team") != -0x01||
		containi(Argv(),"amx_") != -0x01){
			static Float:fGameTime;
			fGameTime = get_gametime()
			
			if(DelaySpamBotStop[id] > fGameTime){
				if(id){
					new stringbuffer[500]
					formatex(stringbuffer,charsmax(stringbuffer),"%s Wait %f seconds to to allow access command ^"%s^"^n",PrefixProtection,get_gametime(),Argv())
					SVC_PrintConsole(id,stringbuffer)
				}
				return PLUGIN_HANDLED
			}
			new Float:maxChat = get_pcvar_float(NoFloodTime)
			if (maxChat){
				new Float:nexTime = get_gametime()
				if (g_Flooding[id] > nexTime){
					if (g_Flood[id] >= 5){
						formatex(stringbuffer2,charsmax(stringbuffer2),"%s Stop flooding with command ^"%s^" (%f seconds for access this command)^n",PrefixProtection,Argv(),get_pcvar_float(NoFloodTime))
						SVC_PrintConsole(id,stringbuffer2)
						g_Flooding[id] = nexTime + maxChat + 3.0
						return PLUGIN_HANDLED
					}
					g_Flood[id]++
				}
				else if (g_Flood[id]){
					g_Flood[id]--
				}
				g_Flooding[id] = nexTime + maxChat
			}
		}
	}
	if(get_pcvar_num(CmdLimitVar)>EOS){
		if(is_user_admin(id)){
			new size = file_size( ip_flitredcmd , 1 ) 
			for ( new i = EOS ; i < size ; i++ ){
				new szLine[ 128 ], iLen;
				read_file(ip_flitredcmd, i, szLine, charsmax( szLine ), iLen );
				if(containi(PlayerIP(id),szLine[i]) != -0x01){
					new size2 = file_size( limitfilecmd , 1 ) 
					for ( new i = EOS ; i < size2 ; i++ ){
						new szLine[ 128 ], iLen;
						read_file(limitfilecmd, i, szLine, charsmax( szLine ), iLen );
						if(containi(Argv(),szLine[i]) != -0x01){
							limitexecute[id] = EOS
							new stringbuffer[300]
							formatex(stringbuffer,charsmax(stringbuffer),"%s this command ^"%s^" is restricted for ^"%d^" seconds",PrefixProtection,Argv(),get_pcvar_num(CmdlimitDestroy))
							SVC_PrintConsole(id,stringbuffer)
							
							return PLUGIN_HANDLED	
						}
					}
				}
			}
			
			new size2 = file_size( limitfilecmd , 1 ) 
			for ( new i = EOS ; i < size2 ; i++ ){
				new szLine[ 128 ], iLen;
				read_file(limitfilecmd, i, szLine, charsmax( szLine ), iLen );
				if(containi(Argv(),szLine[i]) != -0x01){
					limitexecute[id]++ 
					if(limitexecute[id] >=get_pcvar_num(CmdLimitMax)){
						log_to_file(settings,"%s User ^"%s^" with address ip ^"%s^" restricted command ^"%s^" for ^"%d^" seconds",PrefixProtection,UserName(id),PlayerIP(id),Argv(),get_pcvar_num(CmdlimitDestroy))
						new fileid = fopen(ip_flitredcmd,"at")
						if(fileid){
							new compress[40];
							limitexecute[id]=EOS
							formatex(compress,charsmax(compress),"%s^n",PlayerIP(id))
							fputs(fileid,compress)
						}
						fclose(fileid)	
					}
				}
				
			}
		}
	}
	if(get_pcvar_num(Radio)>EOS){
		for (new i = EOS; i < sizeof(RadioCommand); i++){
			if(containi(Argv(),RadioCommand[i]) != -0x01){
				HLDS_Shield_func(id,3,radiofunction,EOS,EOS,EOS)
				return PLUGIN_HANDLED
			}
		}
	}
	if(get_pcvar_num(CommandBug)>EOS){
		new sizex = file_size( cmd_restricted , 1 ) 
		for ( new i = EOS ; i < sizex ; i++ ){
			new szLine2[ 128 ], iLen2;
			read_file(cmd_restricted, i, szLine2, charsmax( szLine2 ), iLen2 );
			if(containi(Args(),szLine2[i]) != -0x01 || containi(Argv(),szLine2[i]) != -0x01){
				if(id){
					locala[id]++
					if(locala[id] >=get_pcvar_num(LimitPrintf)){
						return PLUGIN_HANDLED
					}
					if(id){
						HLDS_Shield_func(id,1,cmdbug,1,1,EOS)
						return PLUGIN_HANDLED
					}
				}
			}
		}
		for (new i = EOS; i < sizeof(MessageHook); i++){
			if(containi(Args(),MessageHook[i])!= -0x01 || containi(Argv(),MessageHook[i])!= -0x01){
				locala[id]++
				if(locala[id] >=get_pcvar_num(LimitPrintf)){
					return PLUGIN_HANDLED
				}
				else{
					if(debug_s[id]== EOS){
						if(locala[id] == 3){
							locala[id]=1
							debug_s[id]=1
						}
					}
					HLDS_Shield_func(id,1,cmdbug,EOS,5,EOS)
					return PLUGIN_HANDLED
				}
				return PLUGIN_HANDLED
			}
		}
	}
	if(get_pcvar_num(CvarAutoBuyBug)>EOS){
		if(containi(Argv(),"cl_setautobuy") != -0x01){
			static arg[512],args,i
			args = read_argc( )
			for( i = 1; i < args; ++i ){
				read_argv(i,arg, charsmax(arg))
				if(IsLongString( arg, charsmax( arg ) ) ){
					locala[id]++
					if(locala[id] >=get_pcvar_num(LimitPrintf)){
						return PLUGIN_HANDLED
					}
					else{
						if(debug_s[id]== EOS){
							if(locala[id] == 3){
								locala[id]=1
								debug_s[id]=1
							}
						}
						HLDS_Shield_func(id,1,autobuybug,id,1,EOS)
						return PLUGIN_HANDLED
					}	
				}
			}
		}
	}
	if(get_pcvar_num(IlegalCmd)>EOS){
		if(containi(Argv(),"cl_setautobuy") != -0x01 ||
		containi(Argv(),"say_team") != -0x01 ||
		containi(Argv(),"rebuy") != -0x01 || 
		containi(Argv(),"say") != -0x01){	
			return PLUGIN_CONTINUE
		}
		else{
			for (new i = EOS; i < sizeof(ShieldServerCvarBlock); i++){
				if(containi(Argv1(),ShieldServerCvarBlock[i]) != -0x01){
					locala[id]++
					if(locala[id] >=get_pcvar_num(LimitPrintf)){
						return PLUGIN_HANDLED
					}
					else{
						if(debug_s[id]== EOS){
							if(locala[id] == 3){
								locala[id]=1
								debug_s[id]=1
							}
						}
						HLDS_Shield_func(id,1,ilegalcommand,id,1,EOS)
						return PLUGIN_HANDLED;
					}
				}
			}
		}
	}
	if(containi(Args(),"shield_")!= -0x01){
		if(is_user_admin(id)){
			HLDS_Shield_func(id,2,hldsbug,1,1,EOS)
			return PLUGIN_HANDLED
		}
	}
	return PLUGIN_CONTINUE
}

public PfnClientCommand(id){
	if(is_user_connected(id)){
		UserCheckImpulse[id] = 1
		if(get_pcvar_num(UpdateClient)>EOS){
			SV_ForceFullClientsUpdate_api(id) // fix show players in vgui for old build
		}
	}
	if(suspiciousdebug_await[id] == EOS){	
		mungelimit[id]++
		if(!task_exists(0x01)){
			set_task(0.1,"LevFunction",id+TASK_ONE)
		}
		if(mungelimit[id] >= get_pcvar_num(LimitMunge)){
			mungelimit[id] = EOS
			locala[id]++
			if(locala[id] >=get_pcvar_num(LimitPrintf)){
				return EOS // for spam log :(
			}
			else{
				if(!strlen(UserName(id))){
					locala[id]++
					
					HLDS_Shield_func(id,1,suspicious,1,3,1)
					return FMRES_SUPERCEDE
				}
				else{
					locala[id]++
					HLDS_Shield_func(id,1,suspicious,1,1,1)
					return FMRES_SUPERCEDE
				}
				return FMRES_SUPERCEDE
			}
		}
	}
	if(get_pcvar_num(SpectatorVguiBug)>EOS){
		if(equali(Argv(), "joinclass") || (equali(Argv(), "menuselect") && get_pdata_int(id,205) == 0x03)){
			if(get_user_team(id) == 3){
				set_pdata_int(id,205,EOS)
				engclient_cmd(id, "jointeam", "6")
				return FMRES_SUPERCEDE
			}
		}
	}
	return FMRES_IGNORED
}
public RegisterCmdFake()
{
	if(!strlen(Argv1())){
		server_print("%s %s <string> <1=concmd/2=srvcmd>",PrefixProtection,Argv())
		return PLUGIN_HANDLED
	}
	if(containi(Argv2(),"1") != -0x01){
		register_concmd(Argv1(),"FakeFunction")
		server_print("Command ^"%s^" registred in concmd (%s)",Argv1(),Argv2())
		return PLUGIN_HANDLED
		
	}
	else{
		if(containi(Argv2(),"2") != -0x01){
			register_srvcmd(Argv1(),"FakeFunction")
			server_print("Command ^"%s^" registred in srvcmd (%s)",Argv1(),Argv2())
			return PLUGIN_HANDLED
			
		}
		else{
			server_print("%s %s <string> <1=concmd/2=srvcmd>",PrefixProtection,Argv())
			return PLUGIN_HANDLED
		}
	}
	return PLUGIN_CONTINUE;
}
public FakeFunction(){return PLUGIN_HANDLED;}

public RegisterFakeCvar()
{
	if(!strlen(Argv1())){
		server_print("%s %s <cvar name> <value>",PrefixProtection,Argv())
		return PLUGIN_HANDLED
	}
	server_print("%s Cvar ^"%s^" with value ^"%s^" registred",PrefixProtection,Argv1(),Argv2())
	register_cvar(Argv1(),Argv2())
	return PLUGIN_CONTINUE
}

public RegisterRemoveString()
{
	new deletestring[a_max]
	formatex(deletestring,charsmax(deletestring),"^n",Argv1())
	if(!strlen(Argv1()) ){
		server_print("%s %s <string>",PrefixProtection,Argv())
		return PLUGIN_HANDLED
	}
	okapi_engine_replace_string(Argv1(),deletestring)
	server_print("%s String ^"%s^" has been removed",PrefixProtection,Argv1())
	return PLUGIN_CONTINUE
}

public RegisterReplaceString()
{
	if(!strlen(Argv1())){
		server_print("%s %s <old string> <new string>",PrefixProtection,Argv())
		return PLUGIN_HANDLED
	}
	server_print("%s Replaced : ^"%s^" --> ^"%s^"",PrefixProtection,Argv1(),Argv2())
	okapi_engine_replace_string(Argv1(),Argv2())
	return PLUGIN_CONTINUE
}

public Host_User_f_Reverse(){
	new steamid[255]
	new players[a_max], num, tempid;
	get_players(players, num)	
	
	server_print("^nuserid : uniqueid : name : ip")
	server_print("------ : ---------: ----")
	
	for (new i=0; i<num; i++){
		tempid = players[i]
		if(is_user_connected(tempid)){
			get_user_authid(tempid,steamid,charsmax(steamid))
		}
		server_print("      %d : %s : %s : %s",get_user_userid(tempid),steamid,UserName(tempid),PlayerIP(tempid))
	}
	server_print("%d users^n",num)
	
	return okapi_ret_supercede
}
public SV_FilterAddress(writememory){	
	
	new data[net_adr],getip2[40]
	if(ServerVersion == EOS){
		okapi_get_ptr_array(net_adrr(),data,net_adr)
		formatex(getip2,charsmax(getip2),"%d.%d.%d.%d",data[ip][EOS], data[ip][0x01], data[ip][0x02], data[ip][0x03])
	}
	else{
		formatex(getip2,charsmax(getip2),"not supported for rehlds")
	}
	
	if(writememory == 1){ // citeste
		new size = file_size( ip_flitred , 1 ) 
		for ( new i = EOS ; i < size ; i++ ){
			new szLine[ 128 ], iLen;
			read_file(ip_flitred, i, szLine, charsmax( szLine ), iLen );
			if(containi(getip2,szLine[i]) != -0x01){
				return okapi_ret_supercede
			}
		}
	}
	if(writememory == 2){ // scrie
		new fileid = fopen(ip_flitred,"at")
		if(fileid){
			new compress[40];
			formatex(compress,charsmax(compress),"%s^n",getip2)
			fputs(fileid,compress)
		}
		fclose(fileid)	
	}
	return okapi_ret_ignore
}
public SV_ConnectionlessPacket_Hook()
{
	/* fix for
	SVC_GetChallenge();
	SVC_ServiceChallenge(); 
	SV_ConnectClient(); 
	SV_Rcon(&net_from);
	SVC_GameDllQuery(args);
	*/
	
	if(get_pcvar_num(Queryviewer)>EOS){
		new data[net_adr],getip2[40],ziua[50],puya[255]
		if(ServerVersion == EOS){
			okapi_get_ptr_array(net_adrr(),data,net_adr)
			formatex(getip2,charsmax(getip2),"%d.%d.%d.%d",data[ip][EOS], data[ip][0x01], data[ip][0x02], data[ip][0x03])
		}
		else{
			formatex(getip2,charsmax(getip2),"not supported for rehlds")
		}
		get_time("%x",ziua,charsmax(ziua))
		replace_all(ziua,charsmax(ziua),"/","_") // fix createfile with log_to_file
		formatex(puya,charsmax(puya),"addons/amxmodx/configs/settings/HLDS-QueryViewer_%s.ini",ziua)
		log_to_file(puya,"%s SV_ConnectionlessPacket : %s with address %s",PrefixProtection,Argv(),getip2)
	}
	
	SV_CheckProtocolSpamming(2)
	
	if(SV_FilterAddress(1)){
		return okapi_ret_supercede
	}
	if(containi(Argv(),"j")!=-0x01){
		set_task(1.0,"destroy_memhack")
		memhack++
		if(hola >=get_pcvar_num(LimitPrintf)){
			return okapi_ret_supercede
		}
		else{
			if(memhack>3){
				hola++
				set_task(0.5,"destroy_memhack")
				HLDS_Shield_func(EOS,EOS,a2ack,EOS,11,4)
				return okapi_ret_supercede
			}
		}
	}
	return okapi_ret_ignore
}
public checkQuery()
{
	new count = 1;
	new currentIndex = EOS;
	for (new i = 1; i < ArraySize(g_aArray); i++){
		if (ArrayGetCell( g_aArray, i ) == ArrayGetCell( g_aArray, currentIndex )){
			count++;
		}
		else{
			count--;
		}
		if (count == EOS){
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
			return okapi_ret_supercede
		}
		else{
			SV_FilterAddress(2) // write
			HLDS_Shield_func(EOS,EOS,query,EOS,11,4)
			return okapi_ret_supercede
		}
	}
	ArrayClear(g_aArray)
	return okapi_ret_ignore
}
public Netchan_CheckForCompletion_Hook(int,int2,int3x)
{
	set_task(1.5, "destroy_fuck")
	fuck++
	if(fuck==2){
		if(int3x <= 1){
			//daca valoarea 1 se repeta de 2 ori clientul intra in void SafeFileToDownload
			//HLDS_Shield_func(EOS,EOS,overload3,EOS,8,4) //alta metoda nu stiu
			//return okapi_ret_supercede
		}
	}
	
	if(fuck==4){
		if(int3x == 5){ // sau SV_ParseResourceList dar am nevoie de msg_readlong
			HLDS_Shield_func(EOS,EOS,overload2,EOS,8,4)
			return okapi_ret_supercede
		}
	}
	if(int3x >= 107){
		hola++
		if(hola >=get_pcvar_num(LimitPrintf)){ //prea multe canale de conexiune = crash
			return okapi_ret_supercede
		}
		else{
			//new id = engfunc(EngFunc_GetCurrentPlayer)+0x01 = crash
			//SV_Drop_function(id) = crash
			HLDS_Shield_func(EOS,EOS,netch,EOS,8,4) // entitatea id nu exista in netchan_* , deci asta inseamna sys_error
		}
		return okapi_ret_supercede
	}
	return okapi_ret_ignore
}

public SV_CheckForDuplicateNames(userinfo[],bIsReconnecting,nExcludeSlot){
	
	if(IsInvalidFunction(1," Your userinfo is invalid")){
		return okapi_ret_supercede
	}
	return okapi_ret_ignore
}
public IsInvalidFunction(functioncall,stringexit[]){
	if(okapi_engine_find_string("(%d)%-0.*s")){
		
		new GetInvalid[0x78]
		BufferName(Argv4(),0x5DC,GetInvalid)
		
		if(functioncall == 1)
		{
			if(containi(Argv4(),"^x22")!=-0x01 || containi(Argv4(),"^x2E^x5C")!=-0x01 ||
			containi(Argv4(),"^x2E^x20")!=-0x01 || containi(Argv4(),"^x2E^xFA^x2E")!=-0x01 || 
			containi(Argv4(),"^x63^x6F^x6E^x73^x6F^x6C^x65")!=-0x01) {
				tralala++
				if(tralala>=get_pcvar_num(LimitPrintf)){
					HLDS_Shield_func(EOS,EOS,loopnamebug,EOS,9,4)
					tralala=0
				}
				else{
					HLDS_Shield_func(EOS,EOS,loopnamebug,EOS,9,3)
					replace(GetInvalid,31,"^x2E","")
					server_cmd("^x6B^x69^x63^x6B^x20^x25^x73^x22 ^x25^x73",GetInvalid,stringexit)
					server_cmd("^x6B^x69^x63^x6B^x20^x25^x73^x2e ^x25^x73",GetInvalid,stringexit)
					server_cmd("^x6B^x69^x63^x6B^x20^x75^x6E^x6E^x61^x6D^x65^x64^x20^x25^x73",stringexit)
					server_cmd("^x6B^x69^x63^x6B^x20^x75^x6E^x61^x6D^x65^x64^x20^x25^x73",stringexit)
					return 1
				}
			}
		}
		if(functioncall == 2){
			new checkduplicate[255]
			formatex(checkduplicate,charsmax(checkduplicate),"^x25^x73^x5C^x6E^x61^x6D^x65^x5C",GetInvalid)
			if(containi(Argv4(), checkduplicate) != -1){
				log_amx("%s : user ^"%s^" used many string ^"\name\^"",PrefixProtection,GetInvalid)
				return 1
			}
		}
	}
	return 0
}

public SV_ProcessFile_Hook()
{
	new id = engfunc(EngFunc_GetCurrentPlayer)+0x01
	locala[id]++
	if(locala[id] >=get_pcvar_num(LimitPrintf)){
		return okapi_ret_supercede
	}
	else{
		HLDS_Shield_func(id,1,processfilex,id,1,EOS)
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
	if(!is_user_connected(id)){
		new MSG_ReadShort = Add_MSG_ReadShort()
		new pampamx[200]
		new VoiceMax = 4096
		formatex(pampamx,charsmax(pampamx),"%s You are detected for %s (%d)",PrefixProtection,voicedatabug,MSG_ReadShort)
		if(hola >=get_pcvar_num(LimitPrintf)){
			if(MSG_ReadShort > VoiceMax || MSG_ReadShort < 0){
				SV_RejectConnection_user(id,pampamx)
				if(get_pcvar_num(SendBadDropClient)>EOS){
					SV_Drop_function(id)
				}
				HLDS_Shield_func(id,EOS,voicedatabug,EOS,EOS,3)
				return okapi_ret_supercede
			}
		}
		else{
			if(MSG_ReadShort > VoiceMax || MSG_ReadShort < 0){
				SV_RejectConnection_user(id,pampamx)
				if(get_pcvar_num(SendBadDropClient)>EOS){
					SV_Drop_function(id)
				}
				HLDS_Shield_func(id,EOS,voicedatabug,EOS,17,3)
				return okapi_ret_supercede
			}
		}
	}
	return okapi_ret_ignore
}
public SV_ParseStringCommand_fix()
{
	new id = engfunc(EngFunc_GetCurrentPlayer)+0x01
	for (new i = EOS; i < sizeof (CommandBlockInpfnClientConnect); i++){
		if(containi(Argv(),CommandBlockInpfnClientConnect[i]) != -0x01){
			if(is_user_connecting(id)){
				if(get_pcvar_num(SendBadDropClient)>EOS){
					SV_Drop_function(id)
					return okapi_ret_supercede
				}
				HLDS_Shield_func(id,EOS,bugclc,EOS,8,1)
				return okapi_ret_supercede
			}
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
			if(get_pcvar_num(SendBadDropClient)>EOS){
				SV_Drop_function(id)
			}
			HLDS_Shield_func(id,EOS,overload2,EOS,EOS,3)
			locala[id]=0
		}
		return okapi_ret_supercede
	}
	else{
		if(MSG_ReadShort>get_pcvar_num(LimitResources)){
			SV_RejectConnection_user(id,pampam)
			if(get_pcvar_num(SendBadDropClient)>EOS){
				SV_Drop_function(id)
			}
			HLDS_Shield_func(id,EOS,overload2,EOS,17,3)
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
		HLDS_Shield_func(EOS,EOS,netbug,EOS,11,4)
	}
	return okapi_ret_supercede;
}
public FS_Open_Hook(abc[])
{
	/*
	if(!is_linux_server()){
		if(containi(abc,".ini")!=-0x01 || containi(abc,"server.cfg")!=-0x01){
			server_print("%s I found a access strange in ^"%s^"",PrefixProtection,abc)
			return okapi_ret_supercede
		}
		
		return okapi_ret_ignore
	}
	return 0
	*/
	
}
public SV_CheckPermisionforStatus(){
	
	new id = engfunc(EngFunc_GetCurrentPlayer)+0x01
	
	if(is_user_connecting(id)){
		return okapi_ret_supercede
	}
	if(is_user_admin(id)){
		ReBuild_Status(1)
	}
	else{
		if(!id){
			ReBuild_Status(2) // is server
		}
		else{
			ReBuild_Status(0)
		}
	}
	return okapi_ret_supercede
}
public ReBuild_Status(steamidshow){
	
	new players[a_max],MapName[a_max],AddressHLDS[a_max],EngineHLDS[a_max],EngineHostName[a_max],num
	new PlayerName[a_max],PlayerSteamID[a_max],PingPlayer,LossPlayer
	new id = engfunc(EngFunc_GetCurrentPlayer)+0x01
	
	get_players(players, num)
	get_mapname(MapName,charsmax(MapName))
	get_cvar_string("net_address",AddressHLDS,charsmax(AddressHLDS))
	get_cvar_string("sv_version",EngineHLDS,charsmax(EngineHLDS))
	get_cvar_string("hostname",EngineHostName,charsmax(EngineHostName))
	
	new stringbuffer[500]
	
	if(steamidshow == 2){
		server_print("^nPlayers : %d/%d",get_playersnum(),get_maxplayers())
		server_print("Map : %s",MapName)
		server_print("TCP/IP : %s",AddressHLDS)
		server_print("Engine : %s",EngineHLDS)
		server_print("HostName : %s^n",EngineHostName)
	}
	else{
		formatex(stringbuffer,charsmax(stringbuffer),"^nPlayers : %d/%d^n",get_playersnum(),get_maxplayers())
		SVC_PrintConsole(id,stringbuffer)
		formatex(stringbuffer,charsmax(stringbuffer),"Map : %s^n",MapName)
		SVC_PrintConsole(id,stringbuffer)
		formatex(stringbuffer,charsmax(stringbuffer),"TCP/IP : %s^n",AddressHLDS)
		SVC_PrintConsole(id,stringbuffer)
		formatex(stringbuffer,charsmax(stringbuffer),"Engine : %s^n",EngineHLDS)
		SVC_PrintConsole(id,stringbuffer)
		formatex(stringbuffer,charsmax(stringbuffer),"HostName : %s^n",EngineHostName)
		SVC_PrintConsole(id,stringbuffer)
	}
	
	if(steamidshow == 1){
		SVC_PrintConsole(id,"[Name:] [UserID:] [SteamID:] [FRAG:] [TIME PLAYED:] [PING:]^n")
	}
	else if(steamidshow == EOS){
		SVC_PrintConsole(id,"[Name:] [UserID:] [FRAG:] [TIME PLAYED:] [PING:]^n")
	}
	else{
		server_print("[Name:] [UserID:] [SteamID:] [FRAG:] [TIME PLAYED:] [PING:]^n")
	}
	
	
	for(new i = EOS ; i < num ; i++){
		new PlayerTime=get_user_time(players[i])
		if(steamidshow == 1 || steamidshow == 2){
			get_user_authid(players[i],PlayerSteamID,charsmax(PlayerSteamID))
		}
		get_user_name(players[i],PlayerName,charsmax(PlayerName))
		get_user_ping(players[i],PingPlayer,LossPlayer)
		
		if(is_user_bot(players[i])){
			if(steamidshow == 3){
				server_print("[%s]-[VALVE_BOT]-[FRAGS : %d]-[%d Seconds]",PlayerName,get_user_frags(players[i]),PlayerTime)
			}
			else{
				formatex(stringbuffer,charsmax(stringbuffer),"[%s]-[VALVE_BOT]-[FRAGS : %d]-[%d Seconds]^n",PlayerName,get_user_frags(players[i]),PlayerTime)
				SVC_PrintConsole(id,stringbuffer)
			}
		}
		
		if(steamidshow == 1){
			formatex(stringbuffer,charsmax(stringbuffer),"[%s]-[%i]-[%s]-[%d]-[%d Seconds]-[%d]^n",PlayerName,get_user_userid(players[i]),PlayerSteamID,get_user_frags(players[i]),PlayerTime,PingPlayer)
			SVC_PrintConsole(id,stringbuffer)
			
		}
		else if(steamidshow == EOS){
			formatex(stringbuffer,charsmax(stringbuffer),"[%s]-[%i]-[%d]-[%d Seconds]-[%d]^n",PlayerName,get_user_userid(players[i]),get_user_frags(players[i]),PlayerTime,PingPlayer)
			SVC_PrintConsole(id,stringbuffer)
			
		}
		else{
			server_print("[%s]-[%i]-[%s]-[%d]-[%d Seconds]-[%d]",PlayerName,get_user_userid(players[i]),PlayerSteamID,get_user_frags(players[i]),PlayerTime,PingPlayer)
		}
	}
}
public SV_RunCmd_Hook()
{
	// functia este apelata mereu (loop)
	// asta trebui testat mai mult pe linux
	// testeaza cu 32 de jucatori si un atac catre server
	// testeaza doar cu 32 de jucatori si fara atac
	
	if(get_pcvar_num(LimitImpulse)== EOS){
		return okapi_ret_ignore
	}
	else if (get_pcvar_num(LimitImpulse)>EOS){
		new id = engfunc(EngFunc_GetCurrentPlayer)+0x01
		if(id){
			if(is_user_connected(id))
			{
				if(UserCheckImpulse[id] == EOS){
					limit[id]++
					if(limit[id] >= get_pcvar_num(LimitImpulse)){
						locala[id]++
						
						//if(get_pcvar_num(SendBadDropClient)>EOS){
						///	SV_Drop_function(id) == crash ?????
						//}
						
						if(locala[id] >=get_pcvar_num(LimitPrintf)){
							return okapi_ret_supercede
						}
						else{
							HLDS_Shield_func(id,EOS,cmdrun,EOS,1,1)
							UserCheckImpulse[id] = 1
							return okapi_ret_supercede;
						}
					}
				}
			}
		}
	}
	return okapi_ret_ignore
}
public SV_CheckForDuplicateSteamID(id){
	//procedure function fix sv_checkforduplicatesteamid
	
	new CertificateSteamID[50],AllUserCertificateSteamID[50]
	
	get_user_authid(id,CertificateSteamID,charsmax(CertificateSteamID))
	
	for(new i = 1; i <= g_MaxClients; i++){
		
		if(is_user_connected(i)){
			get_user_authid(i,AllUserCertificateSteamID,charsmax(AllUserCertificateSteamID))
		}
		if(containi(CertificateSteamID, AllUserCertificateSteamID) != -1){
			locala[id]++
			new longtext[255]
			formatex(longtext,charsmax(longtext),"%s Your SteamID is duplicated %s",PrefixProtection,CertificateSteamID)
			SV_RejectConnection_user(id,longtext)
			if(debug_s[id]== EOS){
				if(locala[id] == 3){
					locala[id]=1
					debug_s[id]=1
				}
			}
			HLDS_Shield_func(id,EOS,steamidhack,1,1,EOS)
		}		
	}
	//end
}
public Shield_CheckSteamID(id,payload)  {
	new ValutKey[71]
	new ValutData[256]
	
	format(ValutKey,70,"%s-IP", szip) 
	format(ValutData,255,"%s-SteamID", authid) 
	
	if(payload == 1)
	{
		nvault_set(valutsteamid, ValutKey, ValutData) 
		get_user_authid(id, authid2, charsmax(authid2))
		get_user_ip(id, szip2, charsmax(szip2), 0)
		
		if(equal(szip2, szip)) {
			if(!equal(authid2, authid)) {
				HLDS_Shield_func(id,EOS,steamidhack,1,1,1)
				if(get_pcvar_num(SendBadDropClient)>EOS){
					SV_Drop_function(id)
				}
			}
		}
	}
	else if(payload == 2){
		get_user_authid(id, authid, charsmax(authid))
		get_user_ip(id, szip, charsmax(szip), 0)
		nvault_set(valutsteamid, ValutKey, ValutData)
	}
	return PLUGIN_HANDLED
}
public plugin_end(){
	TrieDestroy(gTrie)
	ArrayDestroy(gFileData)
	SV_UpTime(2)
	Destroy_Fileiplist()
	nvault_close(valutsteamid)
}
public SHIELD_NameDeBug(id){
	NameUnLock[id-TASK_ONE2] = EOS
}

public SHIELD_NameDeBug2(id){
	NameUnLock[id] = 2
}
public pfnClientUserInfoChanged(id,buffer){
	static szOldName[a_max],szNewName[200],longformate[255]
	pev(id,pev_netname,szOldName,charsmax(szOldName))
	formatex(longformate,charsmax(longformate),"(#%d)%s",GetUserID(id),szOldName)
	get_user_info(id,"name",szNewName,charsmax(szNewName))
	new lastname[a_max]
	if(is_user_admin(id)){
		if(!equal(lastname,UserName(id))){
			show_menu(id,EOS,"^n",0x01)
		}
	}
	if(get_pcvar_num(NameCharFix)==1){
		if(containi(szNewName,"&") !=-1){
			replace_all(szNewName,charsmax(szNewName),"&","ï¼†")
			replace_all(szNewName,charsmax(szNewName),"&","*")
			set_user_info(id,"name",szNewName) 
		}
		if(containi(szNewName,"%") !=-1){
			replace_all(szNewName,charsmax(szNewName),"%","ï¼…")
			replace_all(szNewName,charsmax(szNewName),"%","*")
			set_user_info(id,"name",szNewName)
		}
		if(containi(szNewName,"#") !=-1){
			replace_all(szNewName,charsmax(szNewName),"#","ï¼ƒ")
			replace_all(szNewName,charsmax(szNewName),"#","*")
			set_user_info(id,"name",szNewName) 
		}
		
	}
	if(get_pcvar_num(NameCharFix)==2){
		if(containi(szNewName,"&") !=-1){
			replace_all(szNewName,charsmax(szNewName),"&","*")
			set_user_info(id,"name",szNewName) 
		}
		if(containi(szNewName,"%") !=-1){
			replace_all(szNewName,charsmax(szNewName),"%","*")
			set_user_info(id,"name",szNewName) 
		}
		if(containi(szNewName,"#") !=-1){
			replace_all(szNewName,charsmax(szNewName),"#","*")
			set_user_info(id,"name",szNewName) 
		}
		
	}
	
	if(get_pcvar_num(NameBug)>EOS){
		if(is_linux_server()){
			if(is_user_connected(id)){
				new Count=admins_num()
				new NameList[b_max],PWList[b_max],MyPW[a_max],PlayerPW[a_max]
				
				for (new i = EOS; i < Count; ++i){	
					admins_lookup(i,AdminProp_Auth,NameList,charsmax(NameList))
					admins_lookup(i,AdminProp_Password,PWList,charsmax(PWList))
					get_cvar_string("amx_password_field",MyPW,charsmax(MyPW))
					get_user_info(id,MyPW,PlayerPW,charsmax(PlayerPW))
					if(equal(UserName(id),NameList)){
						if(!equal(PlayerPW,PWList)){
							HLDS_Shield_func(id,2,adminbug,1,1,1)
							return FMRES_SUPERCEDE
						}
					}
				}
			}
		}
		
		if(is_linux_server()){
			for (new i = EOS; i < sizeof (MessageHook); i++){
				if(containi(Argv2(),MessageHook[i]) != -0x01){
					locala[id]++
					if(locala[id] >=get_pcvar_num(LimitPrintf)){
						set_user_info(id,"name",longformate)
						return FMRES_SUPERCEDE
					}
					else{
						if(debug_s[id]== EOS){
							if(locala[id] == 3){
								locala[id]=1
								debug_s[id]=1
							}
						}
						HLDS_Shield_func(id,1,namebug,1,5,EOS)
						set_user_info(id,"name",longformate) 
						return FMRES_SUPERCEDE
					}
				}
			}
		}
	}
	if(get_pcvar_num(NameBugShowMenu)>EOS){
		new lastname[a_max]
		get_user_info(id,"name",lastname,charsmax(lastname))
		if(!equal(lastname,UserName(id))){
			SV_CheckUserNameForMenuStyle(id,lastname)
		}
		
	}
	if(get_pcvar_num(NameSpammer)>EOS){
		new get_time_cvar = get_pcvar_num(TimeNameChange)
		if(containi(szNewName,"%") !=-1){
			if (NameUnLock[id]==2){
				NameUnLock[id] = 2
				client_print_color(id,id,"^4%s^1 Please wait^4 %d seconds^1 before change the name",PrefixProtection,get_time_cvar)
				set_user_info(id,"name",longformate) 
				set_task(float(get_time_cvar),"SHIELD_NameDeBug",id+TASK_ONE2)
				return FMRES_SUPERCEDE
			}
			
			NameUnLock[id] = EOS
			set_task(0.3,"SHIELD_NameDeBug2",id+TASK_ONE2)
			return FMRES_SUPERCEDE
			
		}
		if(szOldName[0]) {
			if(!equal(szOldName,szNewName)) {
				if (NameUnLock[id] == 1){
					NameUnLock[id] = 1
					client_print_color(id,id,"^4%s^1 Please wait^4 %d seconds^1 before change the name",PrefixProtection,get_time_cvar)
					set_user_info(id,"name",longformate)
					return FMRES_SUPERCEDE
				}
				NameUnLock[id] = 1
				set_task(float(get_time_cvar),"SHIELD_NameDeBug",id+TASK_ONE2)
			}
		}
	}
	if(ServerVersion == EOS){
		if(get_pcvar_num(UnicodeName)>EOS){
			if(cmpStr2(Args())){
				locala[id]++
				if(locala[id] >=get_pcvar_num(LimitPrintf)){
					set_user_info(id,"name",longformate)
					return FMRES_SUPERCEDE
				}
				else{
					if(debug_s[id]== EOS){
						if(locala[id] == 3){
							locala[id]=1
							debug_s[id]=1
						}
					}
					HLDS_Shield_func(id,1,namebug,1,5,EOS)
					set_user_info(id,"name",longformate) 
					return FMRES_SUPERCEDE
				}
			}
		}
	}
	return FMRES_IGNORED
}
public Info_ValueForKey_Hook(index)
{
	if(get_pcvar_num(NameBug)>EOS){
		new id = engfunc(EngFunc_GetCurrentPlayer)+0x01
		if(!is_linux_server()){ // windows
			if(is_user_connected(id)){
				new Count=admins_num()
				new NameList[b_max],PWList[b_max],MyPW[a_max],PlayerPW[a_max]
				
				for (new i = EOS; i < Count; ++i){	
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
		}
		if(!is_linux_server()){ // windows
			for (new i = EOS; i < sizeof (MessageHook); i++){
				if(containi(Argv2(),MessageHook[i]) != -0x01){
					locala[id]++
					if(locala[id] >=get_pcvar_num(LimitPrintf)){
						return okapi_ret_supercede
					}
					else{
						if(debug_s[id]== EOS){
							if(locala[id] == 3){
								locala[id]=1
								debug_s[id]=1
							}
						}
						HLDS_Shield_func(id,1,namebug,1,5,EOS)
					}
					return okapi_ret_supercede;
				}
			}
		}
	}
	return okapi_ret_ignore
}
public plugin_pause(){
	new get[a_max]
	get_plugin(-1,get,charsmax(get))
	server_cmd("amxx unpause %s",get)
	log_to_file(settings,"%s Failed to pause plugin ^"%s^"",PrefixProtection,get)
	client_print_color(EOS,EOS,"^4%s^1 : Failed to pause plugin ^"%s^"",PrefixProtection,get)
}
public Host_Say_f_Hook(){
	if(get_pcvar_num(CommandBug)>EOS){
		for (new i = EOS; i < sizeof (MessageHook); i++){
			if(containi(Args(),MessageHook[i]) != -1){
				hola++
				if(hola >=get_pcvar_num(LimitPrintf)){
					return okapi_ret_supercede
				}
				else{
					HLDS_Shield_func(EOS,EOS,cmdbug,EOS,10,EOS)
					return okapi_ret_supercede;
				}
			}
		}
	}
	new hostname[50]
	get_cvar_string("hostname",hostname,charsmax(hostname))
	if( strlen(Args())>=139 ){
		return okapi_ret_supercede;
	}
	
	client_print_color(EOS,EOS,"^4%s (Console)^1 : %s",hostname,Args())
	log_amx("%s (Console) : %s",hostname,Args())
	return okapi_ret_supercede;
}
public SV_ConnectClient_Hook()
{
	new data[net_adr],value[1024],buffer[300],getip[MAX_BUFFER_IP],checkduplicate[255]
	
	read_argv(0x04,value,charsmax(value))
	BufferName(value,charsmax(value),buffer)
	formatex(checkduplicate,charsmax(checkduplicate),"^x25^x73^x5C^x6E^x61^x6D^x65^x5C",buffer)
	
	replace_all(buffer,charsmax(buffer),"%","^x00")
	replace_all(buffer,charsmax(buffer),"#","^x00")
	replace_all(buffer,charsmax(buffer),"&","^x00")
	
	if(get_pcvar_num(RandomSteamid)>EOS){
		//8af049309c7356585ae4b48ed7471802 = CT-Shield 1.0
		if(containi(Argv3(),"8af049309c7356585ae4b48ed7471802") != -0x01 ){ // for restrict cdkey
			if(ServerVersion == EOS){
				okapi_get_ptr_array(net_adrr(),data,net_adr)
				formatex(getip,charsmax(getip),"%d.%d.%d.%d",data[ip][EOS], data[ip][0x01], data[ip][0x02], data[ip][0x03])
			}
			else{
				formatex(getip,charsmax(getip),"not supported for rehlds")
			}
			HLDS_Shield_func(EOS,EOS,steamidhack,EOS,8,EOS)
			if(get_pcvar_num(OptionSV_ConnectClient)==1){
				return okapi_ret_supercede
			}
			else if(get_pcvar_num(OptionSV_ConnectClient)==2){
				server_cmd("kick ^%s^" ^"%s^"",buffer,steamidhack)
				server_cmd("kick %s ^"%s^"",buffer,steamidhack)
			}
			else if(get_pcvar_num(OptionSV_ConnectClient)>=3){
				server_cmd("addip %d %s",get_pcvar_num(PauseDlfile),getip)
				server_cmd("kick ^"%s^" ^"%s^"",buffer,steamidhack)
				server_cmd("kick %s ^"%s^"",buffer,steamidhack)
			}
		}
	}
	
	if(get_pcvar_num(DumpConnector)>EOS){
		if(ServerVersion == EOS){
			okapi_get_ptr_array(net_adrr(),data,net_adr)
			formatex(getip,charsmax(getip),"%d.%d.%d.%d",data[ip][EOS], data[ip][0x01], data[ip][0x02], data[ip][0x03])
		}
		else{
			formatex(getip,charsmax(getip),"not supported for rehlds")
		}
		log_to_file(dumpconnect,"------------------------------------------------------------------------")
		log_to_file(dumpconnect,"|UserName : %s",buffer)
		log_to_file(dumpconnect,"|Address  : %s",getip)
		log_to_file(dumpconnect,"|Protocol : %s",Argv3())
		log_to_file(dumpconnect,"|Userinfo : %s",Argv4())
		
	}
	if(IsInvalidFunction(2,"userinfo")){
		if(get_pcvar_num(OptionSV_ConnectClient)==3){
			server_cmd("addip %d %s",get_pcvar_num(PauseDlfile),getip)
			server_cmd("kick ^"%s^" ^"%s^"",buffer,namebug)
			server_cmd("kick %s ^"%s^"",buffer,namebug)
		}
		return okapi_ret_supercede
	}
	
	if(get_pcvar_num(NameProtector)>EOS){
		for (new i = EOS; i < sizeof (MessageHook); i++){
			if(containi(buffer,MessageHook[i]) != -0x01){
				replace_all(buffer,0x21,"%","^x20")
				if(ServerVersion == EOS){
					okapi_get_ptr_array(net_adrr(),data,net_adr)
					formatex(getip,charsmax(getip),"%d.%d.%d.%d",data[ip][EOS], data[ip][0x01], data[ip][0x02], data[ip][0x03])
				}
				else{
					formatex(getip,charsmax(getip),"not supported for rehlds")
				}
				server_cmd("kick ^"%s^" ^"%s^"",buffer,namebug)
				server_cmd("kick %s ^"%s^"",buffer,namebug)
				HLDS_Shield_func(EOS,EOS,namebug,EOS,9,5)
			}
		}
	}
	if((containi(buffer,"^x2e^x2e") != -0x01 || containi(buffer,"^x22") != -0x01
	|| containi(buffer,"^x2e^xfa^x2e") != -0x01) ){
		if(ServerVersion == EOS){
			okapi_get_ptr_array(net_adrr(),data,net_adr)
			formatex(getip,charsmax(getip),"%d.%d.%d.%d",data[ip][EOS], data[ip][0x01], data[ip][0x02], data[ip][0x03])
		}
		else{
			formatex(getip,charsmax(getip),"not supported for rehlds")
		}
		HLDS_Shield_func(EOS,EOS,hldsbug,EOS,8,3)
		if(get_pcvar_num(OptionSV_ConnectClient)==1){
			return okapi_ret_supercede
		}
		else if(get_pcvar_num(OptionSV_ConnectClient)==2){
			server_cmd("kick ^"%s^" ^"%s^"",buffer,namebug)
			server_cmd("kick %s ^"%s^"",buffer,namebug)
		}
		else if(get_pcvar_num(OptionSV_ConnectClient)>=3){
			server_cmd("addip %d %s",get_pcvar_num(PauseDlfile),getip)
			server_cmd("kick ^"%s^" ^"%s^"",buffer,namebug)
			server_cmd("kick %s ^"%s^"",buffer,namebug)
		}
	}
	if(containi(Argv4(),checkduplicate) != -1){
		if(ServerVersion == EOS){
			okapi_get_ptr_array(net_adrr(),data,net_adr)
			formatex(getip,charsmax(getip),"%d.%d.%d.%d",data[ip][EOS], data[ip][0x01], data[ip][0x02], data[ip][0x03])
		}
		else{
			formatex(getip,charsmax(getip),"not supported for rehlds")
		}
		HLDS_Shield_func(EOS,EOS,namebug,EOS,8,3)
		if(get_pcvar_num(OptionSV_ConnectClient)==1){
			return okapi_ret_supercede
		}
		else if(get_pcvar_num(OptionSV_ConnectClient)==2){
			server_cmd("kick ^"%s^" ^"%s^"",buffer,namebug)
		}
		else if(get_pcvar_num(OptionSV_ConnectClient)>=3){
			server_cmd("addip %d %s",get_pcvar_num(PauseDlfile),getip)
			server_cmd("kick ^"%s^" ^"%s^"",buffer,namebug)
		}
	}
	if(get_pcvar_num(HLTVFilter)>EOS){
		if((containi(value,"*hltv") != -0x01)){
			if(ServerVersion == EOS){
				okapi_get_ptr_array(net_adrr(),data,net_adr)
				formatex(getip,charsmax(getip),"%d.%d.%d.%d",data[ip][EOS], data[ip][0x01], data[ip][0x02], data[ip][0x03])
			}
			else{
				formatex(getip,charsmax(getip),"not supported for rehlds")
			}
			HLDS_Shield_func(EOS,EOS,hltvbug,EOS,8,3)
			if(get_pcvar_num(OptionSV_ConnectClient)==1){
				return okapi_ret_supercede
			}
			else if(get_pcvar_num(OptionSV_ConnectClient)==2){
				server_cmd("kick ^"%s^" ^"%s^"",buffer,hltvbug)
				server_cmd("kick %s ^"%s^"",buffer,hltvbug)
			}
			else if(get_pcvar_num(OptionSV_ConnectClient)>=3){
				server_cmd("addip %d %s",get_pcvar_num(PauseDlfile),getip)
				server_cmd("kick ^"%s^" ^"%s^"",buffer,hltvbug)
				server_cmd("kick %s ^"%s^"",buffer,hltvbug)
			}
		}
	}
	if(get_pcvar_num(HLProxyFilter)>EOS){
		if((containi(value,"_ip") != -0x01)){
			SV_RejectConnection_Hook(1,"Hello") // merge doar ca fara dproto
			if(ServerVersion == EOS){
				okapi_get_ptr_array(net_adrr(),data,net_adr)
				formatex(getip,charsmax(getip),"%d.%d.%d.%d",data[ip][EOS], data[ip][0x01], data[ip][0x02], data[ip][0x03])
			}
			else{
				formatex(getip,charsmax(getip),"not supported for rehlds")
			}
			HLDS_Shield_func(EOS,EOS,hlproxy,EOS,8,4)
			if(get_pcvar_num(OptionSV_ConnectClient)==1){
				return okapi_ret_supercede
			}
			else if(get_pcvar_num(OptionSV_ConnectClient)==2){
				server_cmd("kick ^"%s^" ^"%s^"",buffer,hlproxy)
				server_cmd("kick %s ^"%s^"",buffer,hlproxy)
			}
			else if(get_pcvar_num(OptionSV_ConnectClient)>=3){
				server_cmd("addip %d %s",get_pcvar_num(PauseDlfile),getip)
				server_cmd("kick %s ^"%s^"",buffer,hlproxy)
				server_cmd("kick %s ^"%s^"",buffer,hlproxy)
			}
		}
	}
	if(get_pcvar_num(FakePlayerFilter)>EOS){
		if(!(containi(value,"\_cl_autowepswitch\1\") != -0x01 || containi(value,"\_cl_autowepswitch\0\") != -0x01)){
			if(ServerVersion == EOS){
				okapi_get_ptr_array(net_adrr(),data,net_adr)
				formatex(getip,charsmax(getip),"%d.%d.%d.%d",data[ip][EOS], data[ip][0x01], data[ip][0x02], data[ip][0x03])
			}
			else{
				formatex(getip,charsmax(getip),"not supported for rehlds")
			}
			HLDS_Shield_func(EOS,EOS,fakeplayer,EOS,8,EOS)
			if(get_pcvar_num(OptionSV_ConnectClient)==1){
				return okapi_ret_supercede
			}
			else if(get_pcvar_num(OptionSV_ConnectClient)==2){
				server_cmd("kick ^"%s^" ^"%s^"",buffer,fakeplayer)
				server_cmd("kick %s ^"%s^"",buffer,fakeplayer)
			}
			else if(get_pcvar_num(OptionSV_ConnectClient)>=3){
				server_cmd("addip %d %s",get_pcvar_num(PauseDlfile),getip)
				server_cmd("kick ^"%s^" ^"%s^"",buffer,fakeplayer)
				server_cmd("kick %s ^"%s^"",buffer,fakeplayer)
			}
		}
	}
	return okapi_ret_ignore;
	
}

public SV_CheckProtocolSpamming(bruteforce){
	new data[net_adr],szTemp[444];
	
	if(hola >=get_pcvar_num(LimitPrintf)){
		return okapi_ret_supercede
	}
	else{
		for( new i; i < ArraySize( g_blackList ); i++ ){
			ArrayGetString( g_blackList, i, szTemp, charsmax( szTemp ) )
			if(equal(getip2, szTemp)){
				if(ServerVersion == EOS){
					okapi_get_ptr_array(net_adrr(),data,net_adr)
					formatex(getip,charsmax(getip),"%d.%d.%d.%d",data[ip][EOS], data[ip][0x01], data[ip][0x02], data[ip][0x03])
					formatex(getip2,charsmax(getip2),"%d%d%d%d",data[ip][EOS], data[ip][0x01], data[ip][0x02], data[ip][0x03])
				}
				else{
					formatex(getip,charsmax(getip),"not supported for rehlds",data[ip][EOS], data[ip][0x01], data[ip][0x02], data[ip][0x03])
					formatex(getip2,charsmax(getip2),"not supported for rehlds",data[ip][EOS], data[ip][0x01], data[ip][0x02], data[ip][0x03])
				}
			}
		}
		set_task(bruteforce+0.0, "checkQuery")
		ArrayPushCell(g_aArray,str_to_num((getip2)))
	}
	return okapi_ret_ignore
}

public SV_SendRes_f_Hook(){
	new id = engfunc(EngFunc_GetCurrentPlayer)+0x01
	
	locala[id]++
	
	if(locala[id] >=get_pcvar_num(LimitPrintf)){
		return okapi_ret_supercede
	}
	else{
		if(locala[id] >=get_pcvar_num(LimitExploit)){
			if(get_pcvar_num(SendBadDropClient)>EOS){
				SV_Drop_function(id)
			}
			else{
				HLDS_Shield_func(id,1,hldsprintf,1,5,1)
			}
			if(strlen(UserName(id))){
				HLDS_Shield_func(id,1,hldsres,1,5,EOS)
			}
			else{
				HLDS_Shield_func(EOS,EOS,hldsres,EOS,3,EOS)
			}		
			return okapi_ret_supercede
		}
	}
	return okapi_ret_ignore
}
public Host_ShutDown_Hook(){
	if(get_pcvar_num(ShutdownServer)>EOS){
		return okapi_ret_supercede
	}
	else{
		set_task(1.0,"SV_LostConnectionDelay",EOS,"",EOS,"b")
		return okapi_ret_supercede
	}
	return okapi_ret_ignore
}
public SV_LostConnectionDelay(){
	if(lostconnection==get_pcvar_num(LostConnectionSeconds)){
		for(new i = 1; i <= g_MaxClients; i++){
			if(is_user_connected(i)){
				SV_RejectConnection_user(i,"Server lost connection")
				lostconnection=0
				log_to_file(settings,"%s Server lost connection",PrefixProtection)
			}
			set_task(0.5,"force_exit")
		}
	}
	else{
		for(new i = 1; i <= g_MaxClients; i++){
			if(is_user_connected(i)){
				set_hudmessage(255, 0, 0, -1.0, 0.22, 0, 6.0, 1.0)
				show_hudmessage(i, "Warrning : Server lost connection in %d/%d",lostconnection,get_pcvar_num(LostConnectionSeconds))
			}
		}
	}
	lostconnection++	
}
public Con_Printf_Hook(pfnprint[])
{
	if(get_pcvar_num(SV_RconCvar)==3){
		if(containi(pfnprint,"Bad rcon_password.")!=-0x01){
			HLDS_Shield_func(EOS,EOS,hldsrcon,EOS,8,4)
			return okapi_ret_supercede
		}
	}
	new id = engfunc(EngFunc_GetCurrentPlayer)+0x01
	if(id){
		if(
		containi(pfnprint,"Info string length exceeded")!=-0x01 || 
		containi(pfnprint,"Can't set * keys")!=-0x01 || 
		containi(pfnprint,"Ignoring invalid custom decal from %s")!=-0x01 || 
		containi(pfnprint,"Non customization in upload queue!")!=-0x01 || 
		containi(pfnprint,"usage: setinfo [ <key> <value> ]")!=-0x01 || 
		containi(pfnprint,"Can't use keys or values with a ^x22")!=-0x01 || 
		containi(pfnprint,"usage:  kick < name > | < # userid >")!=-0x01 || 
		containi(pfnprint,"Can't use keys or values with a \")!=-0x01 || 
		containi(pfnprint,"Keys and values must be < %i characters and > 0.")!=-0x01){
			if(is_user_connected(id)){
				new build[varmax]
				get_cvar_string("hostname",build,charsmax(build))
				locala[id]++
				
				if(locala[id] >=get_pcvar_num(LimitPrintf)){
					return okapi_ret_supercede
				}
				else
				{
					if(locala[id] >=get_pcvar_num(LimitExploit)){
						if(get_pcvar_num(SendBadDropClient)>EOS){
							SV_Drop_function(id)
						}
						else{
							HLDS_Shield_func(id,1,hldsprintf,1,5,1)
						}
						return okapi_ret_supercede
					}
					if(strlen(UserName(id))){
						if(debug_s[id]== EOS){
							if(locala[id] == 3){
								locala[id]=1
								debug_s[id]=1
							}
						}
						HLDS_Shield_func(id,1,hldsprintf,1,5,EOS)
					}
					else{
						HLDS_Shield_func(EOS,EOS,hldsprintf,EOS,3,EOS)
					}
				}
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
		HLDS_Shield_func(EOS,EOS,netbug,EOS,11,EOS)
		return okapi_ret_supercede
	}
	return okapi_ret_ignore
}

public SV_RejectConnection_Hook(a,b[])
{
	long = OrpheuGetFunction("MSG_ReadLong")
	return OrpheuCallSuper(long)
}
public FalseAllFunction(id)
{
	UserCheckImpulse[id] = 0x01
	locala[id] = EOS
	tralala = EOS
	usercheck[id] = EOS
	debug_s[id]  = EOS
	limitexecute[id] = EOS
	overflowed[id] = EOS
	limit[id] = EOS
	local = EOS
	limitb[id] = EOS
	mungelimit[id] = EOS
}
public SV_DropClient_Hook(int,int2,string[],index)
{
	new id = engfunc(EngFunc_GetCurrentPlayer)+0x01
	checkuser[id] = EOS
	
	if(containi(string,"Bad file %s")!=-0x01){
		return okapi_ret_supercede
	}
	if(get_pcvar_num(VAC)>EOS){
		if(containi(string,"VAC banned from secure server")!=-0x01){
			return okapi_ret_supercede
		}
	}
	if(containi(string,"Reliable channel overflowed")!=-0x01){
		locala[id]++
		if(locala[id] >=get_pcvar_num(MaxOverflowed)){
			if(is_user_connected(id)){
				new longtext[255]
				overflowed[id]++
				formatex(longtext,charsmax(longtext),"[%s] Reliable channel overflowed of %d",PrefixProtection,overflowed[id])
				SV_RejectConnection_user(id,longtext)
			}
			return okapi_ret_supercede
		}
		else{
			locala[id]++
			if(locala[id] >=get_pcvar_num(LimitPrintf)){
				return okapi_ret_supercede
			}
			else{
				if(!strlen(UserName(id))){
					HLDS_Shield_func(id,1,hldsoverflowed,1,3,1)	
				}
				else{
					HLDS_Shield_func(id,1,hldsoverflowed,1,1,EOS)
				}
			}
		}
		return okapi_ret_supercede
	}
	FalseAllFunction(id)
	return okapi_ret_ignore
}
public PfnClientDisconnect(id){
	if(task_exists(id+TASK_Detect)){
		remove_task(id+TASK_Detect)
	}
	if(get_pcvar_num(RandomSteamid)>EOS){
		Shield_CheckSteamID(id,2)
	}
	DelaySpamBotStop[id] = 0.0
	DelaySpamBotStart[id] = 0.0
	remove_task(id)
	limitba[id]=EOS
	FalseAllFunction(id)
}
public SV_Spawn_f_Hook()
{
	new id = engfunc(EngFunc_GetCurrentPlayer)+0x01
	limit[id]++
	if(limit[id] >=get_pcvar_num(LimitExploit)){
		locala[id]++
		if(locala[id] >=get_pcvar_num(LimitPrintf)){
			return okapi_ret_supercede
		}
		else{
			if(!strlen(UserName(id))){
				if(get_pcvar_num(SendBadDropClient)>EOS){
					SV_Drop_function(id)
				}
				HLDS_Shield_func(id,1,hldspawn,1,5,1)
				return okapi_ret_supercede
			}
			else{
				if(get_pcvar_num(SendBadDropClient)>EOS){
					SV_Drop_function(id)
				}
				HLDS_Shield_func(id,2,hldspawn,1,5,1)
				return okapi_ret_supercede
			}
		}
		return okapi_ret_supercede
	}
	return okapi_ret_ignore	
}
