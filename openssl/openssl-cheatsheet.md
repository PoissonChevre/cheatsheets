# OpenSSL — Cheat Sheet

Certificates and keys: inspect, test a server, create a CSR or a self-signed cert, run a small CA, convert formats. Written for OpenSSL 3.

---

## File formats

| Extension | Content |
|---|---|
| `.pem`, `.crt`, `.cer` | Text (base64) between `-----BEGIN ...-----` lines — most common on Linux |
| `.key` | Private key (PEM) — `chmod 600` |
| `.csr` | Certificate Signing Request |
| `.der` | Binary version of a cert |
| `.p12`, `.pfx` | Bundle: cert + key + chain, protected by a password (Windows, Java) |

A PEM file can hold several certs (a **chain**): your cert first, then the intermediates.

---

## Inspect a certificate

```bash
openssl x509 -in cert.pem -noout -text                  # Everything
openssl x509 -in cert.pem -noout -subject -issuer -dates
openssl x509 -in cert.pem -noout -ext subjectAltName    # DNS names / IPs (SAN)
openssl x509 -in cert.pem -noout -fingerprint -sha256
openssl x509 -in cert.pem -noout -checkend 2592000 && echo "OK > 30 days" || echo "Expires < 30 days"

openssl req -in req.csr -noout -text                    # A CSR
openssl pkey -in key.pem -noout -text                   # A key
```

### Does this key match this cert?

```bash
openssl x509 -in cert.pem -noout -pubkey | sha256sum
openssl pkey -in key.pem -pubout | sha256sum            # Same hash = match
```

---

## Test a remote server

```bash
openssl s_client -connect example.com:443 -servername example.com </dev/null
# -servername = SNI: needed when one IP hosts several sites

# Dates and names of the server cert
openssl s_client -connect example.com:443 -servername example.com </dev/null 2>/dev/null \
  | openssl x509 -noout -subject -issuer -dates

openssl s_client -connect example.com:443 -showcerts </dev/null    # Full chain sent by the server
openssl s_client -connect mail.example.com:587 -starttls smtp       # STARTTLS (smtp, imap, ftp...)
openssl s_client -connect example.com:443 -tls1_2                   # Force a TLS version

curl -vI https://example.com                                        # Quick check with curl
curl --cacert ca.crt https://web.lab                                # Trust your own CA
```

In the `s_client` output: `Verify return code: 0 (ok)` = the chain is valid.

---

## Keys

```bash
openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:4096 -out key.pem
openssl genpkey -algorithm EC -pkeyopt ec_paramgen_curve:P-256 -out key.pem
openssl genpkey -algorithm ed25519 -out key.pem
chmod 600 key.pem

openssl pkey -in key.pem -pubout -out pub.pem           # Public key
openssl pkey -in enc.key -out plain.key                 # Remove the passphrase
```

---

## CSR (to send to a CA)

```bash
openssl req -new -key key.pem -out web.csr \
  -subj "/CN=web.example.com" \
  -addext "subjectAltName=DNS:web.example.com,DNS:www.example.com"

# Key + CSR in one command
openssl req -new -newkey rsa:4096 -noenc -keyout key.pem -out web.csr \
  -subj "/CN=web.example.com" -addext "subjectAltName=DNS:web.example.com"
```

Browsers only look at the **SAN** (subjectAltName), not the CN: always add it.

---

## Self-signed certificate (lab)

```bash
openssl req -x509 -newkey rsa:4096 -sha256 -days 365 -noenc \
  -keyout key.pem -out cert.pem \
  -subj "/CN=web.lab" \
  -addext "subjectAltName=DNS:web.lab,DNS:*.web.lab,IP:10.10.50.10"
```

`-noenc` = key without passphrase (old name: `-nodes`).

---

## Your own small CA (homelab)

