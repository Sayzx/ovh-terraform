# Terraform AWS - Infrastructure Web

Projet d'infrastructure Infrastructure-as-Code (IaC) utilisant Terraform pour provisionner une VM sur AWS avec Nginx.

## 📋 Architecture

Le projet déploie :
- **VPC** (`10.0.0.0/16`) dans la région eu-west-1 (Irlande)
- **Subnet public** (`10.0.1.0/24`) avec auto-assignation d'IP publique
- **Internet Gateway** pour l'accès public
- **Route Table** dirigeant le trafic vers l'IGW
- **Security Group** permettant SSH et HTTP
- **Instance EC2 t3.small** (2 vCPU, 2 GB RAM) avec Debian 12
- **Elastic IP** pour un accès stable à la VM

```
┌─────────────────────────────────┐
│    AWS VPC (eu-west-1)          │
├─────────────────────────────────┤
│  VPC (10.0.0.0/16)              │
│  ├─ Internet Gateway            │
│  ├─ Route Table                 │
│  └─ Subnet Public (10.0.1.0/24) │
│     └─ EC2 Instance             │
│        └─ Elastic IP            │
│  └─ Security Group              │
│     ├─ SSH (port 22)            │
│     └─ HTTP (port 80)           │
└─────────────────────────────────┘
```

## 🚀 Démarrage rapide

### Prérequis

- [Terraform](https://www.terraform.io/downloads) (>= 1.0)
- [AWS CLI](https://aws.amazon.com/cli/) configurée avec les credentials
- Paire de clés SSH créée dans AWS EC2
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) (optionnel, pour Nginx)

### 1. Configuration

Créer un fichier `terraform.tfvars` :

```hcl
aws_region    = "eu-west-1"
ssh_key_name  = "nom_de_votre_clé_aws"
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
├── main.tf              # Ressources principales (VPC, EC2, sécurité)
├── variables.tf         # Déclaration des variables
├── terraform.tfvars     # Valeurs des variables (à créer)
├── deploy-nginx.yaml    # Playbook Ansible pour Nginx
└── README.md           # Ce fichier
```

## 📝 Fichiers Terraform

### `main.tf`

Contient la définition de l'infrastructure AWS :
- Configuration du provider AWS
- Ressources réseau (VPC, Subnet, IGW, Route Table)
- Groupe de sécurité et ses règles
- Instance EC2 avec récupération dynamique de l'AMI Debian
- Allocation Elastic IP

### `variables.tf`

Définit les variables nécessaires :
- `aws_region` - Région AWS (défaut: eu-west-1)
- `ssh_key_name` - Nom de la paire de clés SSH AWS

## 🎯 Opérations courantes

### Voir l'état actuel

```bash
terraform show
terraform state list
```

### Récupérer les outputs

```bash
terraform output
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

Une fois l'instance EC2 créée, utiliser le playbook Ansible :

```bash
# Récupérer l'IP publique de l'instance
INSTANCE_IP=$(terraform output -raw instance_public_ip)

# Exécuter le playbook Ansible
ansible-playbook -i "$INSTANCE_IP," deploy-nginx.yaml -u admin --private-key ~/.ssh/your_aws_key
```

Le playbook va :
1. Mettre à jour le cache APT
2. Installer Nginx
3. Démarrer le service
4. Vérifier que Nginx répond correctement

## 🔒 Sécurité

⚠️ **À faire absolument** :
- Restreindre SSH (port 22) à votre IP au lieu de `0.0.0.0/0`
- Utiliser AWS Secrets Manager pour les données sensibles
- Activer HTTPS avec un certificat SSL (ACM)
- Utiliser un Network ACL restrictif en production
- Mettre en place du logging CloudTrail
- Chiffrer les volumes EBS

## 🐛 Dépannage

### AWS credentials non trouvées
Vérifier que AWS CLI est configurée :
```bash
aws sts get-caller-identity
```

### Instance ne démarre pas
Vérifier que :
- La paire de clés SSH existe dans la région AWS
- Le nom correspond exactement à `ssh_key_name`
- L'AMI Debian 12 est disponible dans la région

### Impossible de se connecter via SSH
```bash
aws ec2 describe-security-groups --group-ids sg-xxxxx
ssh -i ~/your_key.pem admin@<public_ip>
```

### Ansible timeout
S'assurer que l'Elastic IP est bien assignée et que l'instance a eu le temps de démarrer.

## 📊 Outputs

Les outputs disponibles après `terraform apply` :

```
instance_public_ip  = Elastic IP de l'instance
instance_id         = ID de l'instance EC2
vpc_id              = ID du VPC
```

## 💰 Coûts estimés

- **EC2 t3.small** : ~$0.0104/heure
- **Elastic IP** : Gratuit (si associée) / $0.005/heure (si non utilisée)
- **Data transfer** : Gratuit (ingress) / ~$0.02/GB (egress)

## 📚 Ressources

- [Documentation Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Documentation AWS EC2](https://docs.aws.amazon.com/ec2/index.html)
- [Guide AWS VPC](https://docs.aws.amazon.com/vpc/latest/userguide/)
- [Ansible Documentation](https://docs.ansible.com/)

## 👤 Auteur

**sayzx**

---

**Branche AWS** - Pour la version OVH, voir la branche `master`

*Dernière mise à jour : avril 2026*
