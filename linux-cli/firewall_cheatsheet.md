# Firewall Cheat Sheet — LFCS

> **Contexte LFCS** : Networking = 13% de l'exam. Choix distrib au début → Ubuntu (ufw) ou CentOS Stream 9 (firewalld). nftables = backend commun moderne sur les deux.

---

## 0. Architecture mentale

```
                netfilter (kernel)
                       │
                  nftables (engine)
                       │
        ┌──────────────┼──────────────┬──────────────┐
        │              │              │              │
       nft        iptables-nft     firewalld         ufw
    (direct)     (compat layer)   (RHEL/CentOS)    (Ubuntu)
```

**Règle d'or** : ne jamais utiliser ufw ET firewalld en même temps. Un seul frontend par machine.

---

## 1. Identifier ce qui tourne

| Commande | Ce que ça dit |
|---|---|
| `systemctl status firewalld` | Service firewalld actif ? |
| `systemctl status ufw` | Service ufw actif ? |
| `systemctl status nftables` | Service nftables actif ? |
| `iptables --version` | Affiche `(nf_tables)` ou `(legacy)` |
| `nft list ruleset` | Toutes les règles nftables actives (vérité absolue) |
| `firewall-cmd --state` | `running` ou erreur si firewalld off |
| `ufw status` | Statut + règles ufw |

**Réflexe exam** : si tu doutes, `nft list ruleset` te montre TOUT, peu importe le frontend qui a écrit les règles.

---

## 2. UFW (Ubuntu) — le plus simple

### Activation / état

| Commande | Description |
|---|---|
| `ufw enable` | Active ufw (au boot aussi) |
| `ufw disable` | Désactive ufw |
| `ufw reset` | Reset toutes les règles + désactive |
| `ufw status` | Liste règles actives |
| `ufw status verbose` | + politique par défaut + logging |
| `ufw status numbered` | Règles avec numéros (pour delete/insert) |
| `ufw default deny incoming` | Politique par défaut entrant = deny |
| `ufw default allow outgoing` | Politique par défaut sortant = allow |

### Règles courantes

| Commande | Description |
|---|---|
| `ufw allow 22` | Allow port 22 (TCP+UDP) |
| `ufw allow 22/tcp` | Allow port 22 TCP uniquement |
| `ufw allow ssh` | Allow par nom de service (`/etc/services`) |
| `ufw deny 443/tcp` | Bloquer port 443 TCP |
| `ufw allow from 10.0.0.0/24` | Tout depuis ce subnet |
| `ufw allow from 192.168.1.5 to any port 22` | IP source vers port |
| `ufw allow proto tcp from any to any port 80,443` | Multi-ports |
| `ufw deny out to 1.2.3.4` | Bloquer sortie vers IP |
| `ufw delete allow 22/tcp` | Supprimer par règle exacte |
| `ufw delete 3` | Supprimer la règle n°3 (après `status numbered`) |
| `ufw insert 1 allow from 10.0.0.5` | Insérer en position 1 (priorité) |
| `ufw logging on` | Activer logs (dans `/var/log/ufw.log`) |
| `ufw reload` | Recharger les règles |

### Pièges UFW

- **L'ordre compte** : un `deny` placé avant un `allow` matche en premier
- **`ufw allow 22` sans `/tcp`** ouvre TCP **et** UDP — sois explicite
- **`ufw enable` peut couper ta session SSH** → toujours `ufw allow 22/tcp` AVANT `ufw enable`
- Logs dans `/var/log/ufw.log` (pas dans journald par défaut)

---

## 3. firewalld (CentOS Stream 9 / RHEL / Fedora)

### Concept des zones

Chaque interface réseau est assignée à **une zone**. Chaque zone a ses propres règles.

| Zone | Usage typique |
|---|---|
| `public` | Réseaux non fiables (défaut) |
| `home` / `work` | LAN interne |
| `trusted` | Tout autorisé |
| `drop` | Tout drop, pas de réponse |
| `block` | Tout reject avec ICMP |
| `dmz` | Serveur exposé, accès limité |

