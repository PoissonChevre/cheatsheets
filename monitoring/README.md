# Monitoring — Cheat Sheets

Watch servers and services, and get an alert before users notice a problem.

| File | Content |
|---|---|
| [nagios-cheatsheet.md](./nagios-cheatsheet.md) | Check-based monitoring: plugins, states, hosts and services, NRPE, custom check |

## Two approaches

| | Checks | Metrics |
|---|---|---|
| Tools | Nagios, Centreon | Prometheus + Grafana |
| Question | Is it OK right now? | How does the value change over time? |
| Result | A state: OK, WARNING, CRITICAL, UNKNOWN | Time series and graphs |
| Typical use | Classic servers, network devices | Containers, Kubernetes, cloud |
| Alerts | Built in (contacts, notifications) | Alertmanager |

Zabbix sits in between: checks and metrics in the same tool.

## Vocabulary

| Word | Meaning |
|---|---|
| Check | A small test: is the web server answering? Is the disk full? |
| Threshold | The limit that changes the state: warning at 80 %, critical at 90 % |
| Agent | A program on the monitored machine that runs local checks (disk, CPU) |
| Notification | The alert sent when a state changes (mail, chat) |
| Metric | A number collected over time: CPU %, requests per second |
| Dashboard | A page of graphs built from metrics (Grafana) |

Planned: Prometheus and Grafana, with my homelab cluster.
