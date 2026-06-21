# DevOps AWS com Terraform e Ansible

Projeto de automação de infraestrutura e configuração de ambiente na AWS usando Terraform e Ansible.

O Terraform é responsável pelo provisionamento da infraestrutura e executa o Ansible para preparar as instâncias, configurar a aplicação, website e inserir o script SQL no banco de dados.

Infraestrutura para atender aos requisitos do projeto de Pesquisa e Inovação desenvolvido durante o 3° e 4° semestre do curso de Bacharelado em Ciências da Computação na São Paulo Tech School. [Organização no GitHub com os repositórios do projeto.](https://github.com/pezao-sound-projeto-de-extensao)

## Arquitetura

<img width="1246" height="1326" alt="Diagrama DevOps drawio" src="https://github.com/user-attachments/assets/d18d5bc7-f89b-4ffd-8522-f8d8434bc1d5" />

## Estrutura do repositório

```bash
.
├── ansible
│   ├── ansible.cfg
│   ├── inventories
│   │   └── production
│   │       ├── group_vars
│   │       │   ├── all.yml
│   │       │   ├── app.yml
│   │       │   └── web.yml
│   │       └── hosts.ini
│   ├── playbooks
│   │   ├── app.yml
│   │   ├── base.yml
│   │   ├── db.yml
│   │   └── web.yml
│   ├── requirements.yml
│   └── roles
│       ├── app
│       │   ├── tasks
│       │   │   └── main.yml
│       │   └── templates
│       │       ├── app.env.j2
│       │       ├── docker-compose.yml.j2
│       │       └── nginx.conf.j2
│       ├── base
│       │   └── tasks
│       │       └── main.yml
│       ├── db
│       │   ├── files
│       │   │   └── bd.sql
│       │   └── tasks
│       │       └── main.yml
│       └── web
│           ├── tasks
│           │   └── main.yml
│           └── templates
│               └── web.env.j2
└── terraform
    ├── ansible.tf
    ├── chave.pem
    ├── compute.tf
    ├── database.tf
    ├── locals.tf
    ├── network.tf
    ├── providers.tf
    ├── scripts
    │   └── hosts.ini.tftpl
    ├── security.tf
    ├── storage.tf
    ├── terraform.tfstate
    ├── terraform.tfstate.backup
    └── variables.tf


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
- `playbooks/web.yml`: configuração e publicação do website.

## Fluxo de execução

### O Terraform chama o ansible automaticamente

```bash
cd terraform
terraform init
terraform plan
terraform apply
```