```bash
# 1. CA — once
openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:4096 -out ca.key
openssl req -x509 -new -key ca.key -sha256 -days 3650 -out ca.crt -subj "/CN=Homelab CA"

# 2. Server key + CSR
openssl req -new -newkey rsa:2048 -noenc -keyout web.key -out web.csr \
  -subj "/CN=grafana.lab" -addext "subjectAltName=DNS:grafana.lab"

# 3. Sign with the CA (copy the SAN from the CSR)
openssl x509 -req -in web.csr -CA ca.crt -CAkey ca.key -CAcreateserial \
  -out web.crt -days 397 -sha256 -copy_extensions copy

# 4. Check
openssl verify -CAfile ca.crt web.crt
```

Install `ca.crt` as trusted on your machines (below). For Kubernetes, cert-manager can use this CA to issue certs automatically.

---

## Trust a CA on Linux

```bash
# Debian / Ubuntu
sudo cp ca.crt /usr/local/share/ca-certificates/homelab-ca.crt    # Must end in .crt
sudo update-ca-certificates

# RHEL / Fedora
sudo cp ca.crt /etc/pki/ca-trust/source/anchors/
sudo update-ca-trust
```

Firefox and some apps (Java, Python `certifi`) use their own store.

---

## Verify a chain

```bash
openssl verify -CAfile ca.crt cert.pem
openssl verify -CAfile root.pem -untrusted intermediate.pem cert.pem
cat cert.pem intermediate.pem > fullchain.pem           # Order: leaf first, then intermediates
```

---

## Convert

```bash
openssl x509 -in cert.pem -outform der -out cert.der    # PEM → DER
openssl x509 -in cert.der -inform der -out cert.pem     # DER → PEM

openssl pkcs12 -export -out bundle.p12 -inkey key.pem -in cert.pem -certfile chain.pem   # → PFX
openssl pkcs12 -in bundle.p12 -noenc -out all.pem       # PFX → PEM (add -legacy for old files)
openssl pkcs12 -in bundle.p12 -nocerts -noenc -out key.pem
openssl pkcs12 -in bundle.p12 -clcerts -nokeys -out cert.pem
```

---

## Kubernetes

```bash
kubectl create secret tls web-tls --cert=web.crt --key=web.key -n dev

# Read the cert stored in a secret
kubectl get secret web-tls -n dev -o jsonpath='{.data.tls\.crt}' | base64 -d \
  | openssl x509 -noout -subject -dates -ext subjectAltName

# Client cert inside a kubeconfig
kubectl config view --raw -o jsonpath='{.users[0].user.client-certificate-data}' | base64 -d \
  | openssl x509 -noout -subject -dates
```

---

## Other useful commands

```bash
openssl rand -base64 32                  # Random secret (passwords, tokens)
openssl rand -hex 16
openssl dgst -sha256 file.iso            # Hash (same as sha256sum)
openssl passwd -6                        # SHA-512 password hash for /etc/shadow
echo -n 'text' | openssl base64          # Base64 (-d to decode)

openssl enc -aes-256-cbc -pbkdf2 -salt -in secret.txt -out secret.enc    # Encrypt a file
openssl enc -d -aes-256-cbc -pbkdf2 -in secret.enc -out secret.txt       # Decrypt
openssl version
```

---

## Pitfalls

- No SAN = "certificate not valid for this name" in browsers, even with the right CN.
- `s_client` without `-servername` may show the **default** site's cert, not the one you want.
- Wrong chain order (intermediate before leaf) = errors on some clients.
- A server must send the intermediate certs, not only its own: check with `-showcerts`.
- Private keys: `chmod 600`, never in Git.
- `-noenc` / `-nodes` = key without password: fine for servers, protect the file.
- Old `.p12` files may need `-legacy` with OpenSSL 3.
- Public certs get shorter and shorter (200 days max since March 2026, 47 days by 2029): automate renewal with certbot or cert-manager. Your own CA is not limited, but keep lifetimes short.
