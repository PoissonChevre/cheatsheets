# 🐧 LFCS — Référence des commandes essentielles

> **Linux Foundation Certified SysAdmin**
> Un aide-mémoire structuré par domaine d'examen.

---

## Domaine 1 — Commandes essentielles

### Navigation & fichiers

| Commande | Description |
|----------|-------------|
| `ls -lahZ` | Lister avec taille, droits, contexte SELinux |
| `find / -name "*.conf" -type f` | Recherche récursive de fichiers |
| `find / -perm /4000` | Trouver les fichiers SUID |
| `locate <fichier>` | Recherche rapide via base de données |
| `updatedb` | Mettre à jour la base de `locate` |
| `stat <fichier>` | Métadonnées détaillées d'un fichier |
| `file <fichier>` | Identifier le type d'un fichier |
| `which / whereis` | Localiser un binaire |

### Manipulation de fichiers

| Commande | Description |
|----------|-------------|
| `cp -a` | Copie en préservant tous les attributs |
| `mv`, `rm -rf` | Déplacer / supprimer |
| `ln -s <cible> <lien>` | Créer un lien symbolique |
| `tar -czvf archive.tar.gz <dir>` | Créer une archive compressée |
| `tar -xzvf archive.tar.gz` | Extraire une archive |
| `gzip / gunzip / bzip2 / xz` | Compression de fichiers |
| `dd if=/dev/sda of=/dev/sdb` | Copie bloc à bloc |
| `rsync -avz src/ dest/` | Synchronisation de fichiers |

### Recherche & filtres texte

| Commande | Description |
|----------|-------------|
| `grep -rn "motif" /etc/` | Recherche récursive avec numéros de ligne |
| `grep -v / -i / -E` | Inverser / insensible casse / regex étendue |
| `sed 's/ancien/nouveau/g' fichier` | Substitution de texte |
| `awk '{print $1, $3}' fichier` | Extraction de colonnes |
| `cut -d: -f1 /etc/passwd` | Découper un champ |
| `sort -k2 -n / uniq -c` | Trier / dédoublonner |
| `wc -l / head -n / tail -f` | Compter / début / fin de fichier |
| `diff fichier1 fichier2` | Comparer deux fichiers |

### Droits & propriété

| Commande | Description |
|----------|-------------|
| `chmod 755 / chmod u+x` | Modifier les permissions |
| `chown user:group fichier` | Changer propriétaire |
| `chgrp group fichier` | Changer groupe |
| `umask 022` | Masque de permissions par défaut |
| `getfacl / setfacl -m u:user:rwx` | ACL (Access Control Lists) |
| `chattr +i fichier` | Rendre un fichier immuable |
| `lsattr fichier` | Lire les attributs étendus |

### Aide en ligne d'examen

```bash
man -k <mot-clé>      # Chercher une commande par mot-clé
apropos <mot-clé>     # Équivalent de man -k
man 5 passwd          # Section spécifique du manuel
info <commande>       # Documentation GNU
```

---

## Domaine 2 — Utilisateurs & Groupes

### Gestion des utilisateurs

| Commande | Description |
|----------|-------------|
| `useradd -m -s /bin/bash -G sudo user` | Créer un utilisateur complet |
| `usermod -aG groupe user` | Ajouter à un groupe (sans retirer des autres) |
| `userdel -r user` | Supprimer l'utilisateur et son home |
| `passwd user` | Changer le mot de passe |
| `chage -l user` | Afficher l'expiration du mot de passe |
| `chage -E 2025-12-31 user` | Définir une date d'expiration |
| `chage -M 90 user` | Max jours avant renouvellement |
| `id user` | UID, GID et groupes d'un utilisateur |
| `who / w / last` | Sessions actives / historique de connexions |

### Gestion des groupes

| Commande | Description |
|----------|-------------|
| `groupadd <groupe>` | Créer un groupe |
| `groupmod -n nouveau ancien` | Renommer un groupe |
| `groupdel <groupe>` | Supprimer un groupe |
| `gpasswd -a user groupe` | Ajouter un membre |
| `gpasswd -d user groupe` | Retirer un membre |
| `groups user` | Lister les groupes d'un utilisateur |
| `newgrp <groupe>` | Changer de groupe principal temporairement |

### Fichiers clés

```
/etc/passwd     — Informations utilisateurs
/etc/shadow     — Mots de passe hachés
/etc/group      — Définitions des groupes
/etc/sudoers    — Règles sudo (éditer avec visudo !)
/etc/login.defs — Paramètres par défaut (UID_MIN, PASS_MAX_DAYS…)
/etc/skel/      — Fichiers copiés dans chaque nouveau home
```

### Élévation de privilèges

