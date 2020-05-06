#include <amxmodx>
#include <customshop>
#include <hamsandwich>
#include <fun>

new const PLUGIN_VERSION[] = "1.0.1"

#if !defined MAX_PLAYERS
const MAX_PLAYERS = 32
#endif

#define ARG_AMOUNT "Amount"
#define ARG_MAX_HEALTH "Max Health"

additem ITEM_VAMPIRE
new g_bVampire[MAX_PLAYERS + 1]
new g_szVampireFactor[8], g_iMaxHealth

public plugin_init()
{
	register_plugin("CSHOP: Vampire", PLUGIN_VERSION, "OciXCrom")
	register_cvar("CSHOPVampire", PLUGIN_VERSION, FCVAR_SERVER|FCVAR_SPONLY|FCVAR_UNLOGGED)
	RegisterHam(Ham_TakeDamage, "player", "PreTakeDamage", 0)
	cshop_get_string(ITEM_VAMPIRE, ARG_AMOUNT, g_szVampireFactor, charsmax(g_szVampireFactor))
	g_iMaxHealth = cshop_get_int(ITEM_VAMPIRE, ARG_MAX_HEALTH)
}

public plugin_precache()
{
	ITEM_VAMPIRE = cshop_register_item("vampire", "Vampire", 3000)
	cshop_set_string(ITEM_VAMPIRE, ARG_AMOUNT, "25%")
	cshop_set_int(ITEM_VAMPIRE, ARG_MAX_HEALTH, 100)
}

public client_putinserver(id)
{
	g_bVampire[id] = false
}

public cshop_item_selected(id, iItem)
{
	if(iItem == ITEM_VAMPIRE)
	{
		g_bVampire[id] = true
	}
}

public cshop_item_removed(id, iItem)
{
	if(iItem == ITEM_VAMPIRE)
	{
		g_bVampire[id] = false
	}
}

public PreTakeDamage(iVictim, iInflictor, iAttacker, Float:fDamage)
{
	if(is_user_connected(id) && g_bVampire[iAttacker])
	{
		new iHealth = get_user_health(iAttacker)

		if(iHealth < g_iMaxHealth)
		{
			set_user_health(iAttacker, min(iHealth + floatround(math_add_f(fDamage, g_szVampireFactor)), g_iMaxHealth))
		}
	}
}

Float:math_add_f(Float:fNum, const szMath[])
{
	static szNewMath[16], Float:fMath, bool:bPercent, cOperator

	copy(szNewMath, charsmax(szNewMath), szMath)
	bPercent = szNewMath[strlen(szNewMath) - 1] == '%'
	cOperator = szNewMath[0]

	if(!isdigit(szNewMath[0]))
	{
		szNewMath[0] = ' '
	}

	if(bPercent)
	{
		replace(szNewMath, charsmax(szNewMath), "%", "")
	}

	trim(szNewMath)
	fMath = str_to_float(szNewMath)

	if(bPercent)
	{
		fMath *= fNum / 100
	}

	switch(cOperator)
	{
		case '+': fNum += fMath
		case '-': fNum -= fMath
		case '/': fNum /= fMath
		case '*': fNum *= fMath
		default: fNum = fMath
	}

	return fNum
}
