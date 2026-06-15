# DevOps AWS com Terraform e Ansible

Projeto de automação de infraestrutura e configuração de ambiente na AWS usando Terraform e Ansible.

O Terraform é responsável pelo provisionamento da infraestrutura. O Ansible entra na sequência para preparar os hosts, configurar a aplicação e aplicar a configuração do banco de dados.

## Arquitetura

![Diagrama da arquitetura](./docs/aws-diagram.png)

## Estrutura do repositório

```bash
.
├── ansible
│   ├── ansible.cfg
│   ├── inventories
│   │   └── production
│   │       └── group_vars
│   ├── playbooks
│   │   ├── app.yml
│   │   ├── base.yml
│   │   └── db.yml
│   ├── requirements.yml
│   └── roles
│       ├── app
│       ├── base
│       ├── db
│       └── web
├── terraform
│   ├── ansible.tf
│   ├── compute.tf
│   ├── database.tf
│   ├── locals.tf
│   ├── network.tf
│   ├── providers.tf
│   ├── scripts
│   │   └── hosts.ini.tftpl
│   ├── security.tf
│   ├── storage.tf
│   └── variables.tf
└── README.md
```

## Organização do projeto

### Terraform

A pasta `terraform/` concentra o provisionamento da infraestrutura na AWS, com a configuração separada por responsabilidade.

- `providers.tf`: definição do provider.
- `variables.tf`: variáveis de entrada.
- `locals.tf`: valores auxiliares e padronizações.
- `network.tf`: camada de rede.
- `security.tf`: regras e controles de acesso.
- `compute.tf`: recursos computacionais.
- `database.tf`: componentes relacionados ao banco.
- `storage.tf`: recursos de armazenamento.
- `ansible.tf`: integração entre a infraestrutura provisionada e a automação do Ansible.
- `scripts/hosts.ini.tftpl`: template para geração de inventário.

### Ansible

A pasta `ansible/` concentra a configuração dos hosts provisionados.

- `inventories/production/`: inventário do ambiente.
- `playbooks/base.yml`: preparação base das instâncias.
- `playbooks/db.yml`: configuração do banco de dados.
- `playbooks/app.yml`: configuração e publicação da aplicação.

## Fluxo de execução

### O Terraform chama o ansible automaticamente

```bash
cd terraform
terraform init
terraform plan
terraform apply
```