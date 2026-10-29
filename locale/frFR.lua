local _, ns = ...

if GetLocale() ~= "frFR" then return end

local L = ns.L

L.ENABLED = "Activé"
L.DISABLED = "Désactivé"
L.STATE = "Le statut est : %s"
L.PAUSED_HINT = "Maintenez %s pour le suspendre."
L.OPT_UNAVAILABLE = "Le panneau d'options n'est pas disponible sur ce client."
L.HELP = "Usage : /am [on|off|config]"

L.OPT_ENABLE = "Activer AutoMisc"
L.OPT_ENABLE_TIP = "Interrupteur général de toutes les fonctionnalités d'AutoMisc."
L.OPT_MESSAGES = "Messages dans le chat"
L.OPT_MESSAGES_TIP = "Affiche un court résumé dans le chat à chaque action d'AutoMisc."

L.OPT_PAUSE_SECTION = "Touches de pause"
L.OPT_PAUSE_SHIFT = "Pause quand Maj est enfoncée"
L.OPT_PAUSE_SHIFT_TIP = "AutoMisc ne fait rien tant que vous maintenez Maj."
L.OPT_PAUSE_CTRL = "Pause quand Ctrl est enfoncée"
L.OPT_PAUSE_CTRL_TIP = "AutoMisc ne fait rien tant que vous maintenez Ctrl."
L.OPT_PAUSE_ALT = "Pause quand Alt est enfoncée"
L.OPT_PAUSE_ALT_TIP = "AutoMisc ne fait rien tant que vous maintenez Alt."

L.OPT_VENDOR_SECTION = "Marchands"
L.OPT_SELL_JUNK = "Vendre les objets gris"
L.OPT_SELL_JUNK_TIP = "Vend tous les objets de qualité médiocre (gris) de vos sacs à l'ouverture d'un marchand."
L.OPT_REPAIR = "Réparer automatiquement"
L.OPT_REPAIR_TIP = "Répare tout votre équipement à l'ouverture d'un marchand qui peut réparer."
L.OPT_REPAIR_GUILD = "Utiliser d'abord les fonds de guilde"
L.OPT_REPAIR_GUILD_TIP = "Utilise la banque de guilde si vous êtes en guilde, qu'elle l'autorise et que l'allocation du jour couvre le coût."
L.OPT_REPAIR_PERSONAL = "Payer soi-même sinon"
L.OPT_REPAIR_PERSONAL_TIP = "Utilise votre or si vous n'avez pas de guilde, si la réparation de guilde n'est plus possible ou si la banque de guilde refuse."

L.OPT_SOCIAL_SECTION = "Social"
L.OPT_ACCEPT_SUMMON = "Accepter les invocations"
L.OPT_ACCEPT_SUMMON_TIP = "Accepte les invocations de démoniste et de pierre de rencontre (jamais en combat)."
L.OPT_ACCEPT_RESURRECT = "Accepter les résurrections"
L.OPT_ACCEPT_RESURRECT_TIP = "Accepte les résurrections proposées par d'autres joueurs."
L.OPT_DECLINE_DUELS = "Refuser les duels"
L.OPT_DECLINE_DUELS_TIP = "Refuse toutes les demandes de duel."
L.OPT_ACCEPT_INVITES = "Accepter les invitations des amis et de la guilde"
L.OPT_ACCEPT_INVITES_TIP = "Accepte les invitations de groupe des amis, amis Battle.net et membres de la guilde. Ignoré si vous êtes déjà en groupe."

L.MSG_SOLD = "%d objet(s) gris vendu(s) pour %s."
L.MSG_SOLD_UNKNOWN = "%d objet(s) gris vendu(s)."
L.MSG_REPAIRED_GUILD = "Réparation effectuée pour %s (fonds de guilde)."
L.MSG_REPAIRED_PERSONAL = "Réparation effectuée pour %s."
L.MSG_REPAIR_NO_GOLD = "Pas assez d'or pour réparer (%s nécessaires)."
L.MSG_SUMMON = "Invocation acceptée."
L.MSG_RESURRECT = "Résurrection de %s acceptée."
L.MSG_DUEL = "Duel de %s refusé."
L.MSG_INVITE = "Invitation de groupe de %s acceptée."