### Activation / état

| Commande | Description |
|---|---|
| `systemctl enable --now firewalld` | Activer + démarrer |
| `firewall-cmd --state` | `running` ou erreur |
| `firewall-cmd --reload` | Recharger config permanente (sans drop des connexions) |
| `firewall-cmd --complete-reload` | Reload complet (drop des connexions) |
| `firewall-cmd --runtime-to-permanent` | Sauvegarder runtime → permanent |

### Inspection

| Commande | Description |
|---|---|
| `firewall-cmd --get-default-zone` | Zone par défaut |
| `firewall-cmd --get-active-zones` | Zones actives + interfaces |
| `firewall-cmd --get-zones` | Liste toutes zones disponibles |
| `firewall-cmd --list-all` | Tout pour la zone par défaut |
| `firewall-cmd --zone=public --list-all` | Tout pour zone `public` |
| `firewall-cmd --list-services` | Services autorisés (zone défaut) |
| `firewall-cmd --list-ports` | Ports autorisés (zone défaut) |
| `firewall-cmd --get-services` | Tous les services prédéfinis disponibles |

### Ouvrir un service / port

| Commande | Description |
|---|---|
| `firewall-cmd --permanent --add-service=http` | Ajouter HTTP (permanent) |
| `firewall-cmd --permanent --add-port=8080/tcp` | Ajouter port 8080 TCP |
| `firewall-cmd --permanent --add-port=5000-5010/tcp` | Range de ports |
| `firewall-cmd --permanent --remove-service=http` | Retirer service |
| `firewall-cmd --permanent --zone=dmz --add-service=ssh` | Sur zone spécifique |
| `firewall-cmd --reload` | **OBLIGATOIRE** après `--permanent` |

### Gestion zones / interfaces

| Commande | Description |
|---|---|
| `firewall-cmd --set-default-zone=home` | Changer zone par défaut |
| `firewall-cmd --permanent --zone=trusted --add-interface=eth1` | Assigner interface |
| `firewall-cmd --permanent --zone=public --change-interface=eth0` | Déplacer interface |
| `firewall-cmd --get-zone-of-interface=eth0` | Interface dans quelle zone ? |

### Sources IP (rich rules)

| Commande | Description |
|---|---|
| `firewall-cmd --permanent --zone=trusted --add-source=10.0.0.0/24` | Trust un subnet |
| `firewall-cmd --permanent --add-rich-rule='rule family=ipv4 source address=192.168.1.5 accept'` | Rich rule accept |
| `firewall-cmd --permanent --add-rich-rule='rule family=ipv4 source address=1.2.3.4 reject'` | Rich rule reject |
| `firewall-cmd --permanent --add-rich-rule='rule service name=ssh log prefix="SSH " level=notice accept'` | Avec logging |

### Pièges firewalld

- **Oublier `--permanent`** → règle perdue au reboot
- **Oublier `--reload` après `--permanent`** → règle pas active en runtime
- **Combo gagnant** : soit `--permanent` + `--reload`, soit double commande (avec et sans `--permanent`)
- **Zone par défaut ≠ zone active** : ton interface peut être sur une autre zone
- **`firewall-cmd --runtime-to-permanent`** sauve la config courante en permanent — utile si tu as testé en runtime

---

## 4. nftables direct (universel)

### Lecture

| Commande | Description |
|---|---|
| `nft list ruleset` | Affiche TOUTES les règles |
| `nft list tables` | Liste les tables |
| `nft list table inet filter` | Détail d'une table |
| `nft -a list ruleset` | Avec handles (pour delete) |

### Écriture (à connaître pour LFCS, pas à maîtriser à fond)

```bash
# Créer une table (family inet = IPv4 + IPv6)
nft add table inet filter

# Créer une chain attachée au hook input
nft 'add chain inet filter input { type filter hook input priority 0 ; policy drop ; }'

# Ajouter des règles
nft add rule inet filter input iif lo accept
nft add rule inet filter input ct state established,related accept
nft add rule inet filter input tcp dport 22 accept
nft add rule inet filter input tcp dport {80, 443} accept
nft add rule inet filter input ip saddr 10.0.0.0/24 accept

# Supprimer une règle (need handle)
nft -a list ruleset            # repère le handle
nft delete rule inet filter input handle 5
```

