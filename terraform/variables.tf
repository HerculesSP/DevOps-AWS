variable "aws_region" {
  type        = string
  description = "Região da AWS"
  default     = "us-east-1"
}

variable "vpc_name" {
  type        = string
  description = "Nome da VPC"
  default     = "PezaoSound-vpc"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR da VPC"
  default     = "10.0.0.0/22"
}

variable "public_subnet_1_cidr" {
  type        = string
  description = "CIDR da subrede pública 1"
  default     = "10.0.0.0/25"
}

variable "public_subnet_name" {
  type        = string
  description = "Nome da subrede pública"
  default     = "public_subnet"
}

variable "public_subnet_1_availability_zone" {
  type        = string
  description = "AZ da subrede pública 1"
  default     = "a"
}

variable "public_subnet_2_cidr" {
  type        = string
  description = "CIDR da subrede pública 2"
  default     = "10.0.0.128/25"
}

variable "public_subnet_2_availability_zone" {
  type        = string
  description = "AZ da subrede pública 2"
  default     = "b"
}

variable "app_subnet_name" {
  type        = string
  description = "Nome da subrede de aplicação"
  default     = "app_subnet"
}

variable "app_subnet_1_cidr" {
  type        = string
  description = "CIDR da subrede 1 de aplicação"
  default     = "10.0.1.0/25"
}

variable "app_subnet_2_cidr" {
  type        = string
  description = "CIDR da subrede 2 de aplicação"
  default     = "10.0.1.128/25"
}

variable "app_web_subnet_1_availability_zone" {
  type        = string
  description = "AZ da subrede 1 de aplicação e WEB"
  default     = "a"
}

variable "app_web_subnet_2_availability_zone" {
  type        = string
  description = "AZ da subrede 2 de aplicação e WEB"
  default     = "b"
}

variable "db_subnet_name" {
  type        = string
  description = "Nome da subrede de banco de dados"
  default     = "db_subnet"
}

variable "db_subnet_1_cidr" {
  type        = string
  description = "CIDR da subrede 1 de banco de dados"
  default     = "10.0.2.0/25"
}

variable "db_subnet_1_availability_zone" {
  type        = string
  description = "AZ da subrede 1 de banco de dados"
  default     = "a"
}

variable "db_subnet_2_cidr" {
  type        = string
  description = "CIDR da subrede 2 de banco de dados"
  default     = "10.0.2.128/25"
}

variable "db_subnet_2_availability_zone" {
  type        = string
  description = "AZ da subrede 2 de banco de dados"
  default     = "b"
}

variable "web_subnet_name" {
  type        = string
  description = "Nome da subrede WEB"
  default     = "web_subnet"
}

variable "web_subnet_1_cidr" {
  type        = string
  description = "CIDR da subrede 1 WEB"
  default     = "10.0.3.0/25"
}

variable "web_subnet_2_cidr" {
  type        = string
  description = "CIDR da subrede 2 web"
  default     = "10.0.3.128/25"
}

variable "nacl_app_cidr" {
  type        = string
  description = "CIDR para entrada personalizada na app"
  default     = "10.0.3.0/24"
}

variable "nacl_web_cidr" {
  type        = string
  description = "CIDR para entrada personalizada na web"
  default     = "10.0.0.0/24"
}

variable "ami_id" {
  type        = string
  description = "Id da AMI utilizada nas instâncias"
  default     = "ami-0521cb2d60cfbb1a6"
}

variable "key_name" {
  type        = string
  description = "Nome da chave PEM das instâncias"
  default     = "chave"
}

variable "instance_type" {
  type        = string
  description = "Tipo de instância"
  default     = "t3.micro"
}

variable "app_docker_image" {
  type        = string
  description = "URL da imagem da aplicação"
  default     = "herculessp/pezao-sound-api:main"
}

variable "web_docker_image" {
  type        = string
  description = "URL da imagem web"
  default     = "herculessp/pezao-sound-web:main"
}


variable "db_username" {
  type        = string
  description = "Usuário do banco de dados"
  default     = "stockflow"
}

variable "db_name" {
  type        = string
  description = "Nome do banco de dados"
  default     = "stockflow"
}

variable "db_password" {
  type        = string
  description = "Senha do usuário do banco de dados"
  default     = "StockFlow2026!"
}