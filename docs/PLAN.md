# AutoMisc — plan

Addon « petites choses utiles » (QoL) pour WoW Retail (`120105`) et Forever/Classic (`16001`), reparti de zéro à partir de la structure d'AutoQuests (projet séparé).

## Principes (repris d'AutoQuests)
- Panneau d'options Blizzard (Options > AddOns > AutoMisc) piloté par un **registre de fonctionnalités** : ajouter une option = ajouter une entrée.
- Chaque fonctionnalité est une **case à cocher** (valeur par défaut dans `ns.defaults`), sauvegardée dans `AutoMiscDB`.
- **Pause par touches** : Maj, Ctrl, Alt. Maintenir une touche suspend tout l'addon. Chaque touche est activable/désactivable dans les options (les 3 actives par défaut).
- `/automisc` ou `/am` : `on`, `off`, `config`, état.
- Namespace privé, aucune globale hors `AutoMiscDB` et commandes slash.
- Locales : `enUS` (fallback) + `frFR`, les autres clients retombent sur l'anglais.

## Architecture
| Fichier | Rôle |
|---------|------|
| `AutoMisc.toc` | métadonnées, ordre de chargement |
| `locale/enUS.lua`, `locale/frFR.lua` | chaînes (clé absente => affiche la clé) |
| `core.lua` | namespace, défauts, DB, `IsPaused`, dispatcher d'événements, slash, démarrage |
| `modules/vendor.lua` | vente des objets gris, réparation (guilde puis perso) |
| `modules/social.lua` | invocation, résurrection, duels, invitations de groupe |
| `options.lua` | panneau d'options |
| `tests/` | banc d'essai Lua avec API WoW simulée |

## Fonctionnalités v1.0.0
| Option | Défaut | Détail |
|--------|:------:|--------|
| Activer l'addon | oui | interrupteur général |
| Pause Maj / Ctrl / Alt | oui | touche maintenue = addon en pause |
| Messages dans le chat | oui | un résumé par action |
| Vendre les objets gris | oui | `MERCHANT_SHOW`, parcourt les sacs, affiche le gain |
| Réparation automatique | oui | `CanMerchantRepair` + `GetRepairAllCost` |
| ↳ Fonds de guilde d'abord | oui | `IsInGuild`, `CanGuildBankRepair`, `GetGuildBankWithdrawMoney`, `RepairAllItems(true)` |
| ↳ Payer soi-même sinon | oui | pas de guilde, plus de droit/fonds, ou guilde refusée (revérification après 0,5 s) |
| Accepter les invocations | non | `CONFIRM_SUMMON` (jamais en combat) |
| Accepter les résurrections | non | `RESURRECT_REQUEST` |
| Refuser les duels | non | `DUEL_REQUESTED` |
| Accepter invitations amis/guilde | non | `PARTY_INVITE_REQUEST`, amis, amis Battle.net, guilde ; ignoré si déjà en groupe |

Les fonctions sociales sont désactivées par défaut car elles ont un effet sur le groupe/la position du joueur.

## Étapes
1. Skill `wow-addon-development` + agent `WoW Addon Creator` (`.github/`).
2. Retirer l'ancien code AutoQuests (vit dans son propre dépôt).
3. Locales, `core.lua`, `AutoMisc.toc`.
4. Modules `vendor` puis `social`.
5. Panneau d'options.
6. Banc d'essai simulé (syntaxe + comportements), `sync.sh`, workflow de release, README, CHANGELOG.
7. Test en jeu (liste dans le README).

## Idées pour la suite
Liste d'objets protégés de la vente, vente des objets blancs non liés, remplissage de la confirmation de suppression, saut de cinématiques déjà vues.