| Commande | Description |
|----------|-------------|
| `sudo -l` | Lister les droits sudo de l'utilisateur courant |
| `sudo -u user commande` | Exécuter en tant qu'un autre utilisateur |
| `su - user` | Ouvrir un shell complet en tant que `user` |
| `visudo` | Éditer `/etc/sudoers` en sécurité |

---

## Domaine 3 — Stockage

### Partitions & disques

| Commande | Description |
|----------|-------------|
| `lsblk -f` | Arborescence des blocs avec FS |
| `fdisk /dev/sdb` | Partitionner (MBR/DOS) |
| `gdisk /dev/sdb` | Partitionner (GPT) |
| `parted /dev/sdb` | Outil interactif (MBR & GPT) |
| `blkid` | UUID et types des partitions |
| `df -hT` | Espace disque par montage + type FS |
| `du -sh /var/*` | Taille des sous-répertoires |

### Systèmes de fichiers

| Commande | Description |
|----------|-------------|
| `mkfs.ext4 /dev/sdb1` | Formater en ext4 |
| `mkfs.xfs /dev/sdb1` | Formater en XFS |
| `mkswap / swapon / swapoff` | Créer et activer une swap |
| `tune2fs -l /dev/sdb1` | Infos sur un FS ext2/3/4 |
| `xfs_info /dev/sdb1` | Infos sur un FS XFS |
| `fsck /dev/sdb1` | Vérifier/réparer ext2/3/4 |
| `xfs_repair /dev/sdb1` | Vérifier/réparer XFS |
| `e2label / xfs_admin -L` | Définir un label |

### Montage

| Commande | Description |
|----------|-------------|
| `mount /dev/sdb1 /mnt/data` | Monter manuellement |
| `mount -o ro,noexec /dev/sdb1 /mnt` | Monter avec options |
| `umount /mnt/data` | Démonter |
| `mount -a` | Monter tout ce qui est dans `/etc/fstab` |

**Entrée `/etc/fstab` :**
```
UUID=xxxx  /mnt/data  ext4  defaults,nofail  0  2
```

### LVM

| Commande | Description |
|----------|-------------|
| `pvcreate /dev/sdb` | Initialiser un volume physique |
| `vgcreate vg_data /dev/sdb` | Créer un groupe de volumes |
| `lvcreate -L 10G -n lv_data vg_data` | Créer un volume logique |
| `lvextend -L +5G /dev/vg_data/lv_data` | Agrandir un LV |
| `resize2fs / xfs_growfs` | Agrandir le FS après lvextend |
| `pvs / vgs / lvs` | Résumé PV / VG / LV |
| `pvdisplay / vgdisplay / lvdisplay` | Infos détaillées |

---

## Domaine 4 — Réseau

### Configuration réseau

| Commande | Description |
|----------|-------------|
| `ip addr show` | Interfaces et adresses IP |
| `ip link set eth0 up/down` | Activer/désactiver une interface |
| `ip addr add 192.168.1.10/24 dev eth0` | Ajouter une IP temporaire |
| `ip route show` | Table de routage |
| `ip route add default via 192.168.1.1` | Ajouter une route |
| `nmcli device status` | État des interfaces (NetworkManager) |
| `nmcli con show` | Lister les connexions |
| `nmcli con mod <nom> ipv4.addresses 10.0.0.5/24` | Modifier une connexion |
| `nmtui` | Interface texte NetworkManager |
| `ss -tulnp` | Ports ouverts + processus associés |
| `netstat -tulnp` | Équivalent (legacy) |

### DNS & connectivité

| Commande | Description |
|----------|-------------|
| `ping -c 4 <host>` | Tester la connectivité |
| `traceroute / tracepath` | Chemin réseau |
| `dig <domaine>` | Résolution DNS détaillée |
| `nslookup <domaine>` | Résolution DNS simple |
| `host <domaine>` | Résolution rapide |
| `curl -I <url>` | Tester un endpoint HTTP |
| `wget <url>` | Télécharger un fichier |

### Fichiers réseau clés

```
/etc/hosts               — Résolution locale
/etc/resolv.conf         — Serveurs DNS
/etc/hostname            — Nom de la machine
/etc/nsswitch.conf       — Ordre de résolution des noms
/etc/network/interfaces  — Config réseau (Debian)
/etc/sysconfig/network-scripts/  — Config réseau (RHEL)
```

### Pare-feu

| Commande | Description |
|----------|-------------|
| `firewall-cmd --list-all` | Règles actives (firewalld) |
| `firewall-cmd --permanent --add-service=http` | Ouvrir HTTP |
| `firewall-cmd --permanent --add-port=8080/tcp` | Ouvrir un port |
| `firewall-cmd --reload` | Appliquer les changements |
| `ufw status verbose` | État du pare-feu (Ubuntu) |
| `ufw allow 22/tcp` | Autoriser SSH |
| `iptables -L -n -v` | Règles iptables brutes |

---