### Persistance

| Distrib | Fichier | Commande |
|---|---|---|
| Ubuntu/Debian | `/etc/nftables.conf` | `nft -f /etc/nftables.conf` |
| CentOS/RHEL/Fedora | `/etc/sysconfig/nftables.conf` | `systemctl reload nftables` |

**Pour sauvegarder l'état actuel** :
```bash
nft list ruleset > /etc/nftables.conf
# puis : systemctl enable --now nftables
```

---

## 5. iptables (legacy, mais encore vu)

> Aujourd'hui, `iptables` est en réalité `iptables-nft` sur Ubuntu 20.04+ et CentOS 9 → traduit vers nftables.

| Commande | Description |
|---|---|
| `iptables -L -n -v` | Lister règles (numeric, verbose) |
| `iptables -L INPUT -n -v --line-numbers` | Avec numéros pour delete |
| `iptables -A INPUT -p tcp --dport 22 -j ACCEPT` | Append règle |
| `iptables -I INPUT 1 -p tcp --dport 80 -j ACCEPT` | Insert en position 1 |
| `iptables -D INPUT 3` | Supprimer règle n°3 |
| `iptables -P INPUT DROP` | Politique par défaut DROP |
| `iptables -F` | Flush toutes les règles |
| `iptables-save > /etc/iptables/rules.v4` | Sauvegarde |
| `iptables-restore < /etc/iptables/rules.v4` | Restauration |

---

## 6. Conversion mentale rapide

| Tâche | UFW | firewalld | nftables |
|---|---|---|---|
| Ouvrir port 80 | `ufw allow 80/tcp` | `firewall-cmd --permanent --add-port=80/tcp && firewall-cmd --reload` | `nft add rule inet filter input tcp dport 80 accept` |
| Voir règles | `ufw status numbered` | `firewall-cmd --list-all` | `nft list ruleset` |
| Bloquer IP | `ufw deny from 1.2.3.4` | rich rule reject | `nft add rule inet filter input ip saddr 1.2.3.4 drop` |
| Activer service | `ufw allow ssh` | `firewall-cmd --permanent --add-service=ssh && firewall-cmd --reload` | (manuel via port) |
| Reset | `ufw reset` | `firewall-cmd --complete-reload` | `nft flush ruleset` |

---

## 7. Workflow exam type

### Scénario : "Ouvrir port 8080/tcp et autoriser SSH depuis 10.0.0.0/24"

**Ubuntu** :
```bash
ufw allow 22/tcp                          # SSH d'abord (sécurité)
ufw allow from 10.0.0.0/24 to any port 22 # Restreindre source
ufw allow 8080/tcp
ufw enable
ufw status verbose                        # vérifier
```

**CentOS** :
```bash
firewall-cmd --permanent --add-port=8080/tcp
firewall-cmd --permanent --add-rich-rule='rule family=ipv4 source address=10.0.0.0/24 service name=ssh accept'
firewall-cmd --reload
firewall-cmd --list-all                   # vérifier
```

---

## 8. Aide pendant l'exam

```bash
man -k firewall            # liste man pages liées
apropos nftables           # idem
man firewall-cmd
man ufw
man nft
man 5 nftables             # syntaxe du fichier de conf
firewall-cmd --help
ufw --help
```

---

## 9. Checklist J-3

- [ ] Savoir activer/désactiver ufw + firewalld
- [ ] Ouvrir un port en runtime ET permanent
- [ ] Lister les règles avec verbose/numbered
- [ ] Connaître les zones firewalld de base (public, trusted, drop)
- [ ] Lire `nft list ruleset` sans paniquer
- [ ] Réflexe `--reload` après `--permanent`
- [ ] Réflexe `man -k firewall` si blocage
