# WSL 2 & Port forwarding : accéder à sa distribution Linux à distance
# https://www.it-connect.fr/wsl-2-port-forwarding-comment-acceder-a-sa-machine-virtuelle-a-distance/

# open a terminal ps1 as administrator

# create the rule
netsh interface portproxy add v4tov4 listenport=3390 listenaddress=0.0.0.0 connectport=3390 connectaddress=172.21.98.207

# check the rules
netsh interface portproxy show v4tov4

#Listen on ipv4:             Connect to ipv4:
#
#Address         Port        Address         Port
#--------------- ----------  --------------- ----------
#0.0.0.0         3390        172.21.98.207   3390

# erase the rule
netsh interface portproxy reset

# Firewall Rule Outbound
New-NetFirewallRule -DisplayName 'WSL 2' -Direction Outbound -LocalPort "3390" -Action Allow -Protocol TCP

# Name                          : {14e3e015-8f43-4ba9-8676-50b86980ef78}
# DisplayName                   : WSL 2
# Description                   :
# DisplayGroup                  :
# Group                         :
# Enabled                       : True
# Profile                       : Any
# Platform                      : {}
# Direction                     : Outbound
# Action                        : Allow
# EdgeTraversalPolicy           : Block
# LooseSourceMapping            : False
# LocalOnlyMapping              : False
# Owner                         :
# PrimaryStatus                 : OK
# Status                        : The rule was parsed successfully from the store. (65536)
# EnforcementStatus             : NotApplicable
# PolicyStoreSource             : PersistentStore
# PolicyStoreSourceType         : Local
# RemoteDynamicKeywordAddresses : {}
# PolicyAppId                   :

# Firewall Rule Inbound
New-NetFirewallRule -DisplayName 'WSL 2' -Direction Inbound -LocalPort "3390" -Action Allow -Protocol TCP

# Name                          : {0981eb69-e7b0-4d9f-a4a6-b8627511cb14}
# DisplayName                   : WSL 2
# Description                   :
# DisplayGroup                  :
# Group                         :
# Enabled                       : True
# Profile                       : Any
# Platform                      : {}
# Direction                     : Inbound
# Action                        : Allow
# EdgeTraversalPolicy           : Block
# LooseSourceMapping            : False
# LocalOnlyMapping              : False
# Owner                         :
# PrimaryStatus                 : OK
# Status                        : The rule was parsed successfully from the store. (65536)
# EnforcementStatus             : NotApplicable
# PolicyStoreSource             : PersistentStore
# PolicyStoreSourceType         : Local
# RemoteDynamicKeywordAddresses : {}
# PolicyAppId                   :