## Domaine 5 — Opérations & Déploiement

### Gestion des services (systemd)

| Commande | Description |
|----------|-------------|
| `systemctl start/stop/restart <service>` | Contrôler un service |
| `systemctl enable/disable <service>` | Activer au démarrage |
| `systemctl status <service>` | État d'un service |
| `systemctl is-active / is-enabled` | Vérifications rapides |
| `systemctl list-units --type=service` | Lister les services |
| `systemctl daemon-reload` | Recharger les unités modifiées |
| `journalctl -u <service> -f` | Logs d'un service en temps réel |
| `journalctl --since "1 hour ago"` | Logs par plage de temps |
| `journalctl -p err` | Filtrer par priorité |

### Gestion des paquets

**Debian / Ubuntu**
```bash
apt update && apt upgrade
apt install / remove / purge <paquet>
dpkg -l | grep <nom>
dpkg -i <paquet>.deb
```

**RHEL / CentOS / Fedora**
```bash
dnf update
dnf install / remove <paquet>
rpm -qa | grep <nom>
rpm -ivh <paquet>.rpm
```

### Planification de tâches

| Commande | Description |
|----------|-------------|
| `crontab -e` | Éditer le cron de l'utilisateur courant |
| `crontab -l -u user` | Lister le cron d'un utilisateur |
| `crontab -r` | Supprimer le cron de l'utilisateur |
| `at now + 1 hour` | Planifier une commande unique |
| `atq / atrm` | Lister / annuler les tâches `at` |

**Syntaxe cron :**
```
* * * * *  commande
│ │ │ │ └─ jour de semaine (0-7, 0=dimanche)
│ │ │ └─── mois (1-12)
│ │ └───── jour du mois (1-31)
│ └─────── heure (0-23)
└───────── minute (0-59)
```

**Fichiers cron système :**
```
/etc/crontab
/etc/cron.d/
/etc/cron.daily/ /etc/cron.weekly/ /etc/cron.monthly/
```

### Surveillance & processus

| Commande | Description |
|----------|-------------|
| `top / htop` | Processus en temps réel |
| `ps aux / ps -ef` | Liste tous les processus |
| `pgrep / pkill <nom>` | Trouver / tuer par nom |
| `kill -9 <PID>` | Tuer un processus (SIGKILL) |
| `nice -n 10 commande` | Lancer avec priorité modifiée |
| `renice -n 5 -p <PID>` | Modifier la priorité d'un processus |
| `vmstat 1` | Statistiques mémoire/cpu/io |
| `iostat -xz 1` | Statistiques I/O disque |
| `free -h` | Mémoire disponible |
| `uptime / w` | Charge système |

### Noyau & démarrage

| Commande | Description |
|----------|-------------|
| `uname -r` | Version du noyau |
| `dmesg | tail -50` | Messages du noyau (récents) |
| `lsmod` | Modules chargés |
| `modprobe <module>` | Charger un module |
| `modprobe -r <module>` | Décharger un module |
| `sysctl -a` | Paramètres noyau actifs |
| `sysctl -w net.ipv4.ip_forward=1` | Modifier un paramètre (temporaire) |
| `grub2-mkconfig -o /boot/grub2/grub.cfg` | Régénérer GRUB (RHEL) |
| `update-grub` | Régénérer GRUB (Debian) |

### Logs

| Commande | Description |
|----------|-------------|
| `journalctl -xe` | Logs récents avec contexte d'erreur |
| `tail -f /var/log/syslog` | Logs système (Debian) |
| `tail -f /var/log/messages` | Logs système (RHEL) |
| `logrotate -f /etc/logrotate.conf` | Forcer la rotation des logs |

### SSH & accès distant

| Commande | Description |
|----------|-------------|
| `ssh user@host` | Connexion SSH |
| `ssh -i ~/.ssh/id_rsa user@host` | Connexion avec clé privée |
| `ssh-keygen -t ed25519` | Générer une paire de clés |
| `ssh-copy-id user@host` | Copier la clé publique |
| `scp fichier user@host:/dest` | Copie sécurisée |
| `sftp user@host` | FTP sécurisé interactif |
| `rsync -avz -e ssh src/ user@host:/dest/` | Sync via SSH |

---

## Rappels de méthode pour l'examen

> 💡 **En cas de doute sur une commande :** `man -k <mot-clé>` ou `apropos <mot-clé>`
>
> 💡 **Pour lire rapidement une man page :** `/` pour chercher, `n` pour l'occurrence suivante, `q` pour quitter
>
> 💡 **Tester avant d'appliquer :** utiliser `--dry-run` ou `-n` quand disponible
>
> 💡 **Vérifier après chaque action :** `systemctl status`, `df -h`, `ip addr show`, etc.

---

*Référence compilée pour la préparation au LFCS — Linux Foundation Certified SysAdmin*
