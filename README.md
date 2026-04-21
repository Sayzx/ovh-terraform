# Terraform OVH - Infrastructure Web

Projet d'infrastructure Infrastructure-as-Code (IaC) utilisant Terraform pour provisionner une VM sur OVH avec Nginx.

## 📋 Architecture

Le projet déploie :
- **VPC privé** (`vpc-main`) dans le datacenter de Gravelines (GRA11)
- **Subnet privé** avec DHCP (`10.0.1.0/24`)
- **Security Group** permettant SSH et HTTP
- **VM Debian 12** (2 vCPU, 2 GB RAM) 
- **IP publique** pour accéder à la VM

```
┌─────────────────────────────────┐
│    OVH Cloud Project            │
├─────────────────────────────────┤
│  VPC (vpc-main)                 │
│  ├─ Subnet (10.0.1.0/24)        │
│  │  └─ VM (sayzx-vm-debian)     │
│  │     └─ IP Publique           │
│  └─ Security Group (web-sg)     │
│     ├─ SSH (port 22)            │
│     └─ HTTP (port 80)           │
└─────────────────────────────────┘
```

## 🚀 Démarrage rapide

### Prérequis

- [Terraform](https://www.terraform.io/downloads) (>= 1.0)
- Compte OVH avec les clés d'authentification (Application Key, Secret, Consumer Key)
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) (optionnel, pour Nginx)
- Clé SSH générée dans OVH

### 1. Configuration

Créer un fichier `terraform.tfvars` :

```hcl
ovh_application_key    = "votre_application_key"
ovh_application_secret = "votre_application_secret"
consumer_key           = "votre_consumer_key"
project_id             = "votre_project_id_ovh"
ssh_key_name           = "nom_de_votre_clé_ssh"
```

### 2. Initialisation

```bash
terraform init
```

### 3. Validation et Planification

```bash
terraform validate
terraform plan
```

### 4. Déploiement

```bash
terraform apply
```

## 📁 Structure du projet

```
.
├── main.tf              # Ressources principales (VPC, VM, sécurité)
├── variables.tf         # Déclaration des variables
├── terraform.tfvars     # Valeurs des variables (à créer)
├── deploy-nginx.yaml    # Playbook Ansible pour Nginx
└── README.md           # Ce fichier
```

## 📝 Fichiers Terraform

### `main.tf`

Contient la définition de l'infrastructure :
- Configuration du provider OVH
- Ressources réseau (VPC, subnet)
- Groupe de sécurité et ses règles
- Instance VM
- Allocation IP publique

### `variables.tf`

Définit les variables nécessaires :
- `ovh_application_key` - Clé d'authentification OVH
- `ovh_application_secret` - Secret OVH
- `consumer_key` - Clé consommateur OVH
- `project_id` - ID du projet OVH
- `ssh_key_name` - Nom de la clé SSH OVH

## 🎯 Opérations courantes

### Voir l'état actuel

```bash
terraform show
terraform state list
```

### Rafraîchir l'infrastructure (sans changement)

```bash
terraform refresh
```

### Détruire l'infrastructure

```bash
terraform destroy
```

### Mettre à jour après changement

```bash
terraform plan
terraform apply
```

## 🐧 Déployer Nginx (optionnel)

Une fois la VM créée, utiliser le playbook Ansible :

```bash
# Récupérer l'IP de la VM depuis Terraform
INSTANCE_IP=$(terraform output -raw instance_ip)

# Exécuter le playbook Ansible
ansible-playbook -i "$INSTANCE_IP," deploy-nginx.yaml -u debian --private-key ~/.ssh/your_key
```

Le playbook va :
1. Mettre à jour le cache APT
2. Installer Nginx
3. Démarrer le service
4. Vérifier que Nginx répond correctement

## 🔒 Sécurité

⚠️ **À faire absolument** :
- Restreindre SSH (port 22) à votre IP au lieu de `0.0.0.0/0`
- Utiliser un fichier `.tfvars` pour les secrets (jamais en Git)
- Activer HTTPS avec un certificat SSL
- Renforcer les règles de sécurité en production

## 🐛 Dépannage

### Erreur d'authentification OVH
Vérifier que les clés OVH sont correctes et que le `consumer_key` n'a pas expiré.

### VM ne démarre pas
Vérifier que la clé SSH existe bien dans OVH et que le nom correspond à `ssh_key_name`.

### Ansible timeout
S'assurer que la VM a eu le temps de démarrer et que l'IP publique est assignée.

## 📊 Outputs

Pour récupérer les informations de la VM :

```bash
terraform output
```

## 📚 Ressources

- [Documentation Terraform OVH Provider](https://registry.terraform.io/providers/ovh/ovh/latest/docs)
- [Documentation OVH Cloud](https://docs.ovh.com/en/cloud/)
- [Ansible Documentation](https://docs.ansible.com/)

## 👤 Auteur

**sayzx**

---

*Dernière mise à jour : avril 2026*